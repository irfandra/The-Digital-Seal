# Digital Seal Backend - User Authentication

Spring Boot backend API for Digital Seal platform with hybrid authentication (Email + Wallet).

## Features

✅ **Email/Password Authentication**
- User registration with email
- Login with email and password
- Password validation (BCrypt)
- Account lockout after 5 failed attempts

✅ **Wallet Authentication**
- MetaMask wallet registration
- Wallet signature verification
- Login with wallet signature
- Nonce-based replay protection

✅ **Hybrid Authentication**
- Users can link both email and wallet
- Login with either method
- Seamless account recovery

✅ **JWT Token Management**
- Access tokens (24 hours)
- Refresh tokens (30 days)
- Token rotation on refresh
- Secure token storage

## Tech Stack

- **Framework:** Spring Boot 3.2.0
- **Database:** MySQL 8.0
- **Security:** Spring Security + JWT
- **Blockchain:** Web3j (Ethereum signature verification)
- **ORM:** Hibernate/JPA
- **Migration:** Flyway

## Prerequisites

- Java 17 or higher
- Maven 3.6+
- MySQL 8.0+

## Setup Instructions

### 1. Clone the repository

```bash
cd backend
```

### 2. Configure MySQL Database

Create a new database:

```sql
CREATE DATABASE digital_seal;
```

### 3. Update application.yml

Edit `src/main/resources/application.yml`:

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/digital_seal
    username: your_mysql_username
    password: your_mysql_password

jwt:
  secret: your-256-bit-secret-key-change-this-in-production
```

### 4. Build the project

```bash
mvn clean install
```

### 5. Run the application

```bash
mvn spring-boot:run
```

The server will start on `http://localhost:8080`

## API Endpoints

Base URL: `http://localhost:8080/api/v1`

### Email Authentication

#### Register with Email
```http
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass@123",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "role": "OWNER"
}
```

#### Login with Email
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "SecurePass@123"
}
```

### Wallet Authentication

#### Get Nonce
```http
GET /auth/wallet/nonce?address=0x1234567890abcdef1234567890abcdef12345678
```

#### Register with Wallet
```http
POST /auth/wallet/register
Content-Type: application/json

{
  "walletAddress": "0x1234567890abcdef1234567890abcdef12345678",
  "signature": "0xabc123...",
  "message": "Sign this message...",
  "fullName": "John Doe",
  "role": "OWNER"
}
```

#### Login with Wallet
```http
POST /auth/wallet/login
Content-Type: application/json

{
  "walletAddress": "0x1234567890abcdef1234567890abcdef12345678",
  "signature": "0xabc123...",
  "message": "Sign this message..."
}
```

### Token Management

#### Refresh Token
```http
POST /auth/refresh
Content-Type: application/json

{
  "refreshToken": "550e8400-e29b-41d4-a716-446655440000"
}
```

#### Logout
```http
POST /auth/logout
Content-Type: application/json

{
  "refreshToken": "550e8400-e29b-41d4-a716-446655440000"
}
```

## Response Format

### Success Response
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "550e8400-e29b-41d4-a716-446655440000",
    "tokenType": "Bearer",
    "expiresIn": 86400000,
    "user": {
      "id": 1,
      "email": "user@example.com",
      "fullName": "John Doe",
      "role": "OWNER",
      "authType": "EMAIL"
    }
  },
  "message": "Registration successful",
  "timestamp": "2024-02-06T10:30:00Z"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email or password"
  },
  "timestamp": "2024-02-06T10:30:00Z"
}
```

## Database Schema

### Users Table
- **id**: Primary key
- **email**: Unique email address (nullable)
- **password_hash**: BCrypt hashed password (nullable)
- **wallet_address**: Ethereum wallet address (nullable)
- **wallet_nonce**: Nonce for signature verification
- **full_name**: User's full name
- **auth_type**: EMAIL | WALLET | BOTH
- **role**: OWNER | BRAND | ADMIN
- **email_verified**: Email verification status
- **wallet_verified**: Wallet verification status
- **is_locked**: Account lockout status
- **failed_login_attempts**: Failed login counter

### Refresh Tokens Table
- **id**: Primary key
- **user_id**: Foreign key to users
- **token**: Unique refresh token (UUID)
- **expires_at**: Token expiration timestamp
- **device_info**: Device information
- **is_revoked**: Revocation status

## Security Features

1. **Password Security**
   - BCrypt with cost factor 12
   - Minimum 8 characters
   - Must contain uppercase, lowercase, number, and special character

2. **Account Lockout**
   - Locks after 5 failed login attempts
   - Requires password reset to unlock

3. **JWT Security**
   - HS256 algorithm
   - 24-hour access token expiry
   - 30-day refresh token expiry
   - Token rotation on refresh

4. **Wallet Signature Verification**
   - Web3j signature recovery
   - Nonce-based replay protection
   - Address verification

## Development

### Running Tests
```bash
mvn test
```

### Build for Production
```bash
mvn clean package -DskipTests
```

### Run Production Build
```bash
java -jar target/backend-1.0.0.jar
```

## Environment Variables

For production, set these environment variables:

```bash
export DB_USERNAME=your_db_username
export DB_PASSWORD=your_db_password
export JWT_SECRET=your-secure-jwt-secret-key
```

## Next Steps

After setting up authentication, you can implement:
1. Email verification
2. Password reset
3. Profile management
4. Wallet linking (for email users)
5. Email linking (for wallet users)

## Support

For issues or questions, please open an issue on GitHub.
