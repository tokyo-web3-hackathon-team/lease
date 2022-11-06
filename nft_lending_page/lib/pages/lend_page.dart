import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
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
      padding: const EdgeInsets.all(40.0),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'contract address'),
              onChanged: (e) => contractAddress.value = e,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'token id'),
              onChanged: (e) => tokenId.value = e,
            ),
            TextFormField(
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                await _getDate(context, rentalPeriod);
              },
              controller: textEditingController,
              decoration: const InputDecoration(labelText: 'rental period'),
            ),
            TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
              ],
              decoration: const InputDecoration(labelText: 'rental fee'),
              onChanged: (e) => rentalFee.value = double.parse(e),
              initialValue: rentalFee.value.toString(),
            ),
            TextFormField(
              enabled: false,
              decoration:
                  const InputDecoration(labelText: 'return fee:  xxx ETH'),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(lendingRepositoryProvider).lend(
                      contractAddress.value,
                      tokenId.value,
                      rentalPeriod.value,
                      rentalFee.value,
                      returnFee);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text("Lend"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
