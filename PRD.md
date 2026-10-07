# PRODUCT REQUIREMENT DOCUMENT (PRD.MD)
**Nama Produk**: Makotamu (Aplikasi Mobile PDM Kota Malang)  
**Entitas Pemilik**: Pimpinan Daerah Muhammadiyah (PDM) Kota Malang  
**Platform**: Android & iOS (Flutter)  
**Versi Dokumen**: 1.0 (Oktober 2026)

---

## 1. Visi & Tujuan Produk
Aplikasi **Makotamu** merupakan platform ekosistem digital resmi Pimpinan Daerah Muhammadiyah Kota Malang yang dirancang untuk:
1. Menyebarkan syiar Islam berkemajuan, informasi resmi, dan berita terpercaya persyarikatan.
2. Memudahkan warga persyarikatan dan masyarakat umum dalam mengakses jadwal sholat presisi, pengingat ibadah, dan agenda kegiatan dakwah.
3. Menyediakan direktori interaktif seluruh Amal Usaha Muhammadiyah (AUM) di Kota Malang (Pendidikan, Kesehatan, Sosial, Masjid).
4. Menyediakan kanal komunikasi dan notifikasi terpusat dari PDM Kota Malang langsung ke perangkat warga.

---

## 2. Pengguna Target (Target Audience)
* **Warga Persyarikatan**: Anggota Muhammadiyah, ‘Aisyiyah, dan Ortom se-Kota Malang.
* **Pimpinan & Pengurus**: Pimpinan Daerah (PDM), Pimpinan Cabang (PCM), Pimpinan Ranting (PRM), dan pimpinan AUM.
* **Masyarakat Umum & Simpatisan**: Warga Kota Malang dan sekitarnya yang membutuhkan informasi kajian, jadwal sholat, rujukan fasilitas kesehatan PKU, sekolah, atau layanan sosial Lazismu.

---

## 3. Arsitektur Sistem & Spesifikasi Teknis
* **Pola Arsitektur**: **MVVM (Model - View - ViewModel)** dipadukan dengan **Repository Pattern**.
  * **View (`lib/view/`)**: Antarmuka pengguna responsif (halaman dan widget).
  * **ViewModel (`lib/view_models/`)**: Pengelola *state* dan logika bisnis menggunakan `ChangeNotifier` dari `package:provider`.
  * **Repository (`lib/repositories/`)**: Abstraksi sumber data yang menghubungkan ViewModel dengan API dan cache lokal.
  * **Service (`lib/services/`)**: Implementasi teknis komunikasi HTTP, FCM, Local Notification, enkripsi token, dan lokasi.
* **Routing & Deep Linking**:
  * Menggunakan `GoRouter` di [lib/routes/app_router.dart](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/lib/routes/app_router.dart).
  * Mendukung App Links terverifikasi: `https://makotamu.org/berita/*`, `https://makotamu.org/kegiatan/*`, dan `https://makotamu.org/amal-usaha/*`.
* **Penyimpanan Lokal**:
  * Data sesi & token rahasia: `flutter_secure_storage`.
  * Pengaturan UI, cache jadwal sholat, & tema: `shared_preferences`.
* **Layanan Notifikasi**:
  * Notifikasi Cloud: Firebase Cloud Messaging (FCM).
  * Notifikasi Lokal: `flutter_local_notifications` dengan dua saluran independen (Pengingat Sholat / Alarm & Pengumuman Umum).

---

## 4. Alur & Modul Fungsional Aplikasi (User Flows)

```
[Start App] ──> [Splash / Initial Routing]
                     ├──> Sesi Aktif ──────> [Home / Main Shell]
                     └──> Belum Login ─────> [Login / Register / Onboarding]
```

### 4.1. Modul Autentikasi & Akun
1. **Login**: Autentikasi akun pengguna menggunakan email/identitas dan kata sandi. Menyimpan token JWT secara aman dan otomatis melakukan sinkronisasi FCM token ke backend.
2. **Register**: Pendaftaran akun baru warga persyarikatan.
3. **Lupa Kata Sandi (Forgot Password)**: Permintaan reset kata sandi ke email terdaftar.
4. **Auto-Refresh Sesi**: Aplikasi secara transparan memperbarui Access Token di latar belakang (`tryRefreshTokenInBackground`) agar pengguna tidak ter-logout secara tiba-tiba saat beraktivitas.
5. **Mode Tamu (Guest Mode)**: Pengguna yang belum login tetap dapat membaca berita, melihat agenda, dan melihat jadwal sholat.

### 4.2. Modul Beranda (Home Dashboard)
* **Widget Waktu Sholat**: Menampilkan nama waktu sholat aktif hari ini, jadwal sholat berikutnya, serta hitung mundur waktu azan.
* **Banner / Slider Dinamis**: Menampilkan publikasi acara penting atau maklumat resmi dari PDM Malang.
* **Menu Akses Cepat**: Tombol pintas ke Jadwal Sholat Lengkap, Agenda Kegiatan, Berita Terkini, Amal Usaha, dan Arah Kiblat.
* **Feed Berita Terbaru**: Daftar cuplikan artikel dan berita persyarikatan dengan pull-to-refresh.

