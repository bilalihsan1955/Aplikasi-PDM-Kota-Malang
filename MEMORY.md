# MEMORY & STATUS PROYEK (MEMORY.MD)
**Aplikasi: Makotamu (PDM Kota Malang)**  
**Terakhir Diperbarui: 2026-10-13**

Dokumen ini berfungsi sebagai cache konteks, status aktif proyek, catatan konfigurasi teknis penting, dan riwayat pembaruan (*changelog*) untuk menjaga kesinambungan pengembangan.

---

## 1. Profil & Identitas Aplikasi
* **Nama Aplikasi**: Makotamu (Muhammadiyah Kota Malang)
* **Package ID / Application ID**: `id.makotamu.app`
* **Namespace Kotlin**: `com.example.pdm_malang`
* **Versi Saat Ini**: `1.1.21+24` (Version Name: `1.1.21`, Version Code: `24`) — *Optimasi Spasi Bawah Halaman Detail Amal Usaha & Penyelarasan Layout Presisi*
* **Framework**: Flutter 3.x / Dart SDK `^3.10.7`
* **Platform Target**: Android (Min SDK: 21, Target SDK: 36, Compile SDK: 36), iOS

---

## 2. Status Kesiapan Rilis Google Play Store
* **Format Berkas Rilis**: Android App Bundle (AAB)
* **Lokasi Berkas Terakhir**: `build\app\outputs\bundle\release\app-release.aab` (Ukuran: ~77.6 MB)
* **Play App Signing**:
  * File konfigurasi: `android/key.properties`
  * File keystore: `android/app/keystore.jks` (Alias: `key0`)
  * Konfigurasi Gradle: [android/app/build.gradle.kts](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/android/app/build.gradle.kts)
* **Kepatuhan Kebijakan**:
  * Target SDK 36 (Android 16) $\rightarrow$ **Memenuhi syarat mutlak Google Play (API level >= 36)**.
  * Arsitektur 64-bit $\rightarrow$ **Tersedia**.
  * Privacy Policy & Terms $\rightarrow$ Aktif di `https://makotamu.org/privacy-policy` dan in-app WebView.
  * Izin Sensitif (`SCHEDULE_EXACT_ALARM` & `ACCESS_FINE_LOCATION`) $\rightarrow$ Alasan penggunaan: Pengingat ibadah/sholat harian terjadwal presisi dan penentuan arah kiblat.

---

## 3. Catatan Teknis & Dependensi Kritis
* **Google Fonts**: Dipatok pada versi `google_fonts: ^8.2.1` di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml). *Catatan: Jangan upgrade ke versi 9.0.0 secara gegabah karena membawa dependency `material_ui: ^1.4.0` yang menyebabkan konflik tipe `TextTheme` pada Flutter Framework*.
* **Firebase & FCM Service**:
  * Inisialisasi Firebase Messaging dibuat lazy pada [fcm_service.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/services/fcm/fcm_service.dart) dengan pengecekan `Firebase.apps.isNotEmpty` agar aman saat dieksekusi di lingkungan headless automated testing.
  * Dilengkapi gate sinkronisasi izin notifikasi dan lokasi (`releaseLocationGate`).
  * Menggunakan `resetAfterLogout()` untuk mengosongkan token lokal saat sesi berakhir.
* **Routing & Deep Linking**:
  * Menggunakan `GoRouter` di [lib/routes/app_router.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/routes/app_router.dart) yang mendukung navigasi App Links dari domain `https://makotamu.org` untuk Berita, Agenda, dan Amal Usaha.
* **Autentikasi & Sesi**:
  * `AuthLocalService` menggunakan `flutter_secure_storage` untuk menyimpan Access Token dan Refresh Token, serta otomatis melakukan background token refresh saat sesi mendekati kedaluwarsa.
