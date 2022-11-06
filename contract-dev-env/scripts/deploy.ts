import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log("Deploying contracts with the account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());
  const AssetUtil = await ethers.getContractFactory("AssetUtil");
  const assetUtil = await AssetUtil.deploy();
  const LeaseService = await ethers.getContractFactory("LeaseService", {
    libraries: {
      AssetUtil: assetUtil.address,
    }
  });
  const leaseService = await LeaseService.deploy();
  await leaseService.deployed();

  console.log(`deployed to ${leaseService.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
