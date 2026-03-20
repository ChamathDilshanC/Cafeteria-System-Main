#!/bin/bash

################################################################################
# Cafeteria System - Polyrepo Architecture Setup Script
# Creates individual GitHub repositories for each service and a main repository
# with git submodules maintaining the original folder structure.
################################################################################

set -e  # Exit on any error

# Configuration
PROJECT_NAME="Cafeteria-System"
MAIN_REPO_NAME="${PROJECT_NAME}-Main"
GITHUB_USERNAME=$(gh api user --jq '.login')
TEMP_DIR="$(pwd)/.polyrepo-temp"
ORIGINAL_DIR="$(pwd)"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Services and their paths
declare -A SERVICES=(
    ["config-server"]="platform/config-server"
    ["service-registry"]="platform/service-registry"
    ["api-gateway"]="platform/api-gateway"
    ["user-service"]="services/user-service"
    ["menu-service"]="services/menu-service"
    ["order-service"]="services/order-service"
    ["kitchen-service"]="services/kitchen-service"
    ["webapp"]="webapp"
)

################################################################################
# Helper Functions
################################################################################

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

    # Check if gh CLI is installed and authenticated
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed. Please install it from https://cli.github.com/"
        exit 1
    fi
    print_success "GitHub CLI is installed"

    # Check if authenticated
    if ! gh auth status &> /dev/null; then
        print_error "Not authenticated with GitHub. Please run: gh auth login"
        exit 1
    fi
    print_success "Authenticated with GitHub as: $GITHUB_USERNAME"

    # Check if git is installed
    if ! command -v git &> /dev/null; then
        print_error "Git is not installed"
        exit 1
    fi
    print_success "Git is installed"

    # Verify all service directories exist
    for service in "${!SERVICES[@]}"; do
        if [ ! -d "${SERVICES[$service]}" ]; then
            print_error "Directory not found: ${SERVICES[$service]}"
            exit 1
        fi
    done
    print_success "All service directories verified"
}

create_service_repository() {
    local service_name=$1
    local service_path=$2
    local repo_name="${PROJECT_NAME}-${service_name}"

    print_info "Processing: $service_name → $repo_name"

    cd "$ORIGINAL_DIR/$service_path"

    # Initialize git if not already initialized
    if [ ! -d ".git" ]; then
        git init
        print_success "Initialized git repository"
    else
        print_warning "Git repository already initialized"
    fi

    # Create .gitignore if it doesn't exist
    if [ ! -f ".gitignore" ]; then
        cat > .gitignore << 'EOF'
# Maven
target/
pom.xml.tag
pom.xml.releaseBackup
pom.xml.versionsBackup
pom.xml.next
release.properties
dependency-reduced-pom.xml
buildNumber.properties
.mvn/timing.properties
.mvn/wrapper/maven-wrapper.jar

# Java
*.class
*.log
*.jar
*.war
*.ear
hs_err_pid*

# IDE
.idea/
*.iml
.vscode/
.settings/
.classpath
.project

# OS
.DS_Store
Thumbs.db

# Node (for webapp)
node_modules/
dist/
.env
EOF
        print_success "Created .gitignore"
    fi

    # Add all files
    git add .

    # Check if there are changes to commit
    if git diff-index --quiet HEAD -- 2>/dev/null; then
        print_warning "No changes to commit"
    else
        git commit -m "Initial commit: ${service_name}" || print_warning "Commit failed or nothing to commit"
    fi

    # Check if repository already exists on GitHub
    if gh repo view "${GITHUB_USERNAME}/${repo_name}" &> /dev/null; then
        print_warning "Repository ${repo_name} already exists on GitHub"
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh repo delete "${GITHUB_USERNAME}/${repo_name}" --yes
            print_success "Deleted existing repository"
        else
            print_info "Skipping repository creation"
            cd "$ORIGINAL_DIR"
            return
        fi
    fi

    # Create GitHub repository
    print_info "Creating GitHub repository: $repo_name"
    gh repo create "${repo_name}" --public --source=. --remote=origin --push

    print_success "Repository created and pushed: https://github.com/${GITHUB_USERNAME}/${repo_name}"

    cd "$ORIGINAL_DIR"
}

