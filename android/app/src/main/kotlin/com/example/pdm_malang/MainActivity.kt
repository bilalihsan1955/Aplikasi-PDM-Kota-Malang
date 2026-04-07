package com.example.pdm_malang

import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.URLEncoder

/**
 * singleTask + [onNewIntent]: tap notifikasi / App Link mengirim intent baru; [setIntent]
 * agar plugin (firebase_messaging, app_links) membaca data tap dengan benar.
 */
class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "pdm_malang/external_browser",
        ).setMethodCallHandler { call, result ->
            if (call.method != "openUrl") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val urlStr = call.arguments as? String
            if (urlStr.isNullOrBlank()) {
                result.success(false)
                return@setMethodCallHandler
            }
            result.success(openUrlInExternalBrowser(urlStr))
        }
    }

    /**
     * App Links membuat query [ACTION_VIEW] ke makotamu.org hanya mengembalikan app sendiri.
     * Kita probe URL netral, bangun chooser ke komponen yang ditemukan, lalu brute-force paket browser.
     */
    private fun openUrlInExternalBrowser(urlStr: String): Boolean {
        val uri = try {
            Uri.parse(urlStr)
        } catch (_: Exception) {
            return false
        }

        val newTaskFlag = Intent.FLAG_ACTIVITY_NEW_TASK
        val myPkg = packageName
        val pm = packageManager

        // 1) Query dengan URL yang tidak diverifikasi App Links app ini → dapat daftar browser.
        val probeUri = Uri.parse("https://www.w3.org/")
        val probe = Intent(Intent.ACTION_VIEW, probeUri).apply {
            addCategory(Intent.CATEGORY_BROWSABLE)
        }
        @Suppress("DEPRECATION")
        val resolved = pm.queryIntentActivities(probe, PackageManager.MATCH_DEFAULT_ONLY)
        val candidates = resolved
            .filter { it.activityInfo.exported && it.activityInfo.packageName != myPkg }
            .distinctBy { it.activityInfo.packageName }

        try {
            when {
                candidates.size == 1 -> {
                    val ri = candidates.first()
                    startActivity(
                        Intent(Intent.ACTION_VIEW, uri).apply {
                            setClassName(ri.activityInfo.packageName, ri.activityInfo.name)
                            addFlags(newTaskFlag)
                        },
                    )
                    return true
                }
                candidates.size > 1 -> {
                    val intents = candidates.map { ri ->
                        Intent(Intent.ACTION_VIEW, uri).apply {
                            setClassName(ri.activityInfo.packageName, ri.activityInfo.name)
                            addFlags(newTaskFlag)
                        }
                    }
                    val primary = intents.first()
                    val extras = intents.drop(1).toTypedArray()
                    val chooser = Intent.createChooser(primary, "Buka di browser").apply {
                        addFlags(newTaskFlag)
                        putExtra(Intent.EXTRA_INITIAL_INTENTS, extras)
                    }
                    startActivity(chooser)
                    return true
                }
            }
        } catch (_: Exception) {
            // lanjut fallback
        }

        // 2) Tanpa resolveActivity: intent eksplisit ke paket browser (boleh tanpa <queries> untuk launch).
        val browserPackages = listOf(
            "com.android.chrome",
            "com.google.android.apps.chrome",
            "com.chrome.beta",
            "com.chrome.dev",
            "org.mozilla.firefox",
            "com.microsoft.emmx",
            "com.brave.browser",
            "com.opera.browser",
            "com.sec.android.app.sbrowser",
            "com.coloros.browser",
            "com.heytap.browser",
            "com.android.browser",
            "com.mi.globalbrowser",
            "com.miui.browser",
            "com.vivo.browser",
            "com.oplus.browser",
            "com.huawei.browser",
        )
        for (pkg in browserPackages) {
            try {
                startActivity(
                    Intent(Intent.ACTION_VIEW, uri).apply {
                        setPackage(pkg)
                        addFlags(newTaskFlag)
                    },
                )
                return true
            } catch (_: Exception) {
                // coba berikutnya
            }
        }

        // 3) Redirect lewat google.com/url — biasanya terbuka di browser default.
        return try {
            val q = URLEncoder.encode(urlStr, "UTF-8")
            val g = Uri.parse("https://www.google.com/url?q=$q")
            startActivity(
                Intent(Intent.ACTION_VIEW, g).apply {
                    addCategory(Intent.CATEGORY_BROWSABLE)
                    addFlags(newTaskFlag)
                },
            )
            true
        } catch (_: Exception) {
            false
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
