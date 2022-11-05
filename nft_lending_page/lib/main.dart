import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'home_page.dart';

void main() {
  runApp(const ProviderScope(child: NftLendingApp()));
}

class NftLendingApp extends StatelessWidget {
  const NftLendingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      home: HomePage(title: 'NFT LENDING'),
    );
  }
}
