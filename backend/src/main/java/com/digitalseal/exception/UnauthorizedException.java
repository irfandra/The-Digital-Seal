package com.digitalseal.exception;

/**
 * Thrown when a user is not authorized to perform an operation.
 */
public class UnauthorizedException extends RuntimeException {
    public UnauthorizedException(String message) {
        super(message);
    }
}
