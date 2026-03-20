# Git Submodules Quick Reference

Common commands for working with the Cafeteria System Polyrepo structure.

## 🚀 Initial Setup

```bash
# Clone with all submodules (recommended)
git clone --recursive https://github.com/YOUR_USERNAME/Cafeteria-System-Main.git

# OR clone first, then initialize submodules
git clone https://github.com/YOUR_USERNAME/Cafeteria-System-Main.git
cd Cafeteria-System-Main
git submodule update --init --recursive
```

## 📊 Checking Status

```bash
# View all submodules and their current commits
git submodule status

# Check if any submodule has uncommitted changes
git submodule foreach git status

# Show detailed information about submodules
git submodule foreach 'echo "=== $name ===" && git status'
```

## 🔄 Updating Submodules

```bash
# Update all submodules to latest remote commit
git submodule update --remote --merge

# Update a specific submodule
git submodule update --remote services/user-service

# Pull latest changes in all submodules
git submodule foreach git pull origin main
```

## ✏️ Making Changes in a Submodule

```bash
# 1. Navigate to the submodule
cd services/user-service

# 2. Create a branch (optional but recommended)
git checkout -b feature/new-feature

# 3. Make changes and commit
git add .
git commit -m "Add new feature"

# 4. Push to the submodule's remote
git push origin main  # or your branch name

# 5. Return to main repository
cd ../..

# 6. Update main repo to reference the new commit
git add services/user-service
git commit -m "Update user-service to include new feature"
git push
```

## 🔀 Working with Multiple Submodules

```bash
# Execute a command in all submodules
git submodule foreach 'git checkout main'
git submodule foreach 'git pull origin main'

# Check which branch each submodule is on
git submodule foreach 'git branch --show-current'

# Create a new branch in all submodules
git submodule foreach 'git checkout -b feature/new-branch'
```

## 🆕 Adding a New Submodule

```bash
# Add a new service repository as a submodule
git submodule add https://github.com/YOUR_USERNAME/Cafeteria-System-notification-service.git services/notification-service

# Commit the new submodule
git add .gitmodules services/notification-service
git commit -m "Add notification-service submodule"
git push
```

## 🗑️ Removing a Submodule

```bash
# 1. Deinitialize the submodule
git submodule deinit -f services/old-service

# 2. Remove the submodule directory
git rm -f services/old-service

# 3. Remove from .git/modules
rm -rf .git/modules/services/old-service

# 4. Commit the removal
git commit -m "Remove old-service submodule"
git push
```

## 🔄 Syncing After Submodule Updates

```bash
# Someone else updated submodules, sync to their changes
git pull
git submodule update --init --recursive

# Reset submodules to match the main repo's recorded commits
git submodule update --recursive
```

## 🐛 Troubleshooting

### Submodule is in "detached HEAD" state

```bash
cd services/user-service
git checkout main
git pull origin main
cd ../..
git add services/user-service
git commit -m "Update user-service reference"
```

### Submodule has uncommitted changes blocking update

```bash
cd services/user-service
git stash
git checkout main
git pull
git stash pop
```

### Reset all submodules to clean state

```bash
git submodule foreach --recursive git reset --hard
git submodule foreach --recursive git clean -fd
git submodule update --init --recursive
```

### Submodule directory is empty

```bash
git submodule update --init --recursive
```

### Remove all submodules and re-initialize

```bash
git submodule deinit -f .
git submodule update --init --recursive
```

## 🔍 Viewing Submodule Differences

```bash
# Show which commit each submodule is at
git diff --submodule

# Show detailed diff including submodule changes
git diff --submodule=diff

# Show changes in a specific submodule
git diff HEAD:services/user-service
```

## 🌿 Working with Branches

```bash
# Create a branch in main repo and all submodules
git checkout -b feature/new-feature
git submodule foreach 'git checkout -b feature/new-feature'

# Switch back to main branch everywhere
git checkout main
git submodule foreach 'git checkout main'
```

## 📦 Building After Submodule Updates

```bash
# Update all submodules and build
git submodule update --remote --merge
./build-all.sh

# Or if you need a clean build
git submodule foreach 'mvn clean'
./build-all.sh
```

## 🚀 Deployment Workflow

```bash
# 1. Update all submodules to latest
git submodule update --remote --merge

# 2. Test locally
docker-compose up -d
./build-all.sh
# ... test services ...

# 3. Commit submodule updates
git add .
git commit -m "Update all services to latest versions for deployment"
git push

# 4. Deploy (using PM2 on GCP)
pm2 restart ecosystem.config.js
```

## 📝 Configuration for CI/CD

```yaml
# GitHub Actions example for main repository
- name: Checkout with submodules
  uses: actions/checkout@v4
  with:
    submodules: recursive

# Or use command
- name: Update submodules
  run: git submodule update --init --recursive
```

## 🎯 Best Practices

✅ **Always commit in submodule first**: Change → Commit → Push in submodule, then update main repo

✅ **Keep submodules on main branch**: Avoid detached HEAD state by checking out main after making changes

✅ **Document dependencies**: If a service depends on another service's changes, coordinate updates

✅ **Use branches for features**: Create feature branches in submodules when working on new features

✅ **Regular updates**: Periodically update all submodules to stay current

✅ **Test before pushing**: Always test the entire system after updating submodules

## 🔗 Useful Aliases

Add these to your `~/.gitconfig`:

```ini
[alias]
    # Show submodule status
    sub-status = submodule foreach 'echo "=== $name ===" && git status -s'

    # Update all submodules
    sub-update = submodule update --remote --merge

    # Pull main and all submodules
    sub-pull = !git pull && git submodule update --init --recursive

    # Show all submodule branches
    sub-branch = submodule foreach 'echo "$name: $(git branch --show-current)"'

    # Checkout main in all submodules
    sub-main = submodule foreach 'git checkout main'
```

Usage:

```bash
git sub-status
git sub-update
git sub-pull
git sub-branch
git sub-main
```

## 📞 Getting Help

```bash
# View git submodule help
git submodule --help

# View specific command help
git submodule add --help
git submodule update --help
```

---

**Quick Tip**: Create a script to automate common workflows. For example, `update-all.sh`:

```bash
#!/bin/bash
echo "Updating all submodules..."
git submodule update --remote --merge
echo "Building all services..."
./build-all.sh
echo "Running tests..."
# Add your test commands here
echo "✅ All updates complete!"
```

---

**Course**: ITS 2130 Enterprise Cloud Architecture
**Project**: Cafeteria Management System (Polyrepo)
