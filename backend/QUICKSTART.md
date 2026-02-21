# Digital Seal API - Quick Start Guide

## Prerequisites
- Java 21 or higher
- Maven 3.6+
- MySQL 8.0+
- Docker (optional, for MySQL)

## Setup Instructions

### 1. Database Setup

#### Option A: Using Docker (Recommended)
```bash
cd backend
docker-compose up -d
```

#### Option B: Manual MySQL Setup
Create a database named `digital_seal`:
```sql
CREATE DATABASE digital_seal;
```

### 2. Environment Configuration

Create a `.env` file in the `backend` directory or set environment variables:

```properties
DB_USERNAME=root
DB_PASSWORD=your_password
JWT_SECRET=your-256-bit-secret-key-change-this-in-production-12345678901234567890
WEB3_RPC_URL=https://polygon-amoy.infura.io/v3/YOUR_INFURA_KEY
CONTRACT_ADDRESS=your_contract_address
CORS_ORIGINS=http://localhost:3000,http://localhost:8081
```

### 3. Build and Run

#### Using Maven
```bash
cd backend
mvn clean install
mvn spring-boot:run
```

#### Using JAR
```bash
cd backend
mvn clean package
java -jar target/backend-1.0.0.jar
```

### 4. Verify Installation

The application will start on `http://localhost:8080`.

Check the health endpoint:
```bash
curl http://localhost:8080/api/v1/actuator/health
```

## Accessing API Documentation

### Swagger UI (Interactive)
Open your browser and navigate to:
```
http://localhost:8080/api/v1/swagger-ui.html
```

### OpenAPI JSON
```
http://localhost:8080/api/v1/v3/api-docs
```

## Testing the API

### 1. Register a New User

Using cURL:
```bash
curl -X POST http://localhost:8080/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!",
    "fullName": "Test User",
    "role": "OWNER"
  }'
```

Using Swagger UI:
1. Go to `http://localhost:8080/api/v1/swagger-ui.html`
2. Expand the "POST /auth/register" endpoint
3. Click "Try it out"
4. Fill in the request body
5. Click "Execute"

### 2. Login

```bash
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "SecurePass123!"
  }'
```

Response will include `accessToken` and `refreshToken`:
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer",
    "expiresIn": 3600,
    "user": {
      "id": 1,
      "email": "test@example.com",
      "fullName": "Test User"
    }
  }
}
```

### 3. Use Access Token for Protected Endpoints

```bash
curl -X GET http://localhost:8080/api/v1/protected-endpoint \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

### 4. Refresh Token

```bash
curl -X POST http://localhost:8080/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "YOUR_REFRESH_TOKEN"
  }'
```

### 5. Logout

```bash
curl -X POST http://localhost:8080/api/v1/auth/logout \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "YOUR_REFRESH_TOKEN"
  }'
```

## Wallet Authentication Flow

### 1. Get Nonce
```bash
curl -X GET "http://localhost:8080/api/v1/auth/wallet/nonce?address=0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb"
```

### 2. Sign the Message
Use a wallet (MetaMask, WalletConnect, etc.) to sign the message returned in step 1.

### 3. Register or Login with Signature
```bash
curl -X POST http://localhost:8080/api/v1/auth/wallet/register \
  -H "Content-Type: application/json" \
  -d '{
    "walletAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
    "signature": "0x1234567890abcdef...",
    "message": "Sign this message to authenticate with Digital Seal: a1b2c3d4e5f6g7h8i9j0",
    "fullName": "John Doe",
    "role": "OWNER"
  }'
```

## Using Swagger UI Authorization

1. Click the **"Authorize"** button (lock icon) at the top of Swagger UI
2. Enter: `Bearer YOUR_ACCESS_TOKEN`
3. Click **"Authorize"**
4. Click **"Close"**

Now all protected endpoints will automatically include the authorization header.

## Database Migrations

Flyway migrations are automatically applied on startup. Migration files are located at:
```
src/main/resources/db/migration/
```

Current migrations:
- `V1__create_users_table.sql` - Creates users table
- `V2__create_refresh_tokens_table.sql` - Creates refresh tokens table

## Troubleshooting

### Port Already in Use
Change the port in `application.yml`:
```yaml
server:
  port: 8081
```

### Database Connection Error
1. Verify MySQL is running
2. Check credentials in `.env` or `application.yml`
3. Ensure database `digital_seal` exists

### JWT Errors
Ensure `JWT_SECRET` is at least 256 bits (32 characters)

### CORS Errors
Add your frontend URL to `CORS_ORIGINS`:
```
CORS_ORIGINS=http://localhost:3000,http://localhost:8081,http://localhost:4200
```

## Development Tips

### Hot Reload
The project includes `spring-boot-devtools` for automatic restart on code changes.

### View SQL Queries
SQL queries are logged in DEBUG mode (already enabled in `application.yml`)

### Switch Database Mode
Change `DATABASE_MODE` environment variable:
- `validate` - Only validate schema (production)
- `update` - Update schema automatically (development)
- `create-drop` - Drop and recreate (testing only)

## Production Deployment

### Important Security Settings

1. **Change JWT Secret**
   ```
   JWT_SECRET=<generate-a-strong-random-secret-key>
   ```

2. **Use Strong Database Password**
   ```
   DB_PASSWORD=<secure-password>
   ```

3. **Configure CORS Properly**
   ```
   CORS_ORIGINS=https://yourdomain.com
   ```

4. **Set Database Mode to Validate**
   ```
   DATABASE_MODE=validate
   ```

5. **Disable Debug Logging**
   ```yaml
   logging:
     level:
       com.digitalseal: INFO
       org.springframework.security: WARN
   ```

## API Endpoints Summary

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/auth/register` | Email registration | No |
| POST | `/auth/login` | Email login | No |
| GET | `/auth/wallet/nonce` | Get wallet nonce | No |
| POST | `/auth/wallet/register` | Wallet registration | No |
| POST | `/auth/wallet/login` | Wallet login | No |
| POST | `/auth/refresh` | Refresh token | No |
| POST | `/auth/logout` | Logout | No |

## Support & Documentation

- **Swagger UI**: http://localhost:8080/api/v1/swagger-ui.html
- **API Docs**: http://localhost:8080/api/v1/v3/api-docs
- **Actuator Health**: http://localhost:8080/api/v1/actuator/health
- **Full API Documentation**: See `API_DOCUMENTATION.md`

## Next Steps

1. Implement additional endpoints for product management
2. Add email verification
3. Implement rate limiting
4. Add comprehensive unit and integration tests
5. Set up CI/CD pipeline
6. Configure production-grade logging and monitoring
