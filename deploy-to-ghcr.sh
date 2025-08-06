#!/bin/bash
# Deploy script for pushing local Docker image to GitHub Container Registry (GHCR)

set -e  # Exit on any error

# Configuration
LOCAL_IMAGE="custom-database-layer:2.0"
GITHUB_USERNAME="eands9"
REPOSITORY_NAME="custom-database-layer"
VERSION="2.0"
GHCR_IMAGE="ghcr.io/${GITHUB_USERNAME}/${REPOSITORY_NAME}:${VERSION}"
GHCR_IMAGE_LATEST="ghcr.io/${GITHUB_USERNAME}/${REPOSITORY_NAME}:latest"

echo "🚀 GitHub Container Registry Deployment Script"
echo "=============================================="
echo "Local Image: ${LOCAL_IMAGE}"
echo "Target GHCR: ${GHCR_IMAGE}"
echo "=============================================="

# Function to check if command exists
check_command() {
    if ! command -v $1 &> /dev/null; then
        echo "❌ Error: $1 is not installed or not in PATH"
        exit 1
    fi
}

# Check prerequisites
echo "🔍 Checking prerequisites..."
check_command docker
check_command gh
echo "✅ Prerequisites check passed"

# Check if local image exists
echo "🔍 Checking if local image exists..."
if ! docker image inspect "${LOCAL_IMAGE}" &> /dev/null; then
    echo "❌ Error: Local image '${LOCAL_IMAGE}' not found"
    echo "💡 Available images:"
    docker images | grep -E "(REPOSITORY|custom-database)"
    exit 1
fi
echo "✅ Local image found"

# Check GitHub CLI authentication
echo "🔍 Checking GitHub CLI authentication..."
if ! gh auth status &> /dev/null; then
    echo "❌ Error: Not authenticated with GitHub CLI"
    echo "💡 Please run: gh auth login"
    exit 1
fi
echo "✅ GitHub CLI authenticated"

# Login to GHCR
echo "🔐 Logging into GitHub Container Registry..."
echo $CR_PAT | docker login ghcr.io -u ${GITHUB_USERNAME} --password-stdin 2>/dev/null || {
    echo "📝 Manual login required. Please run:"
    echo "echo \$CR_PAT | docker login ghcr.io -u ${GITHUB_USERNAME} --password-stdin"
    echo ""
    echo "💡 If you don't have a Personal Access Token (PAT):"
    echo "1. Go to GitHub Settings → Developer settings → Personal access tokens"
    echo "2. Generate a new token with 'write:packages' and 'read:packages' scopes"
    echo "3. Export it: export CR_PAT=your_token_here"
    echo ""
    read -p "Press Enter after you've logged in manually, or Ctrl+C to exit..."
}

# Tag the image for GHCR
echo "🏷️  Tagging image for GHCR..."
docker tag "${LOCAL_IMAGE}" "${GHCR_IMAGE}"
docker tag "${LOCAL_IMAGE}" "${GHCR_IMAGE_LATEST}"
echo "✅ Image tagged as:"
echo "   - ${GHCR_IMAGE}"
echo "   - ${GHCR_IMAGE_LATEST}"

# Push to GHCR
echo "📤 Pushing to GitHub Container Registry..."
docker push "${GHCR_IMAGE}"
docker push "${GHCR_IMAGE_LATEST}"
echo "✅ Successfully pushed to GHCR!"

# Display information about the published package
echo ""
echo "🎉 Deployment completed successfully!"
echo "=============================================="
echo "📦 Package URL: https://github.com/users/${GITHUB_USERNAME}/packages/container/package/${REPOSITORY_NAME}"
echo "🔗 Pull command: docker pull ${GHCR_IMAGE}"
echo "🔗 Latest: docker pull ${GHCR_IMAGE_LATEST}"
echo "=============================================="

# Cleanup local tags (optional)
read -p "🗑️  Remove local GHCR tags? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    docker rmi "${GHCR_IMAGE}" "${GHCR_IMAGE_LATEST}" 2>/dev/null || true
    echo "✅ Local GHCR tags removed"
fi

echo "🎉 All done!"
