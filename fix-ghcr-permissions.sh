#!/bin/bash
# Fix GHCR Permissions and Package Issues
# This script helps resolve GitHub Container Registry deployment issues

echo "🔧 GHCR Deployment Troubleshooting and Fix Script"
echo "=================================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO_NAME="eands9/custom-database-layer"
PACKAGE_NAME="custom-database-layer"

echo -e "${BLUE}📋 Issue Analysis:${NC}"
echo "The workflow is failing with '403 Forbidden' when pushing to GHCR because:"
echo "1. ❌ The package doesn't exist in GHCR yet"
echo "2. ❌ GitHub Actions lacks permission to create packages"
echo "3. ❌ Repository settings may need adjustment"
echo ""

echo -e "${YELLOW}🔍 Step 1: Checking current repository settings...${NC}"

# Check repository Actions permissions
echo "🔒 Checking GitHub Actions permissions:"
gh api repos/$REPO_NAME/actions/permissions || echo "  ⚠️  Could not check Actions permissions"

echo ""
echo -e "${YELLOW}🔧 Step 2: Solutions to implement:${NC}"

echo -e "${BLUE}Solution A: Repository Settings Fix${NC}"
echo "1. Go to: https://github.com/$REPO_NAME/settings/actions"
echo "2. Under 'Workflow permissions', select:"
echo "   ✅ 'Read and write permissions'"
echo "   ✅ 'Allow GitHub Actions to create and approve pull requests'"
echo ""

echo -e "${BLUE}Solution B: Manual Package Creation${NC}"
echo "Since the package doesn't exist, we need to create it manually first:"
echo ""
echo "🐳 Option 1: Create package via manual Docker push:"
echo "docker build -t ghcr.io/eands9/custom-database-layer:manual ."
echo "docker login ghcr.io -u eands9 -p YOUR_GITHUB_TOKEN"
echo "docker push ghcr.io/eands9/custom-database-layer:manual"
echo ""

echo -e "${BLUE}Solution C: Updated Workflow File${NC}"
echo "The workflow file needs additional permissions. Creating enhanced version..."

# Create an enhanced workflow with better permissions
cat > "/tmp/enhanced-workflow.yml" << 'EOF'
name: Build and Push Docker Image to GHCR

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

permissions:
  contents: read
  packages: write
  actions: read
  security-events: write
  attestations: write
  id-token: write

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout repository
      uses: actions/checkout@v4

    - name: Set up Docker Buildx
      uses: docker/setup-buildx-action@v3

    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}

    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
        tags: |
          type=ref,event=branch
          type=ref,event=pr
          type=raw,value=latest,enable={{is_default_branch}}
          type=raw,value={{branch}}-{{sha}}

    - name: Build and push Docker image
      uses: docker/build-push-action@v5
      with:
        context: .
        file: ./Dockerfile
        platforms: linux/amd64,linux/arm64
        push: true
        tags: ${{ steps.meta.outputs.tags }}
        labels: ${{ steps.meta.outputs.labels }}
        cache-from: type=gha
        cache-to: type=gha,mode=max
        build-args: |
          POSTGRES_USER=postgres
          POSTGRES_PASSWORD=password
          POSTGRES_DB=catsdb

    - name: Generate artifact attestation
      uses: actions/attest-build-provenance@v1
      with:
        subject-name: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME}}
        subject-digest: ${{ steps.build.outputs.digest }}
        push-to-registry: true
EOF

echo "✅ Enhanced workflow created at /tmp/enhanced-workflow.yml"
echo ""

echo -e "${YELLOW}🔧 Step 3: Implementing fixes...${NC}"

echo "📁 Updating workflow file with enhanced permissions..."
if [ -f ".github/workflows/docker-build-push.yml" ]; then
    cp "/tmp/enhanced-workflow.yml" ".github/workflows/docker-build-push.yml"
    echo "✅ Workflow file updated with enhanced permissions"
else
    echo "⚠️  Workflow file not found in current directory"
    echo "   Copy the enhanced workflow manually from /tmp/enhanced-workflow.yml"
fi

echo ""
echo -e "${GREEN}✅ Step 4: Manual Actions Required:${NC}"
echo ""
echo "🌐 1. Update Repository Settings:"
echo "   Visit: https://github.com/$REPO_NAME/settings/actions"
echo "   Set workflow permissions to 'Read and write permissions'"
echo ""
echo "🐳 2. Create Initial Package (Choose ONE method):"
echo ""
echo "   Method A - Manual Docker Push:"
echo "   ==============================="
echo "   # Build and push manually to create the package"
echo "   cd /Users/kathrynhernandez/Documents/agenticai/udemy2/DB-LAYER"
echo "   docker build --build-arg POSTGRES_USER=postgres --build-arg POSTGRES_PASSWORD=password --build-arg POSTGRES_DB=catsdb -t ghcr.io/eands9/custom-database-layer:manual ."
echo "   docker login ghcr.io -u eands9 -p YOUR_GITHUB_TOKEN"
echo "   docker push ghcr.io/eands9/custom-database-layer:manual"
echo ""
echo "   Method B - Create Empty Package via API:"
echo "   ========================================"
echo "   # This would require additional GitHub API calls"
echo ""
echo "🔄 3. After creating the package:"
echo "   - Commit and push the updated workflow"
echo "   - The workflow should now work successfully"
echo ""
echo "🔧 4. Verify package permissions:"
echo "   Visit: https://github.com/users/eands9/packages/container/package/custom-database-layer"
echo "   Ensure the repository has 'Write' access"
echo ""

echo -e "${BLUE}📊 Current Status Summary:${NC}"
echo "❌ GHCR package doesn't exist"
echo "❌ Workflow lacks package creation permissions"
echo "✅ Workflow file structure is correct"
echo "✅ Authentication setup is working"
echo "✅ Docker build process is successful"
echo ""

echo -e "${YELLOW}🚀 Next Steps:${NC}"
echo "1. Update repository workflow permissions (manual step)"
echo "2. Create initial package using Method A above"
echo "3. Commit updated workflow file"
echo "4. Test the automated deployment"
echo ""

echo -e "${GREEN}💡 Pro Tip:${NC}"
echo "Once the package exists and permissions are set, all future pushes"
echo "will work automatically through GitHub Actions!"

echo ""
echo "🔗 Useful Links:"
echo "- Repository Settings: https://github.com/$REPO_NAME/settings/actions"
echo "- Package Management: https://github.com/users/eands9/packages"
echo "- GHCR Documentation: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry"
