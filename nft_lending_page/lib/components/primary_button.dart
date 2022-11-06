import 'package:flutter/material.dart';

import '../constants.dart';

class PrimaryButton extends ElevatedButton {
  PrimaryButton(String? text,
      {super.key, required VoidCallback? onPressed, bool autofocus = false})
      : super(
          autofocus: autofocus,
          onPressed: onPressed,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Expanded(
              child: Container(
                height: 35,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppConst.padding),
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
                    children: [
                      // const Icon(
                      //   Icons.account_balance_wallet_outlined,
                      //   color: Colors.white,
                      //   size: 16,
                      // ),
                      const SizedBox(width: AppConst.padding),
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
            ),
          ),
        );
}
