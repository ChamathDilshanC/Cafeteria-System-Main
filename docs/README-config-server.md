# Config Server - Cafeteria Management System

> Centralized Configuration Management for Microservices Architecture

[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.3-brightgreen.svg)](https://spring.io/projects/spring-boot)
[![Spring Cloud](https://img.shields.io/badge/Spring%20Cloud-2025.1.0-blue.svg)](https://spring.io/projects/spring-cloud)
[![Java](https://img.shields.io/badge/Java-25-orange.svg)](https://openjdk.java.net/)

## 📋 Overview

The Config Server is a centralized configuration management service built with Spring Cloud Config. It provides a single source of truth for all configuration properties across the Cafeteria Management System's microservices architecture.

## 🚀 Features

- **Centralized Configuration**: Manages configuration for all microservices from a single location
- **Native Profile Support**: Uses file system-based configuration storage
- **Hot Reload**: Services can refresh configuration without restart
- **Environment-Specific Config**: Supports development, staging, and production environments
- **Version Control Ready**: Configuration files can be tracked with Git
- **Service Discovery Integration**: Registers with Eureka for discoverability

## 🛠️ Tech Stack

| Technology                         | Version  | Purpose                  |
| ---------------------------------- | -------- | ------------------------ |
| Java                               | 25       | Programming Language     |
| Spring Boot                        | 4.0.3    | Application Framework    |
| Spring Cloud Config Server         | 2025.1.0 | Configuration Management |
| Spring Cloud Netflix Eureka Client | 2025.1.0 | Service Discovery        |
| Maven                              | 3.9+     | Build Tool               |

## 📡 Service Configuration

| Property                | Value                |
| ----------------------- | -------------------- |
| **Service Name**        | `config-server`      |
| **Port**                | `8888`               |
| **Eureka Registration** | Yes                  |
| **Profile**             | `native`             |
| **Config Location**     | `classpath:/config/` |

## 📁 Configuration Structure

```
config-server/
├── src/main/resources/
│   ├── config/
│   │   ├── api-gateway.yml          # API Gateway configuration
│   │   ├── user-service.yml         # User Service configuration
│   │   ├── menu-service.yml         # Menu Service configuration
│   │   ├── order-service.yml        # Order Service configuration
│   │   └── kitchen-service.yml      # Kitchen Service configuration
│   └── application.yml               # Config Server settings
└── pom.xml
```

## 🔧 Configuration Files Managed

### Platform Services

- **api-gateway.yml**: Routes, filters, and gateway-specific settings
  - Defines routes to all business services
  - Configures StripPrefix filters
  - Eureka integration for load balancing

### Business Services

- **user-service.yml**: Database connections, JWT settings
- **menu-service.yml**: Database connections, GCS credentials
- **order-service.yml**: Database connections, Feign client settings
- **kitchen-service.yml**: MongoDB connections, notification settings

## 📦 Installation & Setup

### Prerequisites

- Java 25
- Maven 3.9+
- Port 8888 available

### Build

```bash
mvn clean install
```

### Run Locally

```bash
mvn spring-boot:run
```

### Run with Custom Profile

```bash
mvn spring-boot:run -Dspring-boot.run.arguments=--spring.profiles.active=native
```

## 🌐 API Endpoints

### Health Check

```http
GET http://localhost:8888/actuator/health
```

### Retrieve Configuration

```http
GET http://localhost:8888/{service-name}/{profile}
```

**Examples:**

```bash
# Get user-service configuration (default profile)
curl http://localhost:8888/user-service/default

# Get menu-service configuration (production profile)
curl http://localhost:8888/menu-service/production
```

## 🔗 Service Discovery

The Config Server registers itself with Eureka Service Registry at:

```
http://localhost:8761
```

Other services discover the Config Server through Eureka using:

```yaml
spring:
  config:
    import: optional:configserver:http://localhost:8888
```

## 🔑 Key Configuration Properties

### application.yml (Config Server)

```yaml
server:
  port: 8888

spring:
  application:
    name: config-server
  cloud:
    config:
      server:
        native:
          search-locations: classpath:/config/
  profiles:
    active: native

eureka:
  client:
    service-url:
      defaultZone: http://localhost:8761/eureka/
```

## 🐳 Docker Deployment

### Build Docker Image

```bash
mvn spring-boot:build-image
```

### Run with Docker

```bash
docker run -p 8888:8888 -e EUREKA_URI=http://service-registry:8761/eureka config-server:latest
```

## ☁️ Cloud Deployment (GCP)

### Environment Variables

```bash
export CONFIG_SERVER_URI=http://config-server:8888
export EUREKA_URI=http://service-registry:8761/eureka
```

### Using PM2

```bash
pm2 start ecosystem.config.js --only config-server
```

## 🔒 Security Considerations

### Production Recommendations

1. **Enable Basic Authentication**

   ```yaml
   spring:
     security:
       user:
         name: config-admin
         password: ${CONFIG_PASSWORD}
   ```

2. **Use HTTPS**: Enable SSL/TLS for secure communication
3. **Encrypt Sensitive Properties**: Use Spring Cloud Config encryption
4. **Restrict Access**: Implement network-level security

## 📊 Monitoring

### Actuator Endpoints

```bash
# Health check
curl http://localhost:8888/actuator/health

# Environment properties
curl http://localhost:8888/actuator/env
```

## 🧪 Testing

### Run Tests

```bash
mvn test
```

### Test Configuration Retrieval

```bash
# Test if config server is serving configurations
curl http://localhost:8888/user-service/default | jq .
```

## 🔄 Configuration Refresh

Services can refresh their configuration without restart:

```bash
# Trigger refresh on a service
curl -X POST http://localhost:8081/actuator/refresh
```

## 📝 Adding New Configuration

1. Create a new YAML file in `src/main/resources/config/`

   ```bash
   touch src/main/resources/config/notification-service.yml
   ```

2. Add configuration properties:

   ```yaml
   spring:
     datasource:
       url: jdbc:mysql://localhost:3306/notifications
   ```

3. Restart Config Server or ensure file watching is enabled

4. Services will pick up the new configuration on startup or refresh

## 🤝 Integration with Other Services

### Service Discovery Flow

```
1. Config Server starts on port 8888
2. Config Server registers with Eureka (8761)
3. Other services discover Config Server via Eureka
4. Services fetch their configuration from Config Server
5. Services register themselves with Eureka
```

### Service Dependencies

```
config-server
    ↓ (optional, recommends)
service-registry (Eureka)
    ↓ (recommended for discovery)
All microservices
```

## 🐛 Troubleshooting

### Config Server Not Starting

```bash
# Check if port 8888 is in use
netstat -an | grep 8888

# Check logs
tail -f logs/config-server.log
```

### Services Can't Fetch Configuration

1. Verify Config Server is running: `curl http://localhost:8888/actuator/health`
2. Check service configuration has correct URI:
   ```yaml
   spring:
     config:
       import: optional:configserver:http://localhost:8888
   ```
3. Verify config files exist in `classpath:/config/`

### Configuration Not Updating

1. Ensure file has correct naming: `{service-name}.yml`
2. Restart Config Server
3. Trigger refresh on consuming service: `POST /actuator/refresh`

## 📚 Additional Resources

- [Spring Cloud Config Documentation](https://docs.spring.io/spring-cloud-config/docs/current/reference/html/)
- [Spring Boot Actuator](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html)
- [Eureka Service Discovery](https://spring.io/guides/gs/service-registration-and-discovery/)

## 📄 License

This project is part of the ITS 2130 Enterprise Cloud Architecture course final project.

## 👥 Contributing

This is an academic project. For questions or suggestions, please contact the development team.

---

**Part of**: [Cafeteria Management System](../README.md)
**Service Type**: Platform Service
**Maintained By**: ITS 2130 Project Team
