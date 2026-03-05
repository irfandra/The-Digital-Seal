-- Create collections table
CREATE TABLE collections (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- Brand reference
    brand_id BIGINT NOT NULL,
    
    -- Collection details
    collection_name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url VARCHAR(500),
    season VARCHAR(100),
    is_limited_edition BOOLEAN NOT NULL DEFAULT FALSE,
    release_date DATE,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Key
    CONSTRAINT fk_collections_brand FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE,
    
    -- Indexes
    INDEX idx_collections_brand_id (brand_id),
    INDEX idx_collections_season (season)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create products table
CREATE TABLE products (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- Brand & collection reference
    brand_id BIGINT NOT NULL,
    collection_id BIGINT,
    
    -- Product details
    product_name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(30) NOT NULL,
    sku VARCHAR(100) NOT NULL,
    serial_number VARCHAR(100),
    image_url VARCHAR(500),
    
    -- Blockchain fields
    token_id VARCHAR(255),
    contract_address VARCHAR(42),
    metadata_uri VARCHAR(500),
    status VARCHAR(20) NOT NULL DEFAULT 'DRAFT',
    current_owner_wallet VARCHAR(42),
    minted_at TIMESTAMP,
    
    -- Timestamps
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    CONSTRAINT fk_products_brand FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE CASCADE,
    CONSTRAINT fk_products_collection FOREIGN KEY (collection_id) REFERENCES collections(id) ON DELETE SET NULL,
    
    -- Unique constraints
    CONSTRAINT uk_products_sku UNIQUE (sku),
    CONSTRAINT uk_products_serial_number UNIQUE (serial_number),
    
    -- Indexes
    INDEX idx_products_brand_id (brand_id),
    INDEX idx_products_collection_id (collection_id),
    INDEX idx_products_category (category),
    INDEX idx_products_status (status),
    INDEX idx_products_token_id (token_id),
    INDEX idx_products_sku (sku)
    
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
