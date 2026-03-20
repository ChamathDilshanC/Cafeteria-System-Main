#!/bin/bash

################################################################################
# Cafeteria System - Nested Polyrepo Structure Setup
# Creates parent repositories with nested submodules
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
PROJECT_NAME="Cafeteria-System"
GITHUB_USERNAME=$(gh api user --jq '.login')
ORIGINAL_DIR="$(pwd)"
TEMP_DIR="$(pwd)/.nested-polyrepo-temp"

# Parent repositories
PLATFORM_REPO="${PROJECT_NAME}-Platform"
SERVICES_REPO="${PROJECT_NAME}-Services"
CONFIGS_REPO="${PROJECT_NAME}-Configurations"
MAIN_REPO="${PROJECT_NAME}-Main"

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_prerequisites() {
    print_header "Checking Prerequisites"

    # Check gh CLI
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) not installed"
        exit 1
    fi
    print_success "GitHub CLI installed"

    # Check authentication
    if ! gh auth status &> /dev/null; then
        print_error "Not authenticated with GitHub"
        exit 1
    fi
    print_success "Authenticated as: $GITHUB_USERNAME"

    # Check if individual service repos exist
    print_info "Verifying individual service repositories exist..."
    local services=(
        "api-gateway" "config-server" "service-registry"
        "user-service" "menu-service" "order-service" "kitchen-service"
        "webapp"
    )

    for service in "${services[@]}"; do
        if gh repo view "${GITHUB_USERNAME}/${PROJECT_NAME}-${service}" &> /dev/null; then
            print_success "Found: ${PROJECT_NAME}-${service}"
        else
            print_error "Repository not found: ${PROJECT_NAME}-${service}"
            exit 1
        fi
    done
}

create_parent_pom() {
    local repo_name=$1
    local modules=$2

    cat > pom.xml << EOF
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
         http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>com.cafeteria</groupId>
    <artifactId>${repo_name,,}</artifactId>
    <version>1.0.0</version>
    <packaging>pom</packaging>

    <name>${repo_name}</name>
    <description>Parent POM for ${repo_name}</description>

    <properties>
        <java.version>25</java.version>
        <maven.compiler.source>25</maven.compiler.source>
        <maven.compiler.target>25</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <spring-boot.version>4.0.3</spring-boot.version>
        <spring-cloud.version>2025.1.0</spring-cloud.version>
    </properties>

    <modules>
${modules}
    </modules>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>\${spring-boot.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>\${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <pluginManagement>
            <plugins>
                <plugin>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-maven-plugin</artifactId>
                    <version>\${spring-boot.version}</version>
                </plugin>
            </plugins>
        </pluginManagement>
    </build>
</project>
EOF
    print_success "Created parent pom.xml"
}

create_platform_repository() {
    print_header "Creating Platform Repository"

    local repo_dir="$TEMP_DIR/$PLATFORM_REPO"
    mkdir -p "$repo_dir"
    cd "$repo_dir"

    # Initialize git
    git init
    print_success "Initialized git repository"

    # Create README
    cat > README.md << 'EOF'
# Cafeteria System - Platform Services

Parent repository containing all platform infrastructure services.

## Services

- **config-server**: Centralized configuration management (Port 8888)
- **service-registry**: Netflix Eureka service discovery (Port 8761)
- **api-gateway**: Spring Cloud Gateway API routing (Port 8080)

## Architecture

This is a parent repository that contains individual services as git submodules.

## Build All Services

```bash
mvn clean install
```

## Run All Services

```bash
# Using PM2
pm2 start ecosystem.config.js

# Or build and run individually
cd config-server && mvn spring-boot:run
cd service-registry && mvn spring-boot:run
cd api-gateway && mvn spring-boot:run
```

## Tech Stack

- Java 25
- Spring Boot 4.0.3
- Spring Cloud 2025.1.0
- Maven (Parent POM)

## Repository Structure

```
Cafeteria-System-Platform/
├── config-server/       → Submodule
├── service-registry/    → Submodule
├── api-gateway/         → Submodule
├── pom.xml             → Parent POM
├── ecosystem.config.js → PM2 configuration
└── README.md
```

## Submodule Management

### Clone with submodules
```bash
git clone --recursive https://github.com/YOUR_USERNAME/Cafeteria-System-Platform.git
```

### Update submodules
```bash
git submodule update --remote --merge
```

---

**Part of**: [Cafeteria Management System](https://github.com/YOUR_USERNAME/Cafeteria-System-Main)
EOF

    # Create parent POM
    local modules="        <module>config-server</module>
        <module>service-registry</module>
        <module>api-gateway</module>"
    create_parent_pom "$PLATFORM_REPO" "$modules"

    # Create PM2 configuration
    cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'config-server',
      script: 'java',
      args: ['-jar', 'config-server/target/config-server-1.0.0.jar'],
      cwd: './',
      env: {
        SERVER_PORT: 8888
      }
    },
    {
      name: 'service-registry',
      script: 'java',
      args: ['-jar', 'service-registry/target/service-registry-1.0.0.jar'],
      cwd: './',
      env: {
        SERVER_PORT: 8761
      }
    },
    {
      name: 'api-gateway',
      script: 'java',
      args: ['-jar', 'api-gateway/target/api-gateway-1.0.0.jar'],
      cwd: './',
      env: {
        SERVER_PORT: 8080,
        CONFIG_SERVER_URI: 'http://localhost:8888',
        EUREKA_URI: 'http://localhost:8761/eureka'
      }
    }
  ]
};
EOF
    print_success "Created ecosystem.config.js"

    # Create .gitignore
    cat > .gitignore << 'EOF'
target/
*.class
*.log
.idea/
*.iml
.vscode/
.DS_Store
EOF

    # Add submodules
    print_info "Adding submodules..."
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-config-server.git" config-server
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-service-registry.git" service-registry
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-api-gateway.git" api-gateway
    print_success "Submodules added"

    # Update README with username
    sed -i "s/YOUR_USERNAME/${GITHUB_USERNAME}/g" README.md

    # Commit
    git add .
    git commit -m "Initial commit: Platform services parent repository

- Added config-server, service-registry, api-gateway as submodules
- Added parent POM for unified build
- Added PM2 configuration for deployment"

    # Create GitHub repository
    print_info "Creating GitHub repository..."
    gh repo create "${PLATFORM_REPO}" --public --source=. --remote=origin --push

    print_success "Platform repository created: https://github.com/${GITHUB_USERNAME}/${PLATFORM_REPO}"

    cd "$ORIGINAL_DIR"
}

