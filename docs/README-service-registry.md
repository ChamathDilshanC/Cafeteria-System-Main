# Service Registry (Eureka Server) - Cafeteria Management System

> Netflix Eureka-based Service Discovery for Microservices Architecture

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.3-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-2025.1.0-blue.svg)](https://spring.io/projects/spring-cloud)
[![Java](https://img.shields.io/badge/Java-25-orange.svg)](https://openjdk.java.net/)

## 📋 Overview

The Service Registry is a Netflix Eureka Server implementation that provides service discovery and registration capabilities for the Cafeteria Management System's microservices architecture. It acts as a central registry where all microservices register themselves and discover other services.

## 🚀 Features

- **Service Registration**: Automatic registration of all microservices
- **Service Discovery**: Enables services to find and communicate with each other
- **Health Monitoring**: Tracks the health status of registered services
- **Load Balancing**: Provides client-side load balancing information
- **High Availability**: Supports multiple Eureka instances for redundancy
- **Dashboard UI**: Built-in web dashboard to monitor registered services
- **Self-Preservation Mode**: Protects against network partition failures

## 🛠️ Tech Stack

| Technology                         | Version  | Purpose                  |
| ---------------------------------- | -------- | ------------------------ |
| Java                               | 25       | Programming Language     |
| Spring Boot                        | 4.0.3    | Application Framework    |
| Spring Cloud Netflix Eureka Server | 2025.1.0 | Service Discovery Server |
| Maven                              | 3.9+     | Build Tool               |

## 📡 Service Configuration

| Property                 | Value                   |
| ------------------------ | ----------------------- |
| **Service Name**         | `service-registry`      |
| **Port**                 | `8761`                  |
| **Dashboard URL**        | `http://localhost:8761` |
| **Register with itself** | No (standalone mode)    |
| **Fetch Registry**       | No (server mode)        |

## 🌐 Eureka Dashboard

Access the Eureka Dashboard to view all registered services:

```
http://localhost:8761
```

The dashboard displays:

- List of registered services (instances)
- Service health status
- Lease renewal information
- General server information
- Instance metadata

## 📦 Installation & Setup

### Prerequisites

- Java 25
- Maven 3.9+
- Port 8761 available

### Build

```bash
mvn clean install
```

### Run Locally

```bash
mvn spring-boot:run
```

### Run as JAR

```bash
java -jar target/service-registry-1.0.0.jar
```

## 🔧 Configuration

### application.yml

```yaml
server:
  port: 8761

spring:
  application:
    name: service-registry

eureka:
  instance:
    hostname: localhost
  client:
    register-with-eureka: false # Don't register with itself
    fetch-registry: false # Server doesn't need to fetch registry
    service-url:
      defaultZone: http://${eureka.instance.hostname}:${server.port}/eureka/
  server:
    enable-self-preservation: true # Protects against network issues
```

## 🔗 Service Registration

### How Services Register

All microservices in the Cafeteria System register with Eureka by including:

**1. Dependency in pom.xml:**

```xml
<dependency>
    <groupId>org.springframework.cloud</groupId>
    <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
</dependency>
```

**2. Annotation in Application class:**

```java
@SpringBootApplication
@EnableDiscoveryClient
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}
```

**3. Configuration in application.yml:**

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
  instance:
    prefer-ip-address: true
```

## 📊 Registered Services

The following services register with this Eureka Server:

| Service Name        | Port | Type     | Description                      |
| ------------------- | ---- | -------- | -------------------------------- |
| **config-server**   | 8888 | Platform | Configuration Management         |
| **api-gateway**     | 8080 | Platform | API Gateway & Routing            |
| **user-service**    | 8081 | Business | User Authentication & Management |
| **menu-service**    | 8082 | Business | Menu & Food Item Management      |
| **order-service**   | 8083 | Business | Order Processing                 |
| **kitchen-service** | 8084 | Business | Kitchen Operations               |

## 🔍 Service Discovery Flow

```
┌─────────────────┐
│  Service Start  │
└────────┬────────┘
         │
         ▼
┌─────────────────────────┐
│  Register with Eureka   │
│  (POST /eureka/apps/)   │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Send Heartbeats        │
│  (Every 30 seconds)     │
└────────┬────────────────┘
         │
         ▼
┌─────────────────────────┐
│  Fetch Registry         │
│  (Discover other svcs)  │
└─────────────────────────┘
```

## 🌐 API Endpoints

### Get All Registered Services

```http
GET http://localhost:8761/eureka/apps
Accept: application/json
```

### Get Specific Service

```http
GET http://localhost:8761/eureka/apps/{SERVICE-NAME}
Accept: application/json
```

**Example:**

```bash
curl http://localhost:8761/eureka/apps/user-service
```

### Service Instance Information

```http
GET http://localhost:8761/eureka/apps/{SERVICE-NAME}/{INSTANCE-ID}
```

### Health Check

```http
GET http://localhost:8761/actuator/health
```

## 🔄 Load Balancing

Services discover each other through Eureka and use client-side load balancing:

### In API Gateway (Spring Cloud Gateway)

```yaml
spring:
  cloud:
    gateway:
      server:
        webflux:
          routes:
            - id: user-service
              uri: lb://user-service # lb:// prefix for load balancing
              predicates:
                - Path=/api/users/**
```

### In Order Service (OpenFeign)

```java
@FeignClient(name = "user-service")  // Discovers via Eureka
public interface UserServiceClient {
    @GetMapping("/users/{id}")
    User getUserById(@PathVariable Long id);
}
```

## 🐳 Docker Deployment

### Dockerfile

```dockerfile
FROM eclipse-temurin:25-jdk-alpine
WORKDIR /app
COPY target/service-registry-1.0.0.jar app.jar
EXPOSE 8761
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Build & Run

```bash
docker build -t cafeteria/service-registry:latest .
docker run -p 8761:8761 cafeteria/service-registry:latest
```

## ☁️ Cloud Deployment (GCP)

### Environment Variables

```bash
export EUREKA_HOST=0.0.0.0
export EUREKA_PORT=8761
export EUREKA_URI=http://${EXTERNAL_IP}:8761/eureka/
```

### Using PM2

```bash
pm2 start ecosystem.config.js --only service-registry
```

### GCP VM Setup

1. Open firewall port 8761
2. Set external IP as hostname
3. Update all services to use external Eureka URI

## 🔒 Security Considerations

### Production Recommendations

1. **Enable Basic Authentication**

   ```yaml
   spring:
     security:
       user:
         name: eureka-admin
         password: ${EUREKA_PASSWORD}
   ```

2. **Secure Communication**
   - Use HTTPS for Eureka server
   - Configure SSL certificates
   - Enable mTLS between services

3. **Network Security**
   - Restrict access to internal network
   - Use VPC/Private subnets
   - Configure firewall rules

## 📊 Monitoring & Health

### Self-Preservation Mode

Eureka's self-preservation mode protects against network partitions:

```yaml
eureka:
  server:
    enable-self-preservation: true
    eviction-interval-timer-in-ms: 60000
```

**When enabled:**

- Eureka stops evicting instances during network issues
- Prevents cascade failures
- Warning message appears in dashboard

### Metrics

```bash
# Check number of registered instances
curl http://localhost:8761/actuator/metrics/eureka.server.numOfInstancesRegistered

# View all available metrics
curl http://localhost:8761/actuator/metrics
```

## 🧪 Testing

### Run Tests

```bash
mvn test
```

### Test Service Registration

```bash
# Start Eureka Server
mvn spring-boot:run

# In another terminal, check if Eureka is running
curl http://localhost:8761/actuator/health

# Expected response
{
  "status": "UP"
}
```

## 🐛 Troubleshooting

### Service Not Showing in Dashboard

**Possible causes:**

1. Service not configured with Eureka client dependency
2. Wrong Eureka server URL in service configuration
3. Service failed to start
4. Network connectivity issues

**Solutions:**

```bash
# Check Eureka server logs
tail -f logs/service-registry.log

# Verify service is trying to register
# Look for logs like: "DiscoveryClient_SERVICE-NAME - registration status: 204"

# Check network connectivity
curl http://localhost:8761/eureka/apps
```

### Port Already in Use

```bash
# Find process using port 8761
netstat -ano | findstr :8761     # Windows
lsof -i :8761                     # Linux/Mac

# Kill the process or use a different port
```

### Self-Preservation Mode Triggered

**Symptoms:** Warning in Eureka dashboard

**Causes:** Too many services failing heartbeats

**Solutions:**

1. Check network stability
2. Verify service health
3. Adjust renewal threshold if needed:
   ```yaml
   eureka:
     server:
       renewal-percent-threshold: 0.85
   ```

## 🔧 Advanced Configuration

### High Availability Setup

For production, run multiple Eureka instances:

**Eureka Server 1:**

```yaml
eureka:
  client:
    service-url:
      defaultZone: http://eureka2:8762/eureka/
```

**Eureka Server 2:**

```yaml
server:
  port: 8762

eureka:
  client:
    service-url:
      defaultZone: http://eureka1:8761/eureka/
```

### Custom Instance Metadata

```yaml
eureka:
  instance:
    metadata-map:
      zone: us-central1-a
      version: 1.0.0
      environment: production
```

## 📚 Additional Resources

- [Netflix Eureka Documentation](https://github.com/Netflix/eureka/wiki)
- [Spring Cloud Netflix](https://spring.io/projects/spring-cloud-netflix)
- [Service Discovery Patterns](https://microservices.io/patterns/service-registry.html)

## 🔗 Integration Architecture

```
┌──────────────┐
│   Clients    │
└──────┬───────┘
       │
       ▼
┌──────────────┐      ┌──────────────────┐
│ API Gateway  │◄─────┤ Service Registry │
└──────┬───────┘      └────────▲─────────┘
       │                       │
       ├───────────────────────┼─────┐
       │                       │     │
       ▼                       │     │
┌──────────────┐              │     │
│ User Service │──────────────┘     │
└──────────────┘                    │
       ▼                             │
┌──────────────┐                    │
│ Menu Service │────────────────────┘
└──────────────┘
       ▼
┌──────────────┐
│Order Service │
└──────────────┘
       ▼
┌──────────────┐
│Kitchen Svc   │
└──────────────┘
```

## 📄 License

This project is part of the ITS 2130 Enterprise Cloud Architecture course final project.

---

**Part of**: [Cafeteria Management System](../README.md)
**Service Type**: Platform Service (Service Discovery)
**Maintained By**: ITS 2130 Project Team
