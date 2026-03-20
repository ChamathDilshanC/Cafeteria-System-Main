# README Files Distribution Guide

This document provides instructions for copying the professional README files to each individual sub-repository in your Polyrepo structure.

## 📁 README Files Created

All README files are located in the `docs/` folder:

| README File                  | Target Repository                   | Description                             |
| ---------------------------- | ----------------------------------- | --------------------------------------- |
| `README-config-server.md`    | `Cafeteria-System-config-server`    | Config Server documentation             |
| `README-service-registry.md` | `Cafeteria-System-service-registry` | Service Registry (Eureka) documentation |
| `README-api-gateway.md`      | `Cafeteria-System-api-gateway`      | API Gateway documentation               |
| `README-user-service.md`     | `Cafeteria-System-user-service`     | User Service documentation              |
| `README-menu-service.md`     | `Cafeteria-System-menu-service`     | Menu Service documentation              |
| `README-order-service.md`    | `Cafeteria-System-order-service`    | Order Service documentation             |
| `README-kitchen-service.md`  | `Cafeteria-System-kitchen-service`  | Kitchen Service documentation           |
| `README-webapp.md`           | `Cafeteria-System-webapp`           | Web Application documentation           |

## 🚀 Quick Copy Script

### Option 1: Manual Copy (Before Creating Repositories)

Before running `create-polyrepo.sh`, copy the README files to their respective service folders:

```bash
#!/bin/bash

# Copy READMEs to their service directories
cp docs/README-config-server.md platform/config-server/README.md
cp docs/README-service-registry.md platform/service-registry/README.md
cp docs/README-api-gateway.md platform/api-gateway/README.md
cp docs/README-user-service.md services/user-service/README.md
cp docs/README-menu-service.md services/menu-service/README.md
cp docs/README-order-service.md services/order-service/README.md
cp docs/README-kitchen-service.md services/kitchen-service/README.md
cp docs/README-webapp.md webapp/README.md

echo "✅ All README files copied successfully!"
```

Save this as `copy-readmes.sh` and run:

```bash
chmod +x copy-readmes.sh
./copy-readmes.sh
```

Then proceed with the polyrepo creation:

```bash
./create-polyrepo.sh
```

### Option 2: Copy After Repository Creation

If you've already created the repositories, you can add the README files and commit them:

```bash
#!/bin/bash

ORIGINAL_DIR="$(pwd)"

# Function to add README to a service
add_readme_to_service() {
    local service_path=$1
    local readme_file=$2

    cd "$ORIGINAL_DIR/$service_path"

    # Copy README
    cp "$ORIGINAL_DIR/docs/$readme_file" README.md

    # Git add, commit, and push
    git add README.md
    git commit -m "docs: Add comprehensive README documentation"
    git push origin main

    echo "✅ README added to $service_path"

    cd "$ORIGINAL_DIR"
}

# Add README to each service
add_readme_to_service "platform/config-server" "README-config-server.md"
add_readme_to_service "platform/service-registry" "README-service-registry.md"
add_readme_to_service "platform/api-gateway" "README-api-gateway.md"
add_readme_to_service "services/user-service" "README-user-service.md"
add_readme_to_service "services/menu-service" "README-menu-service.md"
add_readme_to_service "services/order-service" "README-order-service.md"
add_readme_to_service "services/kitchen-service" "README-kitchen-service.md"
add_readme_to_service "webapp" "README-webapp.md"

echo "✅ All README files added and pushed!"
```

Save as `add-readmes-to-repos.sh` and run:

```bash
chmod +x add-readmes-to-repos.sh
./add-readmes-to-repos.sh
```

## 📝 Manual Copy Instructions

If you prefer to copy files manually:

### 1. Config Server

```bash
cp docs/README-config-server.md platform/config-server/README.md
cd platform/config-server
git add README.md
git commit -m "docs: Add comprehensive README"
git push origin main
cd ../..
```

### 2. Service Registry

```bash
cp docs/README-service-registry.md platform/service-registry/README.md
cd platform/service-registry
git add README.md
git commit -m "docs: Add comprehensive README"
git push origin main
cd ../..
```

### 3. API Gateway

```bash
cp docs/README-api-gateway.md platform/api-gateway/README.md
cd platform/api-gateway
git add README.md
git commit -m "docs: Add comprehensive README"
git push origin main
cd ../..
```

### 4. User Service

