# Order Service - Cafeteria Management System

> Order Processing & Management with Inter-Service Communication

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.3-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-2025.1.0-blue.svg)](https://spring.io/projects/spring-cloud)
[![Java](https://img.shields.io/badge/Java-25-orange.svg)](https://openjdk.java.net/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-blue.svg)](https://www.mysql.com/)

## 📋 Overview

The Order Service manages the complete order lifecycle in the Cafeteria Management System, from creating orders to tracking fulfillment. It orchestrates communication between User Service, Menu Service, and Kitchen Service using OpenFeign for inter-service calls.

## 🚀 Features

- **Order Creation**: Create orders with multiple menu items
- **Shopping Cart**: Temporary cart management before checkout
- **Order Validation**: Validates menu items, prices, and user authentication
- **Order Tracking**: Real-time order status updates
- **Order History**: View past orders by user
- **Payment Integration Ready**: Placeholder for payment processing
- **Inter-Service Communication**: OpenFeign clients for User and Menu services
- **Order Status Workflow**: PENDING → CONFIRMED → PREPARING → READY → COMPLETED → CANCELLED
- **Service Discovery**: Registered with Eureka for discoverability

## 🛠️ Tech Stack

| Technology                         | Version  | Purpose                     |
| ---------------------------------- | -------- | --------------------------- |
| Java                               | 25       | Programming Language        |
| Spring Boot                        | 4.0.3    | Application Framework       |
| Spring Cloud Config Client         | 2025.1.0 | Centralized Configuration   |
| Spring Cloud Netflix Eureka Client | 2025.1.0 | Service Discovery           |
| Spring Cloud OpenFeign             | 2025.1.0 | Inter-Service Communication |
| Spring Data JPA                    | 4.0.3    | Database Access Layer       |
| MySQL                              | 8.0      | Relational Database         |
| Maven                              | 3.9+     | Build Tool                  |

## 📡 Service Configuration

| Property                | Value                      |
| ----------------------- | -------------------------- |
| **Service Name**        | `order-service`            |
| **Port**                | `8083`                     |
| **Database**            | MySQL                      |
| **Database Name**       | `cafeteria_orders`         |
| **Feign Clients**       | user-service, menu-service |
| **Eureka Registration** | Yes                        |
| **Config Server**       | `http://localhost:8888`    |

## 💾 Database Schema

### Orders Table

```sql
CREATE TABLE orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(20) UNIQUE NOT NULL,
    user_id BIGINT NOT NULL,
    user_email VARCHAR(255),
    user_name VARCHAR(255),
    total_amount DECIMAL(10, 2) NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'PREPARING', 'READY', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    payment_status ENUM('PENDING', 'PAID', 'FAILED', 'REFUNDED') DEFAULT 'PENDING',
    payment_method VARCHAR(50),
    notes TEXT,
    estimated_ready_time TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_order_number (order_number),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Order Items Table

```sql
CREATE TABLE order_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    order_id BIGINT NOT NULL,
    menu_item_id BIGINT NOT NULL,
    menu_item_name VARCHAR(255) NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10, 2) NOT NULL,
    subtotal DECIMAL(10, 2) NOT NULL,
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    INDEX idx_order_id (order_id),
    INDEX idx_menu_item_id (menu_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

## 📊 Order Status Workflow

```
┌─────────┐
│ PENDING │  ← Order created, awaiting confirmation
└────┬────┘
     │
     ▼
┌───────────┐
│ CONFIRMED │  ← Payment processed, sent to kitchen
└────┬──────┘
     │
     ▼
┌───────────┐
│ PREPARING │  ← Kitchen is preparing the order
└────┬──────┘
     │
     ▼
┌──────┐
│ READY │  ← Order ready for pickup
└────┬─┘
     │
     ▼
┌───────────┐
│ COMPLETED │  ← Order picked up by customer
└───────────┘

     OR
     │
     ▼
┌───────────┐
│ CANCELLED │  ← Order cancelled by user or system
└───────────┘
```

## 📦 Installation & Setup

### Prerequisites

- Java 25
- Maven 3.9+
- MySQL 8.0
- Port 8083 available
- User Service running on port 8081
- Menu Service running on port 8082
- Config Server running on port 8888
- Service Registry running on port 8761

### Database Setup

```bash
# Create database
mysql -u root -p
CREATE DATABASE cafeteria_orders CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# Run initialization script
mysql -u root -p cafeteria_orders < init-scripts/mysql/03_create_orders_tables.sql
```

### Build

```bash
mvn clean install
```

### Run Locally

```bash
mvn spring-boot:run
```

## 🔧 Configuration

### application.yml (Local)

```yaml
server:
  port: 8083

spring:
  application:
    name: order-service
  config:
    import: optional:configserver:http://localhost:8888

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/

# OpenFeign Configuration
feign:
  client:
    config:
      default:
        connectTimeout: 5000
        readTimeout: 5000
```

### order-service.yml (Config Server)

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/cafeteria_orders?useSSL=false&serverTimezone=UTC
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:root}
    driver-class-name: com.mysql.cj.jdbc.Driver

  jpa:
    hibernate:
      ddl-auto: update
    show-sql: true
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect

# Feign Client Configuration
feign:
  client:
    config:
      user-service:
        connectTimeout: 5000
        readTimeout: 5000
        loggerLevel: basic
      menu-service:
        connectTimeout: 5000
        readTimeout: 5000
        loggerLevel: basic
```

## 🔗 OpenFeign Inter-Service Communication

### User Service Client

```java
@FeignClient(name = "user-service")
public interface UserServiceClient {

    @GetMapping("/users/{id}")
    UserDto getUserById(@PathVariable("id") Long id);

    @GetMapping("/users/email/{email}")
    UserDto getUserByEmail(@PathVariable("email") String email);
}
```

### Menu Service Client

```java
@FeignClient(name = "menu-service")
public interface MenuServiceClient {

    @GetMapping("/menu/items/{id}")
    MenuItemDto getMenuItem(@PathVariable("id") Long id);

    @GetMapping("/menu/items")
    List<MenuItemDto> getMenuItems(@RequestParam List<Long> ids);

    @GetMapping("/menu/items/{id}/availability")
    Boolean checkAvailability(@PathVariable("id") Long id);
}
```

### Service Communication Flow

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │ POST /api/orders
       ▼
┌─────────────────┐
│ Order Service   │
└────┬───┬───┬────┘
     │   │   │
     │   │   └──────────────┐
     │   │                  │
     │   │ Feign Call       │ Feign Call
     │   ▼                  ▼
     │ ┌──────────────┐  ┌──────────────┐
     │ │ User Service │  │ Menu Service │
     │ │ (validate    │  │ (get items,  │
     │ │  user)       │  │  prices)     │
     │ └──────────────┘  └──────────────┘
     │
     │ Create Order
     ▼
┌─────────────────┐
│  MySQL Database │
└─────────────────┘
```

## 🌐 API Endpoints

### Order Endpoints

#### Create Order

```http
POST /orders
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "userId": 1,
  "items": [
    {
      "menuItemId": 5,
      "quantity": 2,
      "specialInstructions": "No onions"
    },
    {
      "menuItemId": 12,
      "quantity": 1
    }
  ],
  "paymentMethod": "CREDIT_CARD",
  "notes": "Extra napkins please"
}
```

**Response:**

```json
{
  "id": 123,
  "orderNumber": "ORD-20260318-123",
  "userId": 1,
  "userEmail": "user@example.com",
  "userName": "John Doe",
  "items": [
    {
      "menuItemId": 5,
      "menuItemName": "Chicken Burger",
      "quantity": 2,
      "unitPrice": 8.99,
      "subtotal": 17.98
    },
    {
      "menuItemId": 12,
      "menuItemName": "Coca Cola",
      "quantity": 1,
      "unitPrice": 2.5,
      "subtotal": 2.5
    }
  ],
  "totalAmount": 20.48,
  "status": "PENDING",
  "paymentStatus": "PENDING",
  "estimatedReadyTime": "2026-03-18T13:30:00Z",
  "createdAt": "2026-03-18T13:00:00Z"
}
```

#### Get Order by ID

```http
GET /orders/{id}
Authorization: Bearer <JWT_TOKEN>
```

#### Get Order by Order Number

```http
GET /orders/number/{orderNumber}
Authorization: Bearer <JWT_TOKEN>
```

#### Get User Orders

```http
GET /orders/user/{userId}?page=0&size=20&status=COMPLETED
Authorization: Bearer <JWT_TOKEN>
```

**Response:**

```json
{
  "content": [
    {
      "id": 123,
      "orderNumber": "ORD-20260318-123",
      "totalAmount": 20.48,
      "status": "COMPLETED",
      "itemCount": 3,
      "createdAt": "2026-03-18T13:00:00Z"
    }
  ],
  "totalElements": 15,
  "totalPages": 1
}
```

#### Update Order Status (Kitchen/Admin)

```http
PATCH /orders/{id}/status
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "status": "PREPARING"
}
```

#### Cancel Order

```http
DELETE /orders/{id}
Authorization: Bearer <JWT_TOKEN>
```

### Shopping Cart Endpoints (Optional Feature)

#### Add to Cart

```http
POST /cart/items
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "menuItemId": 5,
  "quantity": 2
}
```

#### Get Cart

```http
GET /cart
Authorization: Bearer <JWT_TOKEN>
```

#### Checkout Cart

```http
POST /cart/checkout
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json

{
  "paymentMethod": "CREDIT_CARD",
  "notes": "Extra napkins"
}
```

## 🧪 Testing

### cURL Examples

#### Create Order

```bash
TOKEN="your-jwt-token"
curl -X POST http://localhost:8080/api/orders \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "userId": 1,
    "items": [
      {"menuItemId": 5, "quantity": 2},
      {"menuItemId": 12, "quantity": 1}
    ],
    "paymentMethod": "CREDIT_CARD"
  }'
```

#### Get User Orders

```bash
curl http://localhost:8080/api/orders/user/1 \
  -H "Authorization: Bearer $TOKEN"
```

#### Update Order Status

```bash
curl -X PATCH http://localhost:8080/api/orders/123/status \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "READY"}'
```

### Unit Tests

```bash
mvn test
```

### Integration Tests with Feign

```bash
mvn verify -Pintegration-tests
```

## 🐳 Docker Deployment

### Dockerfile

```dockerfile
FROM eclipse-temurin:25-jdk-alpine
WORKDIR /app
COPY target/order-service-1.0.0.jar app.jar
EXPOSE 8083
ENV DB_HOST=mysql
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Docker Compose

```yaml
order-service:
  build: ./services/order-service
  ports:
    - "8083:8083"
  depends_on:
    - mysql
    - config-server
    - service-registry
    - user-service
    - menu-service
  environment:
    - SPRING_DATASOURCE_URL=jdbc:mysql://mysql:3306/cafeteria_orders
    - EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE=http://service-registry:8761/eureka/
```

## ☁️ Cloud Deployment (GCP)

### Environment Variables

```bash
export SPRING_DATASOURCE_URL=jdbc:mysql://${DB_IP}:3306/cafeteria_orders
export SPRING_DATASOURCE_USERNAME=${DB_USER}
export SPRING_DATASOURCE_PASSWORD=${DB_PASSWORD}
export EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE=http://${EUREKA_IP}:8761/eureka/
```

### PM2 Configuration

```javascript
{
  name: 'order-service',
  script: 'java',
  args: ['-jar', 'services/order-service/target/order-service-1.0.0.jar'],
  env: {
    SERVER_PORT: 8083,
    SPRING_DATASOURCE_URL: 'jdbc:mysql://mysql-instance:3306/cafeteria_orders'
  }
}
```

## 📊 Monitoring

### Health Check

```bash
curl http://localhost:8083/actuator/health
```

### Feign Client Metrics

```bash
# View Feign client metrics
curl http://localhost:8083/actuator/metrics/feign.client

# Circuit breaker status (if Resilience4j is configured)
curl http://localhost:8083/actuator/circuitbreakers
```

## 🐛 Troubleshooting

### Feign Client Issues

**Issue**: Service Not Found

```
com.netflix.client.ClientException: Load balancer does not have available server for client: user-service
```

**Solutions:**

1. Verify target service is running
2. Check Eureka registration:
   ```bash
   curl http://localhost:8761/eureka/apps/user-service
   ```
3. Verify Feign client name matches Eureka service name

**Issue**: Connection Timeout

```
feign.RetryableException: Read timed out
```

**Solutions:**

1. Increase timeout in configuration:
   ```yaml
   feign:
     client:
       config:
         default:
           connectTimeout: 10000
           readTimeout: 10000
   ```
2. Check target service health

### Order Creation Failures

**Issue**: Menu item not found

**Solution**: Verify menu-service is running and item exists:

```bash
curl http://localhost:8080/api/menu/items/5
```

**Issue**: Invalid user

**Solution**: Verify user-service is running and user exists:

```bash
curl http://localhost:8080/api/users/1 -H "Authorization: Bearer $TOKEN"
```

## 📚 Additional Resources

- [Spring Cloud OpenFeign Documentation](https://docs.spring.io/spring-cloud-openfeign/docs/current/reference/html/)
- [Microservice Communication Patterns](https://microservices.io/patterns/communication-style/messaging.html)
- [Circuit Breaker Pattern](https://martinfowler.com/bliki/CircuitBreaker.html)

## 🔗 Service Integration

### Calls (Outbound)

- **User Service** (via Feign): Validate user, fetch user details
- **Menu Service** (via Feign): Validate menu items, fetch prices

### Called By (Inbound)

- **API Gateway**: Routes `/api/orders/**` and `/api/cart/**`
- **Kitchen Service**: Queries order details

### Database Dependencies

- **MySQL**: Order and order item persistence

### Service Discovery

- **Registers with**: Eureka Service Registry (8761)
- **Fetches config from**: Config Server (8888)
- **Discovers**: user-service, menu-service via Eureka

## 📄 License

This project is part of the ITS 2130 Enterprise Cloud Architecture course final project.

---

**Part of**: [Cafeteria Management System](../README.md)
**Service Type**: Business Service (Order Management)
**Maintained By**: ITS 2130 Project Team
