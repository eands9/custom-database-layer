#!/bin/bash
# Quick Setup Script for GHCR Package Creation
# Run this after updating repository permissions

echo "🚀 Quick GHCR Package Creation Script"
echo "====================================="

# Check if we're in the right directory
if [ ! -f "Dockerfile" ]; then
    echo "❌ Error: Dockerfile not found. Please run this from the DB-LAYER directory."
    exit 1
fi

if [ ! -f "create-data.sql" ]; then
    echo "❌ Error: create-data.sql not found. Please run this from the DB-LAYER directory."
    exit 1
fi

echo "✅ Found required files: Dockerfile and create-data.sql"
echo ""

echo "🔑 Step 1: GitHub Token Setup"
echo "Before proceeding, you need a GitHub Personal Access Token with 'write:packages' scope."
echo ""
echo "To create one:"
echo "1. Go to: https://github.com/settings/tokens"
echo "2. Click 'Generate new token (classic)'"
echo "3. Select scopes: write:packages, read:packages"
echo "4. Copy the token"
echo ""

read -p "Do you have your GitHub token ready? (y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Please get your token first, then run this script again."
    exit 1
fi

echo ""
echo "🐳 Step 2: Docker Build and Push"
echo ""

echo "Building Docker image..."
docker build --build-arg POSTGRES_USER=postgres --build-arg POSTGRES_PASSWORD=password --build-arg POSTGRES_DB=catsdb -t ghcr.io/eands9/custom-database-layer:manual . || {
    echo "❌ Docker build failed. Please check the Dockerfile and try again."
    exit 1
}

echo "✅ Docker image built successfully!"
echo ""

echo "🔐 Logging into GitHub Container Registry..."
echo "Enter your GitHub token when prompted:"
docker login ghcr.io -u eands9 || {
    echo "❌ Login failed. Please check your token and try again."
    exit 1
}

echo "✅ Successfully logged into GHCR!"
echo ""

echo "📦 Pushing Docker image to create GHCR package..."
docker push ghcr.io/eands9/custom-database-layer:manual || {
    echo "❌ Push failed. Please check permissions and try again."
    exit 1
}

echo ""
echo "🎉 SUCCESS! GHCR package created successfully!"
echo ""
echo "✅ Next steps:"
echo "1. Visit: https://github.com/users/eands9/packages/container/package/custom-database-layer"
echo "2. Verify the package was created"
echo "3. Check package visibility settings (should be public for easier access)"
echo "4. Commit and push the updated workflow file to test automation"
echo ""

echo "🔄 Test the automated workflow:"
echo "cd /Users/kathrynhernandez/Documents/agenticai/udemy2/DB-LAYER"
echo "git add ."
echo "git commit -m 'Fix GHCR permissions and update workflow'"
echo "git push"
echo ""

echo "📊 Package URL: https://github.com/users/eands9/packages/container/package/custom-database-layer"
echo "🔗 Repository: https://github.com/eands9/custom-database-layer"
