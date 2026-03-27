# Food Pre-Order & Cafeteria Management System

### ITS 2130 — Enterprise Cloud Architecture | Final Project

---

## Architecture Overview

```
┌────────────────────────────────────────────────────────┐
│                     webapp/  (port 3000)               │
│        Vue 3 + Vite + Tailwind CSS  →  API Gateway     │
└─────────────────────────┬──────────────────────────────┘
                          │ HTTP
┌─────────────────────────▼──────────────────────────────┐
│               api-gateway  (port 8080)                 │
│           Spring Cloud Gateway  lb:// routing          │
└──┬──────────────┬──────────────┬──────────────┬────────┘
   │              │              │              │
   ▼              ▼              ▼              ▼
user-service  menu-service  order-service  kitchen-service
 (8081/PostgreSQL)  (8082/PostgreSQL+GCS) (8083/PostgreSQL)  (8084/MongoDB)

           All services register with ↓
┌───────────────────────────────────────────────────────┐
│           service-registry / Eureka  (port 8761)      │
└───────────────────────────────────────────────────────┘

           All services fetch config from ↓
┌───────────────────────────────────────────────────────┐
│               config-server  (port 9000)              │
│   Git Repo: github.com/ChamathDilshanC/               │
│             Cafeteria-System-Configurations           │
└───────────────────────────────────────────────────────┘
```

---

## Folder Structure

```
EnterpriseCloudArchitecture_Final/
├── docker-compose.yml          ← PostgreSQL + MongoDB for local dev
├── ecosystem.config.js         ← PM2 config for GCP VMs
├── init-scripts/
│   └── postgresql/
│       └── 00_create_databases.sql
├── platform/
│   ├── config-server/          (port 9000) — Spring Cloud Config
│   ├── service-registry/       (port 8761) — Netflix Eureka
│   └── api-gateway/            (port 8080) — Spring Cloud Gateway
├── services/
│   ├── user-service/           (port 8081) — Auth/Users   [PostgreSQL]
│   ├── menu-service/           (port 8082) — Menu/Items   [PostgreSQL + GCS]
│   ├── order-service/          (port 8083) — Orders       [PostgreSQL]
│   └── kitchen-service/        (port 8084) — Kitchen Queue[MongoDB]
└── webapp/                      (port 3000) — Frontend (Vue 3)
```

---

## Quick Start (Local Development)

### Prerequisites

- Java 25, Maven 3.9+
- Docker Desktop
- Node.js 20+ (for webapp with Vite)

### Step 1 — Start databases

```bash
docker compose up -d
```

### Step 2 — Build all services

```bash
./build-all.sh        # Linux/macOS
build-all.bat         # Windows
```

### Step 3 — Start with PM2

```bash
# Install PM2 globally once
npm install -g pm2

# Start all services in order
pm2 start ecosystem.config.js
pm2 logs
```

### Step 4 — Start the webapp

```bash
cd webapp
npm install
npm run dev
```

### Step 5 — Open the app

- Frontend: http://localhost:3000
- API Gateway: http://localhost:8080
- Eureka Dashboard: http://localhost:8761
- Config Server: http://localhost:9000

---

## Centralized Configuration

All service configuration lives in a Git repository:

**Repo:** https://github.com/ChamathDilshanC/Cafeteria-System-Configurations

**Structure:**

```
Cafeteria-System-Configurations/
├── application.yaml          (global config: Eureka cluster, logging)
├── platform/
│   ├── api-gateway.yaml
│   ├── config-server.yaml
│   └── service-registry.yaml
└── services/
    ├── user-service.yaml
    ├── menu-service.yaml
    ├── order-service.yaml
    └── kitchen-service.yaml
```

Each business service's `application.yml` contains only:

```yaml
spring:
  application:
    name: <service-name>
  config:
    import: 'optional:configserver:${CONFIG_SERVER_URI:http://localhost:9000}'
```

The Config Server delivers the full configuration at startup by cloning the Git repository.

---

## Environment Variables (GCP Production)

| Variable            | Default                       | Description           |
| ------------------- | ----------------------------- | --------------------- |
| `CONFIG_SERVER_URI` | http://localhost:9000         | URL of Config Server  |
| `EUREKA_URI`        | http://localhost:8761/eureka/ | Eureka endpoint       |
| `POSTGRES_HOST`     | localhost                     | PostgreSQL hostname   |
| `POSTGRES_USER`     | postgres                      | PostgreSQL username   |
| `POSTGRES_PASSWORD` | postgrespassword              | PostgreSQL password   |
| `MONGO_HOST`        | localhost                     | MongoDB hostname      |
| `MONGO_USER`        | admin                         | MongoDB username      |
| `MONGO_PASSWORD`    | adminpassword                 | MongoDB password      |
| `JWT_SECRET`        | _(dev default)_               | JWT signing secret    |
| `GCS_BUCKET_NAME`   | cafeteria-menu-images         | GCS bucket for images |
| `GCP_PROJECT_ID`    | your-gcp-project-id           | GCP Project ID        |

On GCP, set these in each VM's startup script or use Secret Manager.

---

## Tech Stack

| Layer        | Technology                        |
| ------------ | --------------------------------- |
| Language     | Java 25                           |
| Framework    | Spring Boot 4.0.3                 |
| Cloud        | Spring Cloud 2025.1.0             |
| Service Mesh | Netflix Eureka + Spring Gateway   |
| Config       | Spring Cloud Config (Git)         |
| DB (SQL)     | PostgreSQL 16 via Spring Data JPA |
| DB (NoSQL)   | MongoDB 7.0 via Spring Data Mongo |
| File Storage | Google Cloud Storage (GCS)        |
| Auth         | JWT (jjwt 0.12.6)                 |
| Frontend     | Vue 3 + Vite + Tailwind CSS       |
| Process Mgr  | PM2                               |
| Dev DBs      | Docker Compose                    |
