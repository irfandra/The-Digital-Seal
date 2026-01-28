const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("LuxuryDigitalTwin", function () {
    let LuxuryDigitalTwin;
    let luxuryDigitalTwin;
    let owner;
    let addr1;
    let addr2;

    beforeEach(async function () {
        LuxuryDigitalTwin = await ethers.getContractFactory("LuxuryDigitalTwin");
        [owner, addr1, addr2] = await ethers.getSigners();
        luxuryDigitalTwin = await LuxuryDigitalTwin.deploy("Luxury Brand");
        await luxuryDigitalTwin.deployed();
    });

    describe("Minting", function () {
        it("Should mint a digital twin NFT", async function () {
            const tokenId = await luxuryDigitalTwin.mintDigitalTwin(addr1.address, "SN12345", "ipfs://metadata");
            const ownerOfToken = await luxuryDigitalTwin.ownerOf(tokenId);
            expect(ownerOfToken).to.equal(addr1.address);
        });

        it("Should fail if serial number is not unique", async function () {
            await luxuryDigitalTwin.mintDigitalTwin(addr1.address, "SN12345", "ipfs://metadata");
            await expect(luxuryDigitalTwin.mintDigitalTwin(addr2.address, "SN12345", "ipfs://metadata"))
                .to.be.revertedWith("LuxuryDigitalTwin: serial number already exists");
        });
    });

    describe("Verification", function () {
        it("Should verify product by token ID", async function () {
            const tokenId = await luxuryDigitalTwin.mintDigitalTwin(addr1.address, "SN12345", "ipfs://metadata");
            const verification = await luxuryDigitalTwin.verifyProduct(tokenId);
            expect(verification[0]).to.equal("Luxury Brand");
            expect(verification[1]).to.equal("SN12345");
            expect(verification[2]).to.equal("ipfs://metadata");
            expect(verification[3]).to.be.true;
        });

        it("Should verify product by serial number", async function () {
            await luxuryDigitalTwin.mintDigitalTwin(addr1.address, "SN12345", "ipfs://metadata");
            const verification = await luxuryDigitalTwin.verifyBySerialNumber("SN12345");
            expect(verification[1]).to.equal("Luxury Brand");
            expect(verification[2]).to.equal("ipfs://metadata");
            expect(verification[3]).to.be.true;
        });
    });

    describe("History Tracking", function () {
        it("Should add a history entry", async function () {
            const tokenId = await luxuryDigitalTwin.mintDigitalTwin(addr1.address, "SN12345", "ipfs://metadata");
            await luxuryDigitalTwin.addHistoryEntry(tokenId, "Repair", "Repaired the item");
            const history = await luxuryDigitalTwin.getHistory(tokenId);
            expect(history.length).to.equal(1);
            expect(history[0].entryType).to.equal("Repair");
            expect(history[0].details).to.equal("Repaired the item");
        });
    });

    describe("Authorization Management", function () {
        it("Should authorize a service provider", async function () {
            await luxuryDigitalTwin.authorizeService(addr1.address);
            expect(await luxuryDigitalTwin.isAuthorizedService(addr1.address)).to.be.true;
        });

        it("Should revoke service provider authorization", async function () {
            await luxuryDigitalTwin.authorizeService(addr1.address);
            await luxuryDigitalTwin.revokeServiceAuthorization(addr1.address);
            expect(await luxuryDigitalTwin.isAuthorizedService(addr1.address)).to.be.false;
        });
    });
});