# MEMORY & STATUS PROYEK (MEMORY.MD)
**Aplikasi: Makotamu (PDM Kota Malang)**  
**Terakhir Diperbarui: 2026-10-07**

Dokumen ini berfungsi sebagai cache konteks, status aktif proyek, catatan konfigurasi teknis penting, dan riwayat pembaruan (*changelog*) untuk menjaga kesinambungan pengembangan.

---

## 1. Profil & Identitas Aplikasi
* **Nama Aplikasi**: Makotamu (Muhammadiyah Kota Malang)
* **Package ID / Application ID**: `id.makotamu.app`
* **Namespace Kotlin**: `com.example.pdm_malang`
* **Versi Saat Ini**: `1.1.0+3` (Version Name: `1.1.0`, Version Code: `3`)
* **Framework**: Flutter 3.x / Dart SDK `^3.10.7`
* **Platform Target**: Android (Min SDK: 21, Target SDK: 34), iOS

---

## 2. Status Kesiapan Rilis Google Play Store
* **Format Berkas Rilis**: Android App Bundle (AAB)
* **Lokasi Berkas Terakhir**: `build\app\outputs\bundle\release\app-release.aab` (Ukuran: ~77.2 MB)
* **Play App Signing**:
  * File konfigurasi: `android/key.properties`
  * File keystore: `android/app/keystore.jks` (Alias: `key0`)
  * Konfigurasi Gradle: [android/app/build.gradle.kts](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/android/app/build.gradle.kts)
* **Kepatuhan Kebijakan**:
  * Target SDK 34 (Android 14) $\rightarrow$ **Memenuhi syarat**.
  * Arsitektur 64-bit $\rightarrow$ **Tersedia**.
  * Privacy Policy & Terms $\rightarrow$ Aktif di `https://makotamu.org/privacy-policy` dan in-app WebView.
  * Izin Sensitif (`SCHEDULE_EXACT_ALARM` & `ACCESS_FINE_LOCATION`) $\rightarrow$ Alasan penggunaan: Pengingat ibadah/sholat harian terjadwal presisi dan penentuan arah kiblat.

---

## 3. Catatan Teknis & Dependensi Kritis
* **Google Fonts**: Dipatok pada versi `google_fonts: ^8.2.1` di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml). *Catatan: Jangan upgrade ke versi 9.0.0 secara gegabah karena membawa dependency `material_ui: ^1.4.0` yang menyebabkan konflik tipe `TextTheme` pada Flutter Framework*.
* **Firebase & FCM Service**:
  * Inisialisasi Firebase Messaging dibuat lazy pada [fcm_service.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/services/fcm/fcm_service.dart) dengan pengecekan `Firebase.apps.isNotEmpty` agar aman saat dieksekusi di lingkungan headless automated testing.
  * Dilengkapi gate sinkronisasi izin notifikasi dan lokasi (`releaseLocationGate`).
* **Routing & Deep Linking**:
  * Menggunakan `GoRouter` di [lib/routes/app_router.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/routes/app_router.dart) yang mendukung navigasi App Links dari domain `https://makotamu.org` untuk Berita, Agenda, dan Amal Usaha.
* **Autentikasi & Sesi**:
  * `AuthLocalService` menggunakan `flutter_secure_storage` untuk menyimpan Access Token dan Refresh Token, serta otomatis melakukan background token refresh saat sesi mendekati kedaluwarsa.
