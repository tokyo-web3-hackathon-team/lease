import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/components/app_bar.dart' as app;
import 'package:nft_lending_page/components/explore.dart';
import 'package:nft_lending_page/components/primary_button.dart';
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
            PrimaryButton("Lend", onPressed: () {}),
            const SizedBox(width: AppConst.padding * 2),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: CustomScrollView(
            controller: homeScrollController,
            slivers: const [
              Explore(),
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
          borderRadius: BorderRadius.circular(15),
          child: Image.asset(
            nft.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppConst.padding),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConst.padding),
          child: Row(
            children: [
              const SizedBox(width: AppConst.padding),
              Text(nft.userAddress),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.favorite_border,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: AppConst.padding / 2),
                  Text(nft.likes.toString()),
                  const SizedBox(width: AppConst.padding),
                  const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Colors.white54,
                  ),
                  const SizedBox(width: AppConst.padding / 2),
                  Text(nft.comments.toString()),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConst.padding),
      ],
    );
  }
}
