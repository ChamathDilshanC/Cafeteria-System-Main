# GitHub Polyrepo Setup Guide

This guide will help you restructure your Cafeteria Management System into a Polyrepo architecture with individual GitHub repositories for each service.

## 📋 Prerequisites

Before running the setup scripts, ensure you have:

1. **GitHub CLI (gh)** installed and authenticated

   ```bash
   # Install gh CLI
   # Windows: winget install GitHub.cli
   # Mac: brew install gh
   # Linux: See https://github.com/cli/cli#installation

   # Authenticate
   gh auth login
   ```

2. **Git** installed

   ```bash
   git --version
   ```

3. **Java 25** installed

   ```bash
   java -version
   ```

4. **Maven 3.9+** installed
   ```bash
   mvn -version
   ```

## 🚀 Quick Start

### Step 1: Verify Requirements

First, run the verification script to ensure your project meets all requirements:

```bash
# On Unix/Linux/Mac
chmod +x verify-requirements.sh
./verify-requirements.sh

# On Windows (Git Bash)
bash verify-requirements.sh
```

This script will check:

- Java 25 is installed
- All services use correct Spring Boot (4.0.3) and Spring Cloud (2025.1.0) versions
- CONFIG_SERVER_URI is properly configured for cloud deployment
- Eureka client configuration is present
- API Gateway uses correct Spring Cloud Gateway 2025.x namespace
- Centralized configuration files exist

### Step 2: Create Polyrepo Structure

Once verification passes, run the polyrepo setup script:

```bash
# On Unix/Linux/Mac
chmod +x create-polyrepo.sh
./create-polyrepo.sh

# On Windows (Git Bash)
bash create-polyrepo.sh
```

## 📦 What the Script Does

The `create-polyrepo.sh` script will:

1. **Create individual GitHub repositories** for each service with the naming pattern:
   - `Cafeteria-System-config-server`
   - `Cafeteria-System-service-registry`
   - `Cafeteria-System-api-gateway`
   - `Cafeteria-System-user-service`
   - `Cafeteria-System-menu-service`
   - `Cafeteria-System-order-service`
   - `Cafeteria-System-kitchen-service`
   - `Cafeteria-System-webapp`

2. **Initialize git** in each service directory

3. **Create `.gitignore`** files for each service

4. **Push code** to GitHub for each service

5. **Create a main repository** (`Cafeteria-System-Main`) that contains:
   - All services as git submodules maintaining folder structure
   - Root configuration files (docker-compose.yml, ecosystem.config.js)
   - Build scripts (build-all.sh, build-all.bat)
   - README.md with complete documentation

## 📁 Repository Structure

After running the script, you'll have:

```
Cafeteria-System-Main (Main Repository)
├── platform/
│   ├── config-server/          → Submodule: Cafeteria-System-config-server
│   ├── service-registry/       → Submodule: Cafeteria-System-service-registry
│   └── api-gateway/            → Submodule: Cafeteria-System-api-gateway
├── services/
│   ├── user-service/           → Submodule: Cafeteria-System-user-service
│   ├── menu-service/           → Submodule: Cafeteria-System-menu-service
│   ├── order-service/          → Submodule: Cafeteria-System-order-service
│   └── kitchen-service/        → Submodule: Cafeteria-System-kitchen-service
├── webapp/                     → Submodule: Cafeteria-System-webapp
├── docker-compose.yml
├── ecosystem.config.js
├── build-all.sh
├── build-all.bat
└── README.md
```

## 🔄 Cloning the Complete Project

After setup, anyone can clone your entire project with:

```bash
# Clone with all submodules
git clone --recursive https://github.com/YOUR_USERNAME/Cafeteria-System-Main.git

# OR if already cloned
cd Cafeteria-System-Main
git submodule update --init --recursive
```

## 🛠️ Working with Submodules

### Making Changes to a Service

