import 'dart:convert';

import 'package:flutter_web3/flutter_web3.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:nft_lending_page/data/abis.dart';
import 'package:nft_lending_page/models/offer/offer_state.dart';
import 'package:nft_lending_page/models/offer.dart';


class OfferController extends StateNotifier<OffersState> {
  OfferController() : super(const OffersState());

  Future<List<Offer>> getOffers() async {
    final web3provider = Web3Provider(ethereum!);
    const leaseContractAddress = "0x751A28264d7cC0fc3f7Db0936d08e094E616c3B7";
    final contract = Contract(
      leaseContractAddress,
      Interface(leaseServiceEventAbi),
      web3provider,
    );
    final filter = contract.getFilter('Offer');
    final events = await contract.queryFilter(filter);
    // TODO 貸し出し済みのeventを検知して差し引きする -> スマコン側に確認しにいく
    // "event Offer(address collection, uint256 tokenId, uint256 price, uint until)"
    final offers = <Offer>[];
    for (int i = 0; i < events.length; i++) {
      // final contractAddress = events[i].args[0] as String;
      // final tokenId = events[i].args[1] as int;
      final rentalPeriod = int.parse(events[i].args[2].toString());
      final rentalPrice = int.parse(events[i].args[3].toString());
      final contractAddress = "0x01c7851AE4D42f7B649ce168716C78fC25fE3D16";
      final tokenId = 3;
      final url = Uri.https("eth-goerli.g.alchemy.com",
          "nft/v2/VDzuc6T_BZtAlBf0MnsFZrt-OABQ7E3A/getNFTMetadata", {
        "contractAddress": contractAddress,
        "tokenId": tokenId.toString(),
        "refreshCache": false.toString()
      });
      http.Response response = await http.get(url);
      _response(response);
      var responseJson = json.decode(response.body);
      final imageUrl = responseJson["metadata"]["image"];
      final offer = Offer(
          assetAddress: contractAddress,
          tokenId: tokenId,
          imageUrl: imageUrl,
          lenderAddress: "TODO",
          rentalPeriod: rentalPeriod,
          rentalPrice: rentalPrice);
      offers.add(offer);
      print(imageUrl);
    }
    return offers;
  }

  bool _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return true;
      case 400:
        // 400 Bad Request : 一般的なクライアントエラー
        throw Exception('一般的なクライアントエラーです');
      case 401:
        // 401 Unauthorized : アクセス権がない、または認証に失敗
        throw Exception('アクセス権限がない、または認証に失敗しました');
      case 403:
        // 403 Forbidden ： 閲覧権限がないファイルやフォルダ
        throw Exception('閲覧権限がないファイルやフォルダです');
      case 500:
        // 500 何らかのサーバー内で起きたエラー
        throw Exception('何らかのサーバー内で起きたエラーです');
      default:
        // それ以外の場合
        throw Exception('何かしらの問題が発生しています');
    }
  }
}
