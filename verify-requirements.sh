#!/bin/bash

################################################################################
# Cafeteria System - Requirements Verification Script
# Verifies Java 25, Spring Boot versions, and configuration correctness
################################################################################

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ORIGINAL_DIR="$(pwd)"
ISSUES_FOUND=0

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
    ((ISSUES_FOUND++))
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_java_version() {
    print_header "Checking Java Version"

    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
        if [ "$JAVA_VERSION" = "25" ]; then
            print_success "Java 25 is installed"
        else
            print_error "Java version is $JAVA_VERSION, but Java 25 is required"
        fi
    else
        print_error "Java is not installed or not in PATH"
    fi
}

check_maven_version() {
    print_header "Checking Maven Version"

    if command -v mvn &> /dev/null; then
        MVN_VERSION=$(mvn -version | head -n 1 | cut -d' ' -f3)
        print_success "Maven $MVN_VERSION is installed"
    else
        print_error "Maven is not installed or not in PATH"
    fi
}

check_pom_versions() {
    local service_path=$1
    local service_name=$2

    local pom_file="$service_path/pom.xml"

    if [ ! -f "$pom_file" ]; then
        print_error "$service_name: pom.xml not found"
        return
    fi

    print_info "Checking $service_name..."

    # Check Java version
    local java_version=$(grep -oP '(?<=<java.version>)[^<]+' "$pom_file" | head -1)
    if [ "$java_version" = "25" ]; then
        print_success "$service_name: Java version is 25"
    else
        print_error "$service_name: Java version is $java_version (expected 25)"
    fi

    # Check Spring Boot version
    local spring_boot_version=$(grep -oP '(?<=<version>)[^<]+' "$pom_file" | head -1)
    if [[ "$spring_boot_version" == "4.0.3" ]]; then
        print_success "$service_name: Spring Boot version is 4.0.3"
    else
        print_warning "$service_name: Spring Boot version is $spring_boot_version"
    fi

    # Check Spring Cloud version
    if grep -q "spring-cloud.version" "$pom_file"; then
        local spring_cloud_version=$(grep -oP '(?<=<spring-cloud.version>)[^<]+' "$pom_file")
        if [[ "$spring_cloud_version" == "2025.1.0" ]]; then
            print_success "$service_name: Spring Cloud version is 2025.1.0"
        else
            print_warning "$service_name: Spring Cloud version is $spring_cloud_version"
        fi
    fi
}

check_application_yml() {
    local service_path=$1
    local service_name=$2

    local app_yml="$service_path/src/main/resources/application.yml"

    if [ ! -f "$app_yml" ]; then
        print_warning "$service_name: application.yml not found (might be in config-server)"
        return
    fi

    print_info "Checking $service_name configuration..."

    # Check if config server import exists
    if grep -q "spring.config.import" "$app_yml"; then
        local config_import=$(grep "spring.config.import" "$app_yml")
        if [[ "$config_import" == *"configserver:"* ]]; then
            print_success "$service_name: Config server import configured"

            # Check if it allows environment variable override
            if [[ "$config_import" == *'${CONFIG_SERVER_URI'* ]]; then
                print_success "$service_name: CONFIG_SERVER_URI environment variable support enabled"
            else
                print_warning "$service_name: Consider adding environment variable support for CONFIG_SERVER_URI"
            fi
        else
            print_warning "$service_name: Config import found but not configserver"
        fi
    elif [ "$service_name" != "config-server" ]; then
        print_warning "$service_name: No spring.config.import found"
    fi

    # Check Eureka client configuration
    if [ "$service_name" != "config-server" ] && [ "$service_name" != "service-registry" ]; then
        if grep -q "eureka" "$app_yml"; then
            print_success "$service_name: Eureka configuration found"
        else
            print_warning "$service_name: No Eureka configuration found"
        fi
    fi
}

check_centralized_config() {
    print_header "Checking Centralized Configuration"

    local config_dir="platform/config-server/src/main/resources/config"

    if [ ! -d "$config_dir" ]; then
        print_error "Centralized config directory not found: $config_dir"
        return
    fi

    local configs=("api-gateway.yml" "user-service.yml" "menu-service.yml" "order-service.yml" "kitchen-service.yml")

    for config in "${configs[@]}"; do
        if [ -f "$config_dir/$config" ]; then
            print_success "Found: $config"
        else
            print_error "Missing: $config"
        fi
    done
}

check_discovery_client_annotation() {
    local service_path=$1
    local service_name=$2

    # Find the main application class
    local main_class=$(find "$service_path/src/main/java" -name "*Application.java" 2>/dev/null | head -1)

    if [ -z "$main_class" ]; then
        print_warning "$service_name: Application.java not found"
        return
    fi

    if grep -q "@EnableDiscoveryClient" "$main_class"; then
        print_success "$service_name: @EnableDiscoveryClient annotation present"
    elif [ "$service_name" != "service-registry" ]; then
        print_warning "$service_name: @EnableDiscoveryClient annotation not found"
    fi
}