* **Error Handling Terpusat**:
  * Pemetaan error jaringan/server menggunakan [lib/utils/network_error_mapper.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/utils/network_error_mapper.dart) untuk menjaga kepatuhan prinsip DRY (*Don't Repeat Yourself*).

---

## 4. Status Pengujian Otomatis (Automated Testing Status)
* **Total Automated Tests**: **24 Tests Passed / 0 Failed (100% Lulus)**
  * `test/widget_test.dart`: 1 passed (Pengujian struktur `MyApp`, dependency injection Provider, dan routing awal).
  * `test/app_deep_link_test.dart`: 7 passed (Pengujian verifikasi parsing URL makotamu.org untuk berita, kegiatan/agenda, dan amal-usaha).
  * `test/utils/network_error_mapper_test.dart`: 5 passed (Pengujian mapping SocketException, 404, 500, 403, dan generic fallback).
  * `test/view_models/agenda_view_model_test.dart`: 4 passed (Pengujian inisialisasi state, loadEvents, filter kategori/pencarian, dan error handling).
  * `test/view_models/news_view_model_test.dart`: 4 passed (Pengujian inisialisasi state, loadNews, filter tag/query, dan error mapping).
  * `test/view_models/home_view_model_test.dart`: 3 passed (Pengujian struktur menu navigasi, loadLatestNews max 4, dan filter loadFeaturedNews).
* **Static Analysis (`flutter analyze`)**: **0 Compilation Errors**.

---

## 5. Riwayat Perubahan (Changelog)

### [2026-10-07] - Versi 1.0.0+1
* **Fitur & Perbaikan**:
  1. Integrasi halaman Kebijakan Privasi (Privacy Policy) dan Syarat Ketentuan (Terms of Service) ke dalam in-app WebView pada menu profil dan tautan eksternal resmi.
  2. Perbaikan kompatibilitas package `google_fonts` dari versi 9.0.0 ke `^8.2.1` untuk menyelesaikan error bentrok tipe `TextTheme`.
  3. Perbaikan inisialisasi lazy `_firebaseMessaging` di [fcm_service.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/services/fcm/fcm_service.dart) dan drain timer pada [test/widget_test.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/test/widget_test.dart) sehingga seluruh automated testing lulus 100%.
  4. Pembuatan berkas release bundle `app-release.aab` siap rilis ke Google Play Store dengan konfigurasi signing rilis.
  5. Pembuatan berkas aturan dan dokumentasi inti: `AGENTS.md`, `MEMORY.md`, dan `PRD.md`.
* **Status Pengujian**: `flutter test` $\rightarrow$ 8/8 passed, `flutter analyze` $\rightarrow$ 0 error.

### [2026-10-07] - Versi 1.0.1+2 (Security Hardening & WebView Protection)
* **Fitur & Perbaikan**:
  1. **WebView Navigation Guard**: Menambahkan `onNavigationRequest` pada [webview_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/webview_page.dart) untuk menjamin navigasi web HTTP/HTTPS tetap termuat mulus, serta mengarahkan skema kontak eksternal (`tel:`, `mailto:`, `whatsapp:`, `sms:`) langsung ke aplikasi asli perangkat.
  2. **Android Backup Protection**: Mengubah `android:allowBackup="false"` pada [AndroidManifest.xml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/android/app/src/main/AndroidManifest.xml) guna mencegah ekstraksi data lokal pengguna via ADB / USB Debugging.
  3. **HTTP Log Sanitization**: Membungkus pencatatan body respon HTTP `_logFcmTokenRegisterResponse` dan `_logAuthApiError` dengan guard `kDebugMode` agar payload sensitif tidak tercatat di Logcat rilis.
  4. **Auto Version Bump**: Versi aplikasi dinaikkan dari `1.0.0+1` menjadi `1.0.1+2` di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml).
* **Status Pengujian**: `flutter test` $\rightarrow$ 8/8 passed (100%), `flutter analyze` $\rightarrow$ 0 error.

### [2026-10-07] - Versi 1.1.0+3 (Architecture Refactoring, Code Modularization, & ViewModel Test Coverage)
* **Fitur & Perbaikan**:
  1. **DRY Centralized Error Handling**: Membuat [lib/utils/network_error_mapper.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/utils/network_error_mapper.dart) dan menghubungkannya ke [news_repository.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/repositories/news_repository.dart) dan [agenda_repository.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/repositories/agenda_repository.dart) untuk mengeliminasi duplikasi kode `getFriendlyError`.
  2. **Dekomposisi Monolitik `home_page.dart`**: Memecah berkas raksasa [home_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/home_page.dart) (1.625 baris) menjadi 8 komponen widget modular di folder `lib/view/pages/home/widgets/` (`home_header.dart`, `home_search_section.dart`, `home_news_slide.dart`, `home_prayer_qibla_section.dart`, `home_event_section.dart`, `home_menu_section.dart`, `home_news_section.dart`, dan `home_section_header.dart`). Ukuran `home_page.dart` menyusut drastis menjadi < 90 baris tanpa mengubah alur bisnis atau tampilan aplikasi sedikitpun.
  3. **Penguatan Automated Testing**: Menambahkan 16 unit test baru untuk `NetworkErrorMapper`, `NewsViewModel`, `AgendaViewModel`, dan `HomeViewModel`. Total test suite melonjak dari 8 menjadi 24 tests dengan kelulusan 100%.
  4. **Auto Version Bump**: Versi aplikasi dinaikkan dari `1.0.1+2` menjadi `1.1.0+3` di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml).
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.
