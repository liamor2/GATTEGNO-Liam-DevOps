# Click Tracker Boilerplate

Dockerized monorepo with:
- React frontend (Vite)
- Spring Boot backend (Java 21 + Maven)
- PostgreSQL database

## What it does

The frontend shows one large `Press me` button.
When clicked, it calls `POST /api/click` on the backend.
The backend stores:
- the timestamp (`pressed_at`)
- the client IP (`ip_address`)

## Project structure

- `frontend/`: React app
- `backend/`: Spring Boot API
- `docker-compose.yml`: service orchestration

## Quick start

1. Create your env file:

```bash
cp .env.example .env
```

2. Start containers:

```bash
docker compose up --build
```

3. Open frontend:

- http://localhost:5173

4. Click the button, then verify DB rows:

```bash
docker exec -it clicktracker-db psql -U clickuser -d clickdb -c "SELECT * FROM click_events ORDER BY id DESC;"
```

## API

- `POST /api/click`
- Success response:

```json
{
  "id": 1,
  "pressedAt": "2026-05-21T14:00:00Z",
  "ipAddress": "203.0.113.10"
}
```

## Backend tests

From `backend/`:

```bash
mvn test
```

Includes:
- endpoint response test
- persistence test (timestamp + IP)
- IP resolution test (`X-Forwarded-For` first, fallback to remote address)

## Notes

- JPA schema mode is `update` for quick bootstrap.
- CI/CD is intentionally not implemented yet.
