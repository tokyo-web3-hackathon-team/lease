import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'constants.dart';
import 'pages/home_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: NftLendingApp(),
    ),
  );
}

class NftLendingApp extends HookWidget {
  const NftLendingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NFT Rental',
      theme: ThemeData(
        fontFamily: 'Sofia Pro',
        scaffoldBackgroundColor: AppConst.colorGrey,
        primarySwatch: Colors.red,
        textTheme: const TextTheme(
          bodyText2: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}
