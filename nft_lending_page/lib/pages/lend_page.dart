import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nft_lending_page/components/app_bar.dart' as app;
import 'package:nft_lending_page/components/primary_button.dart';
import 'package:nft_lending_page/components/customized_text_form_field.dart';
import 'package:nft_lending_page/providers.dart';

class LendPage extends HookConsumerWidget {
  LendPage({super.key});

  final textEditingController = TextEditingController();
  final returnFee = 0.05;
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

    useEffect(() {
      textEditingController.text =
          DateFormat('yyyy-MM-dd').format(defaultRentalPeriod);
    }, []);

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
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
              ],
              hintText: 'Rental Fee [ETH] (You receive from borrower.)',
              onChanged: (e) => rentalFee.value = double.parse(e),
            ),
            const SizedBox(height: 20),
            CustomizedTextFormField(
              enabled: false,
              hintText: 'Return Fee [ETH] (Borrower pay for tx of return.)',
              initialValue: returnFee.toString(),
            ),
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
                PrimaryButton("Lend", onPressed: () {
                  if (ref.read(walletProvider.notifier).isLogin()) {
                    ref.read(walletProvider.notifier).lend(
                        contractAddress.value,
                        tokenId.value,
                        rentalPeriod.value,
                        rentalFee.value,
                        returnFee);
                  } else {
                    ref.read(walletProvider.notifier).login();
                  }
                }),
              ],
            )
          ],
        ),
      ),
    );
  }
}
