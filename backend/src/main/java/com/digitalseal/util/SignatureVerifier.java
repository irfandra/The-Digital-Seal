package com.digitalseal.util;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.web3j.crypto.Keys;
import org.web3j.crypto.Sign;
import org.web3j.utils.Numeric;

import java.nio.charset.StandardCharsets;
import java.util.Arrays;

@Component
@Slf4j
public class SignatureVerifier {
    
    private static final String PERSONAL_MESSAGE_PREFIX = "\u0019Ethereum Signed Message:\n";
    
    /**
     * Verify Ethereum signature from MetaMask
     * @param address The wallet address that signed the message
     * @param message The original message that was signed
     * @param signature The signature from the wallet
     * @return true if signature is valid
     */
    public boolean verifySignature(String address, String message, String signature) {
        try {
            // Prepare the message hash
            String prefix = PERSONAL_MESSAGE_PREFIX + message.length();
            byte[] msgHash = org.web3j.crypto.Hash.sha3((prefix + message).getBytes(StandardCharsets.UTF_8));
            
            // Parse signature
            byte[] signatureBytes = Numeric.hexStringToByteArray(signature);
            if (signatureBytes.length != 65) {
                log.error("Invalid signature length: {}", signatureBytes.length);
                return false;
            }
            
            byte v = signatureBytes[64];
            if (v < 27) {
                v += 27;
            }
            
            Sign.SignatureData sd = new Sign.SignatureData(
                v,
                Arrays.copyOfRange(signatureBytes, 0, 32),
                Arrays.copyOfRange(signatureBytes, 32, 64)
            );
            
            // Recover address from signature
            String recoveredAddress = null;
            for (int i = 0; i < 4; i++) {
                try {
                    recoveredAddress = "0x" + Keys.getAddress(
                        Sign.signedPrefixedMessageToKey(msgHash, sd)
                    );
                    break;
                } catch (Exception e) {
                    // Try next recovery id
                    if (i == 3) {
                        log.error("Failed to recover address from signature", e);
                    }
                }
            }
            
            boolean isValid = recoveredAddress != null && 
                             recoveredAddress.equalsIgnoreCase(address);
            
            log.info("Signature verification: address={}, valid={}", address, isValid);
            return isValid;
            
        } catch (Exception e) {
            log.error("Error verifying signature for address: {}", address, e);
            return false;
        }
    }
}
