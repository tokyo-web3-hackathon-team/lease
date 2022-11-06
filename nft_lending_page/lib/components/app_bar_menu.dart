import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';

class AppBarMenu extends StatefulWidget {
  const AppBarMenu({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _AppBarMenuState createState() => _AppBarMenuState();
}

class _AppBarMenuState extends State<AppBarMenu> {
  int _currentSelected = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MenuItem(
          currentIndex: _currentSelected,
          itemIndex: 1,
          title: 'Explore',
          iconUrl: 'assets/icon/search.svg',
          onPress: () {
            setState(() {
              _currentSelected = 1;
            });
          },
        ),
        MenuItem(
          currentIndex: _currentSelected,
          itemIndex: 2,
          title: 'MyPage',
          iconUrl: 'assets/icon/statistic.svg',
          onPress: () {
            setState(() {
              _currentSelected = 2;
            });
          },
        ),
        MenuItem(
          currentIndex: _currentSelected,
          itemIndex: 3,
          title: 'Settings',
          iconUrl: 'assets/icon/settings2.svg',
          onPress: () {
            setState(
              () {
                _currentSelected = 3;
              },
            );
          },
        ),
      ],
    );
  }
}

class MenuItem extends StatelessWidget {
  final int currentIndex;
  final int itemIndex;
  final String title;
  final String iconUrl;
  final int? trailing;
  final VoidCallback onPress;

  const MenuItem({
    Key? key,
    required this.currentIndex,
    required this.itemIndex,
    required this.title,
    this.trailing,
    required this.iconUrl,
    required this.onPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: ListTile(
        onTap: onPress,
        leading: SvgPicture.asset(
          iconUrl,
          height: 18,
          width: 18,
          color: currentIndex == itemIndex
              ? AppConst.colorRedOrange
              : Colors.white,
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        trailing: trailing == null
            ? null
            : Text(
                trailing.toString(),
                style: const TextStyle(color: Colors.grey),
              ),
      ),
    );
  }
}