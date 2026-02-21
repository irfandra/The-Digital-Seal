package com.digitalseal.repository;

import com.digitalseal.model.entity.User;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    
    Optional<User> findByEmail(String email);
    
    Optional<User> findByWalletAddress(String walletAddress);
    
    Optional<User> findByEmailOrWalletAddress(String email, String walletAddress);
    
    Boolean existsByEmail(String email);
    
    Boolean existsByWalletAddress(String walletAddress);
}
