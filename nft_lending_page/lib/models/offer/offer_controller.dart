import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_web3/ethers.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:nft_lending_page/constants.dart';
import 'package:nft_lending_page/data/abis.dart';
import 'package:nft_lending_page/models/offer/offer_state.dart';

class OfferController extends StateNotifier<OffersState> {
  OfferController() : super(const OffersState());

  setCurrentOffer(OfferState currentOffer) {
    state = state.copyWith(currentOffer: currentOffer);
  }

  Future<void> getOffers() async {
    final web3provider = Web3Provider(ethereum!);
    const leaseContractAddress = AppConst.leaseServiceContractAddress;
    final contract = Contract(
      leaseContractAddress,
      Interface(leaseServiceEventAbi),
      web3provider,
    );
    final filter = contract.getFilter('Offer');
    final events = await contract.queryFilter(filter);
    // TODO 貸し出し済みのeventを検知して差し引きする -> スマコン側に確認しにいく
    // "event Offer(address collection, uint256 tokenId, uint256 price, uint until)"
    final List<OfferState> offers = [];
    for (int i = 0; i < events.length; i++) {
      // "event Offer(address lender, address collection, uint256 tokenId, uint256 price, uint until)"
      var lenderAddress = events[i].args[0].toString();
      var contractAddress = events[i].args[1].toString();
      var tokenId = int.parse(events[i].args[2].toString());
      final rentalPrice = int.parse(events[i].args[3].toString());
      final rentalPeriod = int.parse(events[i].args[4].toString());
      final isActive = await _isActiveOffer(
          lenderAddress, contractAddress, tokenId, rentalPrice, rentalPeriod);
      if (!isActive) {
        continue;
      }
      contractAddress = "0x01c7851AE4D42f7B649ce168716C78fC25fE3D16";
      tokenId = 3;
      final url = Uri.https(AppConst.alchemyApiDomain,
          "nft/v2/${dotenv.env["ALCHEMY_API_KEY"]!}/getNFTMetadata", {
        "contractAddress": contractAddress,
        "tokenId": tokenId.toString(),
        "refreshCache": false.toString()
      });
      http.Response response = await http.get(url);
      _response(response);
      var responseJson = json.decode(response.body);
      final imageUrl = responseJson["metadata"]["image"];
      final offer = OfferState(
          assetAddress: contractAddress,
          tokenId: tokenId,
          imageUrl: imageUrl,
          lenderAddress: lenderAddress,
          rentalPeriod: rentalPeriod,
          rentalPrice: rentalPrice);
      offers.add(offer);
    }

    state = state.copyWith(offers: offers);
  }

  Future<bool> _isActiveOffer(String lender, String collection, int tokenId,
      int price, int until) async {
    final web3provider = Web3Provider(ethereum!);
    const leaseContractAddress = AppConst.leaseServiceContractAddress;
    final contract = Contract(
      leaseContractAddress,
      Interface(leaseServiceAbi),
      web3provider,
    );
    try {
      // NUMERIC_FAULT overflowが発生するのでBigNumber型で扱う。
      return await contract.call<bool>(
        'isOfferActive',
        [
          lender,
          collection,
          BigNumber.from(tokenId.toString()),
          BigNumber.from(price.toString()),
          BigNumber.from(until.toString())
        ],
      );
    } catch (ex) {
      print([lender, collection, tokenId, price, until]);
      print("failed. ${ex.toString()}");
      return false;
    }
  }

  bool _response(http.Response response) {
    final statusCode = response.statusCode;
    switch (statusCode) {
      case 200:
        return true;
      default:
        throw Exception('unexpected error. status code $statusCode');
    }
  }
}