create_services_repository() {
    print_header "Creating Services Repository"

    local repo_dir="$TEMP_DIR/$SERVICES_REPO"
    mkdir -p "$repo_dir"
    cd "$repo_dir"

    # Initialize git
    git init
    print_success "Initialized git repository"

    # Create README
    cat > README.md << 'EOF'
# Cafeteria System - Business Services

Parent repository containing all business domain microservices.

## Services

- **user-service**: User authentication and management (Port 8081, MySQL, JWT)
- **menu-service**: Menu and food item management (Port 8082, MySQL, GCS)
- **order-service**: Order processing (Port 8083, MySQL, OpenFeign)
- **kitchen-service**: Kitchen operations (Port 8084, MongoDB)

## Architecture

This is a parent repository that contains individual services as git submodules.

## Build All Services

```bash
mvn clean install
```

## Run All Services

```bash
# Using PM2
pm2 start ecosystem.config.js

# Or build and run individually
cd user-service && mvn spring-boot:run
cd menu-service && mvn spring-boot:run
cd order-service && mvn spring-boot:run
cd kitchen-service && mvn spring-boot:run
```

## Tech Stack

- Java 25
- Spring Boot 4.0.3
- Spring Cloud 2025.1.0
- MySQL 8.0 (user, menu, order services)
- MongoDB 7.0 (kitchen service)
- Maven (Parent POM)

## Prerequisites

- Platform services running (config-server, service-registry, api-gateway)
- MySQL database
- MongoDB database

## Repository Structure

```
Cafeteria-System-Services/
├── user-service/        → Submodule
├── menu-service/        → Submodule
├── order-service/       → Submodule
├── kitchen-service/     → Submodule
├── pom.xml             → Parent POM
├── ecosystem.config.js → PM2 configuration
└── README.md
```

## Submodule Management

### Clone with submodules
```bash
git clone --recursive https://github.com/YOUR_USERNAME/Cafeteria-System-Services.git
```

### Update submodules
```bash
git submodule update --remote --merge
```

---

**Part of**: [Cafeteria Management System](https://github.com/YOUR_USERNAME/Cafeteria-System-Main)
EOF

    # Create parent POM
    local modules="        <module>user-service</module>
        <module>menu-service</module>
        <module>order-service</module>
        <module>kitchen-service</module>"
    create_parent_pom "$SERVICES_REPO" "$modules"

    # Create PM2 configuration
    cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'user-service',
      script: 'java',
      args: ['-jar', 'user-service/target/user-service-1.0.0.jar'],
      cwd: './',
      env: {
        SERVER_PORT: 8081,
        SPRING_DATASOURCE_URL: 'jdbc:mysql://localhost:3306/cafeteria_users',
        CONFIG_SERVER_URI: 'http://localhost:8888',
        EUREKA_URI: 'http://localhost:8761/eureka'
      }
    },
    {
      name: 'menu-service',
      script: 'java',
      args: ['-jar', 'menu-service/target/menu-service-1.0.0.jar'],
      cwd: './',
      env: {
        SERVER_PORT: 8082,
        SPRING_DATASOURCE_URL: 'jdbc:mysql://localhost:3306/cafeteria_menu',
        GCS_BUCKET_NAME: 'cafeteria-menu-images',
        CONFIG_SERVER_URI: 'http://localhost:8888',
        EUREKA_URI: 'http://localhost:8761/eureka'
      }
    },
    {
      name: 'order-service',
      script: 'java',
      args: ['-jar', 'order-service/target/order-service-1.0.0.jar'],
      cwd: './',
      env: {
        SERVER_PORT: 8083,
        SPRING_DATASOURCE_URL: 'jdbc:mysql://localhost:3306/cafeteria_orders',
        CONFIG_SERVER_URI: 'http://localhost:8888',
        EUREKA_URI: 'http://localhost:8761/eureka'
      }
    },
    {
      name: 'kitchen-service',
      script: 'java',
      args: ['-jar', 'kitchen-service/target/kitchen-service-1.0.0.jar'],
      cwd: './',
      env: {
        SERVER_PORT: 8084,
        MONGODB_HOST: 'localhost',
        MONGODB_PORT: 27017,
        CONFIG_SERVER_URI: 'http://localhost:8888',
        EUREKA_URI: 'http://localhost:8761/eureka'
      }
    }
  ]
};
EOF
    print_success "Created ecosystem.config.js"

    # Create .gitignore
    cat > .gitignore << 'EOF'
