const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying DigitalSeal with account:", deployer.address);
  console.log("Account balance:", hre.ethers.formatEther(await hre.ethers.provider.getBalance(deployer.address)), "MATIC");

  // Deploy with deployer as platform wallet (Account #0)
  const DigitalSeal = await hre.ethers.getContractFactory("DigitalSeal");
  const digitalSeal = await DigitalSeal.deploy(deployer.address);
  await digitalSeal.waitForDeployment();

  const contractAddress = await digitalSeal.getAddress();
  console.log("\n=== DEPLOYMENT SUCCESSFUL ===");
  console.log("Contract Address:", contractAddress);
  console.log("Platform Wallet:", deployer.address);
  console.log("Chain ID:", (await hre.ethers.provider.getNetwork()).chainId.toString());
  console.log("\nUpdate your backend .env with:");
  console.log(`CONTRACT_ADDRESS=${contractAddress}`);

  // Authorize Account #1 as a brand wallet
  const signers = await hre.ethers.getSigners();
  if (signers.length > 1) {
    const brandWallet = signers[1].address;
    const tx = await digitalSeal.authorizeBrand(brandWallet, true);
    await tx.wait();
    console.log(`\nAuthorized brand wallet: ${brandWallet}`);
  }

  console.log("\n=== HARDHAT ACCOUNTS ===");
  console.log("Account #0 (Platform):", signers[0].address);
  if (signers.length > 1) console.log("Account #1 (Brand):", signers[1].address);
  if (signers.length > 2) console.log("Account #2 (Buyer):", signers[2].address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
