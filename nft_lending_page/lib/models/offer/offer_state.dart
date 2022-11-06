import 'package:freezed_annotation/freezed_annotation.dart';

part 'offer_state.freezed.dart';

@freezed
abstract class OffersState with _$OffersState {
  const factory OffersState(
      {OfferState? currentOffer,
      @Default([]) List<OfferState> offers}) = _OffersState;
}

@freezed
abstract class OfferState with _$OfferState {
  const factory OfferState({
    @Default("") String assetAddress,
    int? tokenId,
    @Default("") String imageUrl,
    @Default("") String lenderAddress,
    int? rentalPeriod,
    DateTime? dueDate,
    int? rentalPrice,
  }) = _OfferState;
}
