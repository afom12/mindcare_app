# MindCare backend — technology stack (reference)

This document mirrors the **server** implementation for the MindCare project (separate repo from this Flutter app). Use it for onboarding and when aligning mobile + API contracts.

| Layer | Technology |
|--------|------------|
| Runtime | **Node.js** |
| Framework | **Express** |
| Modules | **ES modules** (`"type": "module"` in `package.json`) |
| Database | **MongoDB** via **Mongoose** |
| Auth | **JWT** (`jsonwebtoken`) + **bcryptjs** (passwords) |
| HTTP | **CORS**, **express-rate-limit**, **express-validator** |
| File uploads | **Multer** (e.g. therapist licenses) |
| Email | **Nodemailer** |
| Real-time | **Socket.io** (e.g. community chat) |
| AI / external | **OpenAI SDK** (and possibly Groq or others in `services/` — confirm in server code) |
| HTTP client (server) | **Axios** |
| Config | **dotenv** (`.env`) |
| Dev | **nodemon** (`npm run dev`) |

## API shape

- **REST** under `/api/v1/...` (e.g. `/api/v1/auth`, `/api/v1/ai/chat`).
- **Health:** `/api/health` (or similar).

## Flutter app alignment

- Mobile base URL should point at the same host + `/api/v1` (see `API_BASE_URL` in the Flutter project).
- Therapist student endpoints should live under a path the app can configure via `THERAPIST_PATH_PREFIX` (default `/therapist`) — see `docs/THERAPIST_BACKEND.md`.

## Express tip: “therapist or admin access required” on student actions

If **all** `/api/v1/therapist/*` routes sit behind one `requireRole(['therapist','admin'])` middleware, **students** will be blocked from `POST /api/v1/therapist/request`.

**Fix pattern:**

1. Register **student-safe** routes **before** the strict middleware, e.g.  
   `POST /request`, `GET /status`, `GET /messages`, `POST /messages` with `requireAuth` + `requireRole('student')` (or “authenticated user with student profile”).
2. Mount **therapist/admin-only** routes under a separate router or prefix, e.g. `/api/v1/therapist/admin/...` or `/api/v1/admin/therapist/...`.

Splitting routers avoids one guard applying to every subpath.
