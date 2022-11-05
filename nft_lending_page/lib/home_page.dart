import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nft_lending_page/borrow_page.dart';

import 'lend_page.dart';

class HomePage extends HookWidget {
  HomePage({super.key, required this.title});
  final String title;
  final List<Widget> tabList = [
    const Tab(child: Text('Borrow')),
    const Tab(child: Text('Lend')),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = useTabController(initialLength: tabList.length);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(title),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Center(child: Text("Account")),
          )
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: controller,
            tabs: tabList,
          ),
          Expanded(
            child: TabBarView(
              controller: controller,
              children: [
                const BorrowPage(),
                LendPage(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
