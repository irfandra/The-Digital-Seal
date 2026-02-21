# Digital Seal API Documentation

## Overview
The Digital Seal API provides authentication and authorization services for luxury product authentication using both traditional email/password and blockchain wallet-based authentication.

## Base URL
- **Local Development**: `http://localhost:8080`
- **Production**: `https://api.digitalseal.com`

## Accessing Swagger UI

### Interactive API Documentation
Once the application is running, access the Swagger UI at:

```
http://localhost:8080/swagger-ui.html
```

Or alternatively:

```
http://localhost:8080/swagger-ui/index.html
```

### OpenAPI Specification
Access the raw OpenAPI (Swagger) specification in JSON format:

```
http://localhost:8080/v3/api-docs
```

## Authentication Endpoints

### 1. Email/Password Registration
**POST** `/auth/register`

Register a new user account using email and password.

**Request Body:**
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePass123!",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "role": "OWNER"
}
```

**Response (201 Created):**
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
      "email": "john.doe@example.com",
      "fullName": "John Doe",
      "role": "OWNER",
      "authType": "EMAIL",
      "emailVerified": false,
      "createdAt": "2026-02-07T10:30:00"
    }
  },
  "message": "Registration successful",
  "timestamp": "2026-02-07T10:30:00"
}
```

### 2. Email/Password Login
**POST** `/auth/login`

Authenticate with email and password.

**Request Body:**
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePass123!"
}
```

**Response (200 OK):**
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
      "email": "john.doe@example.com",
      "fullName": "John Doe",
      "role": "OWNER",
      "lastLoginAt": "2026-02-07T15:45:30"
    }
  },
  "message": "Login successful",
  "timestamp": "2026-02-07T15:45:30"
}
```

### 3. Get Wallet Nonce
**GET** `/auth/wallet/nonce?address=0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb`

Generate a unique nonce for wallet signature verification.

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "nonce": "a1b2c3d4e5f6g7h8i9j0",
    "message": "Sign this message to authenticate with Digital Seal: a1b2c3d4e5f6g7h8i9j0"
  },
  "message": "Nonce generated",
  "timestamp": "2026-02-07T10:30:00"
}
```

### 4. Wallet Registration
**POST** `/auth/wallet/register`

Register with wallet signature.

**Request Body:**
```json
{
  "walletAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  "signature": "0x1234567890abcdef...",
  "message": "Sign this message to authenticate with Digital Seal: a1b2c3d4e5f6g7h8i9j0",
  "fullName": "John Doe",
  "phoneNumber": "+1234567890",
  "role": "OWNER"
}
```

### 5. Wallet Login
**POST** `/auth/wallet/login`

Authenticate with wallet signature.

**Request Body:**
```json
{
  "walletAddress": "0x742d35Cc6634C0532925a3b844Bc9e7595f0bEb",
  "signature": "0x1234567890abcdef...",
  "message": "Sign this message to authenticate with Digital Seal: a1b2c3d4e5f6g7h8i9j0"
}
```

### 6. Refresh Token
**POST** `/auth/refresh`

Obtain a new access token using a valid refresh token.

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tokenType": "Bearer",
    "expiresIn": 3600
  },
  "message": "Token refreshed successfully",
  "timestamp": "2026-02-07T16:30:00"
}
```

### 7. Logout
**POST** `/auth/logout`

Invalidate the current refresh token.

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": null,
  "message": "Logged out successfully",
  "timestamp": "2026-02-07T17:00:00"
}
```

## Error Responses

### 400 Bad Request
```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input data",
    "field": "email"
  },
  "timestamp": "2026-02-07T10:30:00"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Invalid email or password"
  },
  "timestamp": "2026-02-07T10:30:00"
}
```

### 409 Conflict
```json
{
  "success": false,
  "error": {
    "code": "EMAIL_ALREADY_EXISTS",
    "message": "Email address is already registered"
  },
  "timestamp": "2026-02-07T10:30:00"
}
```

### 423 Locked
```json
{
  "success": false,
  "error": {
    "code": "ACCOUNT_LOCKED",
    "message": "Account locked due to too many failed login attempts"
  },
  "timestamp": "2026-02-07T10:30:00"
}
```

## Using JWT Tokens

### Authorization Header
After successful login, include the access token in subsequent requests:

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### In Swagger UI
1. Click the "Authorize" button at the top of the Swagger UI
2. Enter your access token in the format: `Bearer <your_token>`
3. Click "Authorize"
4. All subsequent requests will include the authorization header

## Password Requirements
- Minimum 8 characters
- Must contain at least one uppercase letter
- Must contain at least one lowercase letter
- Must contain at least one number
- Must contain at least one special character (@#$%^&+=!)

## User Roles
- **OWNER**: Luxury product owners who want to verify authenticity
- **BRAND**: Brand representatives who manage product registrations

## Request Headers
- `Content-Type: application/json`
- `User-Agent`: Your application name/version
- `Authorization: Bearer <token>` (for protected endpoints)

## Rate Limiting
(To be implemented)

## Support
For API support, contact: support@digitalseal.com