### 4.3. Modul Jadwal Sholat & Pengingat Azan
1. **Deteksi Lokasi**: Mengambil koordinat GPS perangkat pengguna dengan perizinan runtime (`ACCESS_FINE_LOCATION`) untuk menghitung jadwal sholat Kota Malang dan sekitarnya secara akurat.
2. **Penjadwalan Alarm**:
   * Menjadwalkan pengingat otomatis tepat waktu azan (5 waktu sholat wajib).
   * Menjadwalkan pengingat awal "5 menit lagi masuk waktu sholat".
3. **Kepatuhan Android 14+**: Menampilkan panduan dialog perizinan `SCHEDULE_EXACT_ALARM` agar alarm tidak dimatikan paksa oleh sistem operasi.

### 4.4. Modul Berita & Syiar (News)
1. **Daftar Berita**: Navigasi berdasarkan kategori berita, tab pencarian, dan pagination.
2. **Detail Berita**: Render artikel lengkap dengan gambar utama, format konten HTML, metadata penulis, dan tanggal publikasi.
3. **Bagikan Berita**: Tombol *Share* untuk menyebarkan link artikel ke WhatsApp, media sosial, atau aplikasi lain.
4. **Deep Linking**: Membuka link `makotamu.org/berita/{slug}` dari browser atau WhatsApp akan langsung membuka detail artikel di aplikasi.

### 4.5. Modul Agenda & Kegiatan
1. **Kalender & Jadwal Kegiatan**: Daftar agenda kegiatan persyarikatan (pengajian rutin, musyawarah cabang/ranting, tabligh akbar, bakti sosial).
2. **Detail Agenda**: Deskripsi kegiatan, waktu pelaksanaan, penyelenggara, dan peta lokasi kegiatan interaktif via OpenStreetMap.
3. **Navigasi Rute**: Tombol untuk membuka rute lokasi acara di Google Maps.

### 4.6. Modul Direktori Amal Usaha Muhammadiyah (AUM)
1. **Kategori AUM**:
   * Pendidikan (KB/TK ABA, SD, SMP, SMA, SMK, Universitas).
   * Kesehatan (RS PKU Muhammadiyah, Balai Pengobatan/Klinik).
   * Kesejahteraan Sosial (Panti Asuhan, Lazismu).
   * Tempat Ibadah (Masjid & Musholla binaan persyarikatan).
2. **Pencarian & Filter**: Filter lokasi per cabang/kecamatan di Kota Malang.
3. **Detail Fasilitas**: Informasi kontak, foto bangunan, alamat lengkap, dan panduan arah peta.

### 4.7. Modul Notifikasi (Push Notification & Inbox)
1. **Penerimaan Push**: Notifikasi sistem dari FCM ketika ada siaran pers mendesak, agenda baru, atau artikel unggulan.
2. **Inbox Notifikasi**: Halaman riwayat notifikasi di aplikasi untuk membaca kembali pesan yang pernah diterima.
3. **Navigasi Intent**: Mengetuk notifikasi langsung mengarahkan pengguna ke halaman artikel atau agenda terkait (*cold start* maupun saat aplikasi berjalan di *background*).

### 4.8. Modul Profil, Pengaturan & Legalitas
1. **Profil Pengguna**: Menampilkan nama, email, status keanggotaan, dan foto avatar profil.
2. **Ganti Foto Avatar**: Dukungan pengambilan foto langsung dari Kamera atau pemilihan berkas dari Galeri perangkat.
3. **Preferensi Tampilan**: Pilihan tema Terang (*Light*), Gelap (*Dark*), atau Mengikuti Sistem (*System*).
4. **Halaman Legalitas**:
   * **Kebijakan Privasi (Privacy Policy)**: Tampil secara in-app via WebView dengan tautan resmi `https://makotamu.org/privacy-policy`.
   * **Syarat & Ketentuan (Terms of Service)**: Tampil secara in-app via WebView dengan tautan resmi `https://makotamu.org/terms`.
5. **Logout**: Menghapus token dari secure storage, membatalkan pendaftaran token FCM dari backend, dan mengembalikan user ke halaman awal.

---

## 5. Persyaratan Non-Fungsional (Non-Functional Requirements)
* **Kestabilan & Ketiadaan Crash**: Bebas dari unhandled exceptions; seluruh pengujian otomatis wajib lulus 100%.
* **Kepatuhan Google Play Console**: Target SDK Android 34+, dukungan arsitektur 64-bit, penomoran `versionCode` yang selalu meningkat bertahap, dan kelengkapan deklarasi *Data Safety*.
* **Keamanan Data**: Semua komunikasi wajib melalui HTTPS (SSL/TLS), dan data kredensial disimpan terenkripsi di perangkat.
* **Ketahanan Mode Offline**: Cache lokal jadwal sholat dan artikel yang sudah dibuka agar tetap dapat diakses saat jaringan internet lemah.
