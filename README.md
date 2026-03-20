# Food Pre-Order & Cafeteria Management System

### ITS 2130 — Enterprise Cloud Architecture | Final Project

---

## Architecture Overview

```
┌────────────────────────────────────────────────────────┐
│                     webapp/  (port 3000)               │
│           Vanilla HTML/CSS/JS  →  API Gateway          │
└─────────────────────────┬──────────────────────────────┘
                          │ HTTP
┌─────────────────────────▼──────────────────────────────┐
│               api-gateway  (port 8080)                  │
│           Spring Cloud Gateway  lb:// routing           │
└──┬──────────────┬──────────────┬──────────────┬─────────┘
   │              │              │              │
   ▼              ▼              ▼              ▼
user-service  menu-service  order-service  kitchen-service
 (8081/MySQL)  (8082/MySQL+GCS) (8083/MySQL)  (8084/MongoDB)

           All services register with ↓
┌───────────────────────────────────────────────────────┐
│           service-registry / Eureka  (port 8761)       │
└───────────────────────────────────────────────────────┘

           All services fetch config from ↓
┌───────────────────────────────────────────────────────┐
│               config-server  (port 8888)               │
│   Serves: platform/config-server/src/main/resources/   │
│           config/<service-name>.yml                    │
└───────────────────────────────────────────────────────┘
```

---

## Folder Structure

```
EnterpriseCloudArchitecture_Final/
├── docker-compose.yml          ← MySQL + MongoDB for local dev
├── ecosystem.config.js         ← PM2 config for GCP VMs
├── init-scripts/
│   └── mysql/
│       └── 00_create_databases.sql
├── platform/
│   ├── config-server/          (port 8888) — Spring Cloud Config
│   ├── service-registry/       (port 8761) — Netflix Eureka
│   └── api-gateway/            (port 8080) — Spring Cloud Gateway
├── services/
│   ├── user-service/           (port 8081) — Auth/Users   [MySQL]
│   ├── menu-service/           (port 8082) — Menu/Items   [MySQL + GCS]
│   ├── order-service/          (port 8083) — Orders       [MySQL]
│   └── kitchen-service/        (port 8084) — Kitchen Queue[MongoDB]
└── webapp/                      (port 3000) — Frontend
```

---

## Quick Start (Local Development)

### Prerequisites

- Java 25, Maven 3.9+
- Docker Desktop
- Node.js 20+ (for `serve`)

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
npm install -g pm2 serve

# Start all services in order
pm2 start ecosystem.config.js
pm2 logs
```

### Step 4 — Open the app

- Frontend: http://localhost:3000
- API Gateway: http://localhost:8080
- Eureka Dashboard:http://localhost:8761
- Config Server: http://localhost:8888

---

## Centralized Configuration

All service configuration lives in:

```
platform/config-server/src/main/resources/config/
├── api-gateway.yml
├── user-service.yml
├── menu-service.yml
├── order-service.yml
└── kitchen-service.yml
```

Each business service's `application.yml` contains only:

```yaml
spring:
  application:
    name: <service-name>
  config:
    import: "optional:configserver:${CONFIG_SERVER_URI:http://localhost:8888}"
```

The Config Server delivers the full configuration at startup.

---

## Environment Variables (GCP Production)

| Variable            | Default                       | Description           |
| ------------------- | ----------------------------- | --------------------- |
| `CONFIG_SERVER_URI` | http://localhost:8888         | URL of Config Server  |
| `EUREKA_URI`        | http://localhost:8761/eureka/ | Eureka endpoint       |
| `MYSQL_HOST`        | localhost                     | MySQL hostname        |
| `MYSQL_USER`        | root                          | MySQL username        |
| `MYSQL_PASSWORD`    | rootpassword                  | MySQL password        |
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
| Framework    | Spring Boot 3.4.3                 |
| Cloud        | Spring Cloud 2024.0.1 (Leyton)    |
| Service Mesh | Netflix Eureka + Spring Gateway   |
| Config       | Spring Cloud Config (native)      |
| DB (SQL)     | MySQL 8.0 via Spring Data JPA     |
| DB (NoSQL)   | MongoDB 7.0 via Spring Data Mongo |
| File Storage | Google Cloud Storage (GCS)        |
| Auth         | JWT (jjwt 0.12.6)                 |
| Process Mgr  | PM2                               |
| Dev DBs      | Docker Compose                    |
