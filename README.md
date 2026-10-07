# Makotamu (PDM Kota Malang)

Aplikasi mobile resmi **Pimpinan Daerah Muhammadiyah (PDM) Kota Malang** untuk ekosistem dakwah, informasi persyarikatan, agenda kegiatan, jadwal sholat presisi, direktori Amal Usaha Muhammadiyah (AUM), dan layanan warga persyarikatan.

---

## 📌 Identitas Aplikasi
* **Nama Aplikasi**: Makotamu
* **Package / Application ID**: `id.makotamu.app`
* **Versi Baseline Rilis**: `1.1.4+7` (Version Name: `1.1.4`, Version Code: `7`)
* **Framework**: Flutter 3.x / Dart SDK `^3.10.7`
* **Target Platform**: Android (Min SDK: 21, Target SDK: 34), iOS

---

## 🚀 Fitur Utama
1. **Berita & Artikel Persyarikatan**: Berita terkini seputar Muhammadiyah Kota Malang dan nasional dengan fitur pencarian, filter kategori, dan deep linking.
2. **Jadwal Sholat & Arah Kiblat**: Perhitungan waktu sholat presisi berdasarkan lokasi dan kompas kiblat interaktif.
3. **Agenda & Kegiatan Dakwah**: Informasi jadwal pengajian, tabligh akbar, rapat pimpinan, dan kegiatan ortom.
4. **Direktori Amal Usaha (AUM)**: Pencarian dan rujukan fasilitas pendidikan, kesehatan (PKU), sosial (Panti Asuhan & Lazismu), serta masjid di wilayah Kota Malang.
5. **Autentikasi & Akun**: Manajemen sesi aman (`flutter_secure_storage`), update profil, ubah kata sandi, dan notifikasi cloud terintegrasi (FCM).

---

## 🛠️ Menjalankan Proyek

### Prasyarat
- Flutter SDK `^3.10.7`
- Android SDK (API 34) & Java JDK 17
- Git

### Menjalankan Mode Pengembangan
```bash
flutter pub get
flutter run
```

### Pengujian Otomatis (Automated Testing)
```bash
flutter test
flutter analyze --no-fatal-infos --no-fatal-warnings
```

### Build Rilis (Android App Bundle / AAB)
```bash
flutter build appbundle --release
```
Berkas keluaran siap rilis akan berada di: `build/app/outputs/bundle/release/app-release.aab`
