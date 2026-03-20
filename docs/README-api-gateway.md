# API Gateway - Cafeteria Management System

> Spring Cloud Gateway-based API Gateway with Dynamic Routing and Load Balancing

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.3-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-2025.1.0-blue.svg)](https://spring.io/projects/spring-cloud)
[![Java](https://img.shields.io/badge/Java-25-orange.svg)](https://openjdk.java.net/)

## 📋 Overview

The API Gateway serves as the single entry point for all client requests to the Cafeteria Management System. Built with Spring Cloud Gateway (WebFlux), it provides intelligent routing, load balancing, security filtering, and request transformation for all backend microservices.

## 🚀 Features

- **Unified Entry Point**: Single access point for all microservices
- **Dynamic Routing**: Routes requests to appropriate services via Eureka service discovery
- **Load Balancing**: Client-side load balancing with `lb://` URI scheme
- **Path Rewriting**: Strips `/api` prefix before forwarding to services
- **CORS Support**: Configurable Cross-Origin Resource Sharing
- **Rate Limiting**: Protects services from abuse (configurable)
- **Circuit Breaker**: Resilience patterns for fault tolerance
- **Request/Response Filters**: Pre and post-processing of requests
- **WebFlux-based**: Non-blocking reactive architecture

## 🛠️ Tech Stack

| Technology                          | Version  | Purpose                   |
| ----------------------------------- | -------- | ------------------------- |
| Java                                | 25       | Programming Language      |
| Spring Boot                         | 4.0.3    | Application Framework     |
| Spring Cloud Gateway Server WebFlux | 2025.1.0 | API Gateway Framework     |
| Spring Cloud Netflix Eureka Client  | 2025.1.0 | Service Discovery         |
| Spring Cloud Config Client          | 2025.1.0 | Centralized Configuration |
| Maven                               | 3.9+     | Build Tool                |

## 📡 Service Configuration

| Property                | Value                   |
| ----------------------- | ----------------------- |
| **Service Name**        | `api-gateway`           |
| **Port**                | `8080`                  |
| **Base Path**           | `/api`                  |
| **Eureka Registration** | Yes                     |
| **Config Server**       | `http://localhost:8888` |

## 🌐 API Routes

The API Gateway intelligently routes requests to backend services using the following mapping:

| Route Path           | Target Service  | Service Port | Description                      |
| -------------------- | --------------- | ------------ | -------------------------------- |
| `/api/auth/**`       | user-service    | 8081         | Authentication & User Management |
| `/api/users/**`      | user-service    | 8081         | User CRUD Operations             |
| `/api/menu/**`       | menu-service    | 8082         | Menu & Food Items                |
| `/api/categories/**` | menu-service    | 8082         | Food Categories                  |
| `/api/orders/**`     | order-service   | 8083         | Order Management                 |
| `/api/cart/**`       | order-service   | 8083         | Shopping Cart                    |
| `/api/kitchen/**`    | kitchen-service | 8084         | Kitchen Operations               |
| `/api/queue/**`      | kitchen-service | 8084         | Order Queue Management           |

## 📦 Installation & Setup

### Prerequisites

- Java 25
- Maven 3.9+
- Port 8080 available
- Config Server running on port 8888
- Service Registry running on port 8761

### Build

```bash
mvn clean install
```

### Run Locally

```bash
mvn spring-boot:run
```

### Run with Profile

```bash
mvn spring-boot:run -Dspring-boot.run.arguments=--spring.profiles.active=development
```

## 🔧 Configuration

### application.yml (Local)

```yaml
server:
  port: 8080

spring:
  application:
    name: api-gateway
  config:
    import: optional:configserver:http://localhost:8888

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

### api-gateway.yml (Config Server)

The gateway configuration is centralized in the Config Server:

```yaml
spring:
  cloud:
    gateway:
      server:
        webflux:
          routes:
            # User Service Routes
            - id: user-service-auth
              uri: lb://user-service
              predicates:
                - Path=/api/auth/**
              filters:
                - StripPrefix=1

            - id: user-service-users
              uri: lb://user-service
              predicates:
                - Path=/api/users/**
              filters:
                - StripPrefix=1

            # Menu Service Routes
            - id: menu-service-menu
              uri: lb://menu-service
              predicates:
                - Path=/api/menu/**
              filters:
                - StripPrefix=1

            - id: menu-service-categories
              uri: lb://menu-service
              predicates:
                - Path=/api/categories/**
              filters:
                - StripPrefix=1

            # Order Service Routes
            - id: order-service-orders
              uri: lb://order-service
              predicates:
                - Path=/api/orders/**
              filters:
                - StripPrefix=1

            - id: order-service-cart
              uri: lb://order-service
              predicates:
                - Path=/api/cart/**
              filters:
                - StripPrefix=1

            # Kitchen Service Routes
            - id: kitchen-service-kitchen
              uri: lb://kitchen-service
              predicates:
                - Path=/api/kitchen/**
              filters:
                - StripPrefix=1

            - id: kitchen-service-queue
              uri: lb://kitchen-service
              predicates:
                - Path=/api/queue/**
              filters:
                - StripPrefix=1

      globalcors:
        corsConfigurations:
          "[/**]":
            allowedOrigins: "*"
            allowedMethods:
              - GET
              - POST
              - PUT
              - DELETE
              - PATCH
            allowedHeaders: "*"
```

## 🔀 Routing Logic

### How Routing Works

1. **Client Request**: Client sends request to `http://localhost:8080/api/users/123`

2. **Gateway Receives**: API Gateway receives the request

3. **Route Matching**: Gateway matches the path `/api/users/**` to the `user-service-users` route

4. **Service Discovery**: Gateway queries Eureka to find available instances of `user-service`

5. **Load Balancing**: If multiple instances exist, gateway load-balances the request

6. **Path Transformation**: `StripPrefix=1` filter removes `/api`, transforming the path to `/users/123`

7. **Forward Request**: Gateway forwards to `http://user-service-instance:8081/users/123`

8. **Return Response**: Service response is returned to the client through the gateway

### Route Flow Diagram

```
Client Request
    ↓
┌─────────────────────────┐
│   http://localhost:8080 │
│   /api/users/123        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│     API Gateway         │
│   - Match Route         │
│   - Query Eureka        │
│   - Load Balance        │
│   - Strip Prefix        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  Service Discovery      │
│  (Eureka)               │
│  Find: user-service     │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│  User Service           │
│  GET /users/123         │
│  (Port 8081)            │
└───────────┬─────────────┘
            │
            ▼
      Return Response
```

## 🌐 Testing Routes

### Health Check

```bash
curl http://localhost:8080/actuator/health
```

### Test User Service Route

```bash
# Login (via API Gateway)
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "user@example.com", "password": "password123"}'

# Get User
curl http://localhost:8080/api/users/1 \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

### Test Menu Service Route

```bash
# Get all menu items
curl http://localhost:8080/api/menu/items

# Get menu categories
curl http://localhost:8080/api/categories
```

### Test Order Service Route

```bash
# Create order
curl -X POST http://localhost:8080/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -d '{"items": [{"menuItemId": 1, "quantity": 2}]}'

# Get order status
curl http://localhost:8080/api/orders/123 \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

### Test Kitchen Service Route

```bash
# Get kitchen queue
curl http://localhost:8080/api/kitchen/queue \
  -H "Authorization: Bearer <JWT_TOKEN>"

# Update order status
curl -X PATCH http://localhost:8080/api/kitchen/orders/123/status \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -d '{"status": "PREPARING"}'
```

## 🔐 Security & Filters

### Global Filters (Future Enhancement)

```java
@Component
public class AuthenticationFilter implements GlobalFilter, Ordered {

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        ServerHttpRequest request = exchange.getRequest();

        // Skip authentication for public endpoints
        if (isPublicEndpoint(request.getPath().toString())) {
            return chain.filter(exchange);
        }

        // Validate JWT token
        String token = extractToken(request);
        if (token == null || !isValidToken(token)) {
            exchange.getResponse().setStatusCode(HttpStatus.UNAUTHORIZED);
            return exchange.getResponse().setComplete();
        }

        // Add user info to headers
        ServerHttpRequest modifiedRequest = request.mutate()
            .header("X-User-Id", extractUserId(token))
            .build();

        return chain.filter(exchange.mutate().request(modifiedRequest).build());
    }

    @Override
    public int getOrder() {
        return -100; // Execute before routing
    }
}
```

### Rate Limiting (Future Enhancement)

```yaml
spring:
  cloud:
    gateway:
      server:
        webflux:
          routes:
            - id: user-service-rate-limited
              uri: lb://user-service
              predicates:
                - Path=/api/users/**
              filters:
                - name: RequestRateLimiter
                  args:
                    redis-rate-limiter.replenishRate: 10
                    redis-rate-limiter.burstCapacity: 20
```

## 🐳 Docker Deployment

### Dockerfile

```dockerfile
FROM eclipse-temurin:25-jdk-alpine
WORKDIR /app
COPY target/api-gateway-1.0.0.jar app.jar
EXPOSE 8080
ENV CONFIG_SERVER_URI=http://config-server:8888
ENV EUREKA_URI=http://service-registry:8761/eureka
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Docker Compose Integration

```yaml
api-gateway:
  build: ./platform/api-gateway
  ports:
    - "8080:8080"
  depends_on:
    - config-server
    - service-registry
  environment:
    - SPRING_CONFIG_IMPORT=optional:configserver:http://config-server:8888
    - EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE=http://service-registry:8761/eureka/
```

## ☁️ Cloud Deployment (GCP)

### Environment Variables

```bash
export SPRING_CONFIG_IMPORT=optional:configserver:http://${CONFIG_SERVER_IP}:8888
export EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE=http://${EUREKA_IP}:8761/eureka/
```

### PM2 Configuration

```javascript
{
  name: 'api-gateway',
  script: 'java',
  args: ['-jar', 'platform/api-gateway/target/api-gateway-1.0.0.jar'],
  env: {
    SERVER_PORT: 8080,
    SPRING_CONFIG_IMPORT: 'optional:configserver:http://config-server:8888',
    EUREKA_CLIENT_SERVICE_URL_DEFAULTZONE: 'http://service-registry:8761/eureka/'
  }
}
```

## 📊 Monitoring

### Gateway Metrics

```bash
# View gateway routes
curl http://localhost:8080/actuator/gateway/routes

# View specific route details
curl http://localhost:8080/actuator/gateway/routes/user-service-users

# View global filters
curl http://localhost:8080/actuator/gateway/globalfilters
```

### Route Refresh

```bash
# Refresh routes dynamically
curl -X POST http://localhost:8080/actuator/gateway/refresh
```

## 🧪 Testing

### Run Tests

```bash
mvn test
```

### Integration Tests

```bash
mvn verify -Pintegration-tests
```

## 🐛 Troubleshooting

### Route Not Working

**Symptoms**: 404 Not Found when accessing through gateway

**Solutions**:

1. Check route configuration in Config Server
2. Verify target service is registered with Eureka:
   ```bash
   curl http://localhost:8761/eureka/apps
   ```
3. Check gateway routes:
   ```bash
   curl http://localhost:8080/actuator/gateway/routes
   ```
4. Verify StripPrefix filter is configured correctly

### Service Discovery Issues

**Symptoms**: 503 Service Unavailable

**Solutions**:

1. Ensure Eureka is running:
   ```bash
   curl http://localhost:8761/actuator/health
   ```
2. Check if target service is registered
3. Verify `lb://` prefix in URI configuration
4. Check gateway logs for discovery errors

### CORS Errors

**Symptoms**: Browser blocks requests due to CORS

**Solutions**:

1. Verify CORS configuration in api-gateway.yml
2. Ensure `allowedOrigins` includes your frontend URL
3. Check `allowedMethods` includes required HTTP methods

## 📚 Additional Resources

- [Spring Cloud Gateway Documentation](https://docs.spring.io/spring-cloud-gateway/docs/current/reference/html/)
- [API Gateway Pattern](https://microservices.io/patterns/apigateway.html)
- [WebFlux Documentation](https://docs.spring.io/spring-framework/docs/current/reference/html/web-reactive.html)

## 🔗 Service Dependencies

```
┌──────────────────┐
│   Config Server  │ (8888)
└────────┬─────────┘
         │
         ▼
┌──────────────────┐      ┌──────────────────┐
│   API Gateway    │◄─────┤ Service Registry │ (8761)
│     (8080)       │      └──────────────────┘
└────────┬─────────┘
         │
         ├──────────────┬──────────────┬──────────────┐
         ▼              ▼              ▼              ▼
    user-service   menu-service   order-service  kitchen-service
      (8081)         (8082)         (8083)         (8084)
```

## 📄 License

This project is part of the ITS 2130 Enterprise Cloud Architecture course final project.

---

**Part of**: [Cafeteria Management System](../README.md)
**Service Type**: Platform Service (API Gateway)
**Maintained By**: ITS 2130 Project Team
