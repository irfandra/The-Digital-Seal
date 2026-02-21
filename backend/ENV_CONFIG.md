# Environment Configuration for Digital Seal Backend

## Overview
The backend uses a `.env` file to manage environment-specific configurations, particularly for database initialization modes.

## Setup

1. Copy `.env.example` to `.env`:
   ```bash
   cp .env.example .env
   ```

2. Configure your environment variables in `.env`

## Database Modes

The `DATABASE_MODE` variable controls how JPA/Hibernate handles database schema:

### Available Modes:

- **`create`** - First Injection Mode
  - Drops existing schema and creates a new one on startup
  - **Use only for initial database setup**
  - ⚠️ WARNING: Destroys all existing data!
  
- **`validate`** - Development Mode (Recommended)
  - Only validates that schema matches entities
  - Does not modify database structure
  - Best for development with Flyway migrations
  - Safe for production
  
- **`update`** - Auto-Update Mode
  - Automatically updates schema to match entities
  - Use with caution - can cause data inconsistencies
  
- **`none`** - No Schema Operations
  - JPA/Hibernate doesn't manage schema at all
  - Use when Flyway handles all migrations

## Usage Examples

### First Time Setup:
```env
DATABASE_MODE=create
```
Run the application once, then change to:
```env
DATABASE_MODE=validate
```

### Normal Development:
```env
DATABASE_MODE=validate
```

### When Flyway manages everything:
```env
DATABASE_MODE=none
```

## Important Notes

- The `.env` file is automatically loaded on application startup
- Changes to `.env` require application restart
- Never commit `.env` to version control (it's in `.gitignore`)
- Use `.env.example` as a template for team members
