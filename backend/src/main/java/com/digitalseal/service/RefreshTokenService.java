package com.digitalseal.service;

import com.digitalseal.model.entity.RefreshToken;
import com.digitalseal.model.entity.User;
import com.digitalseal.repository.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Optional;
import java.util.UUID;

@Service
@Slf4j
@RequiredArgsConstructor
public class RefreshTokenService {
    
    private final RefreshTokenRepository refreshTokenRepository;
    
    @Value("${jwt.refresh-expiration}")
    private Long refreshExpiration;
    
    /**
     * Create refresh token for user
     */
    @Transactional
    public RefreshToken createRefreshToken(User user, String deviceInfo, String ipAddress) {
        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .token(UUID.randomUUID().toString())
                .expiresAt(LocalDateTime.now().plusSeconds(refreshExpiration / 1000))
                .deviceInfo(deviceInfo)
                .ipAddress(ipAddress)
                .isRevoked(false)
                .build();
        
        return refreshTokenRepository.save(refreshToken);
    }
    
    /**
     * Find refresh token by token string
     */
    public Optional<RefreshToken> findByToken(String token) {
        return refreshTokenRepository.findByToken(token);
    }
    
    /**
     * Verify refresh token
     */
    public RefreshToken verifyExpiration(RefreshToken token) {
        if (token.isExpired()) {
            refreshTokenRepository.delete(token);
            throw new RuntimeException("Refresh token expired. Please login again.");
        }
        return token;
    }
    
    /**
     * Revoke refresh token
     */
    @Transactional
    public void revokeToken(String token) {
        refreshTokenRepository.findByToken(token).ifPresent(rt -> {
            rt.revoke();
            refreshTokenRepository.save(rt);
        });
    }
    
    /**
     * Delete all user's refresh tokens (logout all devices)
     */
    @Transactional
    public void deleteByUser(User user) {
        refreshTokenRepository.deleteByUser(user);
    }
    
    /**
     * Clean up expired tokens (scheduled task)
     */
    @Transactional
    public void deleteExpiredTokens() {
        refreshTokenRepository.deleteExpiredTokens(LocalDateTime.now());
    }
}
