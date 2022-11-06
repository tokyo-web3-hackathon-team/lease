import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/models/menu/MenuController.dart';

import 'models/OfferController.dart';

final menuProvider = StateNotifierProvider((ref) => MenuController());

final offerProvider = StateNotifierProvider((ref) => OfferController());
