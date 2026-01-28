# Pinata IPFS Setup for Luxury Digital Twin

## Why Pinata?

✅ **Reliable** - Industry-leading uptime  
✅ **Fast** - Global CDN for quick access  
✅ **Free tier** - 1GB storage, plenty for NFTs  
✅ **Simple API** - Easy to use  
✅ **Production-ready** - Used by major NFT projects  

## Quick Start

### 1. Get your free Pinata JWT

1. Go to https://app.pinata.cloud
2. Sign up (free account)
3. Click "API Keys" in the left sidebar
4. Click "New Key"
5. Give it **Admin** permissions (check all boxes)
6. Give it a name (e.g., "Luxury Digital Twin")
7. Click "Create Key"
8. **Copy the JWT** (starts with "eyJ..." and is very long)

### 2. Add JWT to .env file

Edit `/smartcontract/.env` and add:

```env
PINATA_JWT=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. Upload NFT metadata

```bash
node ipfs-utils/pinata-upload.js
```

## Usage Examples

### Basic Upload

```javascript
const { uploadNFT } = require('./ipfs-utils/pinata-upload');

const productDetails = {
  name: 'Rolex Submariner #12345',
  description: 'Authentic Rolex Submariner',
  brand: 'Rolex',
  model: 'Submariner Date',
  serialNumber: '12345',
  year: '2020',
  condition: 'Excellent',
  material: 'Stainless Steel'
};

// Upload with image
const result = await uploadNFT(productDetails, './product-photo.jpg');

// Use in smart contract
await luxuryDigitalTwin.mintDigitalTwin(
  ownerAddress,
  "12345",
  result.metadataURI  // ipfs://QmXxxxxx
);
```

## Full Workflow

```javascript
// 1. Prepare product details
const product = {
  name: 'Rolex Submariner #12345',
  description: 'Authentic Rolex',
  brand: 'Rolex',
  model: 'Submariner',
  serialNumber: '12345',
  year: '2020',
  condition: 'Excellent',
  material: 'Stainless Steel'
};

// 2. Upload to Pinata
const { uploadNFT } = require('./ipfs-utils/pinata-upload');
const result = await uploadNFT(product, './watch-photo.jpg');

// 3. Mint NFT with the metadata URI
const tx = await luxuryDigitalTwin.mintDigitalTwin(
  ownerAddress,
  product.serialNumber,
  result.metadataURI  // ipfs://QmXxxxxx
);

console.log('NFT minted!', tx.hash);
```

## Support

- Documentation: https://docs.pinata.cloud
- Support: support@pinata.cloud
- Dashboard: https://app.pinata.cloud
