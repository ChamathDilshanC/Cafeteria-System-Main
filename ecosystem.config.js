/**
 * PM2 Ecosystem File — Cafeteria Management System
 *
 * Usage (local dev):
 *   pm2 start ecosystem.config.js
 *   pm2 logs
 *   pm2 stop all
 *   pm2 delete all
 *
 * Startup order matters:
 *   1. config-server   (port 9000)
 *   2. service-registry (port 8761)
 *   3. api-gateway     (port 8080)
 *   4. business services (ports 8081-8084)
 *
 * On GCP VMs, override environment variables via the env_production block
 * or supply them through GCP Secret Manager / instance metadata.
 */

module.exports = {
  apps: [
    // ─────────────────────────────────────────────
    // PLATFORM — start these first
    // ─────────────────────────────────────────────
    {
      name: "config-server",
      script: "java",
      args: "-jar platform/config-server/target/config-server-1.0.0.jar",
      watch: false,
      autorestart: true,
      max_restarts: 5,
      min_uptime: "10s",
      env: {
        JAVA_OPTS: "-Xms128m -Xmx256m",
        SPRING_PROFILES_ACTIVE: "git",
      },
      env_production: {
        JAVA_OPTS: "-Xms256m -Xmx512m",
        EUREKA_URI: "http://localhost:8761/eureka/",
      },
    },
    {
      name: "service-registry",
      script: "java",
      args: "-jar platform/service-registry/target/service-registry-1.0.0.jar",
      watch: false,
      autorestart: true,
      max_restarts: 5,
      min_uptime: "10s",
      env: {
        JAVA_OPTS: "-Xms128m -Xmx256m",
        CONFIG_SERVER_URI: "http://localhost:9000",
      },
      env_production: {
        JAVA_OPTS: "-Xms256m -Xmx512m",
        CONFIG_SERVER_URI: "http://localhost:9000",
      },
    },
    {
      name: "api-gateway",
      script: "java",
      args: "-jar platform/api-gateway/target/api-gateway-1.0.0.jar",
      watch: false,
      autorestart: true,
      max_restarts: 5,
      min_uptime: "10s",
      env: {
        JAVA_OPTS: "-Xms128m -Xmx256m",
        CONFIG_SERVER_URI: "http://localhost:9000",
        EUREKA_URI: "http://localhost:8761/eureka/",
      },
      env_production: {
        JAVA_OPTS: "-Xms256m -Xmx512m",
        CONFIG_SERVER_URI: "http://localhost:9000",
        EUREKA_URI: "http://localhost:8761/eureka/",
      },
    },

    // ─────────────────────────────────────────────
    // BUSINESS SERVICES
    // ─────────────────────────────────────────────
    {
      name: "user-service",
      script: "java",
      args: "-jar services/user-service/target/user-service-1.0.0.jar",
      watch: false,
      autorestart: true,
      max_restarts: 5,
      min_uptime: "15s",
      env: {
        JAVA_OPTS: "-Xms128m -Xmx256m",
        CONFIG_SERVER_URI: "http://localhost:9000",
        EUREKA_URI: "http://localhost:8761/eureka/",
        MYSQL_HOST: "localhost",
        MYSQL_USER: "root",
        MYSQL_PASSWORD: "rootpassword",
        JWT_SECRET: "my-super-secret-jwt-key-for-cafeteria-system-dev",
      },
      env_production: {
        JAVA_OPTS: "-Xms256m -Xmx512m",
        // Override from GCP metadata or Secret Manager:
        // MYSQL_HOST, MYSQL_USER, MYSQL_PASSWORD, JWT_SECRET
      },
    },
    {
      name: "menu-service",
      script: "java",
      args: "-jar services/menu-service/target/menu-service-1.0.0.jar",
      watch: false,
      autorestart: true,
      max_restarts: 5,
      min_uptime: "15s",
      env: {
        JAVA_OPTS: "-Xms128m -Xmx256m",
        CONFIG_SERVER_URI: "http://localhost:9000",
        EUREKA_URI: "http://localhost:8761/eureka/",
        MYSQL_HOST: "localhost",
        MYSQL_USER: "root",
        MYSQL_PASSWORD: "rootpassword",
        GCS_BUCKET_NAME: "cafeteria-menu-images",
        GCP_PROJECT_ID: "food-order-management-eca",
        // Path to your GCP service-account key JSON (download from GCP console → IAM → Service Accounts)
        GOOGLE_APPLICATION_CREDENTIALS: "C:/Users/chamm/Desktop/EnterpriseCloudArchitecture_Final/docs/keys/gcs-key.json",
      },
      env_production: {
        JAVA_OPTS: "-Xms256m -Xmx512m",
        // On GCP VMs with Workload Identity the credentials are auto-injected;
        // remove GOOGLE_APPLICATION_CREDENTIALS and leave GCS_BUCKET_NAME / GCP_PROJECT_ID only.
        GCS_BUCKET_NAME: "cafeteria-menu-images",
        GCP_PROJECT_ID: "food-order-management-eca",
      },
    },
    {
      name: "order-service",
      script: "java",
      args: "-jar services/order-service/target/order-service-1.0.0.jar",
      watch: false,
      autorestart: true,
      max_restarts: 5,
      min_uptime: "15s",
      env: {
        JAVA_OPTS: "-Xms128m -Xmx256m",
        CONFIG_SERVER_URI: "http://localhost:9000",
        EUREKA_URI: "http://localhost:8761/eureka/",
        MYSQL_HOST: "localhost",
        MYSQL_USER: "root",
        MYSQL_PASSWORD: "rootpassword",
      },
    },
    {
      name: "kitchen-service",
      script: "java",
      args: "-jar services/kitchen-service/target/kitchen-service-1.0.0.jar",
      watch: false,
      autorestart: true,
      max_restarts: 5,
      min_uptime: "15s",
      env: {
        JAVA_OPTS: "-Xms128m -Xmx256m",
        CONFIG_SERVER_URI: "http://localhost:9000",
        EUREKA_URI: "http://localhost:8761/eureka/",
        MONGO_HOST: "localhost",
        MONGO_USER: "admin",
        MONGO_PASSWORD: "adminpassword",
      },
    },

    // ─────────────────────────────────────────────
    // FRONTEND — Vite Vue 3 app
    // Before first run:  cd webapp && npm install && npm run build
    // Requires:          npm install -g serve
    // ─────────────────────────────────────────────
    {
      name: "webapp",
      script: "serve",
      args: "-s webapp/dist -l 3000",
      watch: false,
      autorestart: true,
      env: {
        NODE_ENV: "production",
        // Override the API gateway URL if your gateway is not on localhost:8080
        // VITE_GATEWAY_URL is baked in at build-time, so rebuild if you change it.
      },
    },
  ],
};
