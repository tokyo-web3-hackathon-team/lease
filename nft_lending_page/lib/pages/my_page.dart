import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/components/app_bar.dart' as app;
import 'package:nft_lending_page/components/customized_text_form_field.dart';
import 'package:nft_lending_page/components/primary_button.dart';
import 'package:nft_lending_page/constants.dart';
import 'package:nft_lending_page/models/enum/lease_type.dart';
import 'package:nft_lending_page/providers.dart';

class MyPage extends HookConsumerWidget {
  const MyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletConnectUrl = useState("");

    return Scaffold(
      body: Column(
        children: [
          const app.AppBar(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConst.padding * 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: CustomizedTextFormField(
                    hintText: "Wallet Connect URI",
                    width: 400,
                    onChanged: (e) => walletConnectUrl.value = e,
                  ),
                ),
                PrimaryButton("Connect to Dapps", onPressed: () {
                  ref
                      .watch(walletProvider.notifier)
                      .connectDapps(walletConnectUrl.value);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NftsList extends HookConsumerWidget {
  NftsList({
    Key? key,
  }) : super(key: key);

  final leaseType = useState(LeaseType.borrow);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final leaseType = useState(LeaseType.borrow);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () => leaseType.value = LeaseType.borrow,
            child: RichText(
              text: TextSpan(
                text: LeaseType.borrow.display,
                style: TextStyle(
                  fontSize: 20.0,
                  color: leaseType.value == LeaseType.borrow
                      ? Colors.red
                      : Colors.grey,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => leaseType.value = LeaseType.lend,
          child: RichText(
            text: TextSpan(
              text: LeaseType.lend.display,
              style: TextStyle(
                fontSize: 20.0,
                color: leaseType.value == LeaseType.lend
                    ? Colors.red
                    : Colors.grey,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
