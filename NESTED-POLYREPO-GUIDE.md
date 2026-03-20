# Nested Polyrepo Structure Guide

This guide explains the nested Polyrepo architecture and how to work with it effectively.

## 🏗️ Architecture Overview

### Why Nested Polyrepos?

The nested Polyrepo pattern provides several benefits for enterprise projects:

1. **Logical Grouping**: Related services are grouped into parent repositories
2. **Unified Build**: Parent POMs allow building all services in a group
3. **Better Organization**: Clear separation between platform and business logic
4. **Team Scalability**: Platform team vs Business team can work independently
5. **Simplified Deployment**: Group-level PM2 configurations
6. **Academic Structure**: Matches enterprise patterns taught in courses

## 📁 Repository Structure Comparison

### Before (Flat Polyrepo)

```
Cafeteria-System-Main/
├── platform/
│   ├── config-server/       → Individual repo
│   ├── service-registry/    → Individual repo
│   └── api-gateway/         → Individual repo
├── services/
│   ├── user-service/        → Individual repo
│   ├── menu-service/        → Individual repo
│   ├── order-service/       → Individual repo
│   └── kitchen-service/     → Individual repo
└── webapp/                  → Individual repo
```

### After (Nested Polyrepo)

```
Cafeteria-System-Main/
├── platform/                → PARENT REPO (Cafeteria-System-Platform)
│   ├── config-server/       → Submodule of parent
│   ├── service-registry/    → Submodule of parent
│   ├── api-gateway/         → Submodule of parent
│   ├── pom.xml             → Parent POM for unified build
│   └── ecosystem.config.js  → PM2 config for platform services
├── services/                → PARENT REPO (Cafeteria-System-Services)
│   ├── user-service/        → Submodule of parent
│   ├── menu-service/        → Submodule of parent
│   ├── order-service/       → Submodule of parent
│   ├── kitchen-service/     → Submodule of parent
│   ├── pom.xml             → Parent POM for unified build
│   └── ecosystem.config.js  → PM2 config for business services
└── webapp/                  → Individual repo (submodule)
```

## 🗂️ Repository Hierarchy

### Level 1: Main Repository

**Cafeteria-System-Main** - Orchestrates everything

- Contains: 3 submodule references
- Purpose: Overall project coordination

### Level 2: Parent Repositories

**Cafeteria-System-Platform** - Platform infrastructure

- Contains: config-server, service-registry, api-gateway as submodules
- Purpose: Infrastructure services group

**Cafeteria-System-Services** - Business logic

- Contains: user, menu, order, kitchen services as submodules
- Purpose: Business services group

**Cafeteria-System-webapp** - Frontend

- Standalone submodule

### Level 3: Individual Service Repositories

Still exist independently:

- Cafeteria-System-config-server
- Cafeteria-System-service-registry
- Cafeteria-System-api-gateway
- Cafeteria-System-user-service
- Cafeteria-System-menu-service
- Cafeteria-System-order-service
- Cafeteria-System-kitchen-service

### Auxiliary: Configurations Repository

**Cafeteria-System-Configurations**

- Not a submodule
- Contains YAML configuration files
- Referenced by config-server

## 🚀 Getting Started

### Initial Clone

```bash
# Clone with all nested submodules (2 levels deep)
git clone --recursive https://github.com/YOUR_USERNAME/Cafeteria-System-Main.git
cd Cafeteria-System-Main

# Verify structure
ls -la platform/
ls -la platform/config-server/
ls -la services/
ls -la services/user-service/
```

### If Already Cloned Without --recursive

```bash
cd Cafeteria-System-Main

# Initialize all nested submodules
git submodule update --init --recursive

# Verify
git submodule status --recursive
```

## 🛠️ Working with Nested Submodules

### Scenario 1: Modify a Single Service

```bash
# Navigate to the service
cd services/user-service

# Create branch and make changes
git checkout -b feature/add-role-validation
# ... make changes ...
git add .
git commit -m "Add role validation logic"
git push origin feature/add-role-validation

# Create PR and merge on GitHub

# After merge, update parent repository
cd ..  # Now in services/ (parent repo)
git pull  # Get latest
git add user-service
git commit -m "Update user-service to latest version"
git push origin main

# Update main repository
cd ..  # Now in Main repo
git add services
git commit -m "Update services parent to include user-service changes"
git push origin main
```

### Scenario 2: Build All Platform Services

```bash
cd platform/

# Build all platform services at once
mvn clean install

# This builds:
# - config-server
# - service-registry
# - api-gateway
```

### Scenario 3: Build All Business Services

```bash
cd services/

# Build all business services at once
mvn clean install

# This builds:
# - user-service
# - menu-service
# - order-service
# - kitchen-service
```

### Scenario 4: Deploy Platform Services with PM2

```bash
cd platform/

# Start all platform services
pm2 start ecosystem.config.js

# View status
pm2 status
```

### Scenario 5: Deploy Business Services with PM2

```bash
cd services/

# Start all business services
pm2 start ecosystem.config.js

# View status
pm2 status
```

### Scenario 6: Update All Submodules

```bash
# From Main repository root
git submodule update --remote --recursive --merge

# This updates:
# 1. platform parent repo
# 2. All services within platform
# 3. services parent repo
# 4. All services within services
# 5. webapp

# Commit the updates
git add .
git commit -m "Update all submodules to latest commits"
git push
```

## 📊 Benefits of This Structure

### For Instructors/Reviewers

✅ Clear separation of concerns (platform vs business)
✅ Easy to navigate and understand project organization
✅ Demonstrates understanding of enterprise patterns
✅ Shows ability to work with complex Git structures

### For Development Teams

