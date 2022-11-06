// SPDX-License-Identifier:cc0-1.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./LeaseVault.sol";
import "./ILeaseService.sol";
import "./AssetUtil.sol";

contract LeaseService is ILeaseService, Ownable, ReentrancyGuard {
    using SafeMath for uint;
    using SafeMath for uint256;

    struct OfferCondition {
        address lender;
        address collection;
        uint256 tokenId;
        uint256 price;
        uint until;
    }

    struct LeaseCondition {
        address lender;
        address collection;
        uint256 tokenId;
        address borrower;
        uint256 payment;
        uint expiration;
    }

    uint256 private _margin = 0.002 ether;
    uint256 private _returnBonus = 0.003 ether;
    uint256 private _balance = 0;
    mapping(bytes32 => OfferCondition) private _offerInfo;
    mapping(bytes32 => LeaseCondition) private _leaseInfo;
    mapping(address => address) private _eoaToContractWallets;

    constructor() {
        _transferOwnership(msg.sender);
    }

    function offerLending(
        address lendingCollection,
        uint256 tokenId,
        uint256 price,
        uint until
    ) public {
        AssetUtil.hasNft(msg.sender, lendingCollection, tokenId);
        bytes32 assetHash = AssetUtil.hashAsset(lendingCollection, tokenId);
        _offerInfo[assetHash] = OfferCondition(
            msg.sender,
            lendingCollection,
            tokenId,
            price,
            until
        );
        emit Offer(msg.sender, lendingCollection, tokenId, price, until);
    }

    function cancelOffer(address lendingCollection, uint256 tokenId) public {
        AssetUtil.hasNft(msg.sender, lendingCollection, tokenId);
        bytes32 assetHash = AssetUtil.hashAsset(lendingCollection, tokenId);
        OfferCondition memory offer = _offerInfo[assetHash];
        require(offer.lender == msg.sender, "No available offer exists");
        delete _leaseInfo[assetHash];
        emit OfferCanceled(lendingCollection, tokenId);
    }

    function borrow(
        address borrowCollection,
        uint256 tokenId,
        uint period
    ) public payable nonReentrant {
        bytes32 assetHash = AssetUtil.hashAsset(borrowCollection, tokenId);
        OfferCondition memory offer = _offerInfo[assetHash];
        require(offer.lender != address(0), "No available offer exists");
        uint expiration = block.number.add(period);
        require(offer.until >= expiration, "Period exceeds offer limit");
        uint256 payment = offer.price.mul(period);
        require(
            msg.value >= payment.add(_margin).add(_returnBonus),
            "Fee is lower than required total payment."
        );
        AssetUtil.hasNft(offer.lender, offer.collection, offer.tokenId);

        LeaseVault contractWallet = _getContractWallet();
        contractWallet.setBorrowed(
            offer.lender,
            offer.collection,
            offer.tokenId,
            expiration
        );
        AssetUtil.transfer(
            offer.collection,
            offer.tokenId,
            offer.lender,
            address(contractWallet)
        );
        LeaseCondition memory lease = LeaseCondition(
            offer.lender,
            offer.collection,
            offer.tokenId,
            msg.sender,
            payment,
            expiration
        );
        _leaseInfo[assetHash] = lease;
        delete _offerInfo[assetHash];
        _balance = _balance.add(_margin);
        emit Lease(
            lease.lender,
            lease.collection,
            lease.tokenId,
            lease.borrower,
            payment,
            expiration
        );
    }

    function _getContractWallet() internal returns (LeaseVault leaseVault) {
        LeaseVault contractWallet;
        if (_eoaToContractWallets[msg.sender] == address(0)) {
            contractWallet = new LeaseVault(msg.sender);
            _eoaToContractWallets[msg.sender] = address(contractWallet);
        }
        contractWallet = LeaseVault(_eoaToContractWallets[msg.sender]);
        return contractWallet;
    }

    function returnAssetBeforeExpiration(
        address returnCollection,
        uint256 tokenId
    ) public payable nonReentrant {
        bytes32 assetHash = AssetUtil.hashAsset(returnCollection, tokenId);
        LeaseCondition memory lease = _leaseInfo[assetHash];
        require(
            lease.lender != address(0) && lease.collection != address(0),
            "Asset is not registered."
        );
        require(lease.expiration > block.number, "lease is expired");
        require(
            lease.borrower == msg.sender,
            "Only borrower can return before expiration"
        );
        LeaseVault contractWallet = LeaseVault(
            _eoaToContractWallets[lease.borrower]
        );
        bytes32 returnedAsset = contractWallet.returnLockedAsset(
            returnCollection,
            tokenId
        );
        require(returnedAsset == assetHash, "return failed");
        delete _leaseInfo[assetHash];
        uint256 payBack = lease
            .payment
            .mul(lease.expiration.sub(block.number))
            .div(lease.expiration);
        uint256 partialPayment = lease.payment.sub(payBack);
        (bool feeSent, ) = lease.lender.call{value: partialPayment}("");
        require(feeSent, "unable to send lease fee");
        (bool payBacked, ) = lease.lender.call{
            value: payBack.add(_returnBonus)
        }("");
        require(payBacked, "unable to pay back fee");
    }

    function returnAsset(address returnCollection, uint256 tokenId)
        public
        payable
        nonReentrant
    {
        bytes32 assetHash = AssetUtil.hashAsset(returnCollection, tokenId);
        LeaseCondition memory lease = _leaseInfo[assetHash];
        require(
            lease.lender != address(0) && lease.collection != address(0),
            "Asset is not registered."
        );
        require(lease.expiration <= block.number, "Lease is not expired");
        LeaseVault contractWallet = LeaseVault(
            _eoaToContractWallets[lease.borrower]
        );
        bytes32 returnedAsset = contractWallet.returnAsset(
            returnCollection,
            tokenId
        );
        require(returnedAsset == assetHash, "return failed");
        delete _leaseInfo[assetHash];
        (bool feeSent, ) = lease.lender.call{value: lease.payment}("");
        require(feeSent, "unable to send lease fee");
        (bool vonusSent, ) = msg.sender.call{value: _returnBonus}("");
        require(vonusSent, "unable to send return vonus");
    }

    function withdraw(address to) public payable onlyOwner nonReentrant {
        _balance = 0;
        (bool sent, ) = to.call{value: _balance}("");
        require(sent);
    }

    function leaseVaultOf(address eoa) public view returns (address) {
        return _eoaToContractWallets[eoa];
    }

    function isOfferActive(
        address lender,
        address collection,
        uint256 tokenId,
        uint256 price,
        uint until
    ) public view returns (bool) {
        bytes32 assetHash = AssetUtil.hashAsset(collection, tokenId);
        OfferCondition memory offer = _offerInfo[assetHash];
        return (offer.lender == lender &&
            offer.collection == collection &&
            offer.tokenId == tokenId &&
            offer.price == price &&
            offer.until == until &&
            offer.until >= block.number);
    }
}
