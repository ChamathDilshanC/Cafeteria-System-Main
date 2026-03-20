# Local Development Guide

Cafeteria Management System — ITS 2130 Final Project

---

## 1. Prerequisites

Install all tools before proceeding. Versions listed are the ones the project was 7built against.

| Tool           | Required Version          | Download                                        |
| -------------- | ------------------------- | ----------------------------------------------- |
| Java (JDK)     | 25                        | https://jdk.java.net/25/                        |
| Apache Maven   | 3.9+                      | https://maven.apache.org/download.cgi           |
| Docker Desktop | Latest stable             | https://www.docker.com/products/docker-desktop/ |
| Node.js        | 20 LTS or 22 LTS          | https://nodejs.org/                             |
| PM2            | Latest (`npm i -g pm2`)   | —                                               |
| serve          | Latest (`npm i -g serve`) | —                                               |

**Verify your installs:**

```bash
java -version        # should show 25.x
mvn -version         # should show 3.9.x
docker -version      # should show 27.x or later
node -version        # should show v20.x or v22.x
pm2 -v               # should show 5.x
```

> **Windows note:** All paths in this guide use forward slashes. PowerShell and Git Bash both accept them.

---

## 2. Database & Infrastructure Setup

### 2.1 Start MySQL and MongoDB with Docker

From the project root:

```bash
docker compose up -d
```

This starts two containers:

| Container           | Image     | Port  | Credentials           |
| ------------------- | --------- | ----- | --------------------- |
| `cafeteria-mysql`   | mysql:8.0 | 3306  | root / rootpassword   |
| `cafeteria-mongodb` | mongo:7.0 | 27017 | admin / adminpassword |

Wait ~15 seconds for both containers to pass their health checks:

```bash
docker compose ps
# Both STATUS columns should read "healthy" before continuing
```

### 2.2 Database Initialization

MySQL databases are created automatically on first start by the init script at:

```
init-scripts/mysql/00_create_databases.sql
```

This script creates three schemas:

- `user_service_db`
- `menu_service_db`
- `order_service_db`

> Hibernate's `ddl-auto: update` creates the tables inside each schema on first service startup. You do **not** need to run any additional SQL manually.

MongoDB requires no initialization — the `kitchen_service_db` database and `kitchen_tickets` collection are created automatically when kitchen-service writes its first document.

### 2.3 Confirm Containers Are Healthy

```bash
# Check MySQL
docker exec cafeteria-mysql mysqladmin ping -u root -prootpassword

# Check MongoDB
docker exec cafeteria-mongodb mongosh --quiet --eval "db.adminCommand('ping')"
```

Both should return `mysqld is alive` and `{ ok: 1 }` respectively.

---

## 3. Build All Services

Run from the project root. This compiles all 7 Spring Boot modules and packages them as executable JARs.

**Linux / macOS / Git Bash:**

```bash
chmod +x build-all.sh
./build-all.sh
```

**Windows CMD / PowerShell:**

```bat
build-all.bat
```

After the build each service will have a JAR at:

```
platform/config-server/target/config-server-1.0.0.jar
platform/service-registry/target/service-registry-1.0.0.jar
platform/api-gateway/target/api-gateway-1.0.0.jar
services/user-service/target/user-service-1.0.0.jar
services/menu-service/target/menu-service-1.0.0.jar
services/order-service/target/order-service-1.0.0.jar
services/kitchen-service/target/kitchen-service-1.0.0.jar
```

---

## 4. Backend Execution Order — CRITICAL

Services depend on each other at startup. Starting them out of order will cause `Connection refused` or `Eureka not available` errors. Follow this exact sequence.

```
[1] config-server  →  [2] service-registry  →  [3] api-gateway  →  [4] business services
     port 8888              port 8761               port 8080           ports 8081-8084
```

### 4.1 Manual Start (One Terminal Per Service)

Open seven terminal windows and run each command from the project root.

**Terminal 1 — Config Server**

```bash
java -jar platform/config-server/target/config-server-1.0.0.jar
```

Wait until you see:

```
Started ConfigServerApplication in X.XXX seconds
```

Verify it is healthy before continuing:

```bash
curl http://localhost:8888/actuator/health
# Expected: {"status":"UP"}
```

**Terminal 2 — Service Registry (Eureka)**