create_main_repository() {
    print_header "Creating Main Repository with Submodules"

    # Create temporary directory for main repo
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"

    # Initialize main repository
    print_info "Initializing main repository"
    git init

    # Create directory structure
    mkdir -p platform services

    # Copy root files
    print_info "Copying root configuration files"
    cp "$ORIGINAL_DIR/ecosystem.config.js" .
    cp "$ORIGINAL_DIR/docker-compose.yml" .
    cp "$ORIGINAL_DIR/README.md" .
    cp "$ORIGINAL_DIR/build-all.sh" .
    cp "$ORIGINAL_DIR/build-all.bat" .

    # Copy init-scripts if it exists
    if [ -d "$ORIGINAL_DIR/init-scripts" ]; then
        cp -r "$ORIGINAL_DIR/init-scripts" .
    fi

    # Create main repository README
    cat > README.md << 'EOF'
# Cafeteria System - Main Repository

This is the main repository for the Cafeteria Management System, containing references to all microservices as git submodules.

## Architecture

This project follows a **Polyrepo** architecture with the following components:

### Platform Services
- **config-server**: Centralized configuration management
- **service-registry**: Eureka service discovery
- **api-gateway**: API Gateway with routing and load balancing

### Business Services
- **user-service**: User authentication and management
- **menu-service**: Menu and food item management
- **order-service**: Order processing and management
- **kitchen-service**: Kitchen operations and order fulfillment

### Frontend
- **webapp**: Web application for customers and staff

## Technology Stack

- **Java**: 25
- **Spring Boot**: 4.0.3
- **Spring Cloud**: 2025.1.0
- **Databases**: MySQL 8.0, MongoDB 7.0
- **Cloud**: Google Cloud Platform (GCS for images)

## Getting Started

### Prerequisites
- Java 25
- Maven 3.9+
- Docker & Docker Compose
- Node.js 18+ (for webapp)

### Clone with Submodules

```bash
# Clone the repository with all submodules
git clone --recursive https://github.com/YOUR_USERNAME/Cafeteria-System-Main.git

# OR if already cloned, initialize submodules
git submodule update --init --recursive
```

### Build All Services

```bash
# Unix/Linux/MacOS
./build-all.sh

# Windows
build-all.bat
```

### Start Infrastructure

```bash
# Start MySQL and MongoDB
docker-compose up -d
```

### Running Services

Each service can be run individually:

```bash
cd platform/config-server
mvn spring-boot:run
```

Or use PM2 for production deployment:

```bash
pm2 start ecosystem.config.js
```

## Port Configuration

| Service          | Port |
|------------------|------|
| config-server    | 8888 |
| service-registry | 8761 |
| api-gateway      | 8080 |
| user-service     | 8081 |
| menu-service     | 8082 |
| order-service    | 8083 |
| kitchen-service  | 8084 |
| webapp           | 3000 |

## Submodule Repositories

- [config-server](https://github.com/YOUR_USERNAME/Cafeteria-System-config-server)
- [service-registry](https://github.com/YOUR_USERNAME/Cafeteria-System-service-registry)
- [api-gateway](https://github.com/YOUR_USERNAME/Cafeteria-System-api-gateway)
- [user-service](https://github.com/YOUR_USERNAME/Cafeteria-System-user-service)
- [menu-service](https://github.com/YOUR_USERNAME/Cafeteria-System-menu-service)
- [order-service](https://github.com/YOUR_USERNAME/Cafeteria-System-order-service)
- [kitchen-service](https://github.com/YOUR_USERNAME/Cafeteria-System-kitchen-service)
- [webapp](https://github.com/YOUR_USERNAME/Cafeteria-System-webapp)

## Working with Submodules

### Update all submodules
```bash
git submodule update --remote --merge
```

### Make changes in a submodule
```bash
cd services/user-service
# Make changes
git add .
git commit -m "Your changes"
git push origin main
cd ../..
git add services/user-service
git commit -m "Update user-service submodule"
git push
```

## Documentation

For detailed documentation, please refer to individual service repositories.

## License

This project is for educational purposes (ITS 2130 Final Project).
EOF

    # Update README with actual GitHub username
    sed -i "s/YOUR_USERNAME/${GITHUB_USERNAME}/g" README.md

    # Create .gitignore
    cat > .gitignore << 'EOF'
# Maven
target/
*.class

# IDE
.idea/
*.iml
.vscode/
.settings/

# OS
.DS_Store
Thumbs.db

# Logs
*.log

# Temp
.polyrepo-temp/
EOF

    # Add submodules
    print_info "Adding submodules..."

    # Add platform services
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-config-server.git" platform/config-server
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-service-registry.git" platform/service-registry
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-api-gateway.git" platform/api-gateway

    # Add business services
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-user-service.git" services/user-service
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-menu-service.git" services/menu-service
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-order-service.git" services/order-service
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-kitchen-service.git" services/kitchen-service

    # Add webapp
    git submodule add "https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-webapp.git" webapp

    print_success "All submodules added"

    # Commit everything
    git add .
    git commit -m "Initial commit: Cafeteria System with submodules

- Added all microservices as submodules
- Added configuration files (docker-compose, ecosystem.config.js)
- Added build scripts
- Structured as platform/, services/, and webapp/"

    # Create GitHub repository for main repo
    print_info "Creating main repository on GitHub"

    # Check if main repository already exists
    if gh repo view "${GITHUB_USERNAME}/${MAIN_REPO_NAME}" &> /dev/null; then
        print_warning "Main repository ${MAIN_REPO_NAME} already exists"
        read -p "Do you want to delete and recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            gh repo delete "${GITHUB_USERNAME}/${MAIN_REPO_NAME}" --yes
            print_success "Deleted existing main repository"
        else
            print_error "Cannot proceed with existing main repository"
            cd "$ORIGINAL_DIR"
            return 1
        fi
    fi

    gh repo create "${MAIN_REPO_NAME}" --public --source=. --remote=origin --push

    print_success "Main repository created: https://github.com/${GITHUB_USERNAME}/${MAIN_REPO_NAME}"

    cd "$ORIGINAL_DIR"
}

verify_repositories() {
    print_header "Verifying Created Repositories"

    for service in "${!SERVICES[@]}"; do
        local repo_name="${PROJECT_NAME}-${service}"
        if gh repo view "${GITHUB_USERNAME}/${repo_name}" &> /dev/null; then
            print_success "$repo_name: https://github.com/${GITHUB_USERNAME}/${repo_name}"
        else
            print_error "$repo_name: Repository not found"
        fi
    done

    if gh repo view "${GITHUB_USERNAME}/${MAIN_REPO_NAME}" &> /dev/null; then
        print_success "$MAIN_REPO_NAME: https://github.com/${GITHUB_USERNAME}/${MAIN_REPO_NAME}"
    else
        print_error "$MAIN_REPO_NAME: Repository not found"
    fi
}

create_clone_instructions() {
    print_header "Setup Complete!"

    cat << EOF

${GREEN}All repositories have been created successfully!${NC}

${BLUE}Main Repository:${NC}
https://github.com/${GITHUB_USERNAME}/${MAIN_REPO_NAME}

${BLUE}To clone the complete project with all submodules:${NC}

git clone --recursive https://github.com/${GITHUB_USERNAME}/${MAIN_REPO_NAME}.git

${BLUE}Or if already cloned:${NC}

git submodule update --init --recursive

${BLUE}Individual Service Repositories:${NC}
EOF

    for service in "${!SERVICES[@]}"; do
        echo "- https://github.com/${GITHUB_USERNAME}/${PROJECT_NAME}-${service}"
    done

    cat << EOF

${YELLOW}Note:${NC} The original project directory remains unchanged.
The main repository has been created in: $TEMP_DIR

${BLUE}Next Steps:${NC}
1. Test cloning the main repository in a new directory
2. Verify all submodules are properly linked
3. Run build-all.sh to ensure all services compile
4. Start docker-compose for databases
5. Deploy to GCP as needed

EOF
}

cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        print_info "Temporary directory preserved at: $TEMP_DIR"
        print_info "You can safely delete it after verification"
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header "Cafeteria System - Polyrepo Setup"

    print_info "Project: $PROJECT_NAME"
    print_info "Main Repository: $MAIN_REPO_NAME"
    print_info "GitHub User: $GITHUB_USERNAME"
    print_info "Working Directory: $ORIGINAL_DIR"

    echo ""
    read -p "Continue with repository creation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "Setup cancelled by user"
        exit 0
    fi

    check_prerequisites

    print_header "Creating Individual Service Repositories"
    for service in "${!SERVICES[@]}"; do
        create_service_repository "$service" "${SERVICES[$service]}"
    done

    create_main_repository

    verify_repositories

    create_clone_instructions

    cleanup
}

# Run main function
main

print_success "Script completed successfully!"
