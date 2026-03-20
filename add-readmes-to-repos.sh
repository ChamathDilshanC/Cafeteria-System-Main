#!/bin/bash

################################################################################
# Add README Files to Existing Repositories
# Run this AFTER executing create-polyrepo.sh if READMEs weren't included
################################################################################

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ORIGINAL_DIR="$(pwd)"

print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

add_readme_to_service() {
    local service_path=$1
    local readme_file=$2
    local service_name=$(basename "$service_path")

    print_info "Processing: $service_name"

    cd "$ORIGINAL_DIR/$service_path"

    # Check if git repository exists
    if [ ! -d ".git" ]; then
        print_error "$service_name: Not a git repository. Skipping."
        cd "$ORIGINAL_DIR"
        return 1
    fi

    # Copy README
    cp "$ORIGINAL_DIR/docs/$readme_file" README.md
    print_success "README copied"

    # Git add
    git add README.md

    # Check if there are changes to commit
    if git diff-index --quiet HEAD -- 2>/dev/null; then
        print_info "No changes to commit (README already exists)"
    else
        # Commit
        git commit -m "docs: Add comprehensive README documentation

- Added detailed service overview and features
- Included tech stack information
- Added API endpoint documentation
- Included setup and deployment instructions
- Added troubleshooting guide"

        print_success "Changes committed"

        # Push to remote
        git push origin main
        print_success "Pushed to remote repository"
    fi

    cd "$ORIGINAL_DIR"
}

main() {
    print_header "Add README Files to Repositories"

    print_info "This script will add README files to your existing repositories."
    echo ""
    read -p "Continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Operation cancelled"
        exit 0
    fi

    # Check if docs directory exists
    if [ ! -d "docs" ]; then
        print_error "docs/ directory not found. Please ensure README files exist in docs/"
        exit 1
    fi

    # Add README to each service
    print_header "Platform Services"
    add_readme_to_service "platform/config-server" "README-config-server.md"
    add_readme_to_service "platform/service-registry" "README-service-registry.md"
    add_readme_to_service "platform/api-gateway" "README-api-gateway.md"

    print_header "Business Services"
    add_readme_to_service "services/user-service" "README-user-service.md"
    add_readme_to_service "services/menu-service" "README-menu-service.md"
    add_readme_to_service "services/order-service" "README-order-service.md"
    add_readme_to_service "services/kitchen-service" "README-kitchen-service.md"

    print_header "Frontend"
    add_readme_to_service "webapp" "README-webapp.md"

    print_header "Summary"
    print_success "All README files have been added and pushed!"

    echo -e "\n${BLUE}Next steps:${NC}"
    echo -e "1. Visit GitHub to verify README files appear correctly"
    echo -e "2. If you have a main repository with submodules, update submodule references:"
    echo -e "   ${GREEN}cd /path/to/main-repo${NC}"
    echo -e "   ${GREEN}git submodule update --remote --merge${NC}"
    echo -e "   ${GREEN}git add .${NC}"
    echo -e "   ${GREEN}git commit -m 'Update submodules with README documentation'${NC}"
    echo -e "   ${GREEN}git push${NC}\n"
}

# Run main function
main

print_success "Script completed!"
