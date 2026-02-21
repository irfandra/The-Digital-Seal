-- Create verification codes table
CREATE TABLE verification_codes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- User reference
    user_id BIGINT NOT NULL,
    
    -- Code details
    code VARCHAR(6) NOT NULL,
    type VARCHAR(30) NOT NULL,
    
    -- Expiry & usage
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN NOT NULL DEFAULT FALSE,
    attempts INT NOT NULL DEFAULT 0,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_verification_codes_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_verification_user_id (user_id),
    INDEX idx_verification_code (code),
    INDEX idx_verification_type (type),
    INDEX idx_verification_expires (expires_at)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
