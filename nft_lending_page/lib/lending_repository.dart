import 'package:hooks_riverpod/hooks_riverpod.dart';

final lendingRepositoryProvider =
    Provider<LendingRepository>((_) => LendingRepositoryImpl());

abstract class LendingRepository {
  void lend(
    String contractAddress,
    String tokenId,
    DateTime rentalPeriod,
    double rentalFee,
    double returnFee,
  ) {}
}

class LendingRepositoryImpl implements LendingRepository {
  @override
  void lend(String contractAddress, String tokenId, DateTime rentalPeriod,
      double rentalFee, double returnFee) {
    // metamaskへの接続
  }
}
