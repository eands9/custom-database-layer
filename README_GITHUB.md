# 🐱 Cats Database Container

A PostgreSQL Docker container pre-populated with a cats database and sample data. Automatically built and published to GitHub Container Registry (GHCR).

[![Build and Push Docker Image](https://github.com/eands9/custom-database-layer/actions/workflows/docker-build-push.yml/badge.svg)](https://github.com/eands9/custom-database-layer/actions/workflows/docker-build-push.yml)
[![Docker Pulls](https://img.shields.io/badge/docker-ghcr.io-blue)](https://github.com/users/eands9/packages/container/package/custom-database-layer)

## 🚀 Quick Start

### Pull and Run from GHCR

```bash
# Pull the latest image
docker pull ghcr.io/eands9/custom-database-layer:latest

# Run the container
docker run -d \
  --name cats-db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=your_secure_password \
  ghcr.io/eands9/custom-database-layer:latest

# Connect to the database
psql -h localhost -p 5432 -U postgres -d catsdb
```

### Using Docker Compose

```yaml
version: '3.8'
services:
  database:
    image: ghcr.io/eands9/custom-database-layer:latest
    environment:
      POSTGRES_PASSWORD: your_secure_password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## 📦 Available Images

| Tag | Description | Pull Command |
|-----|-------------|--------------|
| `latest` | Latest stable build from main branch | `docker pull ghcr.io/eands9/custom-database-layer:latest` |
| `v2.0` | Version 2.0 release | `docker pull ghcr.io/eands9/custom-database-layer:v2.0` |
| `main` | Latest build from main branch | `docker pull ghcr.io/eands9/custom-database-layer:main` |

## 🗄️ Database Schema

The container includes a pre-populated `cats` table with the following structure:

```sql
CREATE TABLE cats (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    breed VARCHAR(100),
    age INTEGER,
    color VARCHAR(50),
    weight_kg DECIMAL(4,2),
    is_indoor BOOLEAN DEFAULT true,
    adoption_date DATE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Sample Data

The database comes pre-loaded with 15+ diverse cat records including various breeds like:
- Maine Coon, Siamese, Persian, Bengal
- British Shorthair, Russian Blue, Ragdoll
- And many more with realistic data

## 🔧 Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_DB` | Database name | `catsdb` |
| `POSTGRES_USER` | Database username | `postgres` |
| `POSTGRES_PASSWORD` | Database password | `password` |

## 🏗️ Building Locally

```bash
# Clone the repository
git clone https://github.com/eands9/custom-database-layer.git
cd custom-database-layer

# Build the image
docker build -t custom-database-layer:local .

# Run locally built image
docker run -d \
  --name local-cats-db \
  -p 5432:5432 \
  -e POSTGRES_PASSWORD=mypassword \
  custom-database-layer:local
```

## 🔄 Automated Builds

This repository uses GitHub Actions to automatically:

- ✅ **Build** Docker images on every push
- ✅ **Test** the build process
- ✅ **Scan** for security vulnerabilities
- ✅ **Push** to GitHub Container Registry
- ✅ **Tag** with version numbers and branch names
- ✅ **Support** multi-platform builds (AMD64, ARM64)

### Triggers

Builds are triggered on:
- Push to `main` or `develop` branches
- Version tags (e.g., `v1.0.0`, `v2.1.3`)
- Pull requests to `main`
- Manual workflow dispatch

## 📊 Usage Examples

### Basic Connection Test

```bash
# Start the container
docker run -d --name test-cats -p 5432:5432 -e POSTGRES_PASSWORD=test ghcr.io/eands9/custom-database-layer:latest

# Test connection and query
docker exec test-cats psql -U postgres -d catsdb -c "SELECT COUNT(*) FROM cats;"

# View all cats
docker exec test-cats psql -U postgres -d catsdb -c "SELECT name, breed, age FROM cats LIMIT 5;"
```

### Development Setup

```bash
# Create a development environment
docker-compose up -d

# Connect with your favorite PostgreSQL client
# Host: localhost, Port: 5432, Database: catsdb, User: postgres
```

## 🛠️ Development Tools

This repository includes Python scripts for database interaction:

- `retrieve-data-db.py` - View and analyze database data
- `insert_cats_data.py` - Add new cat records interactively
- `setup_config.py` - Configure environment variables

### Prerequisites

```bash
pip install -r requirements.txt
```

## 🔒 Security

- Images are scanned for vulnerabilities using Trivy
- Build provenance is generated and attested
- Secrets are managed through GitHub Secrets
- Multi-platform builds ensure compatibility

## 📈 Monitoring

Monitor the package at:
- **Package Registry**: https://github.com/users/eands9/packages/container/package/custom-database-layer
- **Build Status**: https://github.com/eands9/custom-database-layer/actions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push to branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Tags and Releases

To create a new release:

```bash
git tag -a v2.1.0 -m "Release version 2.1.0"
git push origin v2.1.0
```

This will automatically trigger a build and push the new version to GHCR.

## 🆘 Support

- 📧 Create an issue for bug reports or feature requests
- 💬 Discussions for questions and community support
- 📖 Check the [documentation](docs/) for detailed guides

---

Built with ❤️ for the cat-loving developer community!