```bash
java -jar platform/service-registry/target/service-registry-1.0.0.jar \
  --spring.config.import=optional:configserver:http://localhost:8888
```

Wait for:

```
Started ServiceRegistryApplication in X.XXX seconds
```

Open the Eureka dashboard to confirm it is running:

```
http://localhost:8761
```

**Terminal 3 — API Gateway**

```bash
java -jar platform/api-gateway/target/api-gateway-1.0.0.jar \
  --spring.config.import=optional:configserver:http://localhost:8888
```

**Terminal 4 — User Service**

```bash
java -DMYSQL_HOST=localhost -DMYSQL_USER=root -DMYSQL_PASSWORD=rootpassword \
  -DJWT_SECRET=my-super-secret-jwt-key-for-cafeteria-system-dev \
  -jar services/user-service/target/user-service-1.0.0.jar \
  --spring.config.import=optional:configserver:http://localhost:8888
```

**Terminal 5 — Menu Service**

```bash
java -DMYSQL_HOST=localhost -DMYSQL_USER=root -DMYSQL_PASSWORD=rootpassword \
  -DGCS_BUCKET_NAME=cafeteria-menu-images \
  -DGCP_PROJECT_ID=food-order-management-eca \
  -DGOOGLE_APPLICATION_CREDENTIALS="C:/Users/chamm/Desktop/EnterpriseCloudArchitecture_Final/docs/keys/gcs-key.json" \
  -jar services/menu-service/target/menu-service-1.0.0.jar \
  --spring.config.import=optional:configserver:http://localhost:8888
```

**Terminal 6 — Order Service**

```bash
java -DMYSQL_HOST=localhost -DMYSQL_USER=root -DMYSQL_PASSWORD=rootpassword \
  -jar services/order-service/target/order-service-1.0.0.jar \
  --spring.config.import=optional:configserver:http://localhost:8888
```

**Terminal 7 — Kitchen Service**

```bash
java -DMONGO_HOST=localhost -DMONGO_USER=admin -DMONGO_PASSWORD=adminpassword \
  -jar services/kitchen-service/target/kitchen-service-1.0.0.jar \
  --spring.config.import=optional:configserver:http://localhost:8888
```

### 4.2 Confirm All Services Registered with Eureka

After all seven terminals are running, open:

```
http://localhost:8761
```

You should see these instances listed under **"Instances currently registered with Eureka"**:

- `API-GATEWAY`
- `USER-SERVICE`
- `MENU-SERVICE`
- `ORDER-SERVICE`
- `KITCHEN-SERVICE`

Allow up to 30 seconds for all instances to register — Eureka has a heartbeat delay by default.

---

## 5. GCS Credentials & Bucket Setup

Before testing the menu image upload you must:
1. Have valid GCS credentials (service account key)
2. Have the GCS bucket configured for public read access

### 5.0 Make Bucket Publicly Readable

Menu images are served **directly from GCS to the browser** — the bucket must allow public reads.

