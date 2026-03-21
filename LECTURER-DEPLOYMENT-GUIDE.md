# Lecturer's Embedded Git Approach - VM Deployment Guide

## Overview
Lecturer ගේ approach එකේදී Config Server එකේ **ඇතුළේම** Git repository එකක් තියෙනවා.
External GitHub dependency නෑ - සියල්ල self-contained.

## Port Structure (Lecturer's Standard)
- **Config Server**: 9000 (instead of 8888)
- **Service Registry**: 9001 (instead of 8761)
- **API Gateway**: 7000 (instead of 8080)

## Step 1: Setup Embedded Config Repository

### Local Setup (Before VM):
```bash
# Run the embedded setup script
chmod +x lecturer-embedded-setup.sh
./lecturer-embedded-setup.sh
```

මේක කරන්නේ:
- Config Server ඇතුළේ `config-repo/` directory එකක් හදනවා
- ඒකේ Git repository එකක් initialize කරනවා
- Platform/Services configurations commit කරනවා

## Step 2: VM Deployment

### SSH into VM:
```bash
gcloud compute ssh your-vm-name --zone=your-zone
```

### Install Prerequisites:
```bash
sudo apt update
sudo apt install openjdk-17-jdk maven git -y
```

### Clone and Setup:
```bash
cd /opt
sudo git clone https://github.com/YOUR-USERNAME/EnterpriseCloudArchitecture_Final.git
cd EnterpriseCloudArchitecture_Final

# Setup embedded config repo (if not already done)
chmod +x lecturer-embedded-setup.sh
sudo ./lecturer-embedded-setup.sh
```

### Build and Run Config Server:
```bash
cd platform/config-server

# Build JAR
sudo mvn clean package -DskipTests

# Run with embedded git
sudo java -jar target/config-server-*.jar
```

## Step 3: Test Config Server

### Health Check:
```bash
curl http://35.198.196.99:9000/actuator/health
```

### Configuration Endpoint:
```bash
curl http://35.198.196.99:9000/service-registry/default
```

**Expected Response:**
```json
{
  "name": "service-registry",
  "profiles": ["default"],
  "label": "main",
  "version": "embedded-repo-commit-hash",
  "state": null,
  "propertySources": [
    {
      "name": "file://config-repo/platform/service-registry.yaml",
      "source": {
        "spring.application.name": "service-registry",
        "server.port": 9001,
        "eureka.instance.hostname": "localhost",
        ...
      }
    }
  ]
}
```

## Step 4: Run Service Registry

```bash
# In new terminal/screen session
cd platform/service-registry

# Build
sudo mvn clean package -DskipTests

# Run
sudo java -jar target/service-registry-*.jar
```

**Test Service Registry:**
```bash
curl http://35.198.196.99:9001/eureka/apps
```

## Step 5: Run API Gateway

```bash
# In new terminal/screen session
cd platform/api-gateway

# Build
sudo mvn clean package -DskipTests

# Run
sudo java -jar target/api-gateway-*.jar
```

**Test API Gateway:**
```bash
curl http://35.198.196.99:7000/actuator/health
```

## Advantages of Lecturer's Approach:

✅ **Self-contained**: No external GitHub dependencies
✅ **Embedded**: Git repo inside config server
✅ **Simple**: Single JAR deployment
✅ **Fast**: No network calls to GitHub
✅ **Portable**: Runs anywhere with Java

## Key Differences from External Git:

| Feature | External Git | Embedded Git (Lecturer) |
|---------|--------------|--------------------------|
| Repository | GitHub | Internal file system |
| Dependencies | GitHub API | None |
| Updates | Git push/pull | Direct file changes |
| Portability | Network dependent | Fully portable |

## Troubleshooting:

### Config Server Issues:
```bash
# Check if embedded repo exists
ls -la platform/config-server/config-repo

# Check git status
cd platform/config-server/config-repo && git status

# Check logs
tail -f config-server.log
```

### Port Conflicts:
```bash
# Check what's running on ports
netstat -tulpn | grep :9000
netstat -tulpn | grep :9001
netstat -tulpn | grep :7000
```

## Success Criteria:

✅ Config Server running on port 9000
✅ Service Registry running on port 9001
✅ API Gateway running on port 7000
✅ Configuration endpoint returns embedded repo data
✅ All services discover each other via Eureka