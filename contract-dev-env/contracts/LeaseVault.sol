// SPDX-License-Identifier:cc0-1.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./AssetUtil.sol";

contract LeaseVault is Ownable, IERC1271 {
    // bytes4(keccak256("isValidSignature(bytes32,bytes)")
    bytes4 internal constant VALID = 0x1626ba7e;
    address private _controller;

    struct Lease {
        address lender;
        address collection;
        uint256 tokenId;
        uint until;
    }

    mapping(bytes32 => Lease) private _leaseInfo;

    constructor(address owner) {
        _controller = msg.sender;
        _transferOwnership(owner);
    }

    modifier onlyController() {
        require(msg.sender == _controller, "Sender is not authorized");
        _;
    }

    function isValidSignature(bytes32 hash, bytes memory signature)
        external
        view
        override
        returns (bytes4 magicValue)
    {
        if (ECDSA.recover(hash, signature) == owner()) {
            return VALID;
        } else {
            return 0xffffffff;
        }
    }

    function setBorrowed(
        address lender,
        address collection,
        uint256 tokenId,
        uint until
    ) public onlyController returns (bytes32) {
        bytes32 assetHash = AssetUtil.hashAsset(collection, tokenId);
        require(
            _leaseInfo[assetHash].lender == address(0) &&
                _leaseInfo[assetHash].collection == address(0),
            "Asset is already borrowed"
        );
        _leaseInfo[assetHash] = Lease(lender, collection, tokenId, until);
        return assetHash;
    }

    function returnAsset(address collection, uint256 tokenId)
        public
        onlyController
        returns (bytes32)
    {
        bytes32 assetHash = AssetUtil.hashAsset(collection, tokenId);
        Lease memory lease = _leaseInfo[assetHash];
        require(
            lease.lender != address(0) && lease.collection != address(0),
            "Asset not borrowed"
        );
        require(block.number >= lease.until, "Asset is locked");
        AssetUtil.transfer(
            lease.collection,
            lease.tokenId,
            address(this),
            lease.lender
        );
        delete _leaseInfo[assetHash];
        return assetHash;
    }

    function returnLockedAsset(address collection, uint256 tokenId)
        public
        onlyController
        returns (bytes32)
    {
        bytes32 assetHash = AssetUtil.hashAsset(collection, tokenId);
        Lease memory lease = _leaseInfo[assetHash];
        require(
            lease.lender != address(0) && lease.collection != address(0),
            "Asset not borrowed"
        );
        require(tx.origin == owner(), "only owner can return locked asset");
        AssetUtil.transfer(
            lease.collection,
            lease.tokenId,
            address(this),
            lease.lender
        );
        delete _leaseInfo[assetHash];
        return assetHash;
    }
}
