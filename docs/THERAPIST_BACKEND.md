# MindCare — Therapist & roles API contract (reference)

This document defines the **student-app ↔ backend** contract for therapist features.  
**Server implementation is not included** in this repository; use this as the source of truth when building your API.

Base path prefix (existing app): `/api/v1`  
All endpoints below assume JWT auth: `Authorization: Bearer <token>` unless noted.

---

## 1. User roles

Represent in your user model / JWT claims (examples):

| Role       | Typical use                          |
|-----------|----------------------------------------|
| `student` | Default for MindCare mobile app users |
| `therapist` | Future web dashboard / clinician tools |
| `admin`   | Operations, assignment routing, audit  |

Student app only calls endpoints that apply to the **authenticated student**.

---

## 2. Therapist assignment model (data shape)

Logical entity (table or document):

| Field          | Type     | Notes |
|----------------|----------|--------|
| `id`           | string   | Assignment id |
| `studentId`    | string   | FK to user |
| `therapistId`  | string?  | Set when matched |
| `status`       | string   | `pending` \| `assigned` \| `closed` |
| `createdAt`    | ISO8601  | |
| `updatedAt`    | ISO8601  | |

---

## 3. `POST /therapist/request`

**Purpose:** Student asks to be matched with a therapist.

**Body:** `{}` or optional `{ "note": "optional student note" }`

**Behavior:**

- Creates or updates assignment for `studentId` from JWT → `status = pending` (if policy allows).
- Idempotent: repeated calls may return 200 with same pending state.

**Success (200):** JSON body may be empty or `{ "ok": true }`.

**Errors:** 401 unauthorized, 409 if not allowed, 429 rate limit — return `{ "message": "..." }`.

---

## 4. `GET /therapist/status`

**Purpose:** Drive UI: none / pending / assigned.

**Response (200) example:**

```json
{
  "status": "none",
  "therapist": null
}
```

```json
{
  "status": "pending",
  "therapist": null
}
```

```json
{
  "status": "assigned",
  "therapist": {
    "id": "t_123",
    "name": "Dr. Sam Rivera"
  }
}
```

**`status` values:** `none` | `pending` | `assigned` (and optionally `closed` — map in app to “closed” state).

**Alternate wrapping:** `{ "data": { ... } }` is supported by the Flutter client parser.

---

## 5. `GET /therapist/messages`

**Purpose:** Paginated thread between student and assigned therapist.

**Query (optional):** `?before=<messageId>&limit=50`

**Response (200):**

```json
{
  "messages": [
    {
      "id": "m1",
      "senderId": "user_student",
      "receiverId": "t_123",
      "message": "Hello",
      "timestamp": "2026-04-06T12:00:00.000Z"
    }
  ]
}
```

**Aliases supported by client:** `sender_id`, `receiver_id`, `text` / `body` for message body, `createdAt` for time.

**Rules:**

- Only return messages for the authenticated **student** and their **active** assignment.
- If not assigned: **403** or empty list with `status` not assigned (client already gates UI).

---

## 6. `POST /therapist/messages`

**Purpose:** Student sends a message.

**Body:**

```json
{ "message": "Plain text content" }
```

**Response (200):** `{ "ok": true }` or echo created message object.

**Errors:** 403 if no active therapist assignment.

---

## 7. Therapist / admin (future)

- **Therapist dashboard** (web): separate app; uses roles `therapist` / `admin` and endpoints such as `GET /therapist/inbox`, `POST /therapist/messages/reply` — **not** implemented in the Flutter student app.
- Keep **AI chat** (`/ai/chat`) and **therapist messaging** disjoint at the API layer.

---

## 8. Security notes

- Never return another student’s data.
- Log access for compliance (region-specific rules apply).
- Crisis copy in-app is **not** a substitute for emergency services.

---

## 9. Common backend mistake (student vs therapist routes)

If the mobile app shows **“therapist or admin access required”** (or 403) when the student taps **Talk to a therapist** / **Request support**, the server is almost certainly applying a **therapist/admin-only** guard to **all** `/therapist/*` routes.

**Wrong:** One middleware for `/therapist/*` that only allows `therapist` or `admin`.

**Right:** Split authorization:

| Who | Routes (examples) |
|-----|-------------------|
| **Student** (JWT + role `student`) | `POST /therapist/request`, `GET /therapist/status`, `GET` + `POST /therapist/messages` for *their own* thread |
| **Therapist / admin** | Separate paths or handlers, e.g. `GET /therapist/inbox`, assignment tools, moderation — **not** the student request endpoint |

`POST /therapist/request` must accept **students**; it creates a **pending** row for staff to assign on the website/dashboard.
