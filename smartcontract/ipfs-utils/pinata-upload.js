const { PinataSDK } = require("pinata-web3");
const fs = require('fs');
const path = require('path');
const FormData = require('form-data');
const fetch = require('node-fetch');
require('dotenv').config();

// Polyfills for Node.js environment
global.FormData = FormData;
global.fetch = fetch;

const PINATA_JWT = process.env.PINATA_JWT;

if (!PINATA_JWT) {
  console.error('❌ Error: PINATA_JWT not found in .env file');
  console.log('\n📝 Please add your Pinata JWT to .env:');
  console.log('   PINATA_JWT=your_jwt_here');
  console.log('\n🔑 Get your free JWT at: https://app.pinata.cloud');
  process.exit(1);
}

const pinata = new PinataSDK({
  pinataJwt: PINATA_JWT
});

/**
 * Upload NFT with image and metadata to Pinata
 * @param {object} productDetails - Product information
 * @param {string} imagePath - Path to product image
 * @returns {Promise<object>} - Upload result with IPFS URLs
 */
async function uploadNFT(productDetails, imagePath) {
  try {
    console.log(`\n🚀 Uploading NFT for: ${productDetails.name}`);
    
    // 1. Upload image first
    console.log(`📸 Uploading image: ${imagePath}`);
    const imageFile = fs.createReadStream(imagePath);
    const imageUpload = await pinata.upload.file(imageFile);
    
    const imageCID = imageUpload.IpfsHash;
    console.log(`✅ Image uploaded! CID: ${imageCID}`);
    
    // 2. Create metadata JSON
    const metadata = {
      name: productDetails.name,
      description: productDetails.description,
      image: `ipfs://${imageCID}`,
      attributes: [
        { trait_type: "Brand", value: productDetails.brand },
        { trait_type: "Model", value: productDetails.model },
        { trait_type: "Serial Number", value: productDetails.serialNumber },
        { trait_type: "Year", value: productDetails.year },
        { trait_type: "Condition", value: productDetails.condition },
        { trait_type: "Material", value: productDetails.material }
      ]
    };
    
    // 3. Upload metadata JSON
    console.log(`📦 Uploading metadata...`);
    const metadataUpload = await pinata.upload.json(metadata);
    
    const metadataCID = metadataUpload.IpfsHash;
    console.log(`✅ Metadata uploaded! CID: ${metadataCID}`);
    
    console.log('\n🎉 Upload Complete!');
    console.log(`   Metadata URI: ipfs://${metadataCID}`);
    console.log(`   Image URI: ipfs://${imageCID}`);
    console.log(`   Gateway URL: https://gateway.pinata.cloud/ipfs/${metadataCID}`);
    
    return {
      metadataURI: `ipfs://${metadataCID}`,
      metadataCID: metadataCID,
      imageURI: `ipfs://${imageCID}`,
      imageCID: imageCID,
      gatewayURL: `https://gateway.pinata.cloud/ipfs/${metadataCID}`
    };
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    throw error;
  }
}

/**
 * Create placeholder image for testing
 */
function createPlaceholderImage() {
  const placeholderSVG = `<svg width="400" height="400" xmlns="http://www.w3.org/2000/svg">
    <rect width="400" height="400" fill="#1a1a2e"/>
    <text x="200" y="180" font-family="Arial" font-size="24" fill="#eee" text-anchor="middle">Luxury Digital Twin</text>
    <text x="200" y="220" font-family="Arial" font-size="18" fill="#ccc" text-anchor="middle">Rolex Submariner</text>
    <text x="200" y="250" font-family="Arial" font-size="16" fill="#aaa" text-anchor="middle">Serial #12345</text>
  </svg>`;
  
  const tempDir = path.join(__dirname, 'temp');
  if (!fs.existsSync(tempDir)) {
    fs.mkdirSync(tempDir);
  }
  
  const placeholderPath = path.join(tempDir, 'placeholder.svg');
  fs.writeFileSync(placeholderPath, placeholderSVG);
  return placeholderPath;
}

/**
 * Example usage
 */
async function example() {
  console.log('=== Pinata IPFS Upload ===');
  
  const productDetails = {
    name: 'Rolex Submariner #12345',
    description: 'Authentic Rolex Submariner Date 41mm in stainless steel with black ceramic bezel. Comes with original box and papers.',
    brand: 'Rolex',
    model: 'Submariner Date',
    serialNumber: '12345',
    year: '2020',
    condition: 'Excellent',
    material: 'Stainless Steel'
  };
  
  // Create placeholder image for testing
  const placeholderPath = createPlaceholderImage();
  console.log(`✨ Generated test image: ${placeholderPath}`);
  
  // Upload to Pinata
  const result = await uploadNFT(productDetails, placeholderPath);
  
  // Clean up
  fs.unlinkSync(placeholderPath);
  fs.rmdirSync(path.join(__dirname, 'temp'));
  
  console.log('\n🎯 Use this URI when minting your NFT:');
  console.log(`   ${result.metadataURI}`);
  console.log('\n💡 To upload with your own image:');
  console.log('   const result = await uploadNFT(productDetails, "./your-photo.jpg");');
}

// Run if called directly
if (require.main === module) {
  example().catch(console.error);
}

module.exports = {
  uploadNFT
};
