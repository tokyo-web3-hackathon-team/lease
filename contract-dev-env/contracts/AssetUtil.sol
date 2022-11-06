// SPDX-License-Identifier:cc0-1.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

library AssetUtil {
    function hashAsset(address collection, uint256 tokenId)
        internal
        pure
        returns (bytes32)
    {
        return keccak256(abi.encode(collection, tokenId));
    }

    function hasNft(
        address claimer,
        address nftContract,
        uint256 tokenId
    ) internal view {
        try IERC721(nftContract).ownerOf(tokenId) returns (
            address ownerAddress
        ) {
            require(claimer == ownerAddress, "Lender don't have NFT");
        } catch (bytes memory reason) {
            if (reason.length == 0) {
                revert("non ERC721.ownerOf implementer");
            } else {
                /// @solidity memory-safe-assembly
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }

    function transfer(
        address collection,
        uint256 tokenId,
        address from,
        address to
    ) public {
        (bool sent, bytes memory reason) = collection.call(
            abi.encodeWithSignature(
                "transferFrom(address,address,uint256)",
                from,
                to,
                tokenId
            )
        );
        if (!sent) {
            if (reason.length == 0) {
                revert("non ERC721.ownerOf implementer");
            } else {
                /// @solidity memory-safe-assembly
                assembly {
                    revert(add(32, reason), mload(reason))
                }
            }
        }
    }
}
