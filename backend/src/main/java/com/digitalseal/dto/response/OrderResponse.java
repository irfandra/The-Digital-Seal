package com.digitalseal.dto.response;

import com.digitalseal.model.entity.OrderStatus;
import io.swagger.v3.oas.annotations.media.Schema;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Order information response")
public class OrderResponse {
    
    @Schema(description = "Order ID", example = "1")
    private Long id;
    
    @Schema(description = "Unique order number", example = "ORD-20260303-ABC123")
    private String orderNumber;
    
    @Schema(description = "Product ID", example = "1")
    private Long productId;
    
    @Schema(description = "Product name", example = "Louis Vuitton Speedy 30")
    private String productName;
    
    @Schema(description = "Product item ID (assigned after reservation)")
    private Long productItemId;
    
    @Schema(description = "Item serial number")
    private String itemSerial;
    
    @Schema(description = "Buyer user ID", example = "5")
    private Long buyerId;
    
    @Schema(description = "Buyer wallet address")
    private String buyerWallet;
    
    @Schema(description = "Quantity ordered", example = "1")
    private Integer quantity;
    
    @Schema(description = "Unit price", example = "0.5")
    private BigDecimal unitPrice;
    
    @Schema(description = "Total price", example = "0.5")
    private BigDecimal totalPrice;
    
    @Schema(description = "Currency", example = "MATIC")
    private String currency;
    
    @Schema(description = "Payment transaction hash")
    private String paymentTxHash;
    
    @Schema(description = "Order status", example = "PENDING")
    private OrderStatus status;
    
    @Schema(description = "Shipping address")
    private String shippingAddress;
    
    @Schema(description = "Tracking number")
    private String trackingNumber;
    
    @Schema(description = "Seal transfer transaction hash")
    private String sealTransferTxHash;
    
    @Schema(description = "When order was created")
    private LocalDateTime createdAt;
    
    @Schema(description = "When payment was confirmed")
    private LocalDateTime paymentConfirmedAt;
    
    @Schema(description = "When item was shipped")
    private LocalDateTime shippedAt;
    
    @Schema(description = "When item was delivered")
    private LocalDateTime deliveredAt;
    
    @Schema(description = "When order was completed")
    private LocalDateTime completedAt;
}
