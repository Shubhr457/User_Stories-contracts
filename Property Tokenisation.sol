// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title PropertyToken
 * @dev ERC20 token representing ownership shares in a specific property
 */
contract PropertyToken is ERC20, Ownable(msg.sender) {
    // Property metadata
    string public propertyId;
    address public issuer;
    uint256 public propertyValuation;
    string public propertyDetails; // URI or IPFS hash to additional property metadata
    
    // Events
    event PropertyTokenCreated(string propertyId, address issuer, uint256 totalSupply, uint256 propertyValuation);
    
    /**
     * @dev Constructor to create a new property token
     * @param _propertyId Unique identifier for the property
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _totalSupply Total supply of tokens
     * @param _issuer Address of the property issuer
     * @param _propertyValuation Valuation of the property in base currency
     * @param _propertyDetails Additional property details (URI or IPFS hash)
     * @param _admin Address that will become the owner of the contract
     */
    constructor(
        string memory _propertyId,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        address _issuer,
        uint256 _propertyValuation,
        string memory _propertyDetails,
        address _admin
    ) ERC20(_name, _symbol) {
        propertyId = _propertyId;
        issuer = _issuer;
        propertyValuation = _propertyValuation;
        propertyDetails = _propertyDetails;
        
        // Mint all tokens to the admin
        _mint(_admin, _totalSupply * 10**decimals());
        
        // Transfer ownership to admin
        transferOwnership(_admin);
        
        emit PropertyTokenCreated(propertyId, issuer, _totalSupply, propertyValuation);
    }
    
    /**
     * @dev Returns the number of decimals used for token (overrides ERC20)
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }
    
    /**
     * @dev Updates property details (only owner can call)
     * @param _newPropertyDetails New property details URI or IPFS hash
     */
    function updatePropertyDetails(string memory _newPropertyDetails) external onlyOwner {
        propertyDetails = _newPropertyDetails;
    }
}

/**
 * @title PropertyNFT
 * @dev ERC721 token representing unique ownership units of a property
 */
contract PropertyNFT is ERC721, Ownable(msg.sender){
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    
    // Property metadata
    string public propertyId;
    address public issuer;
    uint256 public propertyValuation;
    string public propertyDetails; // URI or IPFS hash to additional property metadata
    uint256 public maxSupply;
    
    // Base URI for token metadata
    string private _baseTokenURI;
    
    // Events
    event PropertyNFTCreated(string propertyId, address issuer, uint256 maxSupply, uint256 propertyValuation);
    event NFTMinted(address to, uint256 tokenId);
    
    /**
     * @dev Constructor to create a new property NFT collection
     * @param _propertyId Unique identifier for the property
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _maxSupply Maximum number of NFTs that can be minted
     * @param _issuer Address of the property issuer
     * @param _propertyValuation Valuation of the property in base currency
     * @param _propertyDetails Additional property details (URI or IPFS hash)
     * @param baseTokenURIParam Base URI for token metadata
     */
    constructor(
        string memory _propertyId,
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        address _issuer,
        uint256 _propertyValuation,
        string memory _propertyDetails,
        string memory baseTokenURIParam
    ) ERC721(_name, _symbol) {
        propertyId = _propertyId;
        issuer = _issuer;
        propertyValuation = _propertyValuation;
        propertyDetails = _propertyDetails;
        maxSupply = _maxSupply;
        _baseTokenURI = baseTokenURIParam;
        
        emit PropertyNFTCreated(propertyId, issuer, maxSupply, propertyValuation);
    }
    
    /**
     * @dev Mint a new NFT (only owner can call)
     * @param to Address to mint the NFT to
     * @return tokenId ID of the minted token
     */
    function mint(address to) external onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        require(tokenId < maxSupply, "Maximum supply reached");
        
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        
        emit NFTMinted(to, tokenId);
        return tokenId;
    }
    
    /**
     * @dev Batch mint multiple NFTs (only owner can call)
     * @param to Address to mint the NFTs to
     * @param count Number of NFTs to mint
     */
    function batchMint(address to, uint256 count) external onlyOwner {
        require(_tokenIdCounter.current() + count <= maxSupply, "Would exceed maximum supply");
        
        for (uint256 i = 0; i < count; i++) {
            this.mint(to);

        }
    }
    
    /**
     * @dev Base URI for computing {tokenURI}
     */
    function _baseURI() internal view override returns (string memory) {
        return _baseTokenURI;
    }
    
    /**
     * @dev Updates base token URI (only owner can call)
     * @param newBaseURI New base URI
     */
    function setBaseURI(string memory newBaseURI) external onlyOwner {
        _baseTokenURI = newBaseURI;
    }
    
    /**
     * @dev Updates property details (only owner can call)
     * @param _newPropertyDetails New property details URI or IPFS hash
     */
    function updatePropertyDetails(string memory _newPropertyDetails) external onlyOwner {
        propertyDetails = _newPropertyDetails;
    }
}

