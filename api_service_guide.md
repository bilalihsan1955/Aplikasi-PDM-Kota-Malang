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