target/
*.class
*.log
.idea/
*.iml
.vscode/
.DS_Store
EOF

    # Add submodules
    print_info "Adding submodules..."
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-user-service.git" user-service
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-menu-service.git" menu-service
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-order-service.git" order-service
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-kitchen-service.git" kitchen-service
    print_success "Submodules added"

    # Update README with username
    sed -i "s/YOUR_USERNAME/${GITHUB_USERNAME}/g" README.md

    # Commit
    git add .
    git commit -m "Initial commit: Business services parent repository

- Added user-service, menu-service, order-service, kitchen-service as submodules
- Added parent POM for unified build
- Added PM2 configuration for deployment"

    # Create GitHub repository
    print_info "Creating GitHub repository..."
    gh repo create "${SERVICES_REPO}" --public --source=. --remote=origin --push

    print_success "Services repository created: https://github.com/${GITHUB_USERNAME}/${SERVICES_REPO}"

    cd "$ORIGINAL_DIR"
}

create_configurations_repository() {
    print_header "Creating Configurations Repository"

    local repo_dir="$TEMP_DIR/$CONFIGS_REPO"
    mkdir -p "$repo_dir"
    cd "$repo_dir"

    # Initialize git
    git init
    print_success "Initialized git repository"

    # Create directory structure
    mkdir -p platform services

    # Copy configuration files
    print_info "Copying configuration files..."

    local config_src="$ORIGINAL_DIR/platform/config-server/src/main/resources/config"

    if [ -d "$config_src" ]; then
        # Platform configs
        [ -f "$config_src/api-gateway.yml" ] && cp "$config_src/api-gateway.yml" platform/
        [ -f "$config_src/config-server.yml" ] && cp "$config_src/config-server.yml" platform/
        [ -f "$config_src/service-registry.yml" ] && cp "$config_src/service-registry.yml" platform/

        # Service configs
        [ -f "$config_src/user-service.yml" ] && cp "$config_src/user-service.yml" services/
        [ -f "$config_src/menu-service.yml" ] && cp "$config_src/menu-service.yml" services/
        [ -f "$config_src/order-service.yml" ] && cp "$config_src/order-service.yml" services/
        [ -f "$config_src/kitchen-service.yml" ] && cp "$config_src/kitchen-service.yml" services/

        print_success "Configuration files copied"
    else
        print_warning "Config source directory not found, creating sample configs"

        # Create sample configs if source doesn't exist
        cat > platform/api-gateway.yml << 'EOF'
spring:
  cloud:
    gateway:
      server:
        webflux:
          routes:
            # Add routes here
EOF

        cat > services/user-service.yml << 'EOF'
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/cafeteria_users
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:root}
EOF
    fi

    # Create README
    cat > README.md << 'EOF'