✅ Platform team can work on infrastructure independently
✅ Business team can work on domain services independently
✅ Unified build reduces build complexity
✅ Group-level deployment configurations

### For CI/CD

✅ Can build/test platform services separately
✅ Can build/test business services separately
✅ Faster CI pipelines (only build what changed)
✅ Independent deployment pipelines per group

## 🔄 Common Workflows

### Add a New Service to Business Group

```bash
# 1. Create the new service repository
gh repo create Cafeteria-System-notification-service --public
# ... develop the service ...

# 2. Add to Services parent
cd services/
git submodule add https://github.com/YOUR_USERNAME/Cafeteria-System-notification-service.git notification-service

# 3. Update parent POM
# Edit pom.xml to add:
# <module>notification-service</module>

# 4. Update PM2 config
# Edit ecosystem.config.js to add notification-service

# 5. Commit and push
git add .
git commit -m "Add notification-service to services group"
git push

# 6. Update main repository
cd ..
git add services
git commit -m "Update services to include notification-service"
git push
```

### Remove a Service from a Group

```bash
cd services/

# Deinitialize submodule
git submodule deinit -f old-service

# Remove from git
git rm old-service

# Remove from .git/modules
rm -rf .git/modules/old-service

# Update pom.xml (remove module entry)
# Update ecosystem.config.js (remove service entry)

# Commit
git commit -m "Remove old-service from services group"
git push
```

### Work on Multiple Services Simultaneously

```bash
# Create feature branch in Main repo
git checkout -b feature/order-flow-improvements

# Create matching branches in affected services
cd services/order-service
git checkout -b feature/order-flow-improvements
# ... make changes ...
git add .
git commit -m "Improve order validation"
git push origin feature/order-flow-improvements
cd ../..

cd services/kitchen-service
git checkout -b feature/order-flow-improvements
# ... make changes ...
git add .
git commit -m "Improve order queue handling"
git push origin feature/order-flow-improvements
cd ../..

# Update services parent
cd services/
git add .
git commit -m "WIP: Order flow improvements across services"
git push

# Update main
cd ..
git add services
git commit -m "WIP: Order flow improvements"
git push origin feature/order-flow-improvements
```

## 🧪 Testing Strategies

### Test Platform Services

```bash
cd platform/
mvn test

# Or test individually
cd config-server && mvn test
cd ../service-registry && mvn test
cd ../api-gateway && mvn test
```

### Test Business Services

```bash
cd services/
mvn test

# Or test individually
cd user-service && mvn test
cd ../menu-service && mvn test
cd ../order-service && mvn test
cd ../kitchen-service && mvn test
```

### Integration Tests Across Groups

```bash
# Start platform services
cd platform/
pm2 start ecosystem.config.js

# Wait for services to be ready
sleep 10

# Start business services
cd ../services/
pm2 start ecosystem.config.js

# Run integration tests
cd ../
./run-integration-tests.sh
```

## 📚 Documentation Structure

Each repository level should have its own README:

1. **Main README** (Cafeteria-System-Main)
   - Overall architecture
   - Links to all repositories
   - Quick start guide

2. **Parent README** (Platform/Services)
   - Group-specific overview
   - Build instructions for the group
   - PM2 deployment for the group

3. **Service README** (Individual services)
   - Service-specific documentation
   - API endpoints
   - Configuration details

## 🔧 Troubleshooting

### Submodule is Empty

```bash
cd path/to/empty/submodule
git submodule update --init
```

### Submodule Points to Old Commit

```bash
cd path/to/submodule
git checkout main
git pull origin main
cd ../..
git add path/to/submodule
git commit -m "Update submodule to latest"
git push
```

### Parent POM Not Building All Services

Check that all services are listed as `<module>` entries:

```xml
<modules>
    <module>user-service</module>
    <module>menu-service</module>
    <module>order-service</module>
    <module>kitchen-service</module>
</modules>
```

### PM2 Not Starting Services

Check ecosystem.config.js paths are correct relative to parent directory:

```javascript
{
  name: 'user-service',
  script: 'java',
  args: ['-jar', 'user-service/target/user-service-1.0.0.jar'],
  cwd: './'  // Runs from parent directory
}
```

## 🎯 Best Practices

### 1. Commit Order

Always commit from innermost to outermost:

```
Service → Parent → Main
```

### 2. Keep Parents Clean

Parent repositories should only contain:

- Submodule references
- Parent POM
- PM2/Docker configs
- Group-level README
- .gitignore

### 3. Don't Modify Parent Code

Never add actual code to parent repositories. All code belongs in service repositories.

### 4. Regular Submodule Updates

Update submodules regularly to avoid drift:

```bash
# Weekly or after major changes
git submodule update --remote --recursive --merge
```

### 5. Use Relative URLs

For submodules, use HTTPS URLs (not SSH) for better compatibility:

```bash
# Good
git submodule add https://github.com/user/repo.git

# Less compatible
git submodule add git@github.com:user/repo.git
```

## 📖 Additional Resources

- [Git Submodules Official Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [Maven Multi-Module Projects](https://maven.apache.org/guides/mini/guide-multiple-modules.html)
- [PM2 Documentation](https://pm2.keymetrics.io/docs/usage/quick-start/)

## 🆘 Getting Help

If you encounter issues:

1. Check submodule status: `git submodule status --recursive`
2. View submodule configuration: `cat .gitmodules`
3. Check parent POM: Verify all modules are listed
4. Check PM2 config: Verify paths are relative to parent
5. Consult Git submodule documentation

---

**Course**: ITS 2130 Enterprise Cloud Architecture
**Pattern**: Nested Polyrepo with Parent Repositories
**Benefits**: Logical grouping, unified builds, better organization
