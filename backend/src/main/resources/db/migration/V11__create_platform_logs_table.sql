-- Platform Activity Log
-- Stores every significant event on the platform for monitoring, auditing, and debugging.

CREATE TABLE platform_logs (
    id              BIGINT          NOT NULL AUTO_INCREMENT,
    created_at      DATETIME(3)     NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    -- Severity
    level           VARCHAR(10)     NOT NULL COMMENT 'INFO | WARN | ERROR',

    -- Logical group this event belongs to
    category        VARCHAR(20)     NOT NULL COMMENT 'AUTH | ORDER | CLAIM | BLOCKCHAIN | PRODUCT | BRAND | USER | WALLET | SYSTEM',

    -- Short machine-readable action name, e.g. USER_LOGIN, ORDER_CREATED, NFT_TRANSFER_FAILED
    action          VARCHAR(100)    NOT NULL,

    -- Who triggered this event (nullable for system/anonymous events)
    user_id         BIGINT          NULL,
    user_email      VARCHAR(100)    NULL,

    -- The entity this event is about, e.g. entityType=ORDER entityId=42
    entity_type     VARCHAR(50)     NULL,
    entity_id       VARCHAR(50)     NULL,

    -- Human-readable or JSON details
    details         TEXT            NULL,

    -- Populated only for ERROR level
    error_message   TEXT            NULL,

    -- HTTP request context
    ip_address      VARCHAR(45)     NULL,
    user_agent      VARCHAR(500)    NULL,
    http_method     VARCHAR(10)     NULL,
    request_path    VARCHAR(500)    NULL,

    -- How long the operation took (milliseconds)
    duration_ms     BIGINT          NULL,

    -- Did the operation complete successfully?
    success         TINYINT(1)      NOT NULL DEFAULT 1,

    PRIMARY KEY (id),

    -- Common query patterns
    INDEX idx_pl_created_at     (created_at),
    INDEX idx_pl_level          (level),
    INDEX idx_pl_category       (category),
    INDEX idx_pl_user_id        (user_id),
    INDEX idx_pl_action         (action),
    INDEX idx_pl_entity         (entity_type, entity_id),
    INDEX idx_pl_success        (success),

    CONSTRAINT fk_pl_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Platform-wide activity and error log for monitoring';