# Cafeteria System - Configurations

Centralized configuration repository for all microservices.

## Structure

```
Cafeteria-System-Configurations/
├── platform/
│   ├── api-gateway.yml
│   ├── config-server.yml
│   └── service-registry.yml
└── services/
    ├── user-service.yml
    ├── menu-service.yml
    ├── order-service.yml
    └── kitchen-service.yml
```

## Platform Configurations

### api-gateway.yml
- Gateway routing rules
- CORS configuration
- Service discovery URIs
- Load balancing settings

### config-server.yml
- Config server settings
- Native profile configuration

### service-registry.yml
- Eureka server configuration
- Self-preservation settings

## Service Configurations

### user-service.yml
- MySQL datasource
- JWT configuration
- Authentication settings

### menu-service.yml
- MySQL datasource
- Google Cloud Storage settings
- Image upload configuration

### order-service.yml
- MySQL datasource
- OpenFeign client settings
- Order processing configuration

### kitchen-service.yml
- MongoDB connection
- Kitchen queue settings
- Order priority configuration

## Usage

These configuration files are consumed by the Config Server and distributed to all microservices at runtime.

### Local Development

Config Server reads from this repository using Git backend:

```yaml
spring:
  cloud:
    config:
      server:
        git:
          uri: https://github.com/YOUR_USERNAME/Cafeteria-System-Configurations
          default-label: main
```

### Environment Variables

Use environment variables for sensitive data:

```yaml
spring:
  datasource:
    username: ${DB_USERNAME:root}
    password: ${DB_PASSWORD:secret}
```

## Configuration Properties

Common properties across all services:

- `${CONFIG_SERVER_URI}`: Config server location
- `${EUREKA_URI}`: Service registry location
- `${DB_USERNAME}`, `${DB_PASSWORD}`: Database credentials
- `${JWT_SECRET}`: JWT signing secret
- `${GCS_BUCKET_NAME}`: Google Cloud Storage bucket

## Security Notes

⚠️ **Important**: Never commit sensitive data to this repository.
- Use environment variables for secrets
- Consider using Spring Cloud Vault for production
- Use encrypted properties where possible

## Version Control

Configuration changes should be:
1. Reviewed carefully
2. Tested in development environment
3. Applied to production with proper change management

---

**Part of**: [Cafeteria Management System](https://github.com/YOUR_USERNAME/Cafeteria-System-Main)
EOF

    # Create .gitignore
    cat > .gitignore << 'EOF'
# Ignore files with secrets
*-secret.yml
*.secret.yml
.env
EOF

    # Update README with username
    sed -i "s/YOUR_USERNAME/${GITHUB_USERNAME}/g" README.md

    # Commit
    git add .
    git commit -m "Initial commit: Centralized configurations

- Added platform configuration files
- Added service configuration files
- Organized into platform/ and services/ directories"

    # Create GitHub repository
    print_info "Creating GitHub repository..."
    gh repo create "${CONFIGS_REPO}" --public --source=. --remote=origin --push

    print_success "Configurations repository created: https://github.com/${GITHUB_USERNAME}/${CONFIGS_REPO}"

    cd "$ORIGINAL_DIR"
}