* **Error Handling Terpusat**:
  * Pemetaan error jaringan/server menggunakan [lib/utils/network_error_mapper.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/utils/network_error_mapper.dart) untuk menjaga kepatuhan prinsip DRY (*Don't Repeat Yourself*).
* **Status Notifikasi Agenda di Web Laravel (`D:\laravel`)**:
  * Di backend Laravel (`D:\laravel`), `NewsController`, `ArtikelController`, dan kini `EventController.php` telah terhubung penuh dengan `FCMService` untuk mengirimkan push notification ke ponsel setiap kali berita, artikel, maupun agenda dibuat/diperbarui.
  * Logika push notification agenda mengirim pesan ke topik FCM `'agenda'`, membersihkan tag HTML pada ringkasan, mencatat riwayat ke tabel `push_notifications` dengan tipe redirect `'event'`, dan otomatis membersihkan notifikasi saat kegiatan dihapus.
  * Aplikasi mobile Flutter (`pdm_malang`) sudah 100% siap menangani notifikasi `event`/`agenda` di [notification_navigation.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/utils/notification_navigation.dart).
* **Aturan Signing Key Google Play Console & Google Cloud API Key Restriction**:
  * Keystore lokal [android/app/keystore.jks](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/android/app/keystore.jks) dan [android/key.properties](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/android/key.properties) berfungsi sebagai **Upload Key**.
  * **Dilarang mengganti upload key lokal dengan key Google Play**. Google Play App Signing menandatangani ulang AAB menggunakan App Signing Key mereka di server.
  * Sidik jari SHA-1 dari Google Play Console **wajib ditambahkan** ke:
    1. **Firebase Console** (Project Settings $\rightarrow$ Your apps $\rightarrow$ Add fingerprint).
    2. **Google Cloud Console** (APIs & Services $\rightarrow$ Credentials $\rightarrow$ Android key $\rightarrow$ Application restrictions $\rightarrow$ Add package name `id.makotamu.app` + SHA-1 Google Play). *Tanpa mendaftarkan SHA-1 Google Play di Google Cloud API Key restrictions, request Firebase Installations dari bundle Play Store akan diblokir dengan kode 403 API_KEY_ANDROID_APP_BLOCKED*.

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

### [2026-10-07] - Versi 1.1.1+4 (Login Legal Footer Layout & Global Dialog Root Navigator Overlay)
* **Fitur & Perbaikan**:
  1. **Login Legal Footer Layout**: Menata ulang layout [lib/view/pages/auth/login_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/auth/login_page.dart) menggunakan `LayoutBuilder`, `ConstrainedBox`, `IntrinsicHeight`, dan `Spacer()`. Link **Kebijakan Privasi • Syarat & Ketentuan** kini diletakkan di **paling bawah layar tepat di atas bilah navigasi sistem (`SafeArea` bottom)** tanpa merusak kemampuan scroll saat keyboard terbuka.
  2. **Global Dialog Overlay Menutupi Navbar**: Mengaktifkan `useRootNavigator: true` pada [lib/utils/glass_confirm_dialog.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/utils/glass_confirm_dialog.dart), [lib/utils/glass_image_source_dialog.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/utils/glass_image_source_dialog.dart), dan [lib/view/pages/gallery_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/gallery_page.dart). Seluruh dialog konfirmasi (logout, ubah password, discard perubahan akun, preview gambar, dan pemilih foto) kini di-*push* ke root navigator utama sehingga overlay gelap dan efek blur **menutupi 100% layar termasuk bilah bottom navigation bar (Navbar)**.
  3. **Auto Version Bump**: Versi aplikasi dinaikkan dari `1.1.0+3` menjadi `1.1.1+4` di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml).
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-07] - Versi 1.1.2+5 (Shell-Level Loading Overlay Across MainScreen, Profile, Account, & Password)
* **Fitur & Perbaikan**:
  1. **MainScreen Root Loading Overlay**: Membungkus antarmuka [lib/view/main_screen.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/main_screen.dart) dengan `Consumer<AuthViewModel>` dan `Stack` tingkat teratas. Setiap kali `isSubmitting` aktif (proses logout di Profil, simpan/update profil di [account_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/profile/account_page.dart), maupun ubah sandi di [change_password_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/profile/change_password_page.dart)), overlay gelap dengan indikator loading (`CircularProgressIndicator`) otomatis membentang di **seluruh layar penuh, menutupi konten dan seluruh bilah Bottom Navbar** serta memblokir sentuhan (`AbsorbPointer`).
  2. **Eliminasi Redundansi Overlay Tab**: Membersihkan overlay parsial lokal di [profile_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/profile/profile_page.dart), [account_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/profile/account_page.dart), dan [change_password_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/profile/change_password_page.dart) sehingga rendering lebih ramping dan bebas konflik z-index.
  3. **Auto Version Bump**: Versi aplikasi dinaikkan dari `1.1.1+4` menjadi `1.1.2+5` di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml).
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-07] - Versi 1.1.3+6 (Minimalist Screen & Navbar Dimming Barrier without Loader)
* **Fitur & Perbaikan**:
  1. **Penghapusan Loader pada Overlay Shell**: Menghapus widget `CircularProgressIndicator` dari lapisan overlay [lib/view/main_screen.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/main_screen.dart). Ketika proses submitting berlangsung (logout, update profil, ganti password), aplikasi menampilkan lapisan redup bersih (*clean dimming barrier*) yang menutupi seluruh layar dan bilah Bottom Navbar sembari tetap memblokir interaksi sentuh pengguna (`AbsorbPointer(absorbing: true)`) tanpa memunculkan spinner loader di tengah layar.
  2. **Auto Version Bump**: Versi aplikasi dinaikkan dari `1.1.2+5` menjadi `1.1.3+6` di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml).
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-07] - Versi 1.1.4+7 (Logout Button Dynamic Loading Indicator)
* **Fitur & Perbaikan**:
  1. **Indikator Loading pada Tombol Logout**: Mengintegrasikan state `isSubmitting` ke komponen `_logout` di [lib/view/pages/profile/profile_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/profile/profile_page.dart). Saat proses logout sedang diproses di backend, teks `'Logout'` dan ikonnya otomatis berganti menjadi animasi *loader* (`CircularProgressIndicator` beraksen merah `Colors.redAccent`) dan event tap dinonaktifkan (`onTap: null`).
  2. **Auto Version Bump**: Versi aplikasi dinaikkan dari `1.1.3+6` menjadi `1.1.4+7` di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml).
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-07] - Versi 1.1.5+8 (Google Play Version Code Conflict Resolution & Release Bundle Rebuild)
* **Fitur & Perbaikan**:
  1. **Resolusi Konflik Version Code Google Play**: Mengatasi penolakan upload bundle di Google Play Console (*Version code 7 has already been used*) dengan menaikkan `versionCode` dari 7 menjadi 8 (`1.1.5+8`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml).
  2. **Rebuild Release App Bundle (.aab)**: Berhasil melakukan kompilasi ulang berkas rilis `build/app/outputs/bundle/release/app-release.aab` (~77.6 MB) yang siap diunggah ke Google Play Console.
  3. **Penyiapan Release Name & Release Notes**: Menyediakan panduan teks *Release notes* resmi untuk Google Play Store dalam format multibahasa `<id>...</id>`.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-07] - Versi 1.1.6+9 (Upgrade Target SDK ke API 36 & Google Play Release Bundle Rebuild)
