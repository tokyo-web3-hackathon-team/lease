import 'package:flutter/material.dart';

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
        horizontal: AppConst.padding * 1.5,
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
          const ConnectToWallet(),
        ],
      ),
    );
  }
}

class ConnectToWallet extends StatelessWidget {
  const ConnectToWallet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 35,
      padding: const EdgeInsets.symmetric(horizontal: AppConst.padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: const LinearGradient(
          colors: [
            AppConst.colorRedOrange,
            AppConst.colorRedOrange,
            AppConst.colorRedOrange,
            AppConst.colorOrange,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.white24,
            blurRadius: 10,
          )
        ],
      ),
      child: Center(
          child: Row(
        children: const [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: Colors.white,
            size: 16,
          ),
          SizedBox(width: AppConst.padding),
          Text(
            'Connect to Wallet',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      )),
    );
  }
}