update_main_repository() {
    print_header "Updating Main Repository"

    # Check if main repo exists
    if ! gh repo view "${GITHUB_USERNAME}/${MAIN_REPO}" &> /dev/null; then
        print_warning "Main repository doesn't exist, creating it..."
        create_main_repo_fresh
        return
    fi

    print_info "Main repository exists, updating structure..."

    local repo_dir="$TEMP_DIR/${MAIN_REPO}-updated"
    mkdir -p "$repo_dir"
    cd "$repo_dir"

    # Clone existing main repository
    gh repo clone "${GITHUB_USERNAME}/${MAIN_REPO}" .

    # Remove old submodules
    print_info "Removing old individual service submodules..."
    git submodule deinit -f platform/config-server platform/service-registry platform/api-gateway 2>/dev/null || true
    git submodule deinit -f services/user-service services/menu-service services/order-service services/kitchen-service 2>/dev/null || true
    git rm -rf platform services 2>/dev/null || true
    rm -rf .git/modules/platform .git/modules/services 2>/dev/null || true

    # Add new parent repositories as submodules
    print_info "Adding new parent repositories as submodules..."
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PLATFORM_REPO}.git" platform
    git submodule add "https://github.com/${GITHUB_USERNAME}/${SERVICES_REPO}.git" services

    # Ensure webapp exists as submodule
    if [ ! -d "webapp" ]; then
        git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-webapp.git" webapp
    fi

    # Update README
    cat > README.md << 'EOF'
# Cafeteria System - Main Repository

Enterprise microservices-based cafeteria management system with nested Polyrepo architecture.

## 🏗️ Architecture Overview

This is the main repository that orchestrates the entire Cafeteria Management System using a **nested submodule pattern**.

### Repository Structure

```
Cafeteria-System-Main/
├── platform/                    → Cafeteria-System-Platform (Parent Repo)
│   ├── config-server/          → Submodule
│   ├── service-registry/       → Submodule
│   └── api-gateway/            → Submodule
├── services/                    → Cafeteria-System-Services (Parent Repo)
│   ├── user-service/           → Submodule
│   ├── menu-service/           → Submodule
│   ├── order-service/          → Submodule
│   └── kitchen-service/        → Submodule
├── webapp/                      → Cafeteria-System-webapp (Submodule)
├── docker-compose.yml
├── ecosystem.config.js
└── README.md
```

## 📦 Related Repositories

