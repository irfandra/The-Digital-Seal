-- Create users table
CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- Basic Info
    email VARCHAR(255) NULL,
    password_hash VARCHAR(255) NULL,
    
    -- Wallet Info
    wallet_address VARCHAR(42) NULL,
    wallet_nonce VARCHAR(255) NULL,
    
    -- Profile Information
    full_name VARCHAR(255) NULL,
    phone_number VARCHAR(20) NULL,
    
    -- Authentication & Role
    auth_type VARCHAR(20) NOT NULL DEFAULT 'EMAIL',
    role VARCHAR(20) NOT NULL DEFAULT 'OWNER',
    
    -- Status Flags
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    email_verified BOOLEAN NOT NULL DEFAULT FALSE,
    wallet_verified BOOLEAN NOT NULL DEFAULT FALSE,
    is_locked BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Security
    failed_login_attempts INT NOT NULL DEFAULT 0,
    last_failed_login_at TIMESTAMP NULL,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP NULL,
    
    -- Indexes
    INDEX idx_email (email),
    INDEX idx_wallet_address (wallet_address),
    INDEX idx_auth_type (auth_type),
    INDEX idx_role (role),
    
    -- Unique Constraints
    UNIQUE KEY unique_email (email),
    UNIQUE KEY unique_wallet (wallet_address),
    
    -- Check Constraints
    CONSTRAINT chk_auth_email CHECK (
        auth_type != 'EMAIL' OR (email IS NOT NULL AND password_hash IS NOT NULL)
    ),
    CONSTRAINT chk_auth_wallet CHECK (
        auth_type != 'WALLET' OR wallet_address IS NOT NULL
    ),
    CONSTRAINT chk_auth_both CHECK (
        auth_type != 'BOTH' OR (email IS NOT NULL AND wallet_address IS NOT NULL)
    )
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
