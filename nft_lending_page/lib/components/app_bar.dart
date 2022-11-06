import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/components/primary_button.dart';
import 'package:nft_lending_page/providers.dart';
import '../constants.dart';
import '../models/wallet/wallet_state.dart';
import 'app_bar_menu.dart';
import 'app_bar_logo.dart';

class AppBar extends HookConsumerWidget {
  const AppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String loginAddress =
        (ref.watch(walletProvider) as WalletState).loginAddress;
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
          PrimaryButton(
              loginAddress.isEmpty
                  ? "Connect to Wallet"
                  : "${loginAddress.substring(0, 6)}...${loginAddress.substring(loginAddress.length - 6, loginAddress.length)}",
              onPressed: () async {
            if (ref.read(walletProvider.notifier).isLogin() == false) {
              ref.read(walletProvider.notifier).login().then((bool result) {
                if (result) {
                  print("Success to login");
                  ref.read(menuProvider.notifier).setCurrentIndex(1);
                }
              });
            }
          }),
        ],
      ),
    );
  }
}
