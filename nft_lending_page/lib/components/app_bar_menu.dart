import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/providers.dart';

import '../constants.dart';

class AppBarMenu extends HookConsumerWidget {
  const AppBarMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(menuProvider) as int;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        MenuItem(
          currentIndex: currentIndex,
          itemIndex: 0,
          title: 'Explore',
          iconUrl: 'assets/icon/search.svg',
          onPress: () {
            ref.read(menuProvider.notifier).setCurrentIndex(0);
          },
        ),
        MenuItem(
          currentIndex: currentIndex,
          itemIndex: 1,
          title: 'MyPage',
          iconUrl: 'assets/icon/statistic.svg',
          onPress: () {
            ref.read(menuProvider.notifier).setCurrentIndex(1);
          },
        ),
        MenuItem(
          currentIndex: currentIndex,
          itemIndex: 2,
          title: 'Settings',
          iconUrl: 'assets/icon/settings2.svg',
          onPress: () {
            ref.read(menuProvider.notifier).setCurrentIndex(2);
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
