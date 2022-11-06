import 'package:flutter/material.dart';
import 'package:nft_lending_page/components/primary_button.dart';

import '../constants.dart';
import 'app_bar_menu.dart';
import 'app_bar_logo.dart';

class AppBar extends StatelessWidget {
  const AppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      color: AppConst.colorGreyDark,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConst.padding * 2,
        vertical: AppConst.padding * 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: const [
            AppBarLogo(),
            SizedBox(width: AppConst.padding * 10),
            AppBarMenu(),
          ]),
          PrimaryButton("Connect to Wallet", onPressed: () {}),
        ],
      ),
    );
  }
}