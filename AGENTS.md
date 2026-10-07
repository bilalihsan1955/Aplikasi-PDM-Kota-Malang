# ATURAN & PROTOKOL KERJA AGENT (AGENTS.MD)
**Aplikasi: Makotamu (PDM Kota Malang)**  
**Platform: Flutter (Android & iOS)**

Dokumen ini merupakan panduan aturan mutlak dan standar operasional bagi Agent AI (Antigravity) dalam mengembangkan, memelihara, dan memperbarui codebase aplikasi Makotamu. Seluruh aturan wajib dipatuhi tanpa pengecualian.

---

## 1. Aturan Perencanaan (Plan-First Rule)
* **Wajib Membuat Rencana Sebelum Eksekusi**: Sebelum melakukan perubahan kode, Agent wajib menyusun dan menyampaikan rencana kerja bertahap (*implementation plan*) yang jelas dan terstruktur kepada pengguna.
* **Konfirmasi Langkah Kritis**: Jika perubahan melibatkan refactoring besar, migrasi dependensi, atau penghapusan kode, uraikan dampak potensialnya terlebih dahulu dalam rencana.
* **Dilarang Langsung Eksekusi Buta**: Agent dilarang langsung memodifikasi banyak file tanpa rencana kerja yang disetujui.

---

## 2. Aturan Klarifikasi & Anti-Halusinasi (Ask When In Doubt)
* **Dilarang Mengambil Keputusan Sendiri yang Ambigu**: Jika instruksi pengguna kurang spesifik, memiliki beberapa opsi interpretasi, atau menimbulkan keraguan teknis, **Agent dilarang menebak atau berasumsi**.
* **Wajib Bertanya Langsung**: Agent wajib segera mengajukan pertanyaan klarifikasi secara lugas dan terarah kepada pengguna untuk memvalidasi keinginan pengguna sebelum melangkah.
* **Anti-Halusinasi**: Dilarang mengasumsikan API endpoint, struktur payload backend, atau parameter yang belum terverifikasi di dalam codebase atau dokumentasi resmi.

---

## 3. Aturan Automated Testing & Jaminan Mutu (Quality Assurance)
* **Wajib Automated Testing**: Setiap penambahan fitur baru, perbaikan bug, atau perubahan logika wajib disertai dan divalidasi dengan pengujian otomatis:
  * `flutter test`: Seluruh unit test dan widget test wajib berstatus **PASS 100% (0 failure)**.
  * `flutter analyze`: Kode harus bersih dari compilation error atau syntax issue.
* **Zero Regression**: Perubahan pada satu fitur tidak boleh merusak fitur lain yang sudah berjalan normal (*regression-free*).
* **Headless/Mock Safety**: Komponen yang terhubung ke Firebase, background service, atau native channel wajib memiliki mekanisme proteksi/mock agar tidak menyebabkan crash pada lingkungan pengujian widget otomatis.

---

## 4. Aturan Pembaruan Versi Otomatis (Auto Version Bump)
* **Wajib Naikkan Versi Setiap Update Rilis/Fitur**: Setiap kali ada penambahan fitur atau pembaruan rilis dari pengguna, Agent wajib memperbarui konfigurasi versi di [pubspec.yaml](file:///c:/Users/BILALIHSAN/Documents/project/pdm_malang/pubspec.yaml) secara otomatis.
* **Aturan Kepatuhan Google Play**:
  * Format: `version: x.y.z+n`
  * Angka setelah tanda `+` (`versionCode`) **wajib selalu bertambah naik (+1)** pada setiap rilis agar Google Play Console tidak menolak pembaruan (*contoh: 1.0.0+1 $\rightarrow$ 1.0.1+2 $\rightarrow$ 1.1.0+3*).
  * Sesuaikan penomoran Semantic Versioning (`x.y.z` / `versionName`):
    * Bug fix / optimasi kecil: Naikkan patch (`1.0.0` $\rightarrow$ `1.0.1`).
    * Fitur baru / modul baru: Naikkan minor (`1.0.1` $\rightarrow$ `1.1.0`).
    * Perubahan arsitektur besar / breaking change: Naikkan major (`1.1.0` $\rightarrow$ `2.0.0`).

---

## 5. Aturan Pemecahan Perubahan Bertahap (Chunking & Modular Execution)
* **Dekomposisi Tugas Besar**: Jika suatu fitur atau tugas perbaikan melibatkan perubahan yang terlalu luas/kompleks, Agent **wajib memecahnya menjadi bagian-bagian modular yang lebih kecil** (*chunking*).
* **Tujuan Modularitas**: Mencegah context overload, menghindari file conflict, memudahkan penelusuran bug, dan menjaga stabilitas aplikasi di setiap tahap eksekusi.
* **Verifikasi per Tahap**: Setiap tahapan modular harus dapat dikompilasi dan diverifikasi sebelum melanjutkan ke modul berikutnya.

---

## 6. Aturan Keamanan Data & Integritas Sistem
* **Keamanan Kredensial**: Token autentikasi, refresh token, dan data sesi sensitif wajib disimpan menggunakan `flutter_secure_storage`.
* **Kerahasiaan Kunci & Keystore**: File sensitif seperti `key.properties`, keystore rilis, dan file `.env` tidak boleh dipublikasikan atau di-commit secara terbuka ke VCS publik.
* **Alur Bersih Tanpa Crash**: Pastikan penanganan error (try-catch, fallback UI, offline banner, dan token expired interceptor) terpasang di setiap komunikasi API dan navigasi.

---

## 7. Aturan Pencatatan Riwayat & Cache Konteks (Memory Update)
* **Wajib Catat Setiap Perubahan**: Setiap kali pekerjaan selesai dieksekusi, Agent **wajib mencatat ringkasan perubahan ke dalam berkas `MEMORY.md`**.
* **Format Pencatatan di `MEMORY.md`**:
  * Versi aplikasi terkini.
  * Tanggal dan jam pembaruan.
  * Daftar file yang dimodifikasi beserta ringkasan fungsinya.
  * Status kelulusan testing (`flutter test` & `flutter analyze`).
