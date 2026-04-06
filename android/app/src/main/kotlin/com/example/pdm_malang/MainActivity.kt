package com.example.pdm_malang

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity

/**
 * singleTop: tap notifikasi mengirim intent lewat [onNewIntent].
 * [setIntent] agar plugin firebase_messaging membaca extra / data tap dengan benar.
 */
class MainActivity : FlutterActivity() {
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
    }
}
