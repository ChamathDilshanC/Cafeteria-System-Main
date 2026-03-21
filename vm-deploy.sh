#!/bin/bash

# Cafeteria Management System - VM Deployment Script
# Run this script on your GCP VM

echo "🚀 Deploying Cafeteria Management System to VM..."

# Set production environment variables
export CONFIG_PROFILE=git
export CONFIG_REPO_URI=https://github.com/ChamathDilshanC/cafeteria-config-repo.git
export CONFIG_LABEL=main
export EUREKA_URI=http://35.198.196.99:8761/eureka

# VM Network Configuration
export SERVER_HOST=35.198.196.99
export CONFIG_SERVER_PORT=8888
export EUREKA_SERVER_PORT=8761
export GATEWAY_PORT=8080

# Java Options
export JAVA_OPTS="-Xmx512m -Xms256m -server"

echo "📁 Step 1: Clone repositories..."
cd /opt/
sudo git clone https://github.com/YOUR-USERNAME/EnterpriseCloudArchitecture_Final.git cafeteria-system
cd cafeteria-system

echo "🔧 Step 2: Build Config Server..."
cd platform/config-server
sudo ./mvnw clean package -DskipTests

echo "🔧 Step 3: Build Service Registry..."
cd ../service-registry
sudo ./mvnw clean package -DskipTests

echo "🔧 Step 4: Build API Gateway..."
cd ../api-gateway
sudo ./mvnw clean package -DskipTests

echo "🚀 Step 5: Start services..."

# Start Config Server
echo "Starting Config Server on port 8888..."
cd ../config-server
nohup java $JAVA_OPTS \
  -DCONFIG_PROFILE=$CONFIG_PROFILE \
  -DCONFIG_REPO_URI=$CONFIG_REPO_URI \
  -jar target/config-server-*.jar > config-server.log 2>&1 &

echo "⏳ Waiting for Config Server to start..."
sleep 30

# Start Service Registry
echo "Starting Service Registry on port 8761..."
cd ../service-registry
nohup java $JAVA_OPTS \
  -DEUREKA_HOST=$SERVER_HOST \
  -DCONFIG_SERVER_URI=http://$SERVER_HOST:$CONFIG_SERVER_PORT \
  -jar target/service-registry-*.jar > service-registry.log 2>&1 &

echo "⏳ Waiting for Service Registry to start..."
sleep 30

# Start API Gateway
echo "Starting API Gateway on port 8080..."
cd ../api-gateway
nohup java $JAVA_OPTS \
  -DGATEWAY_PORT=$GATEWAY_PORT \
  -DCONFIG_SERVER_URI=http://$SERVER_HOST:$CONFIG_SERVER_PORT \
  -jar target/api-gateway-*.jar > api-gateway.log 2>&1 &

echo "✅ Deployment Complete!"
echo "🔗 Config Server: http://$SERVER_HOST:8888"
echo "🔗 Service Registry: http://$SERVER_HOST:8761"
echo "🔗 API Gateway: http://$SERVER_HOST:8080"

echo "📋 Test endpoints:"
echo "curl http://35.198.196.99:8888/service-registry/default"
echo "curl http://35.198.196.99:8888/actuator/health"