// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title LuxuryDigitalTwin
 * @dev Smart contract for luxury product digital twins on Polygon network
 * @notice This contract implements ERC-721 NFTs representing physical luxury items
 * 
 * Features:
 * - Minting of digital twins by authorized brands
 * - Product verification and authenticity checks
 * - Secure ownership transfers
 * - Comprehensive history tracking (repairs, appraisals, etc.)
 * - IPFS metadata storage
 * 
 * Optimized for Polygon network (low gas costs)
 */
contract LuxuryDigitalTwin is ERC721URIStorage, Ownable, ReentrancyGuard {
    
    // ========== STATE VARIABLES ==========
    
    /// @notice Counter for token IDs
    uint256 private _tokenIdCounter;
    
    /// @notice Brand name for this contract instance
    string public brandName;
    
    /// @notice Struct to store digital twin metadata
    struct DigitalTwin {
        string serialNumber;      // Unique product serial number
        string ipfsUri;           // IPFS URI for metadata
        uint256 mintTimestamp;    // When the NFT was minted
        address originalMinter;   // Original brand/manufacturer address
        bool isVerified;          // Verification status
    }
    
    /// @notice Struct for history entries (repairs, appraisals, etc.)
    struct HistoryEntry {
        string entryType;         // "Repair", "Appraisal", "Service", etc.
        string details;           // Description or IPFS URI with details
        uint256 timestamp;        // When the entry was added
        address authorizedBy;     // Who added the entry
    }
    
    /// @notice Mapping from token ID to DigitalTwin metadata
    mapping(uint256 => DigitalTwin) private _digitalTwins;
    
    /// @notice Mapping from token ID to array of history entries
    mapping(uint256 => HistoryEntry[]) private _historyLog;
    
    /// @notice Mapping of authorized service addresses (e.g., repair shops, appraisers)
    mapping(address => bool) public authorizedServices;
    
    /// @notice Mapping from serial number to token ID for quick lookups
    mapping(string => uint256) private _serialToTokenId;
    
    /// @notice Mapping to check if serial number exists
    mapping(string => bool) private _serialExists;
    
    // ========== EVENTS ==========
    
    /**
     * @dev Emitted when a new digital twin is minted
     * @param tokenId The ID of the newly minted token
     * @param serialNumber The product's serial number
     * @param ipfsUri The IPFS URI containing metadata
     * @param minter The address that minted the token
     */
    event DigitalTwinMinted(
        uint256 indexed tokenId,
        string serialNumber,
        string ipfsUri,
        address indexed minter
    );
    
    /**
     * @dev Emitted when a history entry is added
     * @param tokenId The token ID receiving the history entry
     * @param entryType Type of entry (Repair, Appraisal, etc.)
     * @param details Details or IPFS URI
     * @param authorizedBy Address that added the entry
     */
    event HistoryEntryAdded(
        uint256 indexed tokenId,
        string entryType,
        string details,
        address indexed authorizedBy
    );
    
    /**
     * @dev Emitted when a service provider is authorized/deauthorized
     * @param serviceAddress The address being authorized
     * @param status True if authorized, false if deauthorized
     */
    event ServiceAuthorizationChanged(
        address indexed serviceAddress,
        bool status
    );
    
    /**
     * @dev Emitted when ownership is transferred (for tracking)
     * @param tokenId The token being transferred
     * @param from Previous owner
     * @param to New owner
     */
    event OwnershipTransferred(
        uint256 indexed tokenId,
        address indexed from,
        address indexed to
    );
    
    // ========== CONSTRUCTOR ==========
    
    /**
     * @dev Constructor to initialize the contract
     * @param _brandName The name of the luxury brand
     * 
     * Web3j note: Constructor parameters must match deployment order
     */
    constructor(string memory _brandName) 
        ERC721("LuxuryDigitalTwin", "LDT")
    {
        brandName = _brandName;
        _tokenIdCounter = 1; // Start token IDs from 1
    }
    
    // ========== MODIFIERS ==========
    
    /**
     * @dev Modifier to check if caller is owner or authorized service
     */
    modifier onlyAuthorized() {
        require(
            msg.sender == owner() || authorizedServices[msg.sender],
            "LuxuryDigitalTwin: caller is not authorized"
        );
        _;
    }
    
    // ========== MINTING FUNCTIONS ==========
    
    /**
     * @dev Mint a new Digital Twin NFT (Brand/Manufacturer only)
     * @param to Address to receive the NFT
     * @param serialNumber Unique product serial number
     * @param ipfsUri IPFS URI containing product metadata
     * @return tokenId The ID of the newly minted token
     * 
     * Requirements:
     * - Caller must be contract owner (brand)
     * - Serial number must be unique
     * - Serial number and IPFS URI cannot be empty
     * 
     * Web3j note: Returns uint256 tokenId for transaction receipt parsing
     */
    function mintDigitalTwin(
        address to,
        string memory serialNumber,
        string memory ipfsUri
    ) public onlyOwner nonReentrant returns (uint256) {
        require(to != address(0), "LuxuryDigitalTwin: mint to zero address");
        require(bytes(serialNumber).length > 0, "LuxuryDigitalTwin: empty serial number");
        require(bytes(ipfsUri).length > 0, "LuxuryDigitalTwin: empty IPFS URI");
        require(!_serialExists[serialNumber], "LuxuryDigitalTwin: serial number already exists");
        
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        
        // Mint the NFT
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, ipfsUri);
        
        // Store digital twin metadata
        _digitalTwins[tokenId] = DigitalTwin({
            serialNumber: serialNumber,
            ipfsUri: ipfsUri,
            mintTimestamp: block.timestamp,
            originalMinter: msg.sender,
            isVerified: true // Automatically verified as minted by brand
        });
        
        // Map serial number to token ID
        _serialToTokenId[serialNumber] = tokenId;
        _serialExists[serialNumber] = true;
        
        emit DigitalTwinMinted(tokenId, serialNumber, ipfsUri, msg.sender);
        
        return tokenId;
    }
    
    /**
     * @dev Batch mint multiple Digital Twins (gas-optimized for Polygon)
     * @param recipients Array of addresses to receive NFTs
     * @param serialNumbers Array of serial numbers
     * @param ipfsUris Array of IPFS URIs
     * @return tokenIds Array of minted token IDs
     * 
     * Requirements:
     * - All arrays must have equal length
     * - Caller must be contract owner
     * 
     * Web3j note: Returns uint256[] for batch operations
     */
    function batchMintDigitalTwins(
        address[] memory recipients,
        string[] memory serialNumbers,
        string[] memory ipfsUris
    ) external onlyOwner nonReentrant returns (uint256[] memory) {
        require(
            recipients.length == serialNumbers.length && 
            recipients.length == ipfsUris.length,
            "LuxuryDigitalTwin: array length mismatch"
        );
        
        uint256[] memory tokenIds = new uint256[](recipients.length);
        
        for (uint256 i = 0; i < recipients.length; i++) {
            tokenIds[i] = mintDigitalTwin(recipients[i], serialNumbers[i], ipfsUris[i]);
        }
        
        return tokenIds;
    }
    
    // ========== VERIFICATION FUNCTIONS ==========
    
    /**
     * @dev Verify product authenticity by token ID
     * @param tokenId The token ID to verify
     * @return brand The brand name
     * @return serialNumber The product serial number
     * @return ipfsUri The IPFS metadata URI
     * @return isVerified Verification status
     * @return owner Current owner address
     * 
     * Web3j note: Multiple return values - parse as tuple/struct
     */
    function verifyProduct(uint256 tokenId) 
        external 
        view 
        returns (
            string memory brand,
            string memory serialNumber,
            string memory ipfsUri,
            bool isVerified,
            address owner
        ) 
    {
        require(_ownerOf(tokenId) != address(0), "LuxuryDigitalTwin: token does not exist");
        
        DigitalTwin memory twin = _digitalTwins[tokenId];
        
        return (
            brandName,
            twin.serialNumber,
            twin.ipfsUri,
            twin.isVerified,
            ownerOf(tokenId)
        );
    }
    
    /**
     * @dev Verify product by serial number
     * @param serialNumber The product serial number
     * @return tokenId The associated token ID
     * @return brand The brand name
     * @return ipfsUri The IPFS metadata URI
     * @return isVerified Verification status
     * @return owner Current owner address
     * 
     * Web3j note: Useful for QR code scanning - lookup by serial
     */
    function verifyBySerialNumber(string memory serialNumber)
        external
        view
        returns (
            uint256 tokenId,
            string memory brand,
            string memory ipfsUri,
            bool isVerified,
            address owner
        )
    {
        require(_serialExists[serialNumber], "LuxuryDigitalTwin: serial number not found");
        
        tokenId = _serialToTokenId[serialNumber];
        DigitalTwin memory twin = _digitalTwins[tokenId];
        
        return (
            tokenId,
            brandName,
            twin.ipfsUri,
            twin.isVerified,
            ownerOf(tokenId)
        );
    }
    
    /**
     * @dev Get detailed information about a digital twin
     * @param tokenId The token ID to query
     * @return twin The complete DigitalTwin struct
     * 
     * Web3j note: Returns struct - map to Java POJO
     */
    function getDigitalTwinInfo(uint256 tokenId) 
        external 
        view 
        returns (DigitalTwin memory twin) 
    {
        require(_ownerOf(tokenId) != address(0), "LuxuryDigitalTwin: token does not exist");
        return _digitalTwins[tokenId];
    }
    
    // ========== OWNERSHIP TRANSFER FUNCTIONS ==========
    
    /**
     * @dev Secure transfer of digital twin to new owner (secondary market)
     * @param from Current owner address
     * @param to New owner address
     * @param tokenId Token ID to transfer
     * 
     * Requirements:
     * - Caller must be token owner or approved
     * - Adds transfer to history log automatically
     * 
     * Web3j note: Standard ERC721 transfer with history logging
     */
    function secureTransfer(
        address from,
        address to,
        uint256 tokenId
    ) external nonReentrant {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "LuxuryDigitalTwin: caller is not owner nor approved"
        );
        
        // Add transfer to history log
        _addHistoryEntry(
            tokenId,
            "Ownership Transfer",
            string(abi.encodePacked("Transferred from ", 
                _addressToString(from), 
                " to ", 
                _addressToString(to)
            )),
            msg.sender
        );
        
        // Execute transfer
        safeTransferFrom(from, to, tokenId);
        
        emit OwnershipTransferred(tokenId, from, to);
    }
    
    // ========== HISTORY TRACKING FUNCTIONS ==========
    
    /**
     * @dev Add a repair log, appraisal, or service entry
     * @param tokenId Token ID to add history for
     * @param entryType Type of entry ("Repair", "Appraisal", "Service", etc.)
     * @param details Description or IPFS URI with detailed information
     * 
     * Requirements:
     * - Caller must be owner or authorized service provider
     * - Token must exist
     * 
     * Web3j note: Emits HistoryEntryAdded event - listen for updates
     */
    function addHistoryEntry(
        uint256 tokenId,
        string memory entryType,
        string memory details
    ) external onlyAuthorized {
        require(_ownerOf(tokenId) != address(0), "LuxuryDigitalTwin: token does not exist");
        require(bytes(entryType).length > 0, "LuxuryDigitalTwin: empty entry type");
        require(bytes(details).length > 0, "LuxuryDigitalTwin: empty details");
        
        _addHistoryEntry(tokenId, entryType, details, msg.sender);
    }
    
    /**
     * @dev Internal function to add history entry
     */
    function _addHistoryEntry(
        uint256 tokenId,
        string memory entryType,
        string memory details,
        address authorizedBy
    ) private {
        _historyLog[tokenId].push(HistoryEntry({
            entryType: entryType,
            details: details,
            timestamp: block.timestamp,
            authorizedBy: authorizedBy
        }));
        
        emit HistoryEntryAdded(tokenId, entryType, details, authorizedBy);
    }
    
    /**
     * @dev Get complete history for a digital twin
     * @param tokenId Token ID to query
     * @return entries Array of all history entries
     * 
     * Web3j note: Returns array of structs - map to Java List<HistoryEntry>
     */
    function getHistory(uint256 tokenId) 
        external 
        view 
        returns (HistoryEntry[] memory entries) 
    {
        require(_ownerOf(tokenId) != address(0), "LuxuryDigitalTwin: token does not exist");
        return _historyLog[tokenId];
    }
    
    /**
     * @dev Get the number of history entries for a token
     * @param tokenId Token ID to query
     * @return count Number of history entries
     * 
     * Web3j note: Use to paginate getHistory results if needed
     */
    function getHistoryCount(uint256 tokenId) 
        external 
        view 
        returns (uint256 count) 
    {
        require(_ownerOf(tokenId) != address(0), "LuxuryDigitalTwin: token does not exist");
        return _historyLog[tokenId].length;
    }
    
    // ========== AUTHORIZATION MANAGEMENT ==========
    
    /**
     * @dev Authorize a service provider (repair shop, appraiser, etc.)
     * @param serviceAddress Address to authorize
     * 
     * Requirements:
     * - Caller must be contract owner (brand)
     * 
     * Web3j note: Call before service provider can add history entries
     */
    function authorizeService(address serviceAddress) external onlyOwner {
        require(serviceAddress != address(0), "LuxuryDigitalTwin: zero address");
        require(!authorizedServices[serviceAddress], "LuxuryDigitalTwin: already authorized");
        
        authorizedServices[serviceAddress] = true;
        emit ServiceAuthorizationChanged(serviceAddress, true);
    }
    
    /**
     * @dev Revoke service provider authorization
     * @param serviceAddress Address to deauthorize
     * 
     * Requirements:
     * - Caller must be contract owner (brand)
     * 
     * Web3j note: Remove service provider access
     */
    function revokeServiceAuthorization(address serviceAddress) external onlyOwner {
        require(authorizedServices[serviceAddress], "LuxuryDigitalTwin: not authorized");
        
        authorizedServices[serviceAddress] = false;
        emit ServiceAuthorizationChanged(serviceAddress, false);
    }
    
    /**
     * @dev Check if an address is an authorized service provider
     * @param serviceAddress Address to check
     * @return bool True if authorized
     * 
     * Web3j note: View function for access control checks
     */
    function isAuthorizedService(address serviceAddress) 
        external 
        view 
        returns (bool) 
    {
        return authorizedServices[serviceAddress];
    }
    
    // ========== UTILITY FUNCTIONS ==========
    
    /**
     * @dev Get total number of minted tokens
     * @return uint256 Total supply
     * 
     * Web3j note: Useful for indexing/pagination
     */
    function totalSupply() external view returns (uint256) {
        return _tokenIdCounter - 1;
    }
    
    /**
     * @dev Check if a serial number exists
     * @param serialNumber Serial number to check
     * @return bool True if exists
     * 
     * Web3j note: Quick existence check before verification
     */
    function serialNumberExists(string memory serialNumber) 
        external 
        view 
        returns (bool) 
    {
        return _serialExists[serialNumber];
    }
    
    /**
     * @dev Convert address to string (for history logging)
     */
    function _addressToString(address _addr) private pure returns (string memory) {
        bytes32 value = bytes32(uint256(uint160(_addr)));
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = '0';
        str[1] = 'x';
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
        }
        return string(str);
    }
    
    /**
     * @dev Override required by Solidity for ERC721URIStorage
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
    
    /**
     * @dev Override required by Solidity for ERC721URIStorage
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}