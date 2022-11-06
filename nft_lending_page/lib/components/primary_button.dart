import 'package:flutter/material.dart';

import '../constants.dart';

class PrimaryButton extends ElevatedButton {
  PrimaryButton(String? text,
      {super.key, required VoidCallback? onPressed, bool autofocus = false})
      : super(
          autofocus: autofocus,
          onPressed: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
              child: Container(
                height: 35,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppConst.padding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        );
}
