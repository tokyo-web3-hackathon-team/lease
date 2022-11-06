import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/components/app_bar.dart' as app;
import 'package:nft_lending_page/components/explore.dart';
import 'package:nft_lending_page/components/primary_button.dart';
import 'package:nft_lending_page/providers.dart';

class HomePage extends HookConsumerWidget {
  HomePage({Key? key}) : super(key: key);

  final List<Widget> _menu = [
    const Explore(),
  ];

  // final List<Widget> tabList = [
  //   const Tab(child: Text('Borrow')),
  //   const Tab(child: Text('Lend')),
  // ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final int menuIndex = ref.watch(menuProvider) as int;
    // final controller = useTabController(initia lLength: tabList.length);
    ScrollController homeScrollController = ScrollController();

    return Scaffold(
      body: Column(
        children: [
          const app.AppBar(),
          const SizedBox(height: 50),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              PrimaryButton("Lend", onPressed: () {}),
            ],
          ),
          const SizedBox(height: 50),
          Expanded(
            child: CustomScrollView(
              controller: homeScrollController,
              slivers: const [
                Explore(),
              ],
            ),
          ),
          // TabBar(
          //   controller: controller,
          //   tabs: tabList,
          // ),
          // Expanded(
          //   child: TabBarView(
          //     controller: controller,
          //     children: [
          //       const BorrowPage(),
          //       LendPage(),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
