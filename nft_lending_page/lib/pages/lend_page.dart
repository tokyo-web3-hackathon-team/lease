import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nft_lending_page/components/primary_button.dart';
import 'package:nft_lending_page/components/customized_text_form_field.dart';
import 'package:nft_lending_page/lending_repository.dart';

class LendPage extends HookConsumerWidget {
  LendPage({super.key});

  final textEditingController = TextEditingController();
  final returnFee = 0.01;
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

    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomizedTextFormField(
                hintText: 'contract address',
                onChanged: (e) => contractAddress.value = e,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomizedTextFormField(
                hintText: 'token id',
                onChanged: (e) => tokenId.value = e,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomizedTextFormField(
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  await _getDate(context, rentalPeriod);
                },
                controller: textEditingController,
                hintText: 'rental period',
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: CustomizedTextFormField(
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
                ],
                hintText: 'rental fee',
                onChanged: (e) => rentalFee.value = double.parse(e),
                initialValue: rentalFee.value.toString(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: CustomizedTextFormField(
                enabled: false,
                hintText: 'return fee:  xxx ETH',
              ),
            ),
            PrimaryButton("Lend", onPressed: () {
              ref.read(lendingRepositoryProvider).lend(
                  contractAddress.value,
                  tokenId.value,
                  rentalPeriod.value,
                  rentalFee.value,
                  returnFee);
            })
          ],
        ),
      ),
    );
  }
}
