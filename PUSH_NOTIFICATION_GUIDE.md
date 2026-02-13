# 📱 Push Notification FCM - Panduan Integrasi

## 📋 Daftar Isi
1. [Arsitektur Sistem](#arsitektur-sistem)
2. [File yang Dibuat](#file-yang-dibuat)
3. [Endpoint Backend API](#endpoint-backend-api)
4. [Konfigurasi Firebase](#konfigurasi-firebase)
5. [Cara Menggunakan](#cara-menggunakan)
6. [Testing](#testing)
7. [Troubleshooting](#troubleshooting)

---

## 🏗️ Arsitektur Sistem

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER APP                           │
│                                                          │
│  ┌────────────────┐         ┌────────────────┐         │
│  │  FCM Service   │────────▶│  API Service   │         │
│  │                │         │                │         │
│  │ - Subscribe    │         │ - HTTP Calls   │         │
│  │ - Unsubscribe  │         │ - Token Mgmt   │         │
│  │ - Token Mgmt   │         └────────┬───────┘         │
│  └────────┬───────┘                  │                 │
│           │                          │                 │
└───────────┼──────────────────────────┼─────────────────┘
            │                          │
            │                          ▼
            │              ┌──────────────────────┐
            │              │   BACKEND SERVER     │
            │              │                      │
            │              │  /api/v1/fcm/...    │
            │              └──────────────────────┘
            │
            ▼
┌──────────────────────────────────────────┐
│        FIREBASE CLOUD MESSAGING           │
│                                          │
│  - Topic Subscription                    │
│  - Push Notifications                    │
│  - Token Management                      │
└──────────────────────────────────────────┘
```

---

## 📁 File yang Dibuat

### 1. **Services**
- `lib/services/fcm_service.dart` - Service untuk handle FCM dan topic subscription
- `lib/services/api_service.dart` - Service untuk HTTP requests ke backend

### 2. **Models**
- `lib/models/notification_model.dart` - Model untuk notifikasi

### 3. **ViewModels**
- `lib/view_models/notification_view_model.dart` - State management notifikasi

### 4. **Pages**
- `lib/view/pages/notification_page.dart` - Halaman list notifikasi

Subscribe ke topic default (general, news, agenda, announcement) dilakukan **sekali saat pertama aplikasi dijalankan** via `FCMService._subscribeToDefaultTopicsIfFirstLaunch()`.

---

## 🔌 Endpoint Backend API

### Base URL
Atur di file **`.env`** (gunakan `.env.example` sebagai template):
```
API_BASE_URL=https://your-domain.com/api/v1
```

### 1. Subscribe ke Topic (Public - Tanpa Login)

**Endpoint:** `POST /fcm/subscribe`

**Headers:**
```json
{
  "Content-Type": "application/json"
}
```

**Body:**
```json
{
  "fcm_token": "fcm_token_dari_flutter",
  "topic": "news"
}
```

**Response Success (200):**
```json
{
  "success": true,
  "message": "Successfully subscribed to topic",
  "data": null
}
```

**Response Error (400/500):**
```json
{
  "success": false,
  "message": "Error message here",
  "data": null
}
```

---

### 2. Unsubscribe dari Topic (Public - Tanpa Login)

**Endpoint:** `POST /fcm/unsubscribe`

**Headers:**
```json
{
  "Content-Type": "application/json"
}
```

**Body:**
```json
{
  "fcm_token": "fcm_token_dari_flutter",
  "topic": "news"
}
```

---

### 3. Subscribe ke Topic (Authenticated)

**Endpoint:** `POST /fcm/subscribe`

**Headers:**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {user_token}"
}
```

**Body:**
```json
{
  "topic": "news"
}
```

---

### 4. Unsubscribe dari Topic (Authenticated)

**Endpoint:** `POST /fcm/unsubscribe`

**Headers:**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {user_token}"
}
```

**Body:**
```json
{
  "topic": "news"
}
```

---

### 5. Update FCM Token (Authenticated)

**Endpoint:** `POST /fcm/token`

**Headers:**
```json
{
  "Content-Type": "application/json",
  "Authorization": "Bearer {user_token}"
}
```

**Body:**
```json
{
  "fcm_token": "fcm_token_dari_flutter"
}
```

---

### 6. Delete FCM Token (Logout)

**Endpoint:** `DELETE /fcm/token`

**Headers:**
```json
{
  "Authorization": "Bearer {user_token}"
}
```

---

## 🔥 Konfigurasi Firebase

### 1. Setup Firebase Project

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Buat project baru atau pilih project yang sudah ada
3. Tambahkan aplikasi Android dan iOS

### 2. Download Config Files

**Android:**
- Download `google-services.json`
- Letakkan di: `android/app/google-services.json`

**iOS:**
- Download `GoogleService-Info.plist`
- Letakkan di: `ios/Runner/GoogleService-Info.plist`

### 3. Update Android Configuration

**File:** `android/app/build.gradle.kts`

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Tambahkan ini
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.8.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")
}
```

**File:** `android/build.gradle.kts`

```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}
```

### 4. Update iOS Configuration

**File:** `ios/Runner/AppDelegate.swift`

```swift
import UIKit
import Flutter
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

---

## 💡 Cara Menggunakan

### 1. Subscribe ke Topic (Tanpa Login)

Di halaman **Notification Settings**, user bisa toggle on/off untuk setiap kategori:

```dart
// Otomatis dipanggil saat user toggle switch
await fcmService.subscribeToTopicPublic('news');
```

Available topics:
- `news` - Berita
- `agenda` - Agenda
- `announcement` - Pengumuman
- `general` - Umum

### 2. Subscribe ke Topic (Dengan Login)

Jika user sudah login dan Anda memiliki user token:

```dart
await fcmService.subscribeToTopicAuth('news', userToken);
```

### 3. Update FCM Token saat Login

```dart
final fcmService = FCMService();
await fcmService.updateTokenToBackend(userToken);
```

### 4. Delete FCM Token saat Logout

```dart
final fcmService = FCMService();
await fcmService.deleteTokenFromBackend(userToken);
```

### 5. Cek Status Subscription

```dart
final fcmService = FCMService();

// Cek semua topic yang di-subscribe
List<String> subscribedTopics = await fcmService.getSubscribedTopics();

// Cek topic tertentu
bool isSubscribed = await fcmService.isSubscribedToTopic('news');
```

---

## 🎯 Flow User

### Flow Tanpa Login (Public)

```
1. User buka app
2. FCM initialize otomatis
3. User masuk ke Notification Settings
4. User toggle kategori yang diinginkan
5. App subscribe/unsubscribe ke topic via FCM
6. App kirim request ke backend API
7. Backend save subscription data
8. User menerima notifikasi untuk topic yang di-subscribe
```

### Flow Dengan Login (Authenticated)

```
1. User login
2. App dapat user token
3. App kirim FCM token ke backend via API
4. User subscribe ke topic
5. Backend save FCM token + topic association
6. User menerima notifikasi
7. User logout
8. App hapus FCM token dari backend
```

---

## 🧪 Testing

### 1. Test Subscribe/Unsubscribe

1. Buka aplikasi
2. Navigate ke: **Home → Notifikasi (icon) → Settings (icon)**
3. Toggle on untuk kategori "Berita"
4. Cek console log untuk konfirmasi
5. Toggle off untuk unsubscribe

### 2. Test Notification dari Firebase Console

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Anda
3. Menu: **Messaging → New campaign → Firebase Notification messages**
4. Isi notifikasi:
   - Title: "Test Notifikasi"
   - Body: "Ini adalah test notifikasi"
5. Target: **Topic** → pilih "news"
6. Send test message
7. Cek aplikasi untuk menerima notifikasi

### 3. Test dengan cURL

**Subscribe:**
```bash
curl -X POST https://your-domain.com/api/v1/fcm/subscribe \
  -H "Content-Type: application/json" \
  -d '{
    "fcm_token": "YOUR_FCM_TOKEN",
    "topic": "news"
  }'
```

**Unsubscribe:**
```bash
curl -X POST https://your-domain.com/api/v1/fcm/unsubscribe \
  -H "Content-Type: application/json" \
  -d '{
    "fcm_token": "YOUR_FCM_TOKEN",
    "topic": "news"
  }'
```

---

## 🔍 Troubleshooting

### FCM Token tidak muncul

**Solusi:**
1. Pastikan Firebase sudah ter-konfigurasi dengan benar
2. Cek permission notifikasi di device settings
3. Restart aplikasi
4. Cek console log untuk error

### Notifikasi tidak diterima

**Solusi:**
1. Cek apakah sudah subscribe ke topic yang benar
2. Cek internet connection
3. Cek device notification settings
4. Test kirim notifikasi dari Firebase Console
5. Cek console log untuk error

### Subscribe gagal ke backend

**Solusi:**
1. Cek endpoint backend sudah benar
2. Cek network connection
3. Cek response error dari backend
4. Pastikan format body request sesuai
5. Cek console log untuk detail error

### App crash saat initialize FCM

**Solusi:**
1. Pastikan `google-services.json` sudah ada di folder yang benar
2. Pastikan dependencies Firebase sudah ter-install
3. Clean dan rebuild project:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

---

## 📝 Catatan Penting

1. **FCM Token Refresh**
   - Token bisa berubah saat:
     - App di-reinstall
     - App data di-clear
     - Device restore
   - Service sudah handle auto re-subscribe saat token refresh

2. **Local Storage**
   - Subscribed topics disimpan di SharedPreferences
   - Digunakan untuk re-subscribe saat app restart
   - Tidak perlu sync manual

3. **Topic Naming Convention**
   - Gunakan lowercase
   - Tanpa spasi
   - Gunakan underscore untuk separator (e.g., `news_update`)

4. **Security**
   - Jangan hardcode API URL di production
   - Gunakan environment variables
   - Implement proper token validation di backend

5. **Testing di Development**
   - Gunakan dummy data untuk testing UI
   - Test dengan Firebase Console untuk real notification
   - Setup separate Firebase project untuk dev/staging/production

---

## 🔗 Referensi

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [Flutter Firebase Messaging Plugin](https://pub.dev/packages/firebase_messaging)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)

---

## 📞 Support

Jika ada pertanyaan atau issue:
1. Cek troubleshooting guide di atas
2. Cek console log untuk error details
3. Cek Firebase Console untuk status notifikasi
4. Contact backend team untuk issue API

---

**Last Updated:** 2026-02-04
**Version:** 1.0.0
