// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title DigitalSeal
 * @dev ERC-721 smart contract for luxury product authentication on Polygon.
 *
 * Flow:
 *  1. Brand (owner) calls batchPreMint() to reserve token IDs for product items.
 *  2. When a buyer purchases, the platform calls purchaseItem() which:
 *     - Accepts MATIC payment
 *     - Takes a 2% platform fee
 *     - Forwards the rest to the brand wallet
 *     - Marks the token as sold
 *  3. After delivery, the platform calls transferSeal() to move the NFT to the buyer.
 *  4. A buyer who has a physical claim code calls claimItem() to claim an NFT directly.
 *  5. Anyone can call verify() to check authenticity.
 */
contract DigitalSeal is ERC721URIStorage, Ownable, ReentrancyGuard {

    // ========== STATE VARIABLES ==========

    uint256 private _nextTokenId;

    /// @notice Platform fee in basis points (200 = 2%)
    uint256 public platformFeeBps = 200;

    /// @notice Platform wallet that receives fees
    address public platformWallet;

    /// @notice Mapping: tokenId → brand wallet that minted it
    mapping(uint256 => address) public tokenBrand;

    /// @notice Mapping: tokenId → item serial string
    mapping(uint256 => string) public tokenSerial;

    /// @notice Mapping: tokenId → whether the item has been sold
    mapping(uint256 => bool) public tokenSold;

    /// @notice Mapping: tokenId → whether the item has been claimed
    mapping(uint256 => bool) public tokenClaimed;

    /// @notice Mapping: tokenId → price in wei (set during premint)
    mapping(uint256 => uint256) public tokenPrice;

    /// @notice Mapping: serial string → tokenId (for lookup)
    mapping(string => uint256) public serialToToken;

    /// @notice Mapping: tokenId → mint timestamp
    mapping(uint256 => uint256) public tokenMintedAt;

    /// @notice Authorized brand wallets (can premint)
    mapping(address => bool) public authorizedBrands;

    // ========== EVENTS ==========

    event BatchPreMinted(
        address indexed brand,
        uint256 startTokenId,
        uint256 count,
        string[] serials
    );

    event ItemPurchased(
        uint256 indexed tokenId,
        address indexed buyer,
        uint256 price,
        uint256 platformFee
    );

    event SealTransferred(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to,
        string reason
    );

    event ItemClaimed(
        uint256 indexed tokenId,
        address indexed claimer,
        string serial
    );

    event BrandAuthorized(address indexed brand, bool authorized);

    event PlatformFeeUpdated(uint256 oldFee, uint256 newFee);

    // ========== MODIFIERS ==========

    modifier onlyAuthorizedBrand() {
        require(
            authorizedBrands[msg.sender] || msg.sender == owner(),
            "DigitalSeal: caller is not an authorized brand"
        );
        _;
    }

    // ========== CONSTRUCTOR ==========

    constructor(address _platformWallet) ERC721("DigitalSeal", "DSEAL") Ownable(msg.sender) {
        require(_platformWallet != address(0), "DigitalSeal: zero address");
        platformWallet = _platformWallet;
        // Owner (platform) is also an authorized brand by default
        authorizedBrands[msg.sender] = true;
    }

    // ========== BRAND MANAGEMENT ==========

    function authorizeBrand(address brand, bool authorized) external onlyOwner {
        authorizedBrands[brand] = authorized;
        emit BrandAuthorized(brand, authorized);
    }

    // ========== PRE-MINT ==========

    /**
     * @dev Batch pre-mint NFTs for a product. Called by brand or platform.
     * @param brandWallet The brand wallet to credit
     * @param serials Array of serial strings (e.g. "SKU-001-0001")
     * @param metadataURIs Array of IPFS/HTTP URIs for token metadata
     * @param pricePerItem Price in wei for each item
     * @return startTokenId The first token ID in the batch
     */
    function batchPreMint(
        address brandWallet,
        string[] calldata serials,
        string[] calldata metadataURIs,
        uint256 pricePerItem
    ) external onlyAuthorizedBrand nonReentrant returns (uint256 startTokenId) {
        require(serials.length > 0, "DigitalSeal: empty batch");
        require(serials.length == metadataURIs.length, "DigitalSeal: array length mismatch");
        require(brandWallet != address(0), "DigitalSeal: zero brand wallet");

        startTokenId = _nextTokenId;

        for (uint256 i = 0; i < serials.length; i++) {
            uint256 tokenId = _nextTokenId++;

            _safeMint(brandWallet, tokenId);
            _setTokenURI(tokenId, metadataURIs[i]);

            tokenBrand[tokenId] = brandWallet;
            tokenSerial[tokenId] = serials[i];
            tokenPrice[tokenId] = pricePerItem;
            tokenMintedAt[tokenId] = block.timestamp;
            serialToToken[serials[i]] = tokenId;
        }

        emit BatchPreMinted(brandWallet, startTokenId, serials.length, serials);
    }

    // ========== PURCHASE ==========

    /**
     * @dev Purchase an item with MATIC. Platform takes fee, rest goes to brand.
     * @param tokenId The token to purchase
     */
    function purchaseItem(uint256 tokenId) external payable nonReentrant {
        require(_ownerExists(tokenId), "DigitalSeal: token does not exist");
        require(!tokenSold[tokenId], "DigitalSeal: already sold");
        require(!tokenClaimed[tokenId], "DigitalSeal: already claimed");
        require(msg.value >= tokenPrice[tokenId], "DigitalSeal: insufficient payment");

        tokenSold[tokenId] = true;

        uint256 fee = (msg.value * platformFeeBps) / 10000;
        uint256 brandPayment = msg.value - fee;

        // Send fee to platform
        (bool feeSuccess, ) = platformWallet.call{value: fee}("");
        require(feeSuccess, "DigitalSeal: fee transfer failed");

        // Send remainder to brand
        address brand = tokenBrand[tokenId];
        (bool brandSuccess, ) = brand.call{value: brandPayment}("");
        require(brandSuccess, "DigitalSeal: brand payment failed");

        emit ItemPurchased(tokenId, msg.sender, msg.value, fee);
    }

    // ========== TRANSFER SEAL ==========

    /**
     * @dev Transfer NFT from brand wallet to buyer after delivery.
     *      Called by platform (owner) or the brand that owns the token.
     * @param tokenId Token to transfer
     * @param to Recipient (buyer) wallet
     * @param reason Reason for transfer ("PURCHASE", "CLAIM", "TRANSFER")
     */
    function transferSeal(
        uint256 tokenId,
        address to,
        string calldata reason
    ) external nonReentrant {
        address tokenOwner = ownerOf(tokenId);

        // Only platform owner or the token holder can initiate transfer
        require(
            msg.sender == owner() || msg.sender == tokenOwner,
            "DigitalSeal: not authorized to transfer"
        );

        address from = tokenOwner;
        _transfer(from, to, tokenId);

        emit SealTransferred(tokenId, from, to, reason);
    }

    // ========== CLAIM ==========

    /**
     * @dev Claim an item (physical QR code flow). Platform calls on behalf of user.
     * @param tokenId Token to claim
     * @param claimer Wallet address of the person claiming
     */
    function claimItem(
        uint256 tokenId,
        address claimer
    ) external onlyOwner nonReentrant {
        require(_ownerExists(tokenId), "DigitalSeal: token does not exist");
        require(!tokenClaimed[tokenId], "DigitalSeal: already claimed");

        tokenClaimed[tokenId] = true;

        address from = ownerOf(tokenId);
        _transfer(from, claimer, tokenId);

        emit ItemClaimed(tokenId, claimer, tokenSerial[tokenId]);
    }

    // ========== VERIFICATION ==========

    /**
     * @dev Verify authenticity of a token.
     * @param tokenId Token to verify
     * @return exists Whether the token exists
     * @return serial The serial number
     * @return brand The brand that minted it
     * @return currentOwner Current owner
     * @return isSold Whether it's been sold
     * @return isClaimed Whether it's been claimed
     * @return mintedAt Mint timestamp
     * @return metadataURI The token URI
     */
    function verify(uint256 tokenId) external view returns (
        bool exists,
        string memory serial,
        address brand,
        address currentOwner,
        bool isSold,
        bool isClaimed,
        uint256 mintedAt,
        string memory metadataURI
    ) {
        exists = _ownerExists(tokenId);
        if (!exists) {
            return (false, "", address(0), address(0), false, false, 0, "");
        }

        serial = tokenSerial[tokenId];
        brand = tokenBrand[tokenId];
        currentOwner = ownerOf(tokenId);
        isSold = tokenSold[tokenId];
        isClaimed = tokenClaimed[tokenId];
        mintedAt = tokenMintedAt[tokenId];
        metadataURI = tokenURI(tokenId);
    }

    /**
     * @dev Verify by serial number
     */
    function verifyBySerial(string calldata serial) external view returns (
        bool exists,
        uint256 tokenId,
        address brand,
        address currentOwner,
        bool isSold,
        bool isClaimed,
        uint256 mintedAt,
        string memory metadataURI
    ) {
        tokenId = serialToToken[serial];
        exists = _ownerExists(tokenId);
        if (!exists) {
            return (false, 0, address(0), address(0), false, false, 0, "");
        }

        brand = tokenBrand[tokenId];
        currentOwner = ownerOf(tokenId);
        isSold = tokenSold[tokenId];
        isClaimed = tokenClaimed[tokenId];
        mintedAt = tokenMintedAt[tokenId];
        metadataURI = tokenURI(tokenId);
    }

    // ========== ADMIN ==========

    function setPlatformFee(uint256 newFeeBps) external onlyOwner {
        require(newFeeBps <= 1000, "DigitalSeal: fee too high (max 10%)");
        uint256 oldFee = platformFeeBps;
        platformFeeBps = newFeeBps;
        emit PlatformFeeUpdated(oldFee, newFeeBps);
    }

    function setPlatformWallet(address newWallet) external onlyOwner {
        require(newWallet != address(0), "DigitalSeal: zero address");
        platformWallet = newWallet;
    }

    // ========== VIEW HELPERS ==========

    function totalSupply() external view returns (uint256) {
        return _nextTokenId;
    }

    function nextTokenId() external view returns (uint256) {
        return _nextTokenId;
    }

    // ========== INTERNAL ==========

    function _ownerExists(uint256 tokenId) internal view returns (bool) {
        if (tokenId >= _nextTokenId) return false;
        try this.ownerOf(tokenId) returns (address) {
            return true;
        } catch {
            return false;
        }
    }
}