check_gateway_routes() {
    print_header "Checking API Gateway Routes Configuration"

    local gateway_config="platform/config-server/src/main/resources/config/api-gateway.yml"

    if [ ! -f "$gateway_config" ]; then
        print_warning "API Gateway config not found at: $gateway_config"
        return
    fi

    # Check for correct Spring Cloud Gateway 2025.x namespace
    if grep -q "spring.cloud.gateway.server.webflux.routes" "$gateway_config"; then
        print_success "Using correct Spring Cloud Gateway 2025.x namespace"
    elif grep -q "spring.cloud.gateway.routes" "$gateway_config"; then
        print_error "Using old Spring Cloud Gateway namespace (should be spring.cloud.gateway.server.webflux.routes)"
    else
        print_warning "Could not find gateway routes configuration"
    fi

    # Check for lb:// URIs
    if grep -q "lb://" "$gateway_config"; then
        print_success "Load-balanced URIs configured (lb://)"
    else
        print_warning "No load-balanced URIs found"
    fi

    # Check for StripPrefix filter
    if grep -q "StripPrefix" "$gateway_config"; then
        print_success "StripPrefix filter configured"
    else
        print_warning "StripPrefix filter not found (routes might include /api prefix)"
    fi
}

check_mongodb_service() {
    print_header "Checking MongoDB Configuration (kitchen-service)"

    local kitchen_config="platform/config-server/src/main/resources/config/kitchen-service.yml"

    if [ ! -f "$kitchen_config" ]; then
        print_warning "kitchen-service.yml not found in config-server"

        # Check local application.yml
        kitchen_config="services/kitchen-service/src/main/resources/application.yml"
    fi

    if [ -f "$kitchen_config" ]; then
        if grep -q "mongodb" "$kitchen_config"; then
            print_success "MongoDB configuration found in kitchen-service"
        else
            print_warning "MongoDB configuration not found in kitchen-service"
        fi
    fi
}

check_jwt_dependencies() {
    print_header "Checking JWT Dependencies (user-service)"

    local user_pom="services/user-service/pom.xml"

    if [ ! -f "$user_pom" ]; then
        print_error "user-service pom.xml not found"
        return
    fi

    if grep -q "jjwt" "$user_pom"; then
        local jwt_version=$(grep -A 1 "jjwt" "$user_pom" | grep -oP '(?<=<version>)[^<]+' | head -1)
        if [[ "$jwt_version" == "0.12.6" ]]; then
            print_success "JJWT 0.12.6 dependency found in user-service"
        else
            print_warning "JJWT version is $jwt_version (expected 0.12.6)"
        fi
    else
        print_warning "JJWT dependency not found in user-service"
    fi
}

################################################################################
# Main Execution
################################################################################

main() {
    print_header "Cafeteria System Requirements Verification"

    cd "$ORIGINAL_DIR"

    # System checks
    check_java_version
    check_maven_version

    # Platform services
    print_header "Verifying Platform Services"
    check_pom_versions "platform/config-server" "config-server"
    check_application_yml "platform/config-server" "config-server"
    check_discovery_client_annotation "platform/config-server" "config-server"

    check_pom_versions "platform/service-registry" "service-registry"
    check_application_yml "platform/service-registry" "service-registry"

    check_pom_versions "platform/api-gateway" "api-gateway"
    check_application_yml "platform/api-gateway" "api-gateway"
    check_discovery_client_annotation "platform/api-gateway" "api-gateway"

    # Business services
    print_header "Verifying Business Services"
    check_pom_versions "services/user-service" "user-service"
    check_application_yml "services/user-service" "user-service"
    check_discovery_client_annotation "services/user-service" "user-service"

    check_pom_versions "services/menu-service" "menu-service"
    check_application_yml "services/menu-service" "menu-service"
    check_discovery_client_annotation "services/menu-service" "menu-service"

    check_pom_versions "services/order-service" "order-service"
    check_application_yml "services/order-service" "order-service"
    check_discovery_client_annotation "services/order-service" "order-service"

    check_pom_versions "services/kitchen-service" "kitchen-service"
    check_application_yml "services/kitchen-service" "kitchen-service"
    check_discovery_client_annotation "services/kitchen-service" "kitchen-service"

    # Configuration checks
    check_centralized_config
    check_gateway_routes
    check_mongodb_service
    check_jwt_dependencies

    # Summary
    print_header "Verification Summary"

    if [ $ISSUES_FOUND -eq 0 ]; then
        print_success "All checks passed! System is ready for deployment."
    else
        print_warning "Found $ISSUES_FOUND issue(s) that may need attention."
        echo -e "${YELLOW}Please review the warnings and errors above.${NC}"
    fi

    echo ""
}

# Run main function
main
