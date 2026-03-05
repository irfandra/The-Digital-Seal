package com.digitalseal.exception;

/**
 * Thrown when an operation is not allowed due to invalid state.
 */
public class InvalidStateException extends RuntimeException {
    public InvalidStateException(String message) {
        super(message);
    }
}
