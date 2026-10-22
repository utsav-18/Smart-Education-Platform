# Smart Education Platform

Initial MERN implementation for the Multi-Cloud CI/CD System for Smart Education Platforms project. The current milestone focuses on local development and a first GitHub Actions CI workflow; cloud provisioning and deployment remain future work.

## Architecture

- `backend/`: Express REST API, Mongoose model, database connection, and Node.js/Supertest tests.
- `frontend/`: React dashboard built with Vite and connected to the backend through `VITE_API_BASE_URL`.
- MongoDB stores course data. The backend does not connect to MongoDB when the Express app is imported by tests.

## Local setup

Requirements: Node.js 22+, npm, and MongoDB (local installation or a MongoDB container).

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

3. Start two terminals:

   ```powershell
   # Terminal 1
   cd backend
   npm start

   # Terminal 2
   cd frontend
   npm run dev
   ```

   Open the Vite URL shown in the frontend terminal. The dashboard retrieves courses from `http://localhost:5000/api/courses`.

4. Run backend tests:

   ```powershell
   cd backend
   npm test
   ```

Tests stub model calls where appropriate, so health, retrieval behavior, nonexistent IDs, and validation tests do not require a running MongoDB instance.

## Continuous integration

The workflow in `.github/workflows/ci.yml` runs for pushes to `main` or `develop` and for pull requests targeting either branch. It uses Node.js 22 and checks:

- Backend dependency installation with `npm ci` and the backend test suite.
- Frontend dependency installation with `npm ci` and the production Vite build.
- Backend and frontend Docker image builds using Docker Buildx.

The workflow only builds images locally on the GitHub-hosted runner. It does not push images, require cloud credentials, start MongoDB, or provision AWS/Azure resources. The current backend tests are intentionally independent of a live MongoDB instance; database integration tests should be added as a separate job when they are introduced.

## API

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

## Docker

Build and run the backend (with MongoDB available at the configured URI):

```powershell
docker build -t smart-education-backend ./backend
docker run --rm -p 5000:5000 `
  -e MONGO_URI=mongodb://host.docker.internal:27017/smart_education_platform `
  smart-education-backend
```

Build the frontend:

```powershell
docker build -t smart-education-frontend ./frontend
docker run --rm -p 8080:80 smart-education-frontend
```

The frontend API URL is compiled into the Vite bundle at build time. For a containerized deployment, provide `VITE_API_BASE_URL` as a build argument or configure the frontend reverse proxy in a later deployment milestone.

## Future work

The next recommended task is to add database integration coverage and then extend the CI workflow with that test job. Cloud resources, credentials, Terraform, Kubernetes, and public deployment are intentionally not included in this milestone.
