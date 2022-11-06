import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/components/app_bar.dart' as app;
import 'package:nft_lending_page/components/primary_button.dart';
import 'package:nft_lending_page/pages/routes.dart';
import 'package:nft_lending_page/pages/screen_status.dart';

import '../constants.dart';
import '../data/dummy_nft.dart';
import '../models/nft.dart';

class ExplorePage extends HookConsumerWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ScrollController homeScrollController = ScrollController();
    return Column(
      children: [
        const app.AppBar(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            PrimaryButton("Lend", onPressed: () {
              Navigator.pushNamed(context, Routes.lendPage);
            }),
            const SizedBox(width: AppConst.padding * 2),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: CustomScrollView(
            controller: homeScrollController,
            slivers: [
              _buildLendingList(context),
            ],
          ),
        ),
      ],
    );
  }

  _buildLendingList(BuildContext context) {
    ScreenStatus screenStatus = ScreenSize.getScreenStatus(context);
    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConst.padding * 2,
      ),
      sliver: SliverStaggeredGrid.countBuilder(
        staggeredTileBuilder: (index) => const StaggeredTile.fit(1),
        crossAxisCount: _getCountForScreenType(screenStatus),
        crossAxisSpacing: AppConst.padding,
        mainAxisSpacing: AppConst.padding,
        itemCount: dummyNFT.length,
        itemBuilder: (ctx, index) {
          return FeedCard(nft: dummyNFT[index]);
        },
      ),
    );
  }

  int _getCountForScreenType(ScreenStatus screenStatus) {
    if (screenStatus == ScreenStatus.desktop) {
      return 4;
    } else if (screenStatus == ScreenStatus.tablet) {
      return 3;
    }
    return 2;
  }
}

class FeedCard extends StatelessWidget {
  final NFT nft;

  const FeedCard({
    Key? key,
    required this.nft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          child: Image.asset(
            nft.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        FractionallySizedBox(
          widthFactor: 1,
          child: Container(
            width: 100,
            height: 160,
            decoration: const BoxDecoration(
              color: AppConst.colorGreyDark,
              borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const RentalCondition(
                      title: "rental period", value: "2022/11/16"),
                  const RentalCondition(
                      title: "rental fee", value: "0.1 ETH / day"),
                  const RentalCondition(title: "return fee", value: "0.1 ETH"),
                  const RentalCondition(
                      title: "total fee", value: "1 ETH / 10days"),
                  PrimaryButton("Borrow", onPressed: () {
                    //
                  })
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppConst.padding),
      ],
    );
  }
}

class RentalCondition extends StatelessWidget {
  const RentalCondition({
    Key? key,
    required this.title,
    this.value,
  }) : super(key: key);
  final String title;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value),
        ],
      ),
    );
  }
}
