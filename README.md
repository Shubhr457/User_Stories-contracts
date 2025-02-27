# Real Estate Tokenization Smart Contracts

This repository contains Solidity smart contracts for tokenizing real estate properties on the blockchain. The system allows property owners to create either fungible (ERC20) or non-fungible (ERC721) tokens representing ownership shares in properties.

## Overview

The system consists of three main contracts:

1. **PropertyToken** - An ERC20 token representing fractional ownership in a property
2. **PropertyNFT** - An ERC721 token representing unique ownership units of a property
3. **PropertyFactory** - A factory contract for creating and managing property tokens

## Contract Details

### PropertyToken (ERC20)

The PropertyToken contract creates fungible tokens that represent fractional ownership shares in a property. Each token represents an equal portion of the underlying real estate asset.

**Features:**
- Property metadata storage (ID, valuation, details)
- Customizable token name and symbol
- Configurable total supply
- Property details can be updated by the owner

### PropertyNFT (ERC721)

The PropertyNFT contract creates non-fungible tokens that represent unique ownership units of a property. Each NFT can represent different portions or aspects of the property.

**Features:**
- Property metadata storage (ID, valuation, details)
- Customizable token name and symbol
- Limited maximum supply
- Individual and batch minting capabilities
- Customizable base URI for token metadata
- Property details can be updated by the owner

### PropertyFactory

The PropertyFactory contract serves as a central registry and factory for creating property tokens. It allows the owner to deploy new PropertyToken or PropertyNFT contracts and keeps track of all created tokens.

**Features:**
- Create ERC20 property tokens
- Create ERC721 property NFT collections
- Track all property tokens by ID
- Query property token addresses

## Usage

### Deploying the Factory

1. Deploy the PropertyFactory contract
2. The deploying address becomes the owner with administrative privileges

### Creating a Property Token (ERC20)

Call the `createPropertyToken` function on the PropertyFactory contract with the following parameters:

```solidity
function createPropertyToken(
    string memory _propertyId,
    string memory _name,
    string memory _symbol,
    uint256 _totalSupply,
    address _issuer,
    uint256 _propertyValuation,
    string memory _propertyDetails
) external onlyOwner returns (address tokenAddress)
```

### Creating a Property NFT Collection (ERC721)

Call the `createPropertyNFT` function on the PropertyFactory contract with the following parameters:

```solidity
function createPropertyNFT(
    string memory _propertyId,
    string memory _name,
    string memory _symbol,
    uint256 _maxSupply,
    address _issuer,
    uint256 _propertyValuation,
    string memory _propertyDetails,
    string memory _baseTokenURI
) external onlyOwner returns (address tokenAddress)
```

### Minting NFTs

Once a PropertyNFT contract is created, the owner can mint NFTs using:

- `mint(address to)` - Mint a single NFT
- `batchMint(address to, uint256 count)` - Mint multiple NFTs at once

## Security Considerations

- All administrative functions are protected with the `onlyOwner` modifier
- The contracts use OpenZeppelin's standard implementations for security and reliability
- Token creation and minting are restricted to authorized addresses

## Requirements

- Solidity ^0.8.18
- OpenZeppelin Contracts

## Dependencies

The contracts rely on the following OpenZeppelin libraries:

```solidity
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
```
