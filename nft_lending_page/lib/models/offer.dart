class Offer {
  final String assetAddress;
  final int tokenId;
  final String imageUrl;
  final String lenderAddress;
  final int rentalPeriod;
  final int rentalPrice;

  Offer({
    required this.assetAddress,
    required this.tokenId,
    required this.imageUrl,
    required this.lenderAddress,
    required this.rentalPeriod,
    required this.rentalPrice,
  });
}
