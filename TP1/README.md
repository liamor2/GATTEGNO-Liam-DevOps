# Click Tracker Boilerplate

Dockerized monorepo with:
- React frontend (Vite)
- Spring Boot backend (Java 25 + Maven)
- PostgreSQL database
- Prometheus and Grafana monitoring

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
- Grafana: http://localhost:3000 (`admin` / `admin` by default)
- Prometheus: http://localhost:9090

4. Click the button, then verify DB rows:

```bash
docker exec -it clicktracker-db psql -U clickuser -d clickdb -c "SELECT * FROM click_events ORDER BY id DESC;"
```

## API

- `POST /api/click`
- Prometheus metrics: `GET /actuator/prometheus`
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

## Monitoring

Prometheus scrapes the Spring Boot actuator endpoint at `/actuator/prometheus`.
Grafana is provisioned automatically with:
- a Prometheus datasource
- the `Click Tracker Overview` dashboard

The dashboard includes backend availability, click throughput, recorded click count, request latency, JVM memory, CPU usage, and database connection metrics.

Grafana credentials can be overridden with:

```env
GRAFANA_ADMIN_USER=admin
GRAFANA_ADMIN_PASSWORD=admin
```

## Auto Deploy On Self-Hosted Runner (Terraform + Docker Compose)

This repository supports automatic deployment on push/merge to `main` using a self-hosted GitHub Actions runner.

### 1. Prepare the remote server

Install on the server:
- Docker Engine
- Docker Compose plugin (`docker compose`)
- Terraform CLI (>= 1.15.4) or use the bundled runner image in `runner/`

Ensure the runner user can run Docker commands.

### Alternative: runner as Docker container

You can run the self-hosted runner from this repo:
- [runner/Dockerfile](runner/Dockerfile)
- [runner/docker-compose.yml](runner/docker-compose.yml)
- [runner/.env.example](runner/.env.example)

Steps on the server:
1. `cd runner`
2. `cp .env.example .env`
3. Fill `GITHUB_URL` and `GITHUB_TOKEN` in `.env`
4. `docker compose up -d --build`

The runner container is pre-bundled with Node, Java 25, Maven, Terraform, Docker CLI, and Compose plugin, and uses the host Docker socket.

### 2. Add GitHub repository secret

In `Settings > Secrets and variables > Actions`, add:
- `DEPLOY_APP_ENV`: full `.env` content used by `docker-compose.yml` during deploy

Example:

```env
POSTGRES_DB=clickdb
POSTGRES_USER=clickuser
POSTGRES_PASSWORD=clickpass
APP_CORS_ALLOWED_ORIGIN_PATTERNS=http://localhost:*,http://127.0.0.1:*
VITE_API_BASE_URL=http://localhost:8080
```

### 3. How deployment works

On push to `main`:
1. Frontend/backend quality checks and tests run.
2. Terraform plan runs in validation mode (`deploy_enabled=false`).
3. Playwright E2E runs.
4. `terraform-apply-auto` runs on the self-hosted runner with:
   - `deploy_enabled=true`
   - `deploy_mode=self_hosted_local`
5. Terraform writes `.env` at repo root and runs:
   - `docker compose up -d --build --remove-orphans`
