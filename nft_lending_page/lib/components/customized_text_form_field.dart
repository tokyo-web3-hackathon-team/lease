import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nft_lending_page/constants.dart';

class CustomizedTextFormField extends StatelessWidget {
  const CustomizedTextFormField(
      {super.key,
      this.text,
      this.initialValue,
      this.hintText,
      this.enabled,
      this.onChanged,
      this.onTap,
      this.controller,
      this.inputFormats,
      this.width});

  final String? text;
  final String? initialValue;
  final String? hintText;
  final bool? enabled;
  final Function(String value)? onChanged;
  final Function()? onTap;
  final TextEditingController? controller;
  final double? width;
  final List<TextInputFormatter>? inputFormats;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 550),
      child: Container(
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: AppConst.padding),
        child: TextFormField(
          readOnly: enabled ?? true,
          initialValue: initialValue,
          inputFormatters: inputFormats,
          controller: controller,
          style: const TextStyle(color: Colors.white, fontSize: 12),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 0,
              ),
            ),
            fillColor: AppConst.colorGreyDark,
            filled: true,
            contentPadding: const EdgeInsets.only(top: 30, left: 30),
          ),
          onChanged: onChanged,
          onTap: onTap,
        ),
      ),
    );
  }
}