/**
 * @title PropertyFactory
 * @dev Factory contract for creating and managing property tokens
 */
contract PropertyFactory is Ownable(msg.sender){
    // Mapping of property ID to token address
    mapping(string => address) public propertyTokens;
    
    // Array to store all property IDs
    string[] public allPropertyIds;
    
    // Mapping to track if a property ID exists
    mapping(string => bool) public propertyExists;
    
    // Enum for token type
    enum TokenType { ERC20, ERC721 }
    
    // Events
    event PropertyTokenCreated(string propertyId, address tokenAddress, TokenType tokenType);
    
    /**
     * @dev Creates a new ERC20 property token
     * @param _propertyId Unique identifier for the property
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _totalSupply Total supply of tokens
     * @param _issuer Address of the property issuer
     * @param _propertyValuation Valuation of the property in base currency
     * @param _propertyDetails Additional property details (URI or IPFS hash)
     * @return tokenAddress Address of the created token contract
     */
    function createPropertyToken(
        string memory _propertyId,
        string memory _name,
        string memory _symbol,
        uint256 _totalSupply,
        address _issuer,
        uint256 _propertyValuation,
        string memory _propertyDetails
    ) external onlyOwner returns (address tokenAddress) {
        require(!propertyExists[_propertyId], "Property ID already exists");
        
        PropertyToken newToken = new PropertyToken(
            _propertyId,
            _name,
            _symbol,
            _totalSupply,
            _issuer,
            _propertyValuation,
            _propertyDetails,
            owner()  // Admin address
        );
        
        tokenAddress = address(newToken);
        propertyTokens[_propertyId] = tokenAddress;
        allPropertyIds.push(_propertyId);
        propertyExists[_propertyId] = true;
        
        emit PropertyTokenCreated(_propertyId, tokenAddress, TokenType.ERC20);
        return tokenAddress;
    }
    
    /**
     * @dev Creates a new ERC721 property NFT collection
     * @param _propertyId Unique identifier for the property
     * @param _name Token name
     * @param _symbol Token symbol
     * @param _maxSupply Maximum number of NFTs that can be minted
     * @param _issuer Address of the property issuer
     * @param _propertyValuation Valuation of the property in base currency
     * @param _propertyDetails Additional property details (URI or IPFS hash)
     * @param _baseTokenURI Base URI for token metadata
     * @return tokenAddress Address of the created NFT contract
     */
    function createPropertyNFT(
        string memory _propertyId,
        string memory _name,
        string memory _symbol,
        uint256 _maxSupply,
        address _issuer,
        uint256 _propertyValuation,
        string memory _propertyDetails,
        string memory _baseTokenURI
    ) external onlyOwner returns (address tokenAddress) {
        require(!propertyExists[_propertyId], "Property ID already exists");
        
        PropertyNFT newNFT = new PropertyNFT(
            _propertyId,
            _name,
            _symbol,
            _maxSupply,
            _issuer,
            _propertyValuation,
            _propertyDetails,
            _baseTokenURI
        );
        
        // Transfer ownership to admin
        newNFT.transferOwnership(owner());
        
        tokenAddress = address(newNFT);
        propertyTokens[_propertyId] = tokenAddress;
        allPropertyIds.push(_propertyId);
        propertyExists[_propertyId] = true;
        
        emit PropertyTokenCreated(_propertyId, tokenAddress, TokenType.ERC721);
        return tokenAddress;
    }
    
    /**
     * @dev Get the total number of properties
     * @return count Number of properties
     */
    function getPropertyCount() external view returns (uint256) {
        return allPropertyIds.length;
    }
    
    /**
     * @dev Get property token address by ID
     * @param _propertyId Property ID
     * @return tokenAddress Address of the property token contract
     */
    function getPropertyTokenAddress(string memory _propertyId) external view returns (address) {
        require(propertyExists[_propertyId], "Property does not exist");
        return propertyTokens[_propertyId];
    }
}