| Repository | Type | Description |
|------------|------|-------------|
| [Cafeteria-System-Platform](https://github.com/YOUR_USERNAME/Cafeteria-System-Platform) | Parent | Platform infrastructure services |
| [Cafeteria-System-Services](https://github.com/YOUR_USERNAME/Cafeteria-System-Services) | Parent | Business domain microservices |
| [Cafeteria-System-Configurations](https://github.com/YOUR_USERNAME/Cafeteria-System-Configurations) | Configs | Centralized configuration files |
| [Cafeteria-System-webapp](https://github.com/YOUR_USERNAME/Cafeteria-System-webapp) | Frontend | Web application |

### Individual Service Repositories

**Platform Services:**
- [config-server](https://github.com/YOUR_USERNAME/Cafeteria-System-config-server) (Port 8888)
- [service-registry](https://github.com/YOUR_USERNAME/Cafeteria-System-service-registry) (Port 8761)
- [api-gateway](https://github.com/YOUR_USERNAME/Cafeteria-System-api-gateway) (Port 8080)

**Business Services:**
- [user-service](https://github.com/YOUR_USERNAME/Cafeteria-System-user-service) (Port 8081)
- [menu-service](https://github.com/YOUR_USERNAME/Cafeteria-System-menu-service) (Port 8082)
- [order-service](https://github.com/YOUR_USERNAME/Cafeteria-System-order-service) (Port 8083)
- [kitchen-service](https://github.com/YOUR_USERNAME/Cafeteria-System-kitchen-service) (Port 8084)

## 🚀 Quick Start

### Clone the Complete Project

```bash
# Clone with all nested submodules
git clone --recursive https://github.com/YOUR_USERNAME/Cafeteria-System-Main.git
cd Cafeteria-System-Main

# If already cloned, initialize submodules
git submodule update --init --recursive
```

### Start Infrastructure

```bash
# Start MySQL and MongoDB
docker-compose up -d
```

### Build All Services

```bash
# Build platform services
cd platform && mvn clean install

# Build business services
cd ../services && mvn clean install

# Return to root
cd ..
```

### Run Services

#### Using PM2 (Recommended for Production)

```bash
pm2 start ecosystem.config.js
pm2 status
```

#### Run Individually

```bash
# Platform services
cd platform/config-server && mvn spring-boot:run &
cd platform/service-registry && mvn spring-boot:run &
cd platform/api-gateway && mvn spring-boot:run &

# Business services
cd services/user-service && mvn spring-boot:run &
cd services/menu-service && mvn spring-boot:run &
cd services/order-service && mvn spring-boot:run &
cd services/kitchen-service && mvn spring-boot:run &

# Webapp
cd webapp && npm start
```

## 🛠️ Tech Stack

| Component | Technology | Version |
|-----------|------------|---------|
| Language | Java | 25 |
| Framework | Spring Boot | 4.0.3 |
| Cloud | Spring Cloud | 2025.1.0 |
| Databases | MySQL, MongoDB | 8.0, 7.0 |
| Service Discovery | Netflix Eureka | 2025.1.0 |
| API Gateway | Spring Cloud Gateway | 2025.1.0 |
| Config Management | Spring Cloud Config | 2025.1.0 |
| Inter-Service Comm | OpenFeign | 2025.1.0 |
| Authentication | JWT (JJWT 0.12.6) | - |
| Cloud Storage | Google Cloud Storage | - |
| Frontend | HTML/CSS/JavaScript | - |
| Build Tool | Maven | 3.9+ |
| Deployment | PM2, Docker | - |

## 📊 Service Ports

| Service | Port | Database | Notes |
|---------|------|----------|-------|
| config-server | 8888 | - | Configuration management |
| service-registry | 8761 | - | Service discovery (Eureka) |
| api-gateway | 8080 | - | API routing & load balancing |
| user-service | 8081 | MySQL | JWT authentication |
| menu-service | 8082 | MySQL | GCS integration for images |
| order-service | 8083 | MySQL | OpenFeign for inter-service calls |
| kitchen-service | 8084 | MongoDB | Kitchen operations |
| webapp | 3000 | - | Frontend application |

## 🔄 Working with Nested Submodules

### Update All Submodules

```bash
# Update parent repositories and their submodules
git submodule update --remote --recursive --merge

# Commit the updated references
git add .
git commit -m "Update submodules to latest versions"
git push
```

### Work on a Specific Service

```bash
# Navigate to the service
cd services/user-service

# Make changes
git checkout -b feature/new-feature
# ... make changes ...
git add .
git commit -m "Add new feature"
git push origin feature/new-feature

# Update parent to reference new commit
cd ../..
cd services
git add user-service
git commit -m "Update user-service reference"
git push

# Update main repository
cd ..
git add services
git commit -m "Update services parent reference"
git push
```

### Check Submodule Status

```bash
# View all submodule statuses
git submodule foreach --recursive 'echo "=== $name ===" && git status -s'

# View current commits
git submodule foreach --recursive 'echo "$name: $(git rev-parse HEAD)"'
```

## 📚 Documentation

Each service has comprehensive documentation:

- Platform services: See `platform/README.md`
- Business services: See `services/README.md`
- Individual services: Check each service's README.md
- Configuration: See [Configurations Repository](https://github.com/YOUR_USERNAME/Cafeteria-System-Configurations)

## 🐳 Docker Deployment

```bash
# Start databases
docker-compose up -d

# View logs
docker-compose logs -f mysql
docker-compose logs -f mongodb
```

## ☁️ Cloud Deployment (GCP)

See deployment guides in:
- `docs/GCP-DEPLOYMENT.md`
- Individual service READMEs

## 🧪 Testing

```bash
# Test platform services
cd platform && mvn test

# Test business services
cd services && mvn test
```

## 📄 License

This project is for educational purposes (ITS 2130 Enterprise Cloud Architecture).

---

**Course**: ITS 2130 - Enterprise Cloud Architecture
**Project**: Food Pre-Order & Cafeteria Management System
**Architecture**: Microservices with Nested Polyrepo Pattern
EOF

    # Update README with username
    sed -i "s/YOUR_USERNAME/${GITHUB_USERNAME}/g" README.md

    # Commit changes
    git add .
    git commit -m "Restructure: Migrate to nested Polyrepo pattern

- Replaced individual service submodules with parent repositories
- Added Platform parent repository with config-server, service-registry, api-gateway
- Added Services parent repository with user, menu, order, kitchen services
- Maintained webapp as direct submodule
- Updated documentation to reflect new structure"

    # Push changes
    git push origin main

    print_success "Main repository updated: https://github.com/${GITHUB_USERNAME}/${MAIN_REPO}"

    cd "$ORIGINAL_DIR"
}

create_main_repo_fresh() {
    print_info "Creating fresh main repository..."

    local repo_dir="$TEMP_DIR/${MAIN_REPO}-new"
    mkdir -p "$repo_dir"
    cd "$repo_dir"

    git init

    # Add submodules
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PLATFORM_REPO}.git" platform
    git submodule add "https://github.com/${GITHUB_USERNAME}/${SERVICES_REPO}.git" services
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-webapp.git" webapp

    # Copy docker-compose and ecosystem.config from original
    [ -f "$ORIGINAL_DIR/docker-compose.yml" ] && cp "$ORIGINAL_DIR/docker-compose.yml" .
    [ -f "$ORIGINAL_DIR/ecosystem.config.js" ] && cp "$ORIGINAL_DIR/ecosystem.config.js" .

    # Create README (same as update_main_repository)
    # ... (README creation code here) ...

    git add .
    git commit -m "Initial commit: Nested Polyrepo structure"

    gh repo create "${MAIN_REPO}" --public --source=. --remote=origin --push

    print_success "Main repository created: https://github.com/${GITHUB_USERNAME}/${MAIN_REPO}"

    cd "$ORIGINAL_DIR"
}

create_summary() {
    print_header "Setup Complete!"

    cat << EOF

${GREEN}✓ All repositories created successfully!${NC}

${BLUE}Repository Structure:${NC}

Main Repository:
└─ ${MAIN_REPO}
   ├─ platform/ → ${PLATFORM_REPO} (Parent)
   │  ├─ config-server/ (Submodule)
   │  ├─ service-registry/ (Submodule)
   │  └─ api-gateway/ (Submodule)
   ├─ services/ → ${SERVICES_REPO} (Parent)
   │  ├─ user-service/ (Submodule)
   │  ├─ menu-service/ (Submodule)
   │  ├─ order-service/ (Submodule)
   │  └─ kitchen-service/ (Submodule)
   └─ webapp/ → ${PROJECT_NAME}-webapp (Submodule)

${BLUE}Created Repositories:${NC}
1. https://github.com/${GITHUB_USERNAME}/${PLATFORM_REPO}
2. https://github.com/${GITHUB_USERNAME}/${SERVICES_REPO}
3. https://github.com/${GITHUB_USERNAME}/${CONFIGS_REPO}
4. https://github.com/${GITHUB_USERNAME}/${MAIN_REPO} (updated)

${BLUE}To clone the complete project:${NC}

git clone --recursive https://github.com/${GITHUB_USERNAME}/${MAIN_REPO}.git
cd ${MAIN_REPO}

${BLUE}To build all services:${NC}

cd platform && mvn clean install
cd ../services && mvn clean install

${BLUE}Benefit of Nested Structure:${NC}
✓ Logical grouping of related services
✓ Unified build with parent POMs
✓ Easier management of platform vs business services
✓ Centralized PM2 configuration per group
✓ Better organization for large teams

${YELLOW}Next Steps:${NC}
1. Clone the main repository with --recursive flag
2. Update config-server to use the new Configurations repository
3. Test building platform services
4. Test building business services
5. Deploy and verify all services

EOF
}

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        print_info "Temporary directory: $TEMP_DIR"
        print_info "You can delete it after verification"
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header "Nested Polyrepo Structure Setup"

    print_info "This script will create a nested submodule structure"
    print_info "GitHub User: $GITHUB_USERNAME"

    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Setup cancelled"
        exit 0
    fi

    # Create temp directory
    mkdir -p "$TEMP_DIR"

    check_prerequisites

    create_platform_repository
    create_services_repository
    create_configurations_repository
    update_main_repository

    create_summary
    cleanup
}

# Run main function
main

print_success "Nested Polyrepo setup completed!"
