#!/bin/bash
# GHCR Troubleshooting Script for GitHub Actions

echo "🔧 GHCR GitHub Actions Troubleshooting"
echo "====================================="

# Check GitHub CLI authentication
echo "🔍 1. Checking GitHub CLI authentication..."
if gh auth status &> /dev/null; then
    echo "✅ GitHub CLI authenticated"
    gh auth status
else
    echo "❌ GitHub CLI not authenticated"
    echo "💡 Run: gh auth login"
fi

echo ""

# Check repository settings
echo "🔍 2. Checking repository settings..."
REPO="eands9/custom-database-layer"

# Check if repository exists
if gh repo view $REPO &> /dev/null; then
    echo "✅ Repository $REPO exists"
    
    # Check repository permissions
    echo "🔍 Checking repository permissions..."
    gh api repos/$REPO --jq '.permissions' 2>/dev/null || echo "⚠️ Cannot check permissions"
    
    # Check if Actions are enabled
    echo "🔍 Checking if Actions are enabled..."
    ACTIONS_ENABLED=$(gh api repos/$REPO --jq '.has_actions' 2>/dev/null)
    if [ "$ACTIONS_ENABLED" = "true" ]; then
        echo "✅ GitHub Actions enabled"
    else
        echo "❌ GitHub Actions not enabled"
        echo "💡 Enable in Settings → Actions → General"
    fi
    
else
    echo "❌ Repository $REPO not found"
    exit 1
fi

echo ""

# Check workflow file
echo "🔍 3. Checking workflow file..."
if [ -f ".github/workflows/docker-build-push.yml" ]; then
    echo "✅ Workflow file exists"
    
    # Check for common issues
    if grep -q "packages: write" .github/workflows/docker-build-push.yml; then
        echo "✅ Has packages: write permission"
    else
        echo "❌ Missing packages: write permission"
    fi
    
    if grep -q "GITHUB_TOKEN" .github/workflows/docker-build-push.yml; then
        echo "✅ Uses GITHUB_TOKEN"
    else
        echo "❌ Not using GITHUB_TOKEN"
    fi
    
else
    echo "❌ Workflow file not found"
fi

echo ""

# Check package permissions
echo "🔍 4. Checking package permissions..."
echo "📦 Package URL: https://github.com/users/eands9/packages/container/package/custom-database-layer"

# Check recent workflow runs
echo ""
echo "🔍 5. Checking recent workflow runs..."
gh run list --repo $REPO --limit 5 2>/dev/null || echo "❌ Cannot fetch workflow runs"

echo ""
echo "🛠️ Common Solutions:"
echo "==================="
echo ""
echo "📝 1. Repository Settings Fix:"
echo "   - Go to: https://github.com/$REPO/settings/actions"
echo "   - Under 'Workflow permissions', select:"
echo "     ✅ Read and write permissions"
echo "     ✅ Allow GitHub Actions to create and approve pull requests"
echo ""
echo "📝 2. Package Permissions Fix:"
echo "   - Go to: https://github.com/users/eands9/packages/container/package/custom-database-layer/settings"
echo "   - Under 'Manage Actions access':"
echo "     ✅ Add repository: eands9/custom-database-layer"
echo "     ✅ Set role: Write"
echo ""
echo "📝 3. Manual Package Creation (if package doesn't exist):"
echo "   - Push any image manually first:"
echo "     docker tag custom-database-layer:2.0 ghcr.io/eands9/custom-database-layer:manual"
echo "     echo \$GITHUB_TOKEN | docker login ghcr.io -u eands9 --password-stdin"
echo "     docker push ghcr.io/eands9/custom-database-layer:manual"
echo ""
echo "📝 4. Workflow File Fixes Applied:"
echo "   ✅ Added 'actions: read' permission"
echo "   ✅ Added 'id: build' to build step"
echo "   ✅ Added condition to attestation step"
echo ""
echo "🚀 Next Steps:"
echo "============="
echo "1. Apply repository settings fixes above"
echo "2. Commit and push the updated workflow:"
echo "   git add .github/workflows/docker-build-push.yml"
echo "   git commit -m 'Fix GHCR workflow permissions and attestation'"
echo "   git push"
echo "3. Or trigger manual workflow:"
echo "   gh workflow run docker-build-push.yml --repo $REPO"
echo ""
echo "💡 Check logs with:"
echo "   gh run list --repo $REPO"
echo "   gh run view <run-id> --log --repo $REPO"
