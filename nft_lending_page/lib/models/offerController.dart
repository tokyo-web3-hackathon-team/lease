import 'dart:convert';

import 'package:flutter_web3/flutter_web3.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/data/abis.dart';
import 'package:http/http.dart' as http;

import 'offer.dart';

class OfferController extends StateNotifier<String> {
  OfferController() : super("");

  setSelectedOffer(String selectedOfferAddress) {
    state = selectedOfferAddress;
  }

  Future<List<Offer>> getOffer() async {
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
    print(events);
    // "event Offer(address collection, uint256 tokenId, uint256 price, uint until)"
    for (int i = 0; i < events.length; i++){
      print("start>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
      print(events[i]);
      print(events[i].args[0]);
      print(events[i].args[1]);
      print(events[i].args[2]);
      print(events[i].args[3]);
      final contractAddress = events[i].args[0] as String;
      final tokenId = events[i].args[1] as int;
      final url = Uri.https("eth-goerli.g.alchemy.com", "nft/v2/VDzuc6T_BZtAlBf0MnsFZrt-OABQ7E3A/getNFTMetadata",
          {"contractAddress": contractAddress, "tokenId": tokenId, "refreshCache": false });
      http.Response response = _response(await http.get(url));
      final a = Offer(assetAddress: contractAddress, tokenId: tokenId,
          imageUrl: "", lenderAddress: "TODO", rentalPeriod: 1, rentalPrice: 1);
    }
    return [];
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = jsonDecode(response.body);
        return responseJson;
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
