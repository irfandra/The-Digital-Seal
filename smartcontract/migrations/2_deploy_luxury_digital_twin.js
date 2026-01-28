require("dotenv").config();

const LuxuryDigitalTwin = artifacts.require("LuxuryDigitalTwin");

module.exports = function (deployer) {
  const brandName = process.env.BRAND_NAME || "YourBrandName";
  deployer.deploy(LuxuryDigitalTwin, brandName);
};