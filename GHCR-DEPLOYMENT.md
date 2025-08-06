# GitHub Container Registry (GHCR) Deployment Guide

This guide will help you deploy your local Docker image `custom-database-layer:2.0` to GitHub Container Registry under your username `eands9`.

## Prerequisites

### 1. Install GitHub CLI (if not already installed)
```bash
# macOS
brew install gh

# Or download from: https://cli.github.com/
```

### 2. Authenticate with GitHub
```bash
gh auth login
```
Follow the prompts to authenticate with your GitHub account.

### 3. Create a Personal Access Token (PAT)
1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select the following scopes:
   - `write:packages` (to push packages)
   - `read:packages` (to pull packages)
   - `delete:packages` (optional, to delete packages)
4. Copy the generated token

### 4. Set Environment Variable
```bash
export CR_PAT=your_personal_access_token_here
```

## Deployment Methods

### Method 1: Automated Script (Recommended)

Run the provided deployment script:
```bash
cd DB-LAYER
./deploy-to-ghcr.sh
```

### Method 2: Manual Commands

#### Step 1: Login to GHCR
```bash
echo $CR_PAT | docker login ghcr.io -u eands9 --password-stdin
```

#### Step 2: Tag your local image
```bash
# Tag with version
docker tag custom-database-layer:2.0 ghcr.io/eands9/custom-database-layer:2.0

# Tag as latest
docker tag custom-database-layer:2.0 ghcr.io/eands9/custom-database-layer:latest
```

#### Step 3: Push to GHCR
```bash
# Push version tag
docker push ghcr.io/eands9/custom-database-layer:2.0

# Push latest tag
docker push ghcr.io/eands9/custom-database-layer:latest
```

## Verification

### 1. Check on GitHub
Visit: https://github.com/users/eands9/packages/container/package/custom-database-layer

### 2. Pull from GHCR
```bash
# Pull specific version
docker pull ghcr.io/eands9/custom-database-layer:2.0

# Pull latest
docker pull ghcr.io/eands9/custom-database-layer:latest
```

### 3. Test the pulled image
```bash
# Run the container from GHCR
docker run -d \
  --name test-ghcr-container \
  -p 5433:5432 \
  -e POSTGRES_PASSWORD=testpassword \
  ghcr.io/eands9/custom-database-layer:2.0

# Test connection
docker exec test-ghcr-container psql -U postgres -d catsdb -c "SELECT COUNT(*) FROM cats;"

# Cleanup
docker stop test-ghcr-container
docker rm test-ghcr-container
```

## Package Visibility

### Make Package Public (Optional)
1. Go to the package page: https://github.com/users/eands9/packages/container/package/custom-database-layer
2. Click "Package settings"
3. Scroll down to "Danger Zone"
4. Click "Change visibility" → "Public"

### Use in Docker Compose
Update your `docker-compose.yml` to use the GHCR image:

```yaml
version: '3.8'

services:
  postgres:
    image: ghcr.io/eands9/custom-database-layer:2.0
    # ... rest of your configuration
```

## Troubleshooting

### Permission Denied
```bash
# Make sure you're logged in
docker login ghcr.io

# Check your PAT has correct permissions
gh auth status
```

### Image Not Found Locally
```bash
# List all local images
docker images

# If your image has a different name/tag, update the script
docker images | grep custom-database
```

### Authentication Issues
```bash
# Logout and login again
docker logout ghcr.io
echo $CR_PAT | docker login ghcr.io -u eands9 --password-stdin
```

### Network Issues
```bash
# Test connectivity
curl -I https://ghcr.io/v2/

# Check Docker daemon
docker info
```

## Advanced Usage

### Build and Push in One Command
```bash
# Build local image first (if needed)
docker build -t custom-database-layer:2.0 .

# Then run deployment
./deploy-to-ghcr.sh
```

### Multiple Tags
```bash
# Tag with different versions
docker tag custom-database-layer:2.0 ghcr.io/eands9/custom-database-layer:v2.0.0
docker tag custom-database-layer:2.0 ghcr.io/eands9/custom-database-layer:stable

# Push all tags
docker push ghcr.io/eands9/custom-database-layer:v2.0.0
docker push ghcr.io/eands9/custom-database-layer:stable
```

## Security Best Practices

1. **Use specific versions** instead of `latest` in production
2. **Regularly rotate** your Personal Access Tokens
3. **Keep packages private** unless they need to be public
4. **Review package permissions** regularly
5. **Use secrets management** for PAT in CI/CD pipelines

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Build and Push to GHCR

on:
  push:
    tags:
      - 'v*'

jobs:
  build-and-push:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Login to GHCR
      uses: docker/login-action@v2
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Build and push
      uses: docker/build-push-action@v4
      with:
        context: ./DB-LAYER
        push: true
        tags: |
          ghcr.io/eands9/custom-database-layer:latest
          ghcr.io/eands9/custom-database-layer:${{ github.ref_name }}
```
