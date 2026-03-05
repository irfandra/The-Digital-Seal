-- V8: Create product_items table — individual NFT units per product

CREATE TABLE IF NOT EXISTS product_items (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- Product reference
    product_id BIGINT NOT NULL,
    
    -- Item identification
    item_serial VARCHAR(150) NOT NULL,
    item_index INT NOT NULL,
    
    -- Blockchain fields
    token_id BIGINT,
    metadata_uri VARCHAR(500),
    mint_tx_hash VARCHAR(66),
    
    -- Claim code for QR-based claiming
    claim_code VARCHAR(64),
    claim_code_hash VARCHAR(64),
    
    -- Seal status
    seal_status VARCHAR(20) NOT NULL DEFAULT 'PRE_MINTED',
    
    -- Current ownership
    current_owner_wallet VARCHAR(42),
    current_owner_id BIGINT,
    
    -- Transfer tracking
    transfer_tx_hash VARCHAR(66),
    
    -- Timestamps
    minted_at TIMESTAMP NULL,
    sold_at TIMESTAMP NULL,
    claimed_at TIMESTAMP NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_product_items_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    CONSTRAINT fk_product_items_owner FOREIGN KEY (current_owner_id) REFERENCES users(id) ON DELETE SET NULL,
    
    -- Unique constraints
    CONSTRAINT uk_product_items_serial UNIQUE (item_serial),
    CONSTRAINT uk_product_items_claim_code UNIQUE (claim_code),
    CONSTRAINT uk_product_items_product_index UNIQUE (product_id, item_index),
    
    -- Indexes
    INDEX idx_product_items_product_id (product_id),
    INDEX idx_product_items_token_id (token_id),
    INDEX idx_product_items_seal_status (seal_status),
    INDEX idx_product_items_current_owner (current_owner_id),
    INDEX idx_product_items_claim_code_hash (claim_code_hash)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
