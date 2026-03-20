#!/bin/bash

################################################################################
# Copy README Files to Service Directories
# Run this BEFORE executing create-polyrepo.sh
################################################################################

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Copy README Files to Services${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Copy READMEs to their respective service directories
echo -e "${BLUE}Copying README files...${NC}\n"

cp docs/README-config-server.md platform/config-server/README.md
echo -e "${GREEN}✓${NC} Copied README to platform/config-server/"

cp docs/README-service-registry.md platform/service-registry/README.md
echo -e "${GREEN}✓${NC} Copied README to platform/service-registry/"

cp docs/README-api-gateway.md platform/api-gateway/README.md
echo -e "${GREEN}✓${NC} Copied README to platform/api-gateway/"

cp docs/README-user-service.md services/user-service/README.md
echo -e "${GREEN}✓${NC} Copied README to services/user-service/"

cp docs/README-menu-service.md services/menu-service/README.md
echo -e "${GREEN}✓${NC} Copied README to services/menu-service/"

cp docs/README-order-service.md services/order-service/README.md
echo -e "${GREEN}✓${NC} Copied README to services/order-service/"

cp docs/README-kitchen-service.md services/kitchen-service/README.md
echo -e "${GREEN}✓${NC} Copied README to services/kitchen-service/"

cp docs/README-webapp.md webapp/README.md
echo -e "${GREEN}✓${NC} Copied README to webapp/"

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}✅ All README files copied successfully!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}Next steps:${NC}"
echo -e "1. Run ${GREEN}./create-polyrepo.sh${NC} to create GitHub repositories"
echo -e "2. The README files will be included in each repository\n"
