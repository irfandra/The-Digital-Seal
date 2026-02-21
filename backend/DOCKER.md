# Docker Compose Setup for Digital Seal Backend

## Overview

This Docker setup provides a **MySQL database container only**. The Spring Boot backend runs locally on your machine and connects to the containerized database.

## Quick Start

### 1. Start MySQL Database

```bash
# Start MySQL container
docker-compose up -d

# Check MySQL is running
docker-compose ps

# View MySQL logs
docker-compose logs -f mysql
```

### 2. Run Spring Boot Backend Locally

```bash
# The backend connects to MySQL on localhost:3306
mvn spring-boot:run

# Or use your IDE to run DigitalSealApplication
```

### 3. Stop Database

```bash
# Stop MySQL container (keeps data)
docker-compose down

# Stop and remove all data
docker-compose down -v
```

## Available Commands

### Start MySQL
```bash
# Start MySQL in detached mode
docker-compose up -d

# Start with logs visible
docker-compose up

# Start specific service
docker-compose up -d mysql
```

### Stop MySQL
```bash
# Stop container (keeps data)
docker-compose down

# Stop and remove volumes (deletes all data)
docker-compose down -v
```

### View Logs
```bash
# MySQL logs
docker-compose logs -f mysql

# Last 100 lines
docker-compose logs --tail=100 mysql
```

### Restart MySQL
```bash
docker-compose restart mysql
```

### Execute Commands in MySQL Container
```bash
# Access MySQL CLI as root
docker-compose exec mysql mysql -u root -p

# Access with specific user
docker-compose exec mysql mysql -u appuser -p digital_seal

# Execute SQL file
docker-compose exec -T mysql mysql -u root -p${DB_PASSWORD} digital_seal < backup.sql

# Dump database
docker-compose exec mysql mysqldump -u root -p${DB_PASSWORD} digital_seal > backup.sql
```

## Environment Variables

Create a `.env.docker` file (optional) or use inline variables:

You can override database credentials using environment variables or a `.env` file:

```bash
# Using inline variables
DB_PASSWORD=mysecretpass docker-compose up -d

# Or create a .env file in the backend directory
DB_USERNAME=myuser
DB_PASSWORD=mypassword
```

## Database Configuration

The MySQL container is configured with:
- **Database Name**: `digital_seal`
- **Root Password**: Set via `DB_PASSWORD` env var (default: `password`)
- **User**: Set via `DB_USERNAME` env var (default: `root`)
- **User Password**: Set via `DB_PASSWORD` env var (default: `password`)

Your Spring Boot application's `.env` file should match these credentials:
```env
DB_USERNAME=root
DB_PASSWORD=password
DATABASE_MODE=validate
```

### MySQL Database
- **Port**: 3306
- **Database**: digital_seal
- **User**: appuser (or DB_USERNAME from .env)
- **Password**: password (or DB_PASSWORD from .env)
- **Root Password**: password (or DB_PASSWORD from .env)

### Backend API
- **Port**: 8080
- **Base Path**: /api/v1
- **Health Check**: http://localhost:8080/api/v1/actuator/health

## Volumes

- `mysql_data`: Persistent MySQL database storage
 (accessible at `localhost:3306`)
- **Database**: digital_seal
- **Root User**: root
- **Root Password**: Set via `DB_PASSWORD` env var (default: `password`)
- **App User**: Set via `DB_USERNAME` env var (default: `root`)
- **App Password**: Set via `DB_PASSWORD` env var

### Spring Boot Backend (Runs Locally)
- Configure your `.env` file to connect to `localhost:3306`
- Run with `mvn spring-boot:run` or through your IDE
- **Port**: 8080
- **Base Path**: /api/v1

## Volumes

- `mysql_data`: Persistent MySQL database storage
  - Location: Docker managed volume
  - Persists data even when container is stopped
  - Removed only with `docker-compose down -v`

## Health Checks

- **MySQL**: Automated health check every 10 seconds
  - Uses `mysqladmin ping` to verify database is responsive

### Database connection issues
```bash
# VeSpring Boot can't connect to MySQL
```bash
# Check MySQL is running
docker-compose ps

# Should show STATUS as "Up" and "healthy"
# If unhealthy, check logs
docker-compose logs mysql

# Test connection from host
mysql -h 127.0.0.1 -P 3306 -u root -p
```

### Database connection issues
```bash
# Verify MySQL is running and healthy
docComplete Workflow

### Initial Setup (First Time)
```bash
# 1. Start MySQL
docker-compose up -d

# 2. Wait for MySQL to be healthy
docker-compose ps

# 3. Configure .env file
cp .env.example .env
# Edit .env: Set DATABASE_MODE=create

# 4. Run Spring Boot (creates schema)
mvn spring-boot:run

# 5. Stop Spring Boot (Ctrl+C)

# 6. Change .env: Set DATABASE_MODE=validate

# 7. Run Spring Boot normally
mvn spring-boot:run
```

### Daily Development
```bash
# 1. Ensure MySQL is running
docker-compose up -d

# 2. Run Spring Boot
mvn spring-boot:run

# When done
docker-compose stop  # Or leave running
```

## Production Considerations

For production deployment:

1. **Do not use Docker Compose** - Use managed database service (AWS RDS, Google Cloud SQL, etc.)
2. Use strong, unique passwords
3. Enable SSL/TLS for database connections
4. Set up automated backups
5. Configure proper monitoring and alerting
6. Use `DATABASE_MODE=validate` or `none`
7. Never expose MySQL port publicly
# Check what's using port 3306
lsof -i :3306

# Stop local MySQL service
sudo systemctl stop mysql  # Linux
brew services stop mysql   # macOS

# Or change the port in docker-compose.yml
# ports:
#   - "3307:3306"  # Use 3307 on host, 3306 in container
```

### Reset everything
```bash
# Stop and remove all data
docker-compose down -v

# Start fresh
docker-compose up -d

# Then run Spring Boot with DATABASE_MODE=create for first time
DATABASE_MODE=create mvn spring-boot:run