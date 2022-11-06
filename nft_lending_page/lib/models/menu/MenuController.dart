import 'package:hooks_riverpod/hooks_riverpod.dart';

class MenuController extends StateNotifier<int> {
  MenuController() : super(0);

  setCurrentIndex(int index) {
    state = index;
  }
}