```bash
cp docs/README-user-service.md services/user-service/README.md
cd services/user-service
git add README.md
git commit -m "docs: Add comprehensive README"
git push origin main
cd ../..
```

### 5. Menu Service

```bash
cp docs/README-menu-service.md services/menu-service/README.md
cd services/menu-service
git add README.md
git commit -m "docs: Add comprehensive README"
git push origin main
cd ../..
```

### 6. Order Service

```bash
cp docs/README-order-service.md services/order-service/README.md
cd services/order-service
git add README.md
git commit -m "docs: Add comprehensive README"
git push origin main
cd ../..
```

### 7. Kitchen Service

```bash
cp docs/README-kitchen-service.md services/kitchen-service/README.md
cd services/kitchen-service
git add README.md
git commit -m "docs: Add comprehensive README"
git push origin main
cd ../..
```

### 8. Web Application

```bash
cp docs/README-webapp.md webapp/README.md
cd webapp
git add README.md
git commit -m "docs: Add comprehensive README"
git push origin main
cd ..
```

## 🔄 Update Main Repository

After adding README files to all submodules, update the main repository to reference the latest commits:

```bash
# In the main repository directory
git submodule update --remote --merge

# Commit the updated submodule references
git add .
git commit -m "Update all submodules with README documentation"
git push origin main
```

## ✅ Verification

After copying all README files, verify they appear correctly on GitHub:

1. **Check Individual Repositories:**

   ```bash
   # List all your repositories
   gh repo list

   # View specific repository
   gh repo view YOUR_USERNAME/Cafeteria-System-user-service
   ```

2. **Check on GitHub Web Interface:**
   - Visit each repository URL
   - Verify README.md is displayed on the repository homepage
   - Check that badges, code blocks, and tables render correctly

3. **Check Main Repository:**
   - Visit the main repository
   - Verify submodule links point to repositories with READMEs

## 📋 README Checklist

Use this checklist to ensure all READMEs are properly added:

- [ ] Config Server (`Cafeteria-System-config-server`)
- [ ] Service Registry (`Cafeteria-System-service-registry`)
- [ ] API Gateway (`Cafeteria-System-api-gateway`)
- [ ] User Service (`Cafeteria-System-user-service`)
- [ ] Menu Service (`Cafeteria-System-menu-service`)
- [ ] Order Service (`Cafeteria-System-order-service`)
- [ ] Kitchen Service (`Cafeteria-System-kitchen-service`)
- [ ] Web Application (`Cafeteria-System-webapp`)
- [ ] Main Repository updated with submodule changes

## 🎯 What Each README Includes

Each README contains:

✅ **Overview**: Service description and purpose
✅ **Features**: Key capabilities
✅ **Tech Stack**: Technologies used with versions
✅ **Configuration**: Port numbers, database info
✅ **Installation**: Step-by-step setup instructions
✅ **API Endpoints**: Complete API documentation with examples
✅ **Testing**: How to test the service
✅ **Docker Deployment**: Container setup
✅ **Cloud Deployment**: GCP deployment instructions
✅ **Troubleshooting**: Common issues and solutions
✅ **Integration**: How service connects with others

### Special Highlights

- **User Service**: JWT authentication with JJWT 0.12.6
- **Menu Service**: Google Cloud Storage integration for images
- **Order Service**: OpenFeign inter-service communication
- **Kitchen Service**: MongoDB database usage
- **API Gateway**: Spring Cloud Gateway 2025.x routing logic
- **Web Application**: Frontend consuming API Gateway

## 🛠️ Customization Tips

Before distributing:

1. **Update GitHub Username**: Replace placeholder links in README-webapp.md
2. **Update API Endpoints**: If you have custom endpoints
3. **Add Screenshots**: Consider adding UI screenshots to webapp README
4. **Update GCP Details**: Add your specific GCP project ID and bucket names

## 📞 Need Help?

If you encounter issues while copying READMEs:

1. Check file paths are correct
2. Ensure you're in the correct directory
3. Verify git repositories are initialized
4. Check remote repositories exist on GitHub

## 🎓 Academic Submission

Your instructor will appreciate:

✅ Professional documentation for each service
✅ Clear architecture diagrams and flow charts
✅ Complete API endpoint documentation
✅ Deployment instructions for GCP
✅ Technology stack clearly stated with versions
✅ Inter-service communication explained

---

**Recommendation**: Copy READMEs **before** running `create-polyrepo.sh` so they're included in the initial repository creation.

Good luck with your ITS 2130 final project submission! 🚀
