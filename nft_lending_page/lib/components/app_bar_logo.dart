import 'package:flutter/material.dart';

class AppBarTopLogo extends StatelessWidget {
  const AppBarTopLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      width: 70,
      child: Image.asset(
        'assets/logo/instagram_logo_with_name.png',
      ),
    );
  }
}
