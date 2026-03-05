package com.digitalseal.model.entity;

/**
 * Type of ownership transfer recorded in ownership history.
 */
public enum TransferType {
    MINT,           // Initial minting (brand → contract)
    PURCHASE,       // Purchased through marketplace
    CLAIM,          // Claimed via QR code / claim code
    TRANSFER,       // Peer-to-peer transfer between wallets
    BURN            // Token burned / destroyed
}
