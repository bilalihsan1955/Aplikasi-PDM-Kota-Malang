# API Service Guide for Flutter Client

## Base URL
```
https://your-domain.com/api/v1
```

## Authentication
API Berita dan Agenda bersifat public (tidak memerlukan autentikasi).

---

## 📰 News API (Berita)

### 1. Get All News
```http
GET /news?page=1&per_page=10&category_id=1&search=keyword
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| page | int | Nomor halaman (default: 1) |
| per_page | int | Jumlah item per halaman (default: 10) |
| category_id | int | Filter berdasarkan kategori |
| search | string | Pencarian berdasarkan judul/konten |

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Judul Berita",
      "slug": "judul-berita",
      "excerpt": "Ringkasan berita...",
      "content": "Konten lengkap...",
      "image": "https://domain.com/storage/news/image.jpg",
      "status": "published",
      "views": 100,
      "is_featured": true,
      "published_at": "2025-02-15 10:00:00",
      "category": {
        "id": 1,
        "name": "Umum",
        "slug": "umum"
      },
      "author": {
        "id": 1,
        "name": "Admin"
      },
      "created_at": "2025-02-15 10:00:00",
      "updated_at": "2025-02-15 10:00:00"
    }
  ],
  "links": {...},
  "meta": {...}
}
```

### 2. Get Featured News
```http
GET /news/featured
```

**Response:** Single news object

### 3. Get Latest News
```http
GET /news/latest
```

**Response:** Array of 5 latest news

### 4. Get News Detail
```http
GET /news/{slug}
```

**Response:** Single news object

---

## 📅 Event API (Agenda)

### 1. Get All Events
```http
GET /events?page=1&per_page=10&category_id=1&status=upcoming
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| page | int | Nomor halaman (default: 1) |
| per_page | int | Jumlah item per halaman (default: 10) |
| category_id | int | Filter berdasarkan kategori |
| status | string | Filter status: `upcoming`, `ongoing`, `completed`, `cancelled` |

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Judul Agenda",
      "slug": "judul-agenda",
      "description": "Deskripsi agenda...",
      "image": "https://domain.com/storage/events/image.jpg",
      "event_date": "2025-02-20",
      "event_time": "09:00:00",
      "location": "Masjid Al-Hikmah",
      "organizer": "Panitia Ramadhan",
      "contact_person": "Ahmad",
      "contact_phone": "08123456789",
      "max_participants": 100,
      "registration_link": "https://link.daftar",
      "status": "upcoming",
      "category": {
        "id": 1,
        "name": "Kajian",
        "slug": "kajian"
      },
      "created_at": "2025-02-15 10:00:00",
      "updated_at": "2025-02-15 10:00:00"
    }
  ],
  "links": {...},
  "meta": {...}
}
```

### 2. Get Upcoming Events
```http
GET /events/upcoming
```

**Response:** Array of 5 upcoming events

### 3. Get Event Detail
```http
GET /events/{slug}
```

**Response:** Single event object

---

## 📂 Category API

### Get All Categories
```http
GET /categories
```

### Get Category Detail
```http
GET /categories/{slug}
```

---

## 📷 Gallery API

### Get All Gallery
```http
GET /galleries?page=1&per_page=20
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| page | int | Nomor halaman (default: 1) |
| per_page | int | Jumlah item per halaman (default: 20) |

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "title": "Kegiatan Ramadhan",
      "description": "Dokumentasi kegiatan...",
      "image": "https://makotamu.org/storage/gallery/image.jpg",
      "type": "photo",
      "created_at": "2026-01-27 10:00:00"
    }
  ]
}
```

---

## 🏛️ Organization API (About PDM)

### Get Organization Profile
```http
GET /organization/profile
Accept: application/json
```

**Response (200):**
```json
{
  "data": {
    "id": 1,
    "name": "Pimpinan Daerah Muhammadiyah Kota Malang",
    "short_name": "PDM Kota Malang",
    "description": "Deskripsi organisasi...",
    "history": "Sejarah organisasi...",
    "vision": "Visi organisasi...",
    "mission": "Misi organisasi...",
    "logo": "https://makotamu.org/storage/logo.png",
    "address": "Jl.....",
    "phone": "0341-123456",
    "email": "info@makotamu.org",
    "website": "https://makotamu.org",
    "social_media": {
      "facebook": "https://facebook.com/pdmmalang",
      "instagram": "https://instagram.com/pdmmalang",
      "youtube": "https://youtube.com/pdmmalang",
      "twitter": "https://twitter.com/pdmmalang"
    },
    "established_year": 1920
  }
}
```

### Get Organization Structure
```http
GET /organization/structure
Accept: application/json
```

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Dr. H. Ahmad",
      "position": "Ketua",
      "division": "Pimpinan",
      "photo": "https://makotamu.org/storage/structure/photo.jpg",
      "phone": "081234567890",
      "email": "ketua@makotamu.org",
      "order": 1,
      "is_active": true
    }
  ]
}
```

---

## 🏢 Amal Usaha API

### Get All Amal Usaha
```http
GET /amal-usaha?page=1&per_page=10&type=pendidikan
Accept: application/json
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| page | int | No | Nomor halaman (default: 1) |
| per_page | int | No | Jumlah item per halaman (default: 10) |
| type | string | No | Filter: `pendidikan`, `kesehatan`, `sosial`, `ekonomi` |

**Response (200):**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Universitas Muhammadiyah Malang",
      "slug": "universitas-muhammadiyah-malang",
      "type": "pendidikan",
      "type_label": "Pendidikan",
      "description": "Deskripsi...",
      "image": "https://makotamu.org/storage/amal-usaha/image.jpg",
      "logo": "https://makotamu.org/storage/amal-usaha/logo.jpg",
      "address": "Jl. Raya Tlogomas No. 246",
      "phone": "0341-123456",
      "email": "info@umm.ac.id",
      "website": "https://www.umm.ac.id",
      "head_name": "Dr. Ahmad",
      "established_year": 1980,
      "is_active": true,
      "created_at": "2026-01-27 10:00:00"
    }
  ]
}
```

---

## 📷 Image URL Handling

Gambar yang dikembalikan API sudah dalam format full URL:
- Jika gambar berasal dari external URL: digunakan as-is
- Jika gambar dari storage lokal: `https://domain.com/storage/{path}`

---

## ⚠️ Error Response

```json
{
  "success": false,
  "message": "Error description"
}
```

HTTP Status Codes:
- `200` - Success
- `404` - Resource not found
- `429` - Too many requests (rate limit)
- `500` - Server error
