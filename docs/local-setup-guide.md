# Cafeteria System — Local Development Guide

This guide walks you through setting up and running the Enterprise Cloud Architecture project locally using Docker for the databases (PostgreSQL & MongoDB) and PM2/Maven for the microservices.

## 1. Prerequisites

- **Docker & Docker Compose** (for PostgreSQL and MongoDB)
- **Java 25+** (for Spring Boot microservices)
- **Maven** (for building the microservices)
- **Node.js** (for running the Vue 3 frontend web app and PM2)
- **PM2** (Optional but recommended, install via `npm install -g pm2`)

---

## 2. Start the Databases (Docker)

We rely on Docker to spin up our new PostgreSQL instance along with MongoDB.

1. Open your terminal at the root directory of the project (`EnterpriseCloudArchitecture_Final`).
2. Run the following command in the background:
   ```bash
   docker-compose up -d
   ```
3. **Verify Containers**: Check if both databases are running smoothly:
   ```bash
   docker ps
   ```
   You should see `cafeteria-postgresql` (Port 5432) and `cafeteria-mongodb` (Port 27017) running.
   _(Note: The PostgreSQL container uses the initialization script in `init-scripts/postgresql/` to automatically create the `menu_service_db`, `order_service_db`, and `user_service_db`)._

---

## 3. Configuration Server Setup

Before starting the microservices, make sure your centralized configurations are available.

1. Ensure you have pushed the latest config files from `platform/config-server/src/main/resources/configurations/` to your Git repository: `https://github.com/ChamathDilshanC/Cafeteria-System-Configurations.git`
2. If working locally without internet, the Config Server holds a `native` fallback profile which reads directly from your classpath.

---

## 4. Compile the Microservices

Before running, build the `.jar` files for all services to make sure they compile effectively and can be run by PM2.

Run this at the root of your project:

```bash
mvn clean install -DskipTests
```

_(This builds all the Platform and Services components into their respective `target/` folders)._

---

## 5. Start the Backend Microservices (Strict Order)

The startup order is **critical** in microservice architecture because dependent services need to fetch configs and register themselves.

If you are using **PM2** (recommended, as we updated the `ecosystem.config.js` files):

### Step 5.1: Start the Platform Services

1. Navigate to the root directory.
2. Start the `config-server`, `service-registry`, and `api-gateway`:
   ```bash
   pm2 start platform/ecosystem.config.js
   ```
3. **Wait 10-15 seconds** to allow the `config-server` (Port 9000) and `service-registry` (Port 9001) to fully boot up.

### Step 5.2: Start the Business Services

1. After the platform services are up and running, start the actual business microservices:
   ```bash
   pm2 start services/ecosystem.config.js
   ```
   This will start `user-service`, `menu-service`, `order-service`, and `kitchen-service` (2 instances of each).
2. Check logs to ensure they connected to Eureka (`localhost:9001`) and the Config Server (`localhost:9000`):
   ```bash
   pm2 logs
   ```

_(Alternative: If you want to run them manually without PM2, open separate terminals and run `mvn spring-boot:run -Dspring-boot.run.profiles=dev` starting with config-server, then matching the order above)._

---

## 6. Verify Service Registration

Navigate to the Eureka Service Registry dashboard in your browser:

- **URL**: [http://localhost:9001](http://localhost:9001)

You should see `API-GATEWAY`, `USER-SERVICE`, `MENU-SERVICE`, `ORDER-SERVICE`, and `KITCHEN-SERVICE` successfully registered.

---

## 7. Start the Web App (Frontend)

Finally, start the Vue 3 frontend to interact with the system.

1. Open a new terminal and navigate to the `webapp/` folder:
   ```bash
   cd webapp
   ```
2. Install dependencies (if you haven't already):
   ```bash
   npm install
   ```
3. Start the development server:
   ```bash
   npm run dev
   ```
4. Access the application in your browser at [http://localhost:3000](http://localhost:3000). The proxy works entirely through the API Gateway on port `8080`.

---

## 8. Shutting Down

When you are done testing:

1. Stop the frontend (`Ctrl + C` in the webapp terminal).
2. Stop all PM2 services:
   ```bash
   pm2 stop all
   pm2 delete all
   ```
3. Spin down the databases:
   ```bash
   docker-compose down
   ```
