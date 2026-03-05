package com.digitalseal.model.entity;

/**
 * Logical area of the platform that generated the log entry.
 */
public enum LogCategory {
    /** User registration, login, logout, token refresh, password reset */
    AUTH,
    /** Purchase orders: created, paid, processed, shipped, completed, cancelled */
    ORDER,
    /** QR-code claim events: purchased-item claims and standalone claims */
    CLAIM,
    /** On-chain interactions: premint, transfer, verification */
    BLOCKCHAIN,
    /** Product lifecycle: draft, publish, premint, list, update */
    PRODUCT,
    /** Brand management: create, update, wallet connect */
    BRAND,
    /** User profile updates, wallet connect, role changes */
    USER,
    /** Wallet verification and connection events */
    WALLET,
    /** Background jobs, startup, migrations, unclassified events */
    SYSTEM
}
