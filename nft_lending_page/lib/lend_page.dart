import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LendPage extends StatelessWidget {
  LendPage({super.key});
  final textEditingController = TextEditingController();

  Future _getDate(BuildContext context) async {
    final initialDate = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(DateTime.now().year - 3),
      lastDate: DateTime(DateTime.now().year + 3),
    );
    if (newDate != null) {
      textEditingController.text = newDate.toString();
    } else {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Form(
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'contract address'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'token id'),
            ),
            TextFormField(
              onTap: () {
                FocusScope.of(context).requestFocus(new FocusNode());
                _getDate(context);
              },
              controller: textEditingController,
              decoration: const InputDecoration(labelText: 'rental period'),
            ),
            TextFormField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))
              ],
              decoration: const InputDecoration(labelText: 'rental fee'),
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
                  // metamaskへ接続させる
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
