-- V9: Create orders table — purchase tracking

CREATE TABLE IF NOT EXISTS orders (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- Order reference
    order_number VARCHAR(30) NOT NULL,
    
    -- Product & item references
    product_id BIGINT NOT NULL,
    product_item_id BIGINT,
    
    -- Buyer
    buyer_id BIGINT NOT NULL,
    buyer_wallet VARCHAR(42),
    
    -- Quantity
    quantity INT NOT NULL DEFAULT 1,
    
    -- Payment info
    unit_price DECIMAL(18,8) NOT NULL,
    total_price DECIMAL(18,8) NOT NULL,
    currency VARCHAR(10) NOT NULL DEFAULT 'MATIC',
    payment_tx_hash VARCHAR(66),
    payment_confirmed_at TIMESTAMP NULL,
    
    -- Shipping
    shipping_address TEXT,
    tracking_number VARCHAR(100),
    shipped_at TIMESTAMP NULL,
    delivered_at TIMESTAMP NULL,
    
    -- Status
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    
    -- Seal transfer
    seal_transfer_tx_hash VARCHAR(66),
    completed_at TIMESTAMP NULL,
    
    -- Cancellation
    cancelled_at TIMESTAMP NULL,
    cancellation_reason VARCHAR(500),
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_orders_product FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT fk_orders_product_item FOREIGN KEY (product_item_id) REFERENCES product_items(id),
    CONSTRAINT fk_orders_buyer FOREIGN KEY (buyer_id) REFERENCES users(id),
    
    -- Unique constraints
    CONSTRAINT uk_orders_order_number UNIQUE (order_number),
    
    -- Indexes
    INDEX idx_orders_product_id (product_id),
    INDEX idx_orders_buyer_id (buyer_id),
    INDEX idx_orders_status (status),
    INDEX idx_orders_order_number (order_number),
    INDEX idx_orders_created_at (created_at)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
