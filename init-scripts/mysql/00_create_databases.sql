-- Auto-run on first MySQL container start.
-- Creates a dedicated schema for each business service.

CREATE DATABASE IF NOT EXISTS user_service_db   CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS menu_service_db   CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS order_service_db  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant the root user (used for local dev) full access to all service DBs.
GRANT ALL PRIVILEGES ON user_service_db.*  TO 'root'@'%';
GRANT ALL PRIVILEGES ON menu_service_db.*  TO 'root'@'%';
GRANT ALL PRIVILEGES ON order_service_db.* TO 'root'@'%';
FLUSH PRIVILEGES;
