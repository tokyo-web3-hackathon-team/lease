// SPDX-License-Identifier:cc0-1.0
pragma solidity >=0.8.0 <0.9.0;

interface ILeaseService {
    /**
     * @dev Emitted when lease offer is delivered by the asset holder.
     */
    event Offer(address collection, uint256 tokenId, uint256 price, uint until);

    /**
     * @dev Emitted when offer revoked.
     */
    event OfferCanceled(address collection, uint256 tokenId);

    /**
     * @dev Emitted when borrower take offer and asset ownership transferred.
     */
    event Lease(
        address lender,
        address collection,
        uint256 tokenId,
        address borrower,
        uint256 payment,
        uint expiration
    );

    /**
     * @dev offer lease.
     *
     * Requirements:
     *
     * - msg.sender is required to own the token (`tokenId` of `lendingCollenction`)
     *
     * Emits a {Offer} event.
     */
    function offerLending(
        address lendingCollection,
        uint256 tokenId,
        uint256 price,
        uint until
    ) external;

    /**
     * @dev revoke lease offer.
     *
     * Requirements:
     *
     * - msg.sender is required to own the token (`tokenId` of `lendingCollenction`)
     * - msg.sender must be same with the offer lender
     *
     * Emits a {OfferCanceled} event.
     */
    function cancelOffer(address lendingCollection, uint256 tokenId) external;

    /**
     * @dev take offer and borrorw NFT.
     *
     * Requirements:
     *
     * - NFT specified by `borrowCollection` and `tokenId` is required to be offered
     * - block.number + period must be before the offer limit.
     * - msg.value need to be greater than price x period + margin + return vonus
     *
     * Emits a {Lease} event.
     */
    function borrow(
        address borrowCollection,
        uint256 tokenId,
        uint period
    ) external payable;

    /**
     * @dev return borrorwing NFT before expiration.
     *
     * Requirements:
     *
     * - NFT specified by `borrowCollection` and `tokenId` is required to be borrowed
     * - block.number must be before the lease expiration.
     * - msg.sender must be the borrower.
     */
    function returnAssetBeforeExpiration(
        address borrowCollection,
        uint256 tokenId
    ) external payable;

    /**
     * @dev return borrorwing NFT.
     *
     * Requirements:
     *
     * - NFT specified by `borrowCollection` and `tokenId` is required to be borrowed
     * - block.number must be after the lease expiration.
     */
    function returnAsset(address borrowCollection, uint256 tokenId)
        external
        payable;
}
