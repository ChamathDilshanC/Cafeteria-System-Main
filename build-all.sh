#!/usr/bin/env bash
# build-all.sh — Build every Maven project from the repo root.
# Run: chmod +x build-all.sh && ./build-all.sh

set -e

PROJECTS=(
    "platform/config-server"
    "platform/service-registry"
    "platform/api-gateway"
    "services/user-service"
    "services/menu-service"
    "services/order-service"
    "services/kitchen-service"
)

for project in "${PROJECTS[@]}"; do
    echo "=========================================="
    echo " Building: $project"
    echo "=========================================="
    (cd "$project" && mvn clean package -DskipTests)
done

echo ""
echo "All builds completed successfully."
