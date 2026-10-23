# Smart Education Platform

Initial MERN implementation for the Multi-Cloud CI/CD System for Smart Education Platforms project. The current milestone focuses on local development, Docker Compose orchestration, and a GitHub Actions CI workflow; cloud provisioning and deployment remain future work.

## Architecture

- `backend/`: Express REST API, Mongoose model, database connection, and Node.js/Supertest tests.
- `frontend/`: React dashboard built with Vite, served via Nginx in production, and connected to the backend.
- `mongodb`: MongoDB container with persistent named volume for course data.

## Local Setup (Without Docker)

Requirements: Node.js 22+, npm, and MongoDB (local installation or container).

1. Configure the backend:

   ```powershell
   cd backend
   Copy-Item .env.example .env
   npm install
   ```

   Update `MONGO_URI` in `backend/.env` if your MongoDB instance uses a different URI.

2. Install and configure the frontend:

   ```powershell
   cd frontend
   Copy-Item .env.example .env
   npm install
   ```

3. Seed courses (optional):

   ```powershell
   cd backend
   npm run seed
   ```

4. Start two terminals:

   ```powershell
   # Terminal 1
   cd backend
   npm start

   # Terminal 2
   cd frontend
   npm run dev
   ```

   Open the Vite URL shown in the frontend terminal. With the example `.env`, the dashboard retrieves courses from `http://localhost:5000/api/courses`.

5. Run backend tests:

   ```powershell
   cd backend
   npm test
   ```

Tests stub model calls where appropriate, so health, retrieval behavior, nonexistent IDs, and validation tests do not require a running MongoDB instance.

`GET /health` is a lightweight liveness check. `GET /readyz` verifies that MongoDB is connected and returns HTTP 503 until the backend is ready for database operations. Course API requests also return HTTP 503 while MongoDB is unavailable.

## Docker Compose (Recommended)

Docker Compose orchestrates the full multi-tier stack: `frontend` (Nginx), `backend` (Node.js/Express), and `mongodb` (persistent database).

### 1. Build and Start Services

```powershell
docker compose up -d --build
```

Compose starts the services with dependency and health-check management:
1. `mongodb` initializes with a persistent named volume (`mongodb_data`).
2. `backend` connects to `mongodb://mongodb:27017/smart_education_platform` once the database reports healthy.
3. `frontend` starts Nginx once the backend reports healthy.

### 2. Verify Status and Health

Check running container status and health:

```powershell
docker compose ps
```

All three services (`frontend`, `backend`, `mongodb`) should show as `healthy` / `Up`.

### 3. Seed Course Data

Seed the 5 sample courses into the containerized MongoDB database (safe to run repeatedly; uses idempotent upserts):

```powershell
docker compose exec backend npm run seed
```

### 4. Access the Application

- **Frontend Application**: [http://localhost:3000](http://localhost:3000)
- **Backend API**: [http://localhost:5000/api/courses](http://localhost:5000/api/courses)
- **Backend Health Check**: [http://localhost:5000/health](http://localhost:5000/health)
- **Backend Readiness Check**: [http://localhost:5000/readyz](http://localhost:5000/readyz)

### 5. Stop Services

To stop containers while **preserving database data**:

```powershell
docker compose down
```

To stop containers and **wipe the persistent database volume**:

```powershell
docker compose down -v
```

## Manual Docker Commands

If running images individually without Docker Compose:

1. Backend:
   ```powershell
   docker build -t smart-education-backend ./backend
   docker run --rm -p 5000:5000 `
     -e MONGO_URI=mongodb://host.docker.internal:27017/smart_education_platform `
     smart-education-backend
   ```

2. Frontend:
   ```powershell
   docker build -t smart-education-frontend ./frontend
   docker run --rm -p 3000:80 smart-education-frontend
   ```

## Continuous Integration

The workflow in `.github/workflows/ci.yml` runs for pushes to `main` or `develop` and for pull requests targeting either branch. It uses Node.js 22 and checks:

- Backend dependency installation with `npm ci` and the backend test suite.
- Frontend dependency installation with `npm ci` and the production Vite build.
- Backend and frontend Docker image builds using Docker Buildx.
- Docker Compose configuration validation (`docker compose config -q`).
- Docker Compose integration testing (orchestration, health checks, database seeding, API verification, and teardown).

The workflow executes on GitHub-hosted Ubuntu runners. It does not push images, require cloud credentials, or provision public cloud resources.

The production frontend uses the same-origin `/api` path, which Nginx proxies to the backend service. Local Vite development can use `VITE_API_BASE_URL=http://localhost:5000` from `frontend/.env.example`. The production bundle does not require or embed a backend hostname.

## API Specification

| Method | Endpoint | Description |
| --- | --- | --- |
| GET | `/health` | Returns `{ "status": "ok" }` |
| GET | `/api/courses` | Lists courses, newest first |
| GET | `/api/courses/:id` | Gets one course or returns 404 |
| POST | `/api/courses` | Creates a course from `title`, `description`, `instructor`, and `duration` |

Example request:

```json
{
  "title": "Introduction to Web Development",
  "description": "Learn the fundamentals of modern web applications.",
  "instructor": "Dr. Priya Sharma",
  "duration": "8 weeks"
}
```

## Future Work

The next recommended task is to add database integration coverage and then extend the CI workflow with that test job. Cloud resources, credentials, Terraform, Kubernetes, and public deployment are intentionally not included in this milestone.
