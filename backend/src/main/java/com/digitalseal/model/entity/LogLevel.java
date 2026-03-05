package com.digitalseal.model.entity;

/**
 * Severity level for a platform log entry.
 */
public enum LogLevel {
    /** Normal operational event — login, order placed, NFT minted */
    INFO,
    /** Something unexpected but non-fatal — invalid attempt, slow call */
    WARN,
    /** A failure that needs attention — blockchain error, DB constraint, exception */
    ERROR
}
