import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/providers.dart';

import 'explore_page.dart';
import 'lend_page.dart';
import 'my_page.dart';

class HomePage extends HookConsumerWidget {
  HomePage({Key? key}) : super(key: key);

  final List<Widget> _menu = [
    const ExplorePage(),
    const MyPage(),
    LendPage(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int currentIndex = ref.watch(menuProvider) as int;
    return Scaffold(
      body: _menu[currentIndex],
    );
  }
}
