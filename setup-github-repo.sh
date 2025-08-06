#!/bin/bash
# GitHub Repository Setup Script for Custom Database Layer

set -e

# Configuration
REPO_NAME="custom-database-layer"
GITHUB_USERNAME="eands9"
REPO_DESCRIPTION="PostgreSQL Docker container with cats database and automated GHCR builds"

echo "🚀 GitHub Repository Setup for Custom Database Layer"
echo "=================================================="
echo "Repository: ${GITHUB_USERNAME}/${REPO_NAME}"
echo "Description: ${REPO_DESCRIPTION}"
echo "=================================================="

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ Error: $1 is not installed or not in PATH"
        echo "💡 Install with: brew install $1"
        exit 1
    fi
}

# Check prerequisites
echo "🔍 Checking prerequisites..."
check_command git
check_command gh
echo "✅ Prerequisites check passed"

# Check GitHub CLI authentication
echo "🔍 Checking GitHub CLI authentication..."
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub CLI"
    echo "💡 Please run: gh auth login"
    exit 1
fi
echo "✅ GitHub CLI authenticated"

# Initialize git repository if not already initialized
if [ ! -d ".git" ]; then
    echo "📝 Initializing Git repository..."
    git init
    echo "✅ Git repository initialized"
else
    echo "✅ Git repository already exists"
fi

# Create/Update .gitignore if needed
if [ ! -f ".gitignore" ]; then
    echo "📝 Creating .gitignore..."
    cat > .gitignore << 'EOF'
.env
__pycache__/
*.py[cod]
.vscode/
.DS_Store
*.log
EOF
    echo "✅ .gitignore created"
fi

# Stage all files
echo "📝 Staging files for commit..."
git add .

# Check if there are any changes to commit
if git diff --staged --quiet; then
    echo "ℹ️ No changes to commit"
else
    # Commit changes
    echo "💾 Committing changes..."
    git commit -m "Initial commit: PostgreSQL Docker container with cats database

- Added Dockerfile with PostgreSQL 15 Alpine
- Added create-data.sql with cats table and sample data
- Added GitHub Actions workflow for automated builds
- Added Python scripts for database interaction
- Added comprehensive documentation
- Configured environment variables support
- Added GHCR deployment automation"
    echo "✅ Changes committed"
fi

# Create GitHub repository
echo "🌐 Creating GitHub repository..."
if gh repo view ${GITHUB_USERNAME}/${REPO_NAME} &> /dev/null; then
    echo "ℹ️ Repository ${GITHUB_USERNAME}/${REPO_NAME} already exists"
    read -p "❓ Do you want to continue with the existing repository? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Setup cancelled"
        exit 1
    fi
else
    gh repo create ${REPO_NAME} \
        --description "${REPO_DESCRIPTION}" \
        --public \
        --add-readme=false
    echo "✅ GitHub repository created"
fi

# Set up remote if not exists
if ! git remote get-url origin &> /dev/null; then
    echo "🔗 Adding remote origin..."
    git remote add origin https://github.com/${GITHUB_USERNAME}/${REPO_NAME}.git
    echo "✅ Remote origin added"
else
    echo "✅ Remote origin already exists"
fi

# Set default branch to main
echo "🌿 Setting up main branch..."
git branch -M main

# Push to GitHub
echo "📤 Pushing to GitHub..."
git push -u origin main
echo "✅ Code pushed to GitHub"

# Set up branch protection (optional)
read -p "🛡️ Do you want to set up branch protection for main? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🛡️ Setting up branch protection..."
    gh api repos/${GITHUB_USERNAME}/${REPO_NAME}/branches/main/protection \
        --method PUT \
        --field required_status_checks='{"strict":true,"contexts":[]}' \
        --field enforce_admins=true \
        --field required_pull_request_reviews='{"required_approving_review_count":1}' \
        --field restrictions=null \
        2>/dev/null || echo "⚠️ Branch protection setup failed (may require admin permissions)"
fi

# Create initial release tag
read -p "🏷️ Do you want to create an initial release tag (v1.0.0)? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🏷️ Creating release tag..."
    git tag -a v1.0.0 -m "Initial release v1.0.0

Features:
- PostgreSQL 15 Alpine base image
- Pre-populated cats database with sample data
- GitHub Actions automated builds
- Multi-platform support (AMD64, ARM64)
- Security scanning with Trivy
- Environment variables configuration
- Python interaction scripts"
    
    git push origin v1.0.0
    echo "✅ Release tag v1.0.0 created and pushed"
fi

# Display summary
echo ""
echo "🎉 Repository setup completed successfully!"
echo "=============================================="
echo "📦 Repository URL: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}"
echo "🔄 Actions: https://github.com/${GITHUB_USERNAME}/${REPO_NAME}/actions"
echo "📊 Packages: https://github.com/users/${GITHUB_USERNAME}/packages/container/package/${REPO_NAME}"
echo "=============================================="
echo ""
echo "🚀 Next steps:"
echo "1. Wait for GitHub Actions to build and push the Docker image"
echo "2. Check the Actions tab for build progress"
echo "3. Once built, pull your image with:"
echo "   docker pull ghcr.io/${GITHUB_USERNAME}/${REPO_NAME}:latest"
echo ""
echo "📝 To trigger a new build:"
echo "1. Make changes to your code"
echo "2. Commit and push: git add . && git commit -m 'Update' && git push"
echo "3. Or create a new tag: git tag v1.0.1 && git push origin v1.0.1"
echo ""
echo "✨ Happy coding!"
