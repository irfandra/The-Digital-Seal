-- V7: Alter products table — add pricing, quantity, listing, and update blockchain fields
-- Remove old single-item blockchain columns, add multi-item support
-- NOTE: Rewritten for idempotency after partial apply on MySQL (DDL is non-transactional)

-- Column changes (safe: use stored procedure to skip if already applied)
DROP PROCEDURE IF EXISTS migrate_v7;
DELIMITER //
CREATE PROCEDURE migrate_v7()
BEGIN
    -- Add pricing columns
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'products' AND column_name = 'price') THEN
        ALTER TABLE products ADD COLUMN price DECIMAL(18,8) DEFAULT NULL AFTER image_url;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'products' AND column_name = 'currency') THEN
        ALTER TABLE products ADD COLUMN currency VARCHAR(10) NOT NULL DEFAULT 'MATIC' AFTER price;
    END IF;

    -- Add quantity columns
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'products' AND column_name = 'total_quantity') THEN
        ALTER TABLE products ADD COLUMN total_quantity INT NOT NULL DEFAULT 1 AFTER currency;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'products' AND column_name = 'available_quantity') THEN
        ALTER TABLE products ADD COLUMN available_quantity INT NOT NULL DEFAULT 0 AFTER total_quantity;
    END IF;

    -- Rename metadata_uri → metadata_base_uri
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'products' AND column_name = 'metadata_uri') THEN
        ALTER TABLE products CHANGE COLUMN metadata_uri metadata_base_uri VARCHAR(500);
    END IF;

    -- Add listing fields
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'products' AND column_name = 'listed_at') THEN
        ALTER TABLE products ADD COLUMN listed_at TIMESTAMP NULL AFTER status;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'products' AND column_name = 'listing_deadline') THEN
        ALTER TABLE products ADD COLUMN listing_deadline TIMESTAMP NULL AFTER listed_at;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'products' AND column_name = 'preminted_at') THEN
        ALTER TABLE products ADD COLUMN preminted_at TIMESTAMP NULL AFTER listing_deadline;
    END IF;

    -- Drop old single-item columns (moved to product_items table)
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'products' AND column_name = 'token_id') THEN
        ALTER TABLE products DROP COLUMN token_id;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'products' AND column_name = 'current_owner_wallet') THEN
        ALTER TABLE products DROP COLUMN current_owner_wallet;
    END IF;

    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema = DATABASE() AND table_name = 'products' AND column_name = 'minted_at') THEN
        ALTER TABLE products DROP COLUMN minted_at;
    END IF;

    -- Add indexes for marketplace queries (skip if exists)
    IF NOT EXISTS (SELECT 1 FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'products' AND index_name = 'idx_products_price') THEN
        CREATE INDEX idx_products_price ON products (price);
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.statistics WHERE table_schema = DATABASE() AND table_name = 'products' AND index_name = 'idx_products_listed_at') THEN
        CREATE INDEX idx_products_listed_at ON products (listed_at);
    END IF;
END //
DELIMITER ;

CALL migrate_v7();
DROP PROCEDURE IF EXISTS migrate_v7;
