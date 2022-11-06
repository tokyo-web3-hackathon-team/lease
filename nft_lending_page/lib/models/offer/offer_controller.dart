import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/models/offer/offer_state.dart';

class OfferController extends StateNotifier<OffersState> {
  OfferController() : super(const OffersState());
}