* **Fitur & Perbaikan**:
  1. **Upgrade Target SDK ke API Level 36**: Memenuhi regulasi Google Play Store terkait kewajiban minimum API level 36 dengan mengubah `compileSdk = 36` dan `targetSdk = 36` di [android/app/build.gradle.kts](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/android/app/build.gradle.kts).
  2. **Resolusi Version Code ke 9 (`1.1.6+9`)**: Menaikkan `versionCode` menjadi 9 di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) karena version code 8 telah terekam pada draf pengujian internal sebelumnya.
  3. **Verifikasi Manifest & Kompilasi AAB**: Berhasil mengompilasi ulang berkas rilis `build/app/outputs/bundle/release/app-release.aab` (~77.6 MB) dengan verifikasi `android:targetSdkVersion="36"` pada seluruh berkas merged manifest.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.
### [2026-10-08] - Sinkronisasi Notifikasi Agenda/Event ke Backend Laravel (D:\laravel)
* **Fitur & Perbaikan**:
  1. **Aktivasi Notifikasi Agenda di Backend Laravel**: Menyinkronkan file [EventController.php](file:///D:/laravel/app/Http/Controllers/Admin/EventController.php) di `D:\laravel` dari referensi [PDM_web](file:///C:/Users/BILALIHSAN/Documents/project/PDM_web/app/Http/Controllers/Admin/EventController.php).
  2. **Push Notification Topik 'agenda'**: Pada metode `store()` dan `update()`, sistem kini otomatis membersihkan tag HTML pada ringkasan, membuat catatan di tabel `push_notifications`, dan menembakkan pesan FCM ke topik `'agenda'` yang di-subscribe oleh aplikasi mobile.
  3. **Penghapusan Riwayat Bersih**: Pada metode `destroy()`, record notifikasi terkait di tabel `push_notifications` otomatis dibersihkan saat agenda dihapus.
  4. **Verifikasi Sintaks & Regression**: Validasi sintaks `php -l` lulus 100% tanpa error (`No syntax errors detected`). Pengujian unit & widget Flutter (`flutter test`) berstatus **PASS 100% (24/24 tests passed)** dan `flutter analyze` 0 compilation error.

### [2026-10-08] - Versi 1.1.7+10 (Perbaikan Kedip Layar Xiaomi 14/Adreno 750, Sensor Kiblat & Kompilasi AAB)
* **Fitur & Perbaikan**:
  1. **Nonaktifkan Impeller (`EnableImpeller: false`)**: Menambahkan konfigurasi `<meta-data android:name="io.flutter.embedding.android.EnableImpeller" android:value="false" />` di [android/app/src/main/AndroidManifest.xml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/android/app/src/main/AndroidManifest.xml) untuk mengembalikan engine render grafis ke Skia (OpenGL ES). Menghilangkan bug layar berkedip (*flickering*) pada perangkat GPU Adreno 750 / Snapdragon 8 Gen 3 (seperti Xiaomi 14 dan Samsung Galaxy S24) saat menjalankan shader shimmer `Skeletonizer`.
  2. **Penyempurnaan Pesan Sensor Kiblat**: Memperjelas teks petunjuk di [lib/view/pages/kiblat_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/kiblat_page.dart) menjadi `'Sensor kompas tidak terdeteksi atau aktifkan izin lokasi'` untuk perangkat fisik yang tidak memiliki sensor magnetometer.
  3. **Auto Version Bump ke 1.1.7+10**: Menaikkan versi aplikasi menjadi `version: 1.1.7+10` (`versionCode: 10`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
  4. **Kompilasi Ulang Rilis AAB**: Berhasil mengompilasi berkas `build/app/outputs/bundle/release/app-release.aab` (~77.6 MB) dengan `versionCode="10"` dan `compileSdk/targetSdk = 36`.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-08] - Versi 1.1.8+11 (Optimasi Provider Selector, FCM Agenda Auto-Subscribe & Kompilasi AAB)
* **Fitur & Perbaikan**:
  1. **Optimasi Provider Selector di MainScreen**: Mengganti `Consumer<AuthViewModel>` menjadi `Selector<AuthViewModel, bool>` di [lib/view/main_screen.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/main_screen.dart) khusus memantau `authVm.isSubmitting`. Mencegah rebuild seluruh kerangka `Scaffold` dan `navigationShell` saat ada perubahan data auth yang tidak berhubungan dengan overlay submission.
  2. **Optimasi Provider Selector di NavbarWidgets**: Mengganti `Consumer<NotificationViewModel>` menjadi `Selector<NotificationViewModel, bool>` di [lib/view/widgets/navbar_widgets.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/widgets/navbar_widgets.dart) khusus memantau `vm.unreadCount > 0`. Mencegah rebuild tombol lonceng notifikasi saat pengguna hanya mengubah-ubah filter kategori di halaman notifikasi.
  3. **Auto-Subscribe Topik Agenda FCM**: Menambahkan `_ensureDefaultTopicsSubscribed()` di [lib/services/fcm/fcm_service.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/services/fcm/fcm_service.dart). Memastikan seluruh topik default (termasuk topik `'agenda'`) otomatis di-subscribe ke Firebase setiap kali aplikasi login atau dibuka, sehingga perangkat yang sudah pernah menginstal aplikasi pada versi lama tetap otomatis menerima push notifikasi agenda/kegiatan.
  4. **Auto Version Bump ke 1.1.8+11**: Menaikkan versi aplikasi menjadi `version: 1.1.8+11` (`versionCode: 11`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
  5. **Kompilasi Ulang Rilis AAB**: Berhasil mengompilasi berkas `build/app/outputs/bundle/release/app-release.aab` (~77.7 MB) dengan `versionCode="11"` dan `compileSdk/targetSdk = 36`.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-08] - Versi 1.1.9+12 (Perbaikan Pengiriman Token FCM Login/Register & Kompilasi AAB)
* **Fitur & Perbaikan**:
  1. **Pengiriman Token FCM Langsung Saat Login & Register**: Menambahkan pemanggilan langsung `unawaited(FCMService().initializeAfterLogin())` di [lib/view_models/auth_view_model.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view_models/auth_view_model.dart), [lib/view/pages/auth/login_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/auth/login_page.dart), dan [lib/view/pages/auth/register_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/auth/register_page.dart). Mengatasi celah di mana token tidak terkirim ke server karena `HomePage` tidak memanggil `initState` ulang saat navigasi dari tab profil.
  2. **Pembersihan State FCM Saat Logout (`resetAfterLogout`)**: Menambahkan method `resetAfterLogout()` di [lib/services/fcm/fcm_service.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/services/fcm/fcm_service.dart) yang mereset `_fcmAfterLoginSetupDone`, `_lastSyncedFcmTokenPosted`, dan `_lastFcmTokenPostAt` saat logout, sehingga saat login kembali token pasti segera ditembakkan ke endpoint `POST /api/v1/fcm/token`.
  3. **Auto Version Bump ke 1.1.9+12**: Menaikkan versi aplikasi menjadi `version: 1.1.9+12` (`versionCode: 12`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
  4. **Kompilasi Ulang Rilis AAB**: Berhasil mengompilasi berkas `build/app/outputs/bundle/release/app-release.aab` (~77.7 MB) dengan `versionCode="12"` dan `compileSdk/targetSdk = 36`.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-08] - Versi 1.1.10+13 (Penyesuaian Warna Skeleton Loader Tema Terang & Kompilasi AAB)
* **Fitur & Perbaikan**:
  1. **Konfigurasi Global `SkeletonizerConfig` di `main.dart`**: Menambahkan pembungkus `SkeletonizerConfig` di `builder` [lib/main.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/main.dart) dengan palet tema terang: `baseColor: Color(0xFFE9ECEF)` dan `highlightColor: Color(0xFFF8F9FA)`. Menghilangkan tampilan abu-abu gelap kusam pada tema terang dan menggantikannya dengan abu-abu terang lembut dan bersih tanpa mengubah kecepatan atau animasi shimmer.
  2. **Harmonisasi Warna Komponen Kartu Placeholder**:
     - [lib/view/pages/home/widgets/home_news_section.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/home/widgets/home_news_section.dart): Memperbarui badge tag skeleton dari `Colors.grey[400]` menjadi `Color(0xFFE9ECEF)` dan teks tag menjadi `Color(0xFFA0A5B1)`.
     - [lib/view/pages/berita/berita_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/berita/berita_page.dart): Memperbarui badge tag skeleton dari `Colors.grey[400]` menjadi `Color(0xFFE9ECEF)` dan teks tag menjadi `Color(0xFFA0A5B1)`.
     - [lib/view/pages/agenda/agenda_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/agenda/agenda_page.dart): Memperbarui wadah tanggal skeleton dari `Colors.grey[300]` menjadi `Color(0xFFE9ECEF)` dan teks skeleton menjadi abu-abu lembut.
     - [lib/view/pages/notification_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/notification_page.dart): Memperbarui wadah ikon skeleton menjadi `Color(0xFFE9ECEF)` dan `Color(0xFFA0A5B1)`.
     - [lib/view/pages/home/widgets/home_event_section.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/home/widgets/home_event_section.dart): Memperbarui teks skeleton dari `Color(0xFF2D3142)` menjadi `Color(0xFFA0A5B1)`.
  3. **Auto Version Bump ke 1.1.10+13**: Menaikkan versi aplikasi menjadi `version: 1.1.10+13` (`versionCode: 13`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
  4. **Kompilasi Ulang Rilis AAB**: Berhasil mengompilasi berkas `build/app/outputs/bundle/release/app-release.aab` (~77.6 MB) dengan `versionCode="13"` dan `compileSdk/targetSdk = 36`.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-08] - Versi 1.1.11+14 (Perbaikan Brightness Skeletonizer Anti-Override Mode Gelap Sistem & Safeguard FCM Token)
* **Fitur & Perbaikan**:
  1. **Pengikatan Tegas `brightness` pada `SkeletonizerConfigData`**: Menambahkan parameter `brightness: isDarkMode ? Brightness.dark : Brightness.light` ke dalam [lib/main.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/main.dart). Mengatasi akar masalah di mana paket Skeletonizer secara bawaan mengambil `MediaQuery.platformBrightnessOf(context)` (setelan tema gelap bawaan sistem HP Android pengguna). Dengan pengikatan eksplisit ini, saat pengguna memilih tema terang di aplikasi, efek skeleton 100% dipaksa menggunakan `baseColor: Color(0xFFE9ECEF)` abu-abu terang dan tidak akan lagi ter-override menjadi abu-abu gelap akibat setelan Dark Mode sistem ponsel.
  2. **Isolasi Error Handling `getToken()` FCM**: Membungkus pemanggilan `_firebaseMessaging.getToken()` di [lib/services/fcm/fcm_service.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/services/fcm/fcm_service.dart) dengan try-catch terisolasi. Mencegah error jaringan atau `FIS_AUTH_ERROR` menghentikan eksekusi sinkronisasi topik dan token pendaftaran di backend.
  3. **Auto Version Bump ke 1.1.11+14**: Menaikkan versi aplikasi menjadi `version: 1.1.11+14` (`versionCode: 14`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
  4. **Kompilasi Ulang Rilis AAB**: Berhasil mengompilasi berkas `build/app/outputs/bundle/release/app-release.aab` (~77.7 MB) dengan `versionCode="14"` dan `compileSdk/targetSdk = 36`.
  5. **Resolusi Registrasi Token FCM Rilis Google Play**: Mengatasi pemblokiran request Google Firebase Installations (`API_KEY_ANDROID_APP_BLOCKED` 403) pada versi rilis Play Store dengan menambahkan SHA-1 Play Store App Signing ke *Application Restrictions* pada Google Cloud Console untuk API Key `Android key (auto created by Firebase)`. Hasilnya, perangkat yang menginstal via Play Store berhasil mendapatkan token dan terdaftar di database web.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-13] - Versi 1.1.12+15 (Pembersihan Menu Ketentuan & Legalitas dari Halaman Profil Organisasi)
* **Fitur & Perbaikan**:
  1. **Pembersihan Halaman Profil Organisasi (About PDM)**: Menghapus widget `_buildLegalSection` dan import `legal_navigation.dart` dari [lib/view/pages/about_pdm_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/about_pdm_page.dart). Halaman Tentang PDM Malang kini bersih dan berakhir rapi di bawah pratinjau peta lokasi, tanpa kartu Ketentuan & Legalitas yang tidak diminta. Tautan legalitas tetap berada di lokasi semestinya (menu Akun/Profil Pengguna, Login, dan Registrasi).
  2. **Auto Version Bump ke 1.1.12+15**: Menaikkan versi aplikasi menjadi `version: 1.1.12+15` (`versionCode: 15`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-13] - Versi 1.1.13+16 (Normalisasi Spasi di Bawah Peta Halaman Profil Organisasi)
* **Fitur & Perbaikan**:
  1. **Normalisasi Spasi Peta `AboutPdmPage`**: Menyetel `bottom: false` pada `SafeArea` di [lib/view/pages/about_pdm_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/about_pdm_page.dart) untuk meniadakan penyisipan padding bawah sistem yang duplikat, serta menyesuaikan `SizedBox(height: 40)` menjadi `SizedBox(height: 20)` di bawah pratinjau peta lokasi. Jarak di bawah peta kini tampak rapi, proporsional, dan presisi.
  2. **Auto Version Bump ke 1.1.13+16**: Menaikkan versi aplikasi menjadi `version: 1.1.13+16` (`versionCode: 16`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-13] - Versi 1.1.14+17 (Kalibrasi Clearance Bawah Peta Terhadap Floating Bottom Navbar)
* **Fitur & Perbaikan**:
  1. **Kalibrasi Clearance Peta `AboutPdmPage`**: Mengalibrasi spasi bawah di [lib/view/pages/about_pdm_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/about_pdm_page.dart) menjadi `const SizedBox(height: 72)`. Nilai 72 px ini menaikkan kartu alamat peta setinggi 52 px sehingga terbebas seutuhnya dari tumpukan floating bottom navbar ([lib/view/widgets/navbar_widgets.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/widgets/navbar_widgets.dart)) saat di-scroll mentok ke bawah, dengan jarak margin bersih yang simetris dan pas (~20–24 px) di atas navbar.
  2. **Auto Version Bump ke 1.1.14+17**: Menaikkan versi aplikasi menjadi `version: 1.1.14+17` (`versionCode: 17`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-13] - Versi 1.1.18+21 (Normalisasi Padding Bawah Halaman Profil Organisasi & Penyelarasan dengan Skeleton)
* **Fitur & Perbaikan**:
  1. **Normalisasi Padding Bawah `AboutPdmPage`**: Mengeliminasi kalkulasi `bottomClearance` berlebih (~104dp) yang menimbulkan ruang hampa kosong di atas bottom navbar. Menetapkan padding bawah kontainer peta ke nilai standar yang seragam dengan halaman aplikasi lainnya (`const EdgeInsets.fromLTRB(24, 32, 24, 24)`).
  2. **Penyelarasan Skeleton Loading**: Menyesuaikan `_buildAboutPageSkeleton` pada [lib/view/pages/about_pdm_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/about_pdm_page.dart) agar menggunakan padding `const EdgeInsets.fromLTRB(24, 32, 24, 24)` yang identik dengan konten utama, menjaga visual layout konsisten tanpa lompatan jarak.
  3. **Auto Version Bump ke 1.1.18+21**: Menaikkan versi aplikasi menjadi `version: 1.1.18+21` (`versionCode: 21`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-13] - Versi 1.1.19+22 (Penerapan SafeArea & Kalibrasi Padding Bawah Halaman Profil Organisasi & Skeleton)
* **Fitur & Perbaikan**:
  1. **Penerapan SafeArea Dinamis & Presisi Padding Bawah `AboutPdmPage`**: Membungkus blok konten bawah pada [lib/view/pages/about_pdm_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/about_pdm_page.dart) dengan `SafeArea(top: false)` dan menyetel padding bawah `const EdgeInsets.fromLTRB(24, 32, 24, 0)`. Komponen bawah kartu preview peta kini terlindungi oleh insets SafeArea sistem tanpa tambahan padding statis berlebih, sehingga posisinya pas dan bersih saat di-scroll mentok di atas floating navbar.
  2. **Pembersihan Spacing Duplikat**: Menghapus `const SizedBox(height: 32)` redundan di atas 'Program Kerja Unggulan' yang bertumpuk dengan `Padding(top: 32)`.
  3. **Penyelarasan Skeleton Loading**: Membungkus `Padding` pada `_buildAboutPageSkeleton` dengan `SafeArea(top: false)` dan padding bawah `0` (`const EdgeInsets.fromLTRB(24, 32, 24, 0)`) agar skeleton kartu peta seragam dan bebas layout jump saat berpindah ke data nyata.
  4. **Auto Version Bump ke 1.1.19+22**: Menaikkan versi aplikasi menjadi `version: 1.1.19+22` (`versionCode: 22`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

### [2026-10-13] - Versi 1.1.20+23 (Penghapusan Margin Perulangan Bawah untuk Item Notifikasi Terakhir)
* **Fitur & Perbaikan**:
  1. **Penghapusan Margin Bawah Item Notifikasi Terakhir**: Menambahkan parameter `isLast: bool` pada `_NotificationCard` di [lib/view/pages/notification_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/notification_page.dart) agar item notifikasi paling akhir memiliki `margin: EdgeInsets.only(bottom: isLast ? 0 : 12)` baik untuk kartu utama maupun background `Dismissible`. Item-item sebelumnya tetap mempertahankan jarak 12dp antar kartu, dan item terbawah tidak lagi menimbulkan margin ganda terhadap padding kontainer luar.
  2. **Penyelarasan Skeleton Notifikasi**: Mengatur parameter `isLast: index == 5` pada delegasi skeleton list notifikasi dan menghapus pembungkus `Padding(bottom: 12)` duplikat agar layout skeleton presisi dan selaras dengan daftar nyata.
  3. **Auto Version Bump ke 1.1.20+23**: Menaikkan versi aplikasi menjadi `version: 1.1.20+23` (`versionCode: 23`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.
### [2026-10-13] - Versi 1.1.21+24 (Optimasi Spasi Bawah Halaman Detail Amal Usaha & Penyelarasan Layout Presisi)
* **Fitur & Perbaikan**:
  1. **Optimasi Spasi Bawah `DetailAmalUsahaPage`**: Menghilangkan bottom padding berlebih (`24 + 96` / 120dp $\rightarrow$ `0`) dan menetralkan translation offset kartu (`-40` $\rightarrow$ `0`) pada [lib/view/pages/amal_usaha/detail_amal_usaha_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/amal_usaha/detail_amal_usaha_page.dart) agar konten tersaji lebih rapat, presisi, dan proporsional.
  2. **Penyelarasan Spasi Halaman Profil Akun**: Mengurangi jarak vertical spacing berlebih pada tombol aksi edit & logout di [lib/view/pages/profile/account_page.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/view/pages/profile/account_page.dart) (`SizedBox(height: 32/40)` $\rightarrow$ `24`) untuk tampilan yang lebih seimbang dan ergonomis.
  3. **Auto Version Bump ke 1.1.21+24**: Menaikkan versi aplikasi menjadi `version: 1.1.21+24` (`versionCode: 24`) di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) untuk kepatuhan Google Play Console.
* **Status Pengujian**: `flutter test` $\rightarrow$ 24/24 passed (100%), `flutter analyze` $\rightarrow$ 0 compilation error.

