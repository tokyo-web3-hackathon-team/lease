import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nft_lending_page/components/app_bar.dart' as app;
import 'package:nft_lending_page/components/primary_button.dart';
import 'package:nft_lending_page/components/customized_text_form_field.dart';
import 'package:nft_lending_page/pages/routes.dart';
import 'package:nft_lending_page/providers.dart';
import 'package:nft_lending_page/constants.dart';

class LendPage extends HookConsumerWidget {
  LendPage({super.key});

  final textEditingController = TextEditingController();
  final returnFee = 0.005;
  final defaultRentalPeriod = DateTime.now().add(const Duration(days: 1));
  final hour = 23;
  final minute = 59;
  final second = 59;

  Future _getDate(
      BuildContext context, ValueNotifier<DateTime> rentalPeriod) async {
    final initialDate = defaultRentalPeriod;
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(defaultRentalPeriod.day),
      lastDate: DateTime(defaultRentalPeriod.year + 3),
      selectableDayPredicate: (DateTime date) =>
          date.compareTo(defaultRentalPeriod.add(const Duration(days: -1))) > 0
              ? true
              : false,
    );
    if (newDate != null) {
      textEditingController.text = DateFormat('yyyy-MM-dd').format(newDate);
      rentalPeriod.value = DateTime(
          newDate.year, newDate.month, newDate.day, hour, minute, second);
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAddress = useState("");
    final tokenId = useState("");
    final rentalPeriod = useState(DateTime(
        defaultRentalPeriod.year,
        defaultRentalPeriod.month,
        defaultRentalPeriod.day,
        hour,
        minute,
        second));
    final rentalFee = useState(0.00);
    final isApproved = useState(false);

    useEffect(() {
      textEditingController.text =
          DateFormat('yyyy-MM-dd').format(defaultRentalPeriod);
    }, []);
    useEffect(() {
      if (!ref.read(walletProvider.notifier).isLogin() ||
          contractAddress.value == "" ||
          tokenId.value == "") {
        print("Cannot get approved address: not initialized");
        return;
      }
      ref
          .read(walletProvider.notifier)
          .getApproved(contractAddress.value, tokenId.value)
          .then((String approved) {
        isApproved.value = approved == AppConst.leaseServiceContractAddress;
        print("approved address ${approved}");
      });
    }, [contractAddress.value, tokenId.value]);

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const app.AppBar(),
            const SizedBox(height: 100),
            CustomizedTextFormField(
              hintText: 'NFT Contract Address (0x38ai...dkjk)',
              onChanged: (e) => contractAddress.value = e,
            ),
            const SizedBox(height: 20),
            CustomizedTextFormField(
              hintText: 'Token ID',
              onChanged: (e) => tokenId.value = e,
            ),
            const SizedBox(height: 20),
            CustomizedTextFormField(
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                await _getDate(context, rentalPeriod);
              },
              controller: textEditingController,
              hintText: 'Due Date',
            ),
            const SizedBox(height: 20),
            CustomizedTextFormField(
              inputFormats: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
              ],
              hintText: 'Rental Fee [ETH / Day] (You receive from borrower.)',
              onChanged: (e) => rentalFee.value = double.parse(e),
            ),
            const SizedBox(height: 20),
            CustomizedTextFormField(
              enabled: false,
              hintText: 'Return Fee [ETH] (Borrower pay for tx of return.)',
              initialValue: returnFee.toString(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PrimaryButton(
                  "Back",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 10),
                PrimaryButton("Approve",
                    onPressed: !isApproved.value
                        ? () {
                            if (ref.read(walletProvider.notifier).isLogin()) {
                              ref
                                  .read(walletProvider.notifier)
                                  .approve(contractAddress.value, tokenId.value)
                                  .then((bool result) {
                                if (result) {
                                  isApproved.value = result;
                                } else {
                                  showDialog<void>(
                                      context: context,
                                      builder: (_) {
                                        return const FailToLendDialogForTx();
                                      });
                                }
                              });
                            } else {
                              showDialog<void>(
                                  context: context,
                                  builder: (_) {
                                    return const FailToLendDialogForLogin();
                                  }).then((value) {
                                ref.read(walletProvider.notifier).login();
                              });
                            }
                          }
                        : null),
                const SizedBox(width: 10),
                PrimaryButton("Lend",
                    onPressed: isApproved.value
                        ? () {
                            if (ref.read(walletProvider.notifier).isLogin()) {
                              ref
                                  .read(offerProvider.notifier)
                                  .offerToLend(
                                      ref
                                          .read(walletProvider.notifier)
                                          .getLoginAddress(),
                                      contractAddress.value,
                                      tokenId.value,
                                      rentalPeriod.value,
                                      rentalFee.value)
                                  .then((bool result) {
                                if (result) {
                                  ref
                                      .read(menuProvider.notifier)
                                      .setCurrentIndex(1);
                                  Navigator.popUntil(context,
                                      ModalRoute.withName(Routes.homePage));
                                } else {
                                  showDialog<void>(
                                      context: context,
                                      builder: (_) {
                                        return const FailToLendDialogForTx();
                                      });
                                }
                              });
                            } else {
                              showDialog<void>(
                                  context: context,
                                  builder: (_) {
                                    return const FailToLendDialogForLogin();
                                  }).then((value) {
                                ref.read(walletProvider.notifier).login();
                              });
                            }
                          }
                        : null),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class FailToLendDialogForLogin extends StatelessWidget {
  const FailToLendDialogForLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fail to lend !!'),
      content: const Text('Please connect to wallet before lend.'),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        PrimaryButton(
          "OK",
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}

class FailToLendDialogForTx extends StatelessWidget {
  const FailToLendDialogForTx({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Fail to lend !!'),
      content: const Text('Please confirm parameters and try again.'),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        PrimaryButton(
          "OK",
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
