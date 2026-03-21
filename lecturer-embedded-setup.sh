#!/bin/bash

# Lecturer's Approach: Embedded Git Config Server + VM Deployment
# This script sets up embedded config repository and deploys to VM

echo "🎯 Lecturer's Embedded Git Approach - VM Deployment"
echo "=================================================="

# Step 1: Setup embedded config repository
echo "📁 Setting up embedded configuration repository..."

# Change to config server directory
cd platform/config-server

# Create embedded config-repo directory
mkdir -p config-repo
cd config-repo

# Initialize git repository
git init
git config user.email "config-server@cafeteria.com"
git config user.name "Config Server"

# Create directory structure
mkdir -p platform services

# Create configurations
echo "📝 Creating embedded configurations..."

# Platform configurations with lecturer's ports
cat > platform/config-server.yaml << 'EOF'
spring:
  application:
    name: config-server

server:
  port: 9000

eureka:
  client:
    service-url:
      default-zone: http://localhost:9001/eureka/
  instance:
    prefer-ip-address: true

management:
  endpoints:
    web:
      exposure:
        include: health,info,env,refresh
EOF

cat > platform/service-registry.yaml << 'EOF'
spring:
  application:
    name: service-registry

server:
  port: 9001

eureka:
  instance:
    hostname: localhost
    prefer-ip-address: false
  client:
    register-with-eureka: false
    fetch-registry: false
    service-url:
      default-zone: http://localhost:9001/eureka/
  server:
    wait-time-in-ms-when-sync-empty: 0
    enable-self-preservation: false

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,env,eureka
EOF

cat > platform/api-gateway.yaml << 'EOF'
spring:
  application:
    name: api-gateway

server:
  port: 7000

spring:
  cloud:
    gateway:
      server:
        webflux:
          routes:
            - id: user-service
              uri: lb://USER-SERVICE
              predicates:
                - Path=/api/auth/**, /api/users/**
              filters:
                - StripPrefix=1
            - id: menu-service
              uri: lb://MENU-SERVICE
              predicates:
                - Path=/api/menu/**, /api/categories/**
              filters:
                - StripPrefix=1

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,gateway
EOF

# Service configurations
cat > services/user-service.yaml << 'EOF'
spring:
  application:
    name: user-service
  datasource:
    url: jdbc:mysql://localhost:3306/user_service_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC
    username: root
    password: rootpassword
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: update
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect

server:
  port: 8081
EOF

cat > services/menu-service.yaml << 'EOF'
spring:
  application:
    name: menu-service
  datasource:
    url: jdbc:mysql://localhost:3306/menu_service_db?createDatabaseIfNotExist=true&useSSL=false&serverTimezone=UTC
    username: root
    password: rootpassword
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: update
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQL8Dialect

server:
  port: 8082
EOF

# Base application config
cat > application.yaml << 'EOF'
eureka:
  client:
    service-url:
      default-zone: http://localhost:9001/eureka
  instance:
    prefer-ip-address: true

management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics
EOF

# Commit configurations
echo "💾 Committing to embedded git..."
git add .
git commit -m "Initial embedded config setup - Lecturer's approach"

# Return to config server directory
cd ..

echo "✅ Embedded Git Repository Created!"
echo "📍 Location: platform/config-server/config-repo"
echo "🔗 URI: file://\${user.dir}/config-repo"
echo ""
echo "🚀 VM Deployment Commands:"
echo "=========================="
echo "# 1. Build config server"
echo "cd platform/config-server"
echo "mvn clean package -DskipTests"
echo ""
echo "# 2. Run config server with embedded git"
echo "java -jar target/config-server-*.jar"
echo ""
echo "# 3. Test endpoint"
echo "curl http://35.198.196.99:9000/service-registry/default"
echo ""
echo "✅ Ready for VM deployment!"