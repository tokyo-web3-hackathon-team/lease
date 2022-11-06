import { loadFixture } from "@nomicfoundation/hardhat-network-helpers";
import { expect } from "chai";
import { ethers, network } from "hardhat";

const EXTERNAL_ACCOUNT = "0x96508874B53Bc73f68017a8e5fa10F73DfC797A7";
const ZERO_ADDRESS = "0x0000000000000000000000000000000000000000";
const TOKEN_URI = "ipfs://dummy";
const TOKEN_ID = 1;
const PRICE = 10;
const PERIOD = 30;

describe("LeaseService", function () {
  async function deployContract() {
    const [deployer, lender, borrower] = await ethers.getSigners();
    const AssetUtil = await ethers.getContractFactory("AssetUtil");
    const assetUtil = await AssetUtil.deploy();
    const LeaseService = await ethers.getContractFactory("LeaseService", {
      libraries: {
        AssetUtil: assetUtil.address,
      }
    });
    const leaseService = await LeaseService.deploy();
    return { leaseService, deployer, lender, borrower, assetUtil }
  }

  async function deployAsset() {
    const { leaseService, deployer, lender, borrower } = await loadFixture(deployContract);
    const Asset = await ethers.getContractFactory("Asset");
    const asset = await Asset.deploy("Asset", "A");
    await asset.mint(lender.address, TOKEN_URI);
    await asset.connect(lender).approve(leaseService.address, TOKEN_ID);
    return { asset, leaseService, deployer, lender, borrower }
  }

  async function borrowAsset() {
    const { leaseService, deployer, lender, borrower } = await loadFixture(deployContract);
    const Asset = await ethers.getContractFactory("Asset");
    const asset = await Asset.deploy("Asset", "A");
    await asset.mint(lender.address, TOKEN_URI);
    await asset.connect(lender).approve(leaseService.address, TOKEN_ID);
    await leaseService.connect(lender).offerLending(asset.address, TOKEN_ID, PRICE, PERIOD);
    const borrowPeriod = 5;
    await leaseService.connect(borrower).borrow(asset.address, TOKEN_ID, borrowPeriod, { from: borrower.address, value: ethers.utils.parseEther(PRICE.toString()) });
    return { asset, leaseService, deployer, lender, borrower }
  }

  describe("Deployment", function () {
    it("owner is properly set", async function () {
      const { leaseService, deployer } = await loadFixture(deployContract);
      expect(await leaseService.owner()).to.equal(deployer.address);
    });
  });

  describe("offerLending", function () {
    describe("Validations", function () {
      it("check that actor don't have NFTs", async function () {
        const { asset, leaseService, borrower } = await loadFixture(deployAsset);
        await expect(leaseService.connect(borrower).offerLending(asset.address, TOKEN_ID, PRICE, PERIOD))
          .to.be.revertedWith("Lender don't have NFT");
      });
    });
    describe("Functionality", function () {
      it("asset is offered", async function () {
        const { asset, leaseService, lender } = await loadFixture(deployAsset);
        await expect(leaseService.connect(lender).offerLending(asset.address, TOKEN_ID, PRICE, PERIOD))
          .to.emit(leaseService, "Offer").withArgs(lender.address, asset.address, TOKEN_ID, PRICE, PERIOD);
      });
      it("offer can be overwritten", async function () {
        const { asset, leaseService, lender } = await loadFixture(deployAsset);
        await expect(leaseService.connect(lender).offerLending(asset.address, TOKEN_ID, PRICE, PERIOD))
          .to.emit(leaseService, "Offer").withArgs(lender.address, asset.address, TOKEN_ID, PRICE, PERIOD);
        await expect(leaseService.connect(lender).offerLending(asset.address, TOKEN_ID, PRICE * 2, PERIOD))
          .to.emit(leaseService, "Offer").withArgs(lender.address, asset.address, TOKEN_ID, PRICE * 2, PERIOD);
      });
    });
  });

  describe("cancelOffer", function () {
    describe("Validations", function () {
      it("check that lender have offered", async function () {
        const { asset, leaseService, lender } = await loadFixture(deployAsset);
        await expect(leaseService.connect(lender).cancelOffer(asset.address, TOKEN_ID))
          .to.be.revertedWith("No available offer exists");
      });
    });
    describe("Functionality", function () {
      it("offer is canceled", async function () {
        const { asset, leaseService, lender } = await loadFixture(deployAsset);
        await leaseService.connect(lender).offerLending(asset.address, TOKEN_ID, PRICE, PERIOD)
        await expect(leaseService.connect(lender).cancelOffer(asset.address, TOKEN_ID))
          .to.emit(leaseService, "OfferCanceled").withArgs(asset.address, TOKEN_ID);
      });
    });
  });

  describe("borrow", function () {
    describe("Validations", function () {
      it("period exceeds offer limit", async function () {
        const { asset, leaseService, lender, borrower } = await loadFixture(deployAsset);
        await leaseService.connect(lender).offerLending(asset.address, TOKEN_ID, PRICE, PERIOD)
        await expect(leaseService.connect(borrower)
          .borrow(asset.address, TOKEN_ID, PERIOD, { from: borrower.address, value: ethers.utils.parseEther(PRICE.toString()) }))
          .to.be.revertedWith("Period exceeds offer limit");
      });
      it("lack of fees", async function () {
        const { asset, leaseService, lender, borrower } = await loadFixture(deployAsset);
        const currentBlockNumber1 = await ethers.provider.getBlockNumber();
        await leaseService.connect(lender).offerLending(asset.address, TOKEN_ID, PRICE, PERIOD + currentBlockNumber1);
        const borrowPeriod = 2
        await expect(leaseService.connect(borrower)
          .borrow(asset.address, TOKEN_ID, borrowPeriod, { from: borrower.address, value: "1" }))
          .to.be.revertedWith("Fee is lower than required total payment.");
      });
      it("Asset is no longer owned by lender", async function () {
        const { asset, leaseService, lender, borrower } = await loadFixture(deployAsset);
        const currentBlockNumber1 = await ethers.provider.getBlockNumber();
        await leaseService.connect(lender).offerLending(asset.address, TOKEN_ID, PRICE, PERIOD + currentBlockNumber1);
        await asset.connect(lender).transferFrom(lender.address, EXTERNAL_ACCOUNT, TOKEN_ID);
        const borrowPeriod = 2
        await expect(leaseService.connect(borrower)
          .borrow(asset.address, TOKEN_ID, borrowPeriod, { value: ethers.utils.parseEther(PRICE.toString()) }))
          .to.be.revertedWith("Lender don't have NFT");
      });
      it("Approval revoked", async function () {
        const { asset, leaseService, lender, borrower } = await loadFixture(deployAsset);
        const currentBlockNumber1 = await ethers.provider.getBlockNumber();
        await leaseService.connect(lender).offerLending(asset.address, TOKEN_ID, PRICE, PERIOD + currentBlockNumber1);
        await asset.connect(lender).approve(ZERO_ADDRESS, TOKEN_ID);
        const borrowPeriod = 2
        await expect(leaseService.connect(borrower)
          .borrow(asset.address, TOKEN_ID, borrowPeriod, { value: ethers.utils.parseEther(PRICE.toString()) }))
          .to.be.revertedWith("ERC721: caller is not token owner nor approved");
      });
    });
    describe("Functionality", function () {
      it("borrow NFT", async function () {
        const { asset, leaseService, lender, borrower } = await loadFixture(deployAsset);
        const currentBlockNumber1 = await ethers.provider.getBlockNumber();
        await leaseService.connect(lender).offerLending(asset.address, TOKEN_ID, PRICE, PERIOD + currentBlockNumber1);
        const currentBlockNumber2 = await ethers.provider.getBlockNumber();
        const borrowPeriod = 2
        const borrowTx = await leaseService.connect(borrower).borrow(asset.address, TOKEN_ID, borrowPeriod, { from: borrower.address, value: ethers.utils.parseEther(PRICE.toString()) });
        await expect(borrowTx).to.emit(leaseService, "Lease")
          .withArgs(lender.address, asset.address, TOKEN_ID, borrower.address, PRICE * borrowPeriod, borrowPeriod + currentBlockNumber2 + 1);
        const vault = await leaseService.leaseVaultOf(borrower.address);
        await expect(borrowTx).to.emit(asset, "Transfer")
          .withArgs(lender.address, vault, TOKEN_ID);
        expect(await asset.ownerOf(TOKEN_ID)).not.to.equals(lender.address);
      });
      it("Contract wallet would be reused", async function () {
        const { asset, leaseService, lender, borrower } = await loadFixture(borrowAsset);
        await network.provider.send("hardhat_mine", ["0x100"]);
        await leaseService.connect(borrower).returnAsset(asset.address, TOKEN_ID);
        await asset.connect(lender).approve(leaseService.address, TOKEN_ID);
        await leaseService.connect(lender).offerLending(asset.address, TOKEN_ID, PRICE, PERIOD + 256);
        const vault = await leaseService.leaseVaultOf(borrower.address);
        const borrowPeriod = 10;
        const borrowTx = await leaseService.connect(borrower).borrow(asset.address, TOKEN_ID, borrowPeriod, { value: ethers.utils.parseEther(PRICE.toString()), gasLimit: "500000"});
        await expect(borrowTx).to.emit(asset, "Transfer")
          .withArgs(lender.address, vault, TOKEN_ID);
        expect(await leaseService.leaseVaultOf(borrower.address)).to.equals(vault);
      });
    });
  });

  describe("returnAssetBeforeExpiration", function () {
    describe("Validations", function () {
      it("only borrower can call", async function () {
        const { asset, leaseService, lender } = await loadFixture(borrowAsset);
        await expect(
          leaseService.connect(lender).returnAssetBeforeExpiration(asset.address, TOKEN_ID)
        ).to.be.rejectedWith("Only borrower can return before expiration");
      });
      it("returnAssetBeforeExpiration must be called before expiration", async function () {
        const { asset, leaseService, borrower } = await loadFixture(borrowAsset);
        await network.provider.send("hardhat_mine", ["0x100"]);
        await expect(
          leaseService.connect(borrower).returnAssetBeforeExpiration(asset.address, TOKEN_ID)
        ).to.be.rejectedWith("lease is expired");
      });
    });
    describe("Functionality", function () {
      it("asset can be returned before expiration", async function () {
        const { asset, leaseService, lender, borrower } = await loadFixture(borrowAsset);
        const vault = await leaseService.leaseVaultOf(borrower.address);
        const earlyReturnTx = await leaseService.connect(borrower).returnAssetBeforeExpiration(asset.address, TOKEN_ID);
        await expect(earlyReturnTx).to.emit(asset, "Transfer").withArgs(vault, lender.address, TOKEN_ID);
        expect(await asset.ownerOf(TOKEN_ID)).to.equals(lender.address);
      });
    });
  });

  describe("returnAsset", function () {
    describe("Validations", function () {
      it("returnAsset must be called after expiration", async function () {
        const { asset, leaseService } = await loadFixture(borrowAsset);
        await expect(
          leaseService.returnAsset(asset.address, TOKEN_ID)
        ).to.be.rejectedWith("Lease is not expired");
      });
    });
    describe("Functionality", function () {
      it("asset can be returned", async function () {
        const { asset, leaseService, lender, borrower } = await loadFixture(borrowAsset);
        const vault = await leaseService.leaseVaultOf(borrower.address);
        await network.provider.send("hardhat_mine", ["0x100"]);
        const returnTx = await leaseService.connect(borrower).returnAsset(asset.address, TOKEN_ID);
        await expect(returnTx).to.emit(asset, "Transfer").withArgs(vault, lender.address, TOKEN_ID);
        expect(await asset.ownerOf(TOKEN_ID)).to.equals(lender.address);
      });
      it("lender can call the method", async function () {
        const { asset, leaseService, lender, borrower } = await loadFixture(borrowAsset);
        const vault = await leaseService.leaseVaultOf(borrower.address);
        await network.provider.send("hardhat_mine", ["0x100"]);
        const returnTx = await leaseService.connect(lender).returnAsset(asset.address, TOKEN_ID);
        await expect(returnTx).to.emit(asset, "Transfer").withArgs(vault, lender.address, TOKEN_ID);
        expect(await asset.ownerOf(TOKEN_ID)).to.equals(lender.address);
      });
    });
  });

  describe("leaseServiceOf", function () {
    describe("Functionality", function () {
      it("return contract wallet address", async function () {
        const { leaseService, borrower } = await loadFixture(deployContract);
        expect(await leaseService.leaseVaultOf(borrower.address)).to.equals(ethers.constants.AddressZero);
      });
    });
  });
});
