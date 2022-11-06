/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: directives_ordering,unnecessary_import,implicit_dynamic_list_literal

import 'package:flutter/widgets.dart';

class $AssetsDummyGen {
  const $AssetsDummyGen();

  /// File path: assets/dummy/post1.jpg
  AssetGenImage get post1 => const AssetGenImage('assets/dummy/post1.jpg');

  /// File path: assets/dummy/post10.jpg
  AssetGenImage get post10 => const AssetGenImage('assets/dummy/post10.jpg');

  /// File path: assets/dummy/post2.jpg
  AssetGenImage get post2 => const AssetGenImage('assets/dummy/post2.jpg');

  /// File path: assets/dummy/post3.jpg
  AssetGenImage get post3 => const AssetGenImage('assets/dummy/post3.jpg');

  /// File path: assets/dummy/post4.jpg
  AssetGenImage get post4 => const AssetGenImage('assets/dummy/post4.jpg');

  /// File path: assets/dummy/post5.jpg
  AssetGenImage get post5 => const AssetGenImage('assets/dummy/post5.jpg');

  /// File path: assets/dummy/post6.jpg
  AssetGenImage get post6 => const AssetGenImage('assets/dummy/post6.jpg');

  /// File path: assets/dummy/post7.jpg
  AssetGenImage get post7 => const AssetGenImage('assets/dummy/post7.jpg');

  /// File path: assets/dummy/post8.jpg
  AssetGenImage get post8 => const AssetGenImage('assets/dummy/post8.jpg');

  /// File path: assets/dummy/post9.jpg
  AssetGenImage get post9 => const AssetGenImage('assets/dummy/post9.jpg');

  /// List of all assets
  List<AssetGenImage> get values =>
      [post1, post10, post2, post3, post4, post5, post6, post7, post8, post9];
}

class $AssetsEnvGen {
  const $AssetsEnvGen();

  /// File path: assets/env/.env
  String get env => 'assets/env/.env';

  /// List of all assets
  List<String> get values => [env];
}

class $AssetsIconGen {
  const $AssetsIconGen();

  /// File path: assets/icon/direct_message.svg
  String get directMessage => 'assets/icon/direct_message.svg';

  /// File path: assets/icon/grid.svg
  String get grid => 'assets/icon/grid.svg';

  /// File path: assets/icon/igtv.svg
  String get igtv => 'assets/icon/igtv.svg';

  /// File path: assets/icon/logout.svg
  String get logout => 'assets/icon/logout.svg';

  /// File path: assets/icon/notification_bell.svg
  String get notificationBell => 'assets/icon/notification_bell.svg';

  /// File path: assets/icon/search.svg
  String get search => 'assets/icon/search.svg';

  /// File path: assets/icon/settings2.svg
  String get settings2 => 'assets/icon/settings2.svg';

  /// File path: assets/icon/statistic.svg
  String get statistic => 'assets/icon/statistic.svg';

  /// List of all assets
  List<String> get values => [
        directMessage,
        grid,
        igtv,
        logout,
        notificationBell,
        search,
        settings2,
        statistic
      ];
}

class $AssetsLogoGen {
  const $AssetsLogoGen();

  /// File path: assets/logo/instagram_logo_with_name.png
  AssetGenImage get instagramLogoWithName =>
      const AssetGenImage('assets/logo/instagram_logo_with_name.png');

  /// List of all assets
  List<AssetGenImage> get values => [instagramLogoWithName];
}

class $AssetsNftGen {
  const $AssetsNftGen();

  /// File path: assets/nft/cow.svg
  String get cow => 'assets/nft/cow.svg';

  /// File path: assets/nft/fish.svg
  String get fish => 'assets/nft/fish.svg';

  /// File path: assets/nft/kraken.svg
  String get kraken => 'assets/nft/kraken.svg';

  /// File path: assets/nft/pig.svg
  String get pig => 'assets/nft/pig.svg';

  /// File path: assets/nft/seahorse.svg
  String get seahorse => 'assets/nft/seahorse.svg';

  /// File path: assets/nft/wolf.svg
  String get wolf => 'assets/nft/wolf.svg';

  /// List of all assets
  List<String> get values => [cow, fish, kraken, pig, seahorse, wolf];
}

class Assets {
  Assets._();

  static const $AssetsDummyGen dummy = $AssetsDummyGen();
  static const $AssetsEnvGen env = $AssetsEnvGen();
  static const $AssetsIconGen icon = $AssetsIconGen();
  static const $AssetsLogoGen logo = $AssetsLogoGen();
  static const $AssetsNftGen nft = $AssetsNftGen();
}

class AssetGenImage {
  const AssetGenImage(this._assetName);

  final String _assetName;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = false,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.low,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider() => AssetImage(_assetName);

  String get path => _assetName;

  String get keyName => _assetName;
}
