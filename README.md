# Cats Database Docker Setup

This directory contains the necessary files to run a PostgreSQL database with a `cats` table populated with sample data. The setup uses environment variables for secure configuration management.

## Files

- `Dockerfile`: Defines the PostgreSQL container with our custom database setup
- `create-data.sql`: SQL script that creates the cats table and inserts sample data
- `docker-compose.yml`: Docker Compose configuration for easy container management
- `.env.example`: Template for environment variables
- `.env`: Your actual environment configuration (create from .env.example)
- `setup_config.py`: Interactive setup script for environment configuration
- `retrieve-data-db.py`: Script to view and analyze database data
- `insert_cats_data.py`: Script to insert new cat data
- `requirements.txt`: Python dependencies
- `.gitignore`: Prevents sensitive files from being committed
- `README.md`: This file with usage instructions

## Environment Variables Setup

### Option 1: Quick Setup (Automated)

Run the interactive setup script:
```bash
python setup_config.py
```

This script will:
- ✅ Create your `.env` file with secure configuration
- 🔍 Check Python requirements
- 🔌 Test database connection
- 🔒 Set appropriate file permissions

### Option 2: Manual Setup

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Edit `.env` and update the values:
   ```bash
   # Database Configuration
   POSTGRES_DB=catsdb
   POSTGRES_USER=postgres
   POSTGRES_PASSWORD=your_secure_password_here
   DB_HOST=localhost
   DB_PORT=5432
   ```

### Environment Variables Explained

| Variable | Description | Default |
|----------|-------------|---------|
| `POSTGRES_DB` | Database name | `catsdb` |
| `POSTGRES_USER` | Database username | `postgres` |
| `POSTGRES_PASSWORD` | Database password | `password` |
| `DB_HOST` | Database host | `localhost` |
| `DB_PORT` | Database port | `5432` |

## Quick Start

### Step 1: Environment Setup

```bash
# Install Python dependencies
pip install -r requirements.txt

# Setup configuration (interactive)
python setup_config.py

# OR manually copy and edit
cp .env.example .env
# Edit .env with your preferred editor
```

### Step 2: Start Database

```bash
# Build and start the database
docker-compose up -d

# Check if container is running
docker-compose ps
```

### Step 3: Verify Setup

```bash
# Test database connection and view data
python retrieve-data-db.py

# OR use the setup script
python setup_config.py
# Choose option 3 to test connection
```

## Connecting to the Database

You can connect to the database using any PostgreSQL client:

- Host: `localhost`
- Port: `5432`
- Database: `catsdb`
- Username: `postgres`
- Password: `password`

### Using psql (command line)

```bash
psql -h localhost -p 5432 -U postgres -d catsdb
```

### Sample Queries

Once connected, you can run queries like:

```sql
-- View all cats
SELECT * FROM cats;

-- Find cats by breed
SELECT name, breed, age FROM cats WHERE breed = 'Maine Coon';

-- Find indoor cats
SELECT name, color, age FROM cats WHERE is_indoor = true;

-- Count cats by breed
SELECT breed, COUNT(*) as count FROM cats GROUP BY breed ORDER BY count DESC;
```

## Stopping the Database

### If using Docker Compose:
```bash
docker-compose down
```

### If using Docker directly:
```bash
docker stop cats-postgres-db
docker rm cats-postgres-db
```

## Python Scripts for Database Interaction

Two Python scripts are included for comprehensive database management:

### 1. Data Retrieval Script (`retrieve-data-db.py`)
Connects to the database and displays existing cats data.

### 2. Data Insertion Script (`insert_cats_data.py`)
Interactive script for adding new cat data to the database.

### Setup Python Environment

1. Install the required Python package:
   ```bash
   pip install -r requirements.txt
   ```

2. Make sure your PostgreSQL container is running:
   ```bash
   docker-compose up -d
   ```

### Running the Scripts

#### View Existing Data:
```bash
python retrieve-data-db.py
```

#### Insert New Data:
```bash
python insert_cats_data.py
```

### What the Retrieval Script Does

The retrieval script will:
- ✅ Connect to the PostgreSQL database
- 📋 Display table structure information
- 📊 Show total count of cats
- 🐱 List all cats with their details
- 📈 Display summary statistics (breeds, age stats, indoor/outdoor counts)
- 🔍 Example search by breed

### What the Insertion Script Does

The insertion script provides an interactive menu to:
- 📝 **Manual Single Entry**: Add one cat with guided input validation
- 📝 **Manual Bulk Entry**: Add multiple cats one by one
- 🎲 **Random Generation**: Generate and insert random cat data for testing
- ✅ **Data Validation**: Ensures proper data types and ranges
- 💾 **Transaction Safety**: Uses database transactions with rollback capability

### Script Features

- **Error handling**: Graceful handling of connection and query errors
- **Input validation**: Validates age, weight, dates, and other fields
- **Interactive menus**: User-friendly command-line interface
- **Transaction management**: Safe database operations with commit/rollback
- **Random data generation**: Perfect for testing and demos
- **Formatted output**: Clean, readable display of data
- **Type hints**: Well-documented code with Python type annotations

## Data Persistence

When using Docker Compose, data is persisted in a named volume `postgres_data`. This means your data will survive container restarts. To completely remove the data, you would need to remove the volume:

```bash
docker-compose down -v
```