```bash
# Navigate to the service
cd services/user-service

# Make your changes
# ... edit files ...

# Commit and push in the submodule
git add .
git commit -m "Update user authentication"
git push origin main

# Return to main repo and update submodule reference
cd ../..
git add services/user-service
git commit -m "Update user-service to latest version"
git push
```

### Updating All Submodules

```bash
# Pull latest changes for all submodules
git submodule update --remote --merge

# Commit the updated references
git add .
git commit -m "Update all submodules to latest versions"
git push
```

### Viewing Submodule Status

```bash
# Show current commit for each submodule
git submodule status

# Show if submodules have uncommitted changes
git submodule foreach git status
```

## ✅ Verification Steps

After running the script:

1. **Check all repositories were created:**

   ```bash
   gh repo list
   ```

2. **Verify main repository:**

   ```bash
   gh repo view YOUR_USERNAME/Cafeteria-System-Main
   ```

3. **Test cloning in a new directory:**

   ```bash
   cd /tmp
   git clone --recursive https://github.com/YOUR_USERNAME/Cafeteria-System-Main.git
   cd Cafeteria-System-Main
   ls -la
   ```

4. **Verify all submodules loaded:**

   ```bash
   git submodule status
   # Should show 8 submodules with commit hashes
   ```

5. **Build all services:**
   ```bash
   ./build-all.sh
   ```

## 🎓 Benefits of Polyrepo Architecture

✅ **Independent versioning**: Each service has its own version history
✅ **Focused repositories**: Easier to navigate and understand individual services
✅ **Granular access control**: Can set different permissions per repository
✅ **Smaller clones**: Can clone individual services when needed
✅ **Better CI/CD**: Can deploy services independently
✅ **Clear ownership**: Each team can own specific service repositories

## 🔧 Troubleshooting

### "Repository already exists" Error

The script will prompt you to delete and recreate. Alternatively:

```bash
gh repo delete YOUR_USERNAME/Cafeteria-System-user-service --yes
```

### Authentication Issues

```bash
# Check auth status
gh auth status

# Re-authenticate
gh auth login
```

### Submodule Issues

```bash
# Reset submodules
git submodule deinit -f .
git submodule update --init --recursive
```

### Permission Denied

```bash
# Make scripts executable
chmod +x create-polyrepo.sh verify-requirements.sh
```

## 📝 Important Notes

1. **Original directory preserved**: The script does NOT modify your original project directory. It creates a new temporary directory for the main repository.

2. **Verify before submitting**: Always test cloning the main repository in a fresh directory before submitting your project.

3. **Config Server URI**: Ensure all services can reach the config server when deployed to cloud. The verification script checks for `${CONFIG_SERVER_URI}` environment variable support.

4. **Database initialization**: Don't forget to include `init-scripts/` in your main repository.

5. **Documentation**: Update the README in the main repository with your actual GitHub username.

## 🎯 Next Steps After Setup

1. ✅ Test clone in a fresh directory
2. ✅ Verify all services build successfully
3. ✅ Test local deployment with Docker Compose
4. ✅ Update documentation with your GitHub username
5. ✅ Configure GCP deployment settings
6. ✅ Add any additional documentation to individual service repos
7. ✅ Set up CI/CD pipelines if needed
8. ✅ Configure branch protection rules on GitHub

## 📚 Additional Resources

- [Git Submodules Documentation](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [Spring Cloud Config](https://docs.spring.io/spring-cloud-config/docs/current/reference/html/)
- [Polyrepo vs Monorepo](https://github.com/joelparkerhenderson/monorepo-vs-polyrepo)

## 🆘 Getting Help

If you encounter issues:

1. Check the script output for specific error messages
2. Run the verification script to identify configuration issues
3. Verify GitHub authentication: `gh auth status`
4. Check service logs if deployment fails
5. Review individual service pom.xml files for correct versions

---

**Course**: ITS 2130 - Enterprise Cloud Architecture
**Project**: Food Pre-Order & Cafeteria Management System
**Architecture**: Microservices (Polyrepo)
