#!/bin/bash
# Test script to validate GitHub Actions workflow

echo "🧪 GitHub Actions Workflow Validation"
echo "===================================="

# Check if workflow file exists
if [ -f ".github/workflows/docker-build-push.yml" ]; then
    echo "✅ GitHub Actions workflow file found"
else
    echo "❌ GitHub Actions workflow file not found"
    exit 1
fi

# Check if required files exist
echo "🔍 Checking required files..."

required_files=("Dockerfile" "create-data.sql" "README_GITHUB.md" "LICENSE")
missing_files=()

for file in "${required_files[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file found"
    else
        echo "❌ $file missing"
        missing_files+=("$file")
    fi
done

if [ ${#missing_files[@]} -gt 0 ]; then
    echo "❌ Missing required files: ${missing_files[*]}"
    exit 1
fi

# Validate Dockerfile
echo "🔍 Validating Dockerfile..."
if grep -q "FROM postgres:15-alpine" Dockerfile; then
    echo "✅ Dockerfile base image is correct"
else
    echo "❌ Dockerfile base image issue"
fi

if grep -q "COPY create-data.sql" Dockerfile; then
    echo "✅ Dockerfile copies SQL file"
else
    echo "❌ Dockerfile doesn't copy SQL file"
fi

# Validate SQL file
echo "🔍 Validating SQL file..."
if grep -q "CREATE TABLE.*cats" create-data.sql; then
    echo "✅ SQL file creates cats table"
else
    echo "❌ SQL file doesn't create cats table"
fi

if grep -q "INSERT INTO cats" create-data.sql; then
    echo "✅ SQL file has sample data"
else
    echo "❌ SQL file missing sample data"
fi

# Validate workflow
echo "🔍 Validating GitHub Actions workflow..."
if grep -q "ghcr.io" .github/workflows/docker-build-push.yml; then
    echo "✅ Workflow targets GHCR"
else
    echo "❌ Workflow doesn't target GHCR"
fi

if grep -q "docker/build-push-action" .github/workflows/docker-build-push.yml; then
    echo "✅ Workflow uses build-push action"
else
    echo "❌ Workflow missing build-push action"
fi

echo ""
echo "🎉 All validations passed!"
echo "🚀 Ready to set up GitHub repository!"
echo ""
echo "Run: ./setup-github-repo.sh"
