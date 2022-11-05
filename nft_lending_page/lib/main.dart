import 'package:flutter/material.dart';

import 'home_page.dart';

void main() {
  runApp(const NftLendingApp());
}

class NftLendingApp extends StatelessWidget {
  const NftLendingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      home: const HomePage(title: 'NFT LENDING'),
    );
  }
}
