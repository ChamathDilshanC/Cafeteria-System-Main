# VM Deployment Guide for Cafeteria Management System

## Step 1: SSH into your GCP VM
```bash
# Connect to your VM
gcloud compute ssh your-vm-name --zone=your-zone
```

## Step 2: Install Prerequisites
```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Java 17+ (required for Spring Boot 4.x)
sudo apt install openjdk-17-jdk -y

# Install Maven
sudo apt install maven -y

# Install Git
sudo apt install git -y

# Verify installations
java --version
mvn --version
git --version
```

## Step 3: Clone and Build
```bash
# Create deployment directory
sudo mkdir -p /opt/cafeteria
cd /opt/cafeteria

# Clone main repository
sudo git clone https://github.com/YOUR-USERNAME/EnterpriseCloudArchitecture_Final.git
cd EnterpriseCloudArchitecture_Final

# Set environment variables for production
export CONFIG_PROFILE=git
export CONFIG_REPO_URI=https://github.com/ChamathDilshanC/cafeteria-config-repo.git
export SERVER_HOST=35.198.196.99
export EUREKA_URI=http://35.198.196.99:8761/eureka
```

## Step 4: Build and Run Config Server
```bash
# Navigate to config server
cd platform/config-server

# Build JAR
sudo mvn clean package -DskipTests

# Run Config Server with production settings
nohup java -jar target/config-server-*.jar \
  --spring.profiles.active=git \
  --spring.cloud.config.server.git.uri=https://github.com/ChamathDilshanC/cafeteria-config-repo.git \
  --server.port=8888 \
  --eureka.instance.hostname=35.198.196.99 > config-server.log 2>&1 &
```

## Step 5: Test Config Server Endpoint
```bash
# Wait 30 seconds, then test
sleep 30

# Test config server health
curl http://35.198.196.99:8888/actuator/health

# Test configuration endpoint
curl http://35.198.196.99:8888/service-registry/default

# Check logs
tail -f config-server.log
```

## Step 6: Build and Run Service Registry
```bash
# In new terminal session or use screen
cd ../service-registry

# Build JAR
sudo mvn clean package -DskipTests

# Run Service Registry
nohup java -jar target/service-registry-*.jar \
  --spring.config.import=configserver:http://35.198.196.99:8888 \
  --eureka.instance.hostname=35.198.196.99 \
  --server.port=8761 > service-registry.log 2>&1 &

# Test service registry
sleep 30
curl http://35.198.196.99:8761/eureka/apps
```

## Expected Results:
- ✅ Config Server: http://35.198.196.99:8888/actuator/health
- ✅ Service Registry: http://35.198.196.99:8761
- ✅ Configuration endpoint: http://35.198.196.99:8888/service-registry/default

## Troubleshooting:
```bash
# Check processes
ps aux | grep java

# Check logs
tail -f config-server.log
tail -f service-registry.log

# Check network
netstat -tulpn | grep :8888
netstat -tulpn | grep :8761
```