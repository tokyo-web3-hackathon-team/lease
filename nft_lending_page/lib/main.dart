import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/pages/borrow_page.dart';
import 'package:nft_lending_page/pages/lend_page.dart';
import 'package:nft_lending_page/pages/routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'constants.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  await dotenv.load(fileName: "env/.env");
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
      initialRoute: Routes.homePage,
      routes: {
        Routes.homePage: (context) => HomePage(),
        Routes.lendPage: (context) => LendPage(),
        Routes.borrowPage: (context) => BorrowPage(),
      },
    );
  }
}