1. Go to [GCS Console](https://console.cloud.google.com) → Cloud Storage → `cafeteria-menu-images` → **Permissions**
2. If **"Public access prevention"** is enabled → click **"Remove public access prevention"** and confirm
3. Click **"Grant access"** → Principal: `allUsers` → Role: **Storage Object Viewer** → Save

> Without this step, menu images will fail to load in the browser with a CORS/blocked error.

### 5.1 Check the Key File Exists

```bash
# Should print the file path — if not, the path is wrong
ls "C:/Users/chamm/Desktop/EnterpriseCloudArchitecture_Final/docs/keys/gcs-key.json"
```

### 5.2 Validate the Key Format

The file must be a valid service-account JSON. Check that it contains these top-level keys:

```bash
# Linux / macOS / Git Bash
grep -o '"type"\|"project_id"\|"client_email"' \
  "C:/Users/chamm/Desktop/EnterpriseCloudArchitecture_Final/docs/keys/gcs-key.json"
```

Expected output (three matches):

```
"type"
"project_id"
"client_email"
```

### 5.3 Verify the Environment Variable Is Picked Up by Java

When starting menu-service manually (Section 4.1 Terminal 5), pass the path as a JVM system property **and** as an environment variable. Both are shown in the command above.

Alternatively, export it in your shell session before running:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="C:/Users/chamm/Desktop/EnterpriseCloudArchitecture_Final/docs/keys/gcs-key.json"
```

### 5.4 Quick GCS Write Test (Optional)

Use the Google Cloud SDK to confirm the service account can write to the bucket:

```bash
# Install gcloud CLI first if you haven't: https://cloud.google.com/sdk/docs/install
gcloud auth activate-service-account \
  --key-file="C:/Users/chamm/Desktop/EnterpriseCloudArchitecture_Final/docs/keys/gcs-key.json"

echo "test" | gsutil cp - gs://cafeteria-menu-images/test-write.txt
# Expected: Copying... / Operation completed
gsutil rm gs://cafeteria-menu-images/test-write.txt
```

---

## 6. Build & Run the Frontend

```bash
cd webapp

# Install dependencies (first time only)
npm install

# Development mode — hot reload
npm run dev
# App is live at http://localhost:3000

# --- OR for a production-like build ---
npm run build
# Creates webapp/dist/
# Then serve it:
npx serve -s dist -l 3000
```

---

## 7. Running Everything with PM2 (Local Simulation)

PM2 lets you manage all processes as a single ecosystem, just like a GCP VM deployment.

### 7.1 Prerequisites

```bash
npm install -g pm2 serve
```

### 7.2 Build JARs and Frontend First

PM2 runs the pre-built JARs and the `dist/` folder — it does **not** build them.

```bash
# Build all Java JARs
./build-all.sh

# Build the Vue frontend
cd webapp && npm install && npm run build && cd ..
```

### 7.3 Start the Ecosystem

```bash
pm2 start ecosystem.config.js
```

PM2 will start all 8 processes (7 Java services + webapp). Output:

```
┌────┬──────────────────┬─────────┬────────┬──────┬────────┐
│ id │ name             │ status  │ cpu    │ mem  │ uptime │
├────┼──────────────────┼─────────┼────────┼──────┼────────┤
│  0 │ config-server    │ online  │ 0%     │ ...  │ Xs     │
│  1 │ service-registry │ online  │ 0%     │ ...  │ Xs     │
│  2 │ api-gateway      │ online  │ 0%     │ ...  │ Xs     │
│  3 │ user-service     │ online  │ 0%     │ ...  │ Xs     │
│  4 │ menu-service     │ online  │ 0%     │ ...  │ Xs     │
│  5 │ order-service    │ online  │ 0%     │ ...  │ Xs     │
│  6 │ kitchen-service  │ online  │ 0%     │ ...  │ Xs     │
│  7 │ webapp           │ online  │ 0%     │ ...  │ Xs     │
└────┴──────────────────┴─────────┴────────┴──────┴────────┘
```

> **Startup delay:** config-server needs ~10s to be ready before service-registry can import its config. If service-registry shows `errored` immediately, PM2 will auto-restart it — it will stabilize within 30–60 seconds.

### 7.4 Monitor in Real Time

```bash
# Interactive process monitor (CPU, memory, logs per process)
pm2 monit

# Tail all logs combined
pm2 logs

# Tail a specific service
pm2 logs menu-service
pm2 logs user-service --lines 50

# List all processes and their status
pm2 list
```

### 7.5 Useful PM2 Commands

```bash
pm2 restart config-server     # Restart a single service after a JAR rebuild
pm2 restart all               # Restart every process
pm2 stop all                  # Stop everything (keep processes in list)
pm2 delete all                # Remove all processes from PM2
pm2 save                      # Persist process list to survive reboots
pm2 startup                   # Generate the OS startup command
```

---

## 8. API Testing with curl

All requests go through the API Gateway at `http://localhost:8080`.

### 8.1 Register a New User

```bash
curl -s -X POST http://localhost:8080/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Alice Student",
    "email": "alice@cafeteria.local",
    "password": "secret123",
    "role": "CUSTOMER"
  }' | jq .
```

**Expected response:**

```json
{
  "token": "eyJhbGci...",
  "type": "Bearer",
  "id": 1,
  "name": "Alice Student",
  "email": "alice@cafeteria.local",
  "role": "CUSTOMER"
}
```

Save the token for subsequent requests:

```bash
TOKEN="eyJhbGci..."   # paste your token here
```

### 8.2 Log In

```bash
curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "alice@cafeteria.local", "password": "secret123"}' | jq .
```

### 8.3 Create a Category (no auth required for GET; POST is open in current config)

```bash
curl -s -X POST http://localhost:8080/api/categories \
  -H "Content-Type: application/json" \
  -d '{"name": "Main Course", "description": "Rice and noodle dishes"}' | jq .
```

### 8.4 Create a Menu Item (with image upload)

```bash
# Without image
curl -s -X POST http://localhost:8080/api/menu \
  -F 'data={"name":"Nasi Lemak","description":"Coconut rice with sambal","price":8.50,"categoryId":1,"available":true};type=application/json' \
  -H "Authorization: Bearer $TOKEN" | jq .

# With image file
curl -s -X POST http://localhost:8080/api/menu \
  -F 'data={"name":"Nasi Lemak","description":"Coconut rice","price":8.50,"categoryId":1};type=application/json' \
  -F 'image=@/path/to/nasi-lemak.jpg' \
  -H "Authorization: Bearer $TOKEN" | jq .
```

### 8.5 Fetch the Menu

```bash
# All available items
curl -s http://localhost:8080/api/menu \
  -H "Authorization: Bearer $TOKEN" | jq .

# Filtered by category ID
curl -s "http://localhost:8080/api/menu?categoryId=1" \
  -H "Authorization: Bearer $TOKEN" | jq .

# All categories
curl -s http://localhost:8080/api/categories \
  -H "Authorization: Bearer $TOKEN" | jq .
```

### 8.6 Place an Order

```bash
curl -s -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "items": [
      {"menuItemId": 1, "quantity": 2},
      {"menuItemId": 2, "quantity": 1}
    ],
    "notes": "Less spicy please"
  }' | jq .
```

**Expected response** includes the order ID, status `CONFIRMED`, paymentStatus `UNPAID`, and a kitchen ticket is automatically created.

### 8.7 Pay for an Order

> **Payment method:** This system uses **cash-only payments**. Customers pay at the counter, then click **"Mark as Paid"** in the app to confirm.

```bash
# Replace 1 with your actual order ID
curl -s -X PUT http://localhost:8080/api/orders/1/pay \
  -H "Authorization: Bearer $TOKEN" | jq .
```

### 8.8 View My Orders

```bash
curl -s http://localhost:8080/api/orders/my \
  -H "Authorization: Bearer $TOKEN" | jq .
```

### 8.9 View Kitchen Queue (Staff)

```bash
# Register a STAFF user first, then login to get a STAFF token
STAFF_TOKEN="eyJhbGci..."

curl -s http://localhost:8080/api/kitchen/queue \
  -H "Authorization: Bearer $STAFF_TOKEN" | jq .
```

### 8.10 Update Kitchen Ticket Status

```bash
# Replace TICKET_ID with the MongoDB ObjectId string from the queue response
TICKET_ID="665f2a..."

curl -s -X PUT "http://localhost:8080/api/kitchen/tickets/$TICKET_ID/status" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $STAFF_TOKEN" \
  -d '{"status": "PREPARING"}' | jq .
```

Valid status transitions: `PENDING` → `PREPARING` → `READY` → `COMPLETED`

> **Order sync:** When kitchen-service updates a ticket status, it automatically calls order-service via Feign to keep the customer's order status in sync. This means: if staff marks a ticket `CANCELLED` in the kitchen, the customer's order will also show `CANCELLED` (and `REFUNDED` if already paid).

---

## 9. Troubleshooting

### Service fails to start with "Connection refused to config-server"

**Cause:** config-server is not yet ready when the service starts.

**Fix:** Wait for config-server health before starting other services. With PM2, the auto-restart will handle this, but you may need to wait 30–60 seconds. You can also restart the failing service manually:

```bash
pm2 restart service-registry
```

### Service not appearing in Eureka dashboard

**Cause 1:** Service started before config-server was healthy — it fetched no Eureka URL.
**Fix:** `pm2 restart <service-name>`

**Cause 2:** The service crashed on startup — check the logs.

```bash
pm2 logs user-service --lines 100
```

**Cause 3:** Eureka self-preservation mode is throttling registrations (rare in dev).
**Fix:** Wait 90 seconds. Self-preservation is disabled in the current config (`enable-self-preservation: false`).

### MySQL connection timeout (user-service / menu-service / order-service)

**Cause:** Docker container is not healthy yet, or the database schema does not exist.

**Fix 1:** Confirm containers are running and healthy:

```bash
docker compose ps
docker compose logs mysql --tail 20
```

**Fix 2:** Confirm the init script ran:

```bash
docker exec cafeteria-mysql mysql -uroot -prootpassword \
  -e "SHOW DATABASES;" | grep service_db
```

Expected output:

```
menu_service_db
order_service_db
user_service_db
```

**Fix 3:** If the init script did not run (volume already existed from a previous start), drop and recreate the volume:

```bash
docker compose down -v     # WARNING: deletes all data
docker compose up -d
```

### MongoDB authentication failure (kitchen-service)

**Cause:** Wrong username or password in the connection URI.

Check the running config:

```bash
pm2 env kitchen-service | grep MONGO
```

Confirm the credentials match `docker-compose.yml` (`admin` / `adminpassword`).

### GCS upload fails with "Could not load credentials"

**Cause:** `GOOGLE_APPLICATION_CREDENTIALS` points to a non-existent or malformed file.

**Fix 1:** Verify the path:

```bash
ls -la "C:/Users/chamm/Desktop/EnterpriseCloudArchitecture_Final/docs/keys/gcs-key.json"
```

**Fix 2:** Validate the JSON:

```bash
python -m json.tool \
  "C:/Users/chamm/Desktop/EnterpriseCloudArchitecture_Final/docs/keys/gcs-key.json" \
  > /dev/null && echo "Valid JSON" || echo "INVALID JSON"
```

**Fix 3:** Verify the service account has the **Storage Object Admin** role in your GCP project:

```
GCP Console → IAM & Admin → IAM → find the service account email → check roles
```

### API Gateway returns 503 or "no healthy upstream"

**Cause:** The downstream service (e.g., `menu-service`) is not registered in Eureka yet, or it crashed.

**Fix:**

1. Check Eureka: `http://localhost:8761` — is the service visible?
2. Check the service logs: `pm2 logs menu-service`
3. Restart if needed: `pm2 restart menu-service`

### Multipart upload rejected with "Maximum upload size exceeded"

**Cause:** File larger than 10 MB was uploaded.

**Fix:** The limit is configured in `menu-service.yml`:

```yaml
spring.servlet.multipart.max-file-size: 10MB
```

Resize the image before uploading, or increase the limit and rebuild/restart config-server + menu-service.

### Frontend shows CORS errors in the browser console

**Cause:** CORS is handled exclusively by the API Gateway (`CorsConfig.java` bean). Backend services must NOT add their own CORS headers.

**Current setup (correct):**
- API Gateway adds `Access-Control-Allow-Origin` via `CorsWebFilter` for `http://localhost:3000` and `http://localhost:3001`
- User-service has CORS **disabled** in `SecurityConfig` (`.cors(cors -> cors.disable())`)
- `api-gateway.yml` does **not** have a `corsConfigurations` block (removed to avoid duplicate headers)

**Fix if CORS errors appear:** Confirm the frontend origin is in `CorsConfig.java`:

```java
corsConfiguration.setAllowedOrigins(List.of("http://localhost:3000", "http://localhost:3001"));
```

Rebuild and restart api-gateway:

```bash
cd platform/api-gateway && mvn clean package -DskipTests && cd ../..
pm2 restart api-gateway
```

---

## 10. Port Quick Reference

| Service          | Port  | URL                                     |
| ---------------- | ----- | --------------------------------------- |
| config-server    | 8888  | http://localhost:8888/actuator/health   |
| service-registry | 8761  | http://localhost:8761 (Eureka UI)       |
| api-gateway      | 8080  | http://localhost:8080 (all API traffic) |
| user-service     | 8081  | http://localhost:8081/actuator/health   |
| menu-service     | 8082  | http://localhost:8082/actuator/health   |
| order-service    | 8083  | http://localhost:8083/actuator/health   |
| kitchen-service  | 8084  | http://localhost:8084/actuator/health   |
| webapp           | 3000  | http://localhost:3000                   |
| MySQL            | 3306  | —                                       |
| MongoDB          | 27017 | —                                       |
