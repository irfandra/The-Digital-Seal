-- Split full_name into first_name and last_name
ALTER TABLE users ADD COLUMN first_name VARCHAR(255) NULL AFTER wallet_nonce;
ALTER TABLE users ADD COLUMN last_name VARCHAR(255) NULL AFTER first_name;

-- Migrate existing data: put full_name into first_name
UPDATE users SET first_name = full_name WHERE full_name IS NOT NULL;

-- Drop old column
ALTER TABLE users DROP COLUMN full_name;
