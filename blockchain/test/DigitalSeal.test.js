const { expect } = require("chai");
const hre = require("hardhat");

describe("DigitalSeal", function () {
  let digitalSeal;
  let platform, brand, buyer, other;
  const PRICE = hre.ethers.parseEther("0.5"); // 0.5 MATIC

  beforeEach(async function () {
    [platform, brand, buyer, other] = await hre.ethers.getSigners();

    const DigitalSeal = await hre.ethers.getContractFactory("DigitalSeal");
    digitalSeal = await DigitalSeal.deploy(platform.address);
    await digitalSeal.waitForDeployment();

    // Authorize brand
    await digitalSeal.authorizeBrand(brand.address, true);
  });

  describe("Deployment", function () {
    it("Should set the correct platform wallet", async function () {
      expect(await digitalSeal.platformWallet()).to.equal(platform.address);
    });

    it("Should set platform fee to 2%", async function () {
      expect(await digitalSeal.platformFeeBps()).to.equal(200n);
    });

    it("Should set platform as owner", async function () {
      expect(await digitalSeal.owner()).to.equal(platform.address);
    });
  });

  describe("Brand Authorization", function () {
    it("Should authorize a brand", async function () {
      expect(await digitalSeal.authorizedBrands(brand.address)).to.be.true;
    });

    it("Should reject unauthorized brand minting", async function () {
      await expect(
        digitalSeal.connect(other).batchPreMint(
          other.address,
          ["SERIAL-001"],
          ["ipfs://meta1"],
          PRICE
        )
      ).to.be.revertedWith("DigitalSeal: caller is not an authorized brand");
    });
  });

  describe("Batch PreMint", function () {
    it("Should batch premint items", async function () {
      const serials = ["LV-BAG-0001", "LV-BAG-0002", "LV-BAG-0003"];
      const uris = ["ipfs://meta1", "ipfs://meta2", "ipfs://meta3"];

      const tx = await digitalSeal.connect(brand).batchPreMint(
        brand.address, serials, uris, PRICE
      );
      const receipt = await tx.wait();

      expect(await digitalSeal.totalSupply()).to.equal(3n);
      expect(await digitalSeal.ownerOf(0)).to.equal(brand.address);
      expect(await digitalSeal.ownerOf(1)).to.equal(brand.address);
      expect(await digitalSeal.ownerOf(2)).to.equal(brand.address);
      expect(await digitalSeal.tokenSerial(0)).to.equal("LV-BAG-0001");
      expect(await digitalSeal.tokenPrice(0)).to.equal(PRICE);
    });

    it("Should map serial to tokenId", async function () {
      await digitalSeal.connect(brand).batchPreMint(
        brand.address, ["SERIAL-X"], ["ipfs://x"], PRICE
      );
      expect(await digitalSeal.serialToToken("SERIAL-X")).to.equal(0n);
    });

    it("Should reject empty batch", async function () {
      await expect(
        digitalSeal.connect(brand).batchPreMint(brand.address, [], [], PRICE)
      ).to.be.revertedWith("DigitalSeal: empty batch");
    });
  });

  describe("Purchase", function () {
    beforeEach(async function () {
      await digitalSeal.connect(brand).batchPreMint(
        brand.address, ["ITEM-001"], ["ipfs://item1"], PRICE
      );
    });

    it("Should allow purchase with correct payment", async function () {
      const brandBalBefore = await hre.ethers.provider.getBalance(brand.address);
      const platformBalBefore = await hre.ethers.provider.getBalance(platform.address);

      await digitalSeal.connect(buyer).purchaseItem(0, { value: PRICE });

      expect(await digitalSeal.tokenSold(0)).to.be.true;

      // Check platform received 2% fee
      const fee = PRICE * 200n / 10000n;
      const brandPayment = PRICE - fee;
      const platformBalAfter = await hre.ethers.provider.getBalance(platform.address);
      const brandBalAfter = await hre.ethers.provider.getBalance(brand.address);

      expect(platformBalAfter - platformBalBefore).to.equal(fee);
      expect(brandBalAfter - brandBalBefore).to.equal(brandPayment);
    });

    it("Should reject insufficient payment", async function () {
      const lowPrice = hre.ethers.parseEther("0.1");
      await expect(
        digitalSeal.connect(buyer).purchaseItem(0, { value: lowPrice })
      ).to.be.revertedWith("DigitalSeal: insufficient payment");
    });

    it("Should reject double purchase", async function () {
      await digitalSeal.connect(buyer).purchaseItem(0, { value: PRICE });
      await expect(
        digitalSeal.connect(other).purchaseItem(0, { value: PRICE })
      ).to.be.revertedWith("DigitalSeal: already sold");
    });
  });

  describe("Transfer Seal", function () {
    beforeEach(async function () {
      await digitalSeal.connect(brand).batchPreMint(
        brand.address, ["ITEM-001"], ["ipfs://item1"], PRICE
      );
    });

    it("Should allow platform to transfer seal to buyer", async function () {
      await digitalSeal.transferSeal(0, buyer.address, "PURCHASE");
      expect(await digitalSeal.ownerOf(0)).to.equal(buyer.address);
    });

    it("Should allow brand (token owner) to transfer", async function () {
      await digitalSeal.connect(brand).transferSeal(0, buyer.address, "PURCHASE");
      expect(await digitalSeal.ownerOf(0)).to.equal(buyer.address);
    });

    it("Should reject unauthorized transfer", async function () {
      await expect(
        digitalSeal.connect(other).transferSeal(0, buyer.address, "PURCHASE")
      ).to.be.revertedWith("DigitalSeal: not authorized to transfer");
    });
  });

  describe("Claim Item", function () {
    beforeEach(async function () {
      await digitalSeal.connect(brand).batchPreMint(
        brand.address, ["ITEM-001"], ["ipfs://item1"], PRICE
      );
    });

    it("Should allow platform to claim item for user", async function () {
      await digitalSeal.claimItem(0, buyer.address);
      expect(await digitalSeal.ownerOf(0)).to.equal(buyer.address);
      expect(await digitalSeal.tokenClaimed(0)).to.be.true;
    });

    it("Should reject double claim", async function () {
      await digitalSeal.claimItem(0, buyer.address);
      await expect(
        digitalSeal.claimItem(0, other.address)
      ).to.be.revertedWith("DigitalSeal: already claimed");
    });

    it("Should reject non-owner claim call", async function () {
      await expect(
        digitalSeal.connect(buyer).claimItem(0, buyer.address)
      ).to.be.reverted;
    });
  });

  describe("Verification", function () {
    beforeEach(async function () {
      await digitalSeal.connect(brand).batchPreMint(
        brand.address, ["ITEM-001"], ["ipfs://item1"], PRICE
      );
    });

    it("Should verify an existing token", async function () {
      const result = await digitalSeal.verify(0);
      expect(result.exists).to.be.true;
      expect(result.serial).to.equal("ITEM-001");
      expect(result.brand).to.equal(brand.address);
      expect(result.currentOwner).to.equal(brand.address);
      expect(result.isSold).to.be.false;
      expect(result.isClaimed).to.be.false;
    });

    it("Should verify by serial", async function () {
      const result = await digitalSeal.verifyBySerial("ITEM-001");
      expect(result.exists).to.be.true;
      expect(result.tokenId).to.equal(0n);
      expect(result.brand).to.equal(brand.address);
    });

    it("Should return exists=false for non-existent token", async function () {
      const result = await digitalSeal.verify(999);
      expect(result.exists).to.be.false;
    });
  });

  describe("Admin", function () {
    it("Should update platform fee", async function () {
      await digitalSeal.setPlatformFee(300); // 3%
      expect(await digitalSeal.platformFeeBps()).to.equal(300n);
    });

    it("Should reject fee > 10%", async function () {
      await expect(
        digitalSeal.setPlatformFee(1100)
      ).to.be.revertedWith("DigitalSeal: fee too high (max 10%)");
    });

    it("Should update platform wallet", async function () {
      await digitalSeal.setPlatformWallet(other.address);
      expect(await digitalSeal.platformWallet()).to.equal(other.address);
    });
  });

  describe("Full Flow", function () {
    it("Should complete full premint → purchase → transfer flow", async function () {
      // 1. Brand premints
      await digitalSeal.connect(brand).batchPreMint(
        brand.address, ["GUCCI-BAG-0001"], ["ipfs://gucci-meta"], PRICE
      );
      expect(await digitalSeal.ownerOf(0)).to.equal(brand.address);

      // 2. Buyer purchases
      await digitalSeal.connect(buyer).purchaseItem(0, { value: PRICE });
      expect(await digitalSeal.tokenSold(0)).to.be.true;

      // 3. Platform transfers seal to buyer after delivery
      await digitalSeal.transferSeal(0, buyer.address, "PURCHASE");
      expect(await digitalSeal.ownerOf(0)).to.equal(buyer.address);

      // 4. Verify
      const verification = await digitalSeal.verify(0);
      expect(verification.exists).to.be.true;
      expect(verification.currentOwner).to.equal(buyer.address);
      expect(verification.isSold).to.be.true;
    });

    it("Should complete full premint → claim flow", async function () {
      // 1. Brand premints
      await digitalSeal.connect(brand).batchPreMint(
        brand.address, ["LUXURY-WATCH-0001"], ["ipfs://watch-meta"], PRICE
      );

      // 2. Buyer claims via QR code (platform mediates)
      await digitalSeal.claimItem(0, buyer.address);
      expect(await digitalSeal.ownerOf(0)).to.equal(buyer.address);
      expect(await digitalSeal.tokenClaimed(0)).to.be.true;

      // 3. Verify
      const verification = await digitalSeal.verify(0);
      expect(verification.currentOwner).to.equal(buyer.address);
      expect(verification.isClaimed).to.be.true;
    });
  });
});
