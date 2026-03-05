-- V10: Create ownership_history table — provenance tracking for digital seals

CREATE TABLE IF NOT EXISTS ownership_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- Product item reference
    product_item_id BIGINT NOT NULL,
    
    -- Transfer details
    from_wallet VARCHAR(42),
    to_wallet VARCHAR(42),
    transfer_type VARCHAR(20) NOT NULL,
    
    -- Blockchain proof
    tx_hash VARCHAR(66),
    block_number BIGINT,
    
    -- Notes
    notes VARCHAR(500),
    
    -- When it happened
    transferred_at TIMESTAMP NOT NULL,
    
    -- Record timestamp
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_ownership_history_item FOREIGN KEY (product_item_id) REFERENCES product_items(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_ownership_history_item_id (product_item_id),
    INDEX idx_ownership_history_transfer_type (transfer_type),
    INDEX idx_ownership_history_tx_hash (tx_hash),
    INDEX idx_ownership_history_transferred_at (transferred_at)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
