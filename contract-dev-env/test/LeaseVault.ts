import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers, network } from "hardhat";

const EOA = "0x96508874B53Bc73f68017a8e5fa10F73DfC797A7";
const TOKEN_URI = "ipfs://dummy";
const TOKEN_ID = 1;

describe("LeaseVault", function () {
  async function deployContract() {
    const [deployer, otherAccount] = await ethers.getSigners();
    const AssetUtil = await ethers.getContractFactory("AssetUtil");
    const assetUtil = await AssetUtil.deploy();
    const LeaseVault = await ethers.getContractFactory("LeaseVault", {
      libraries: {
        AssetUtil: assetUtil.address,
      }
    });
    const leaseVault = await LeaseVault.deploy(EOA);
    const Asset = await ethers.getContractFactory("Asset");
    const asset = await Asset.deploy("Asset", "A");
    await asset.mint(deployer.address, TOKEN_URI);
    return { leaseVault, asset, deployer, otherAccount };
  }

  async function deployAndBorrow() {
    const { leaseVault, asset, deployer, otherAccount } = await deployContract();
    await asset.transferFrom(deployer.address, leaseVault.address, TOKEN_ID);
    await leaseVault.setBorrowed(
      deployer.address,
      asset.address,
      TOKEN_ID,
      255
    );
    await network.provider.send("hardhat_mine", ["0x100"]);
    return { leaseVault, asset, deployer, otherAccount };
  }

  describe("Deployment", function () {
    it("owner is properly set", async function () {
      const { leaseVault } = await loadFixture(deployContract);
      expect(await leaseVault.owner()).to.equal(EOA);
    });
  });

  describe("setBorrowed", function () {
    describe("Validations", function () {
      it("only deployer can call setBorrowed", async function () {
        const { leaseVault, asset, deployer, otherAccount } = await loadFixture(deployContract);
        await expect(leaseVault.connect(otherAccount).setBorrowed(
          deployer.address,
          asset.address,
          TOKEN_ID,
          12345
        )).to.be.revertedWith("Sender is not authorized");
      });

      it("cannot call setBorrowed for already borrowed asset", async function () {
        const { leaseVault, asset, deployer } = await loadFixture(deployContract);
        await leaseVault.setBorrowed(
          deployer.address,
          asset.address,
          TOKEN_ID,
          12345
        );
        await expect(leaseVault.setBorrowed(
          deployer.address,
          asset.address,
          TOKEN_ID,
          12345
        )).to.be.revertedWith("Asset is already borrowed");
      });
    });
  });

  describe("returnAsset", function () {
    describe("Validations", function () {
      it("asset need to be borrowed", async function () {
        const { leaseVault, asset } = await loadFixture(deployContract);
        await expect(leaseVault.returnAsset(
          asset.address,
          TOKEN_ID
        )).to.be.revertedWith("Asset not borrowed");
      });
      it("asset is locked as long as lease condition", async function () {
        const { leaseVault, asset, deployer } = await loadFixture(deployContract);
        await asset.transferFrom(deployer.address, leaseVault.address, TOKEN_ID);
        await leaseVault.setBorrowed(
          deployer.address,
          asset.address,
          TOKEN_ID,
          12345
        );
        await expect(leaseVault.returnAsset(
          asset.address,
          TOKEN_ID
        )).to.be.revertedWith("Asset is locked");
      });
      it("only deployer can call returnAsset", async function () {
        const { leaseVault, asset, deployer, otherAccount } = await loadFixture(deployAndBorrow);
        await expect(leaseVault.connect(otherAccount).returnAsset(
          asset.address,
          TOKEN_ID
        )).to.be.revertedWith("Sender is not authorized");
      });
    });
    describe("Functionality", function () {
      it("asset is transferred back to lender", async function () {
        const { leaseVault, asset, deployer } = await loadFixture(deployAndBorrow);
        expect(await asset.ownerOf(TOKEN_ID)).to.equals(leaseVault.address);
        await expect(leaseVault.returnAsset(
          asset.address,
          TOKEN_ID
        )).to.emit(asset, "Transfer").withArgs(leaseVault.address, deployer.address, TOKEN_ID);
        expect(await asset.ownerOf(TOKEN_ID)).to.equals(deployer.address);
      });
      it("asset can be borrowed again after returnAsset", async function () {
        const { leaseVault, asset, deployer, otherAccount } = await loadFixture(deployAndBorrow);
        await expect(leaseVault.returnAsset(
          asset.address,
          TOKEN_ID
        )).to.emit(asset, "Transfer").withArgs(leaseVault.address, deployer.address, TOKEN_ID);
        expect(await asset.ownerOf(TOKEN_ID)).to.equals(deployer.address);
        await asset.transferFrom(deployer.address, leaseVault.address, TOKEN_ID);
        await leaseVault.setBorrowed(
          deployer.address,
          asset.address,
          TOKEN_ID,
          512
        );
      });
    });
  });
});
