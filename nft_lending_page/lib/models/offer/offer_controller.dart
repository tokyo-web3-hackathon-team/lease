import 'dart:convert';
import 'dart:math';

import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      final url = Uri.https(AppConst.alchemyApiDomain,
          "nft/v2/VDzuc6T_BZtAlBf0MnsFZrt-OABQ7E3A/getNFTMetadata", {
        "contractAddress": contractAddress,
        "tokenId": tokenId.toString(),
        "refreshCache": false.toString()
      });
      http.Response response = await http.get(url);
      _response(response);
      var responseJson = json.decode(response.body);
      var imageUrl = await _getImageUrl(responseJson);
      imageUrl = _convertIpfsToHttps(imageUrl);
      if (imageUrl.isEmpty) {
        continue;
      }
      final offer = OfferState(
          assetAddress: contractAddress,
          tokenId: tokenId,
          imageUrl: imageUrl,
          lenderAddress: lenderAddress,
          rentalPeriod: rentalPeriod,
          dueDate: await _convertBlockNumberToDueDate(rentalPeriod),
          rentalPrice: rentalPrice);
      offers.add(offer);
    }
    state = state.copyWith(offers: offers);
  }

  Future<String> _getImageUrl(dynamic responseJson) async {
    if (responseJson["metadata"] != null &&
        responseJson["metadata"]["image"] != null) {
      return responseJson["metadata"]["image"];
    }
    final gateway = responseJson["tokenUri"]["gateway"];
    if (gateway == null || gateway.toString().isEmpty) {
      return "";
    }
    http.Response response = await http.get(Uri.parse(gateway));
    var metadataJson = json.decode(response.body);
    var imageUrl = metadataJson["image"];
    if (imageUrl == null) {
      return "";
    }
    return imageUrl;
  }

  String _convertIpfsToHttps(String imageUrl) {
    imageUrl = imageUrl.replaceFirst("ipfs://", "https://ipfs.io/ipfs/");
    if (imageUrl.startsWith("http")) {
      return imageUrl;
    }
    return "";
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

  Future<bool> offerToLend(String lenderAddress, String nftContractAddress,
      String tokenId, DateTime dueDate, double rentalFee) async {
    final leaseContract = Contract(
      AppConst.leaseServiceContractAddress,
      Interface(leaseServiceAbi),
      provider!.getSigner(),
    );

    int toBlockNumber = await _convertDueDateToBlockNumber(dueDate);
    rentalFee = rentalFee / (86400 / 15); // ETH/block
    BigInt rentalFeeWei = BigInt.from(rentalFee * pow(10, 18));
    try {
      TransactionResponse tx = await leaseContract.send(
        'offerLending',
        [nftContractAddress, tokenId, rentalFeeWei, toBlockNumber],
      );
      print(
          "TxHash: ${tx.hash}, NFT Contract Address : $nftContractAddress, Token ID : $tokenId,"
          " Rental Fee : $rentalFeeWei, Until : $toBlockNumber");
      List<OfferState> offers = [...state.offers];
      offers.add(
        OfferState(
          lenderAddress: lenderAddress,
          assetAddress: nftContractAddress,
          tokenId: int.parse(tokenId),
          rentalPeriod: toBlockNumber,
          dueDate: await _convertBlockNumberToDueDate(toBlockNumber),
          rentalPrice: rentalFeeWei.toInt(),
        ),
      );
      state = state.copyWith(offers: offers);
    } catch (ex) {
      print("Fail to offer. ${ex.toString()}");
      return false;
    }
    return true;
  }

  Future<bool> borrow(
      String nftContractAddress, String tokenId, DateTime dueDate, BigInt price) async {
    final leaseContract = Contract(
      AppConst.leaseServiceContractAddress,
      Interface(leaseServiceAbi),
      provider!.getSigner(),
    );

    int periodBlockNumber = await _convertDueDateToBlockNumber(dueDate) - await provider!.getBlockNumber();
    BigInt payment = EthUtils.parseEther("0.005").toBigInt + price * BigInt.from(periodBlockNumber);
    try {
      TransactionResponse tx = await leaseContract.send(
        'borrow',
        [nftContractAddress, tokenId, periodBlockNumber],
        TransactionOverride(value: payment),
      );
      print(
          "TxHash: ${tx.hash}, Contract Address : $nftContractAddress, Token ID : $tokenId,"
          " Period : $periodBlockNumber");
    } catch (ex) {
      print("Fail to offer. ${ex.toString()}");
      return false;
    }
    return true;
  }

  Future<int> _convertDueDateToBlockNumber(DateTime dueDate) async {
    DateTime now = DateTime.now();
    DateTime fromDate = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);
    DateTime toDate =
        DateTime(dueDate.year, dueDate.month, dueDate.day, 0, 0, 0, 0);
    int diffBlocks = toDate.difference(fromDate).inSeconds ~/ 15;
    int fromBlockNumber = await provider!.getBlockNumber();
    return fromBlockNumber + diffBlocks;
  }

  Future<DateTime> _convertBlockNumberToDueDate(int toBlockNumber) async {
    int fromBlockNumber = await provider!.getBlockNumber();
    int diffDays = (toBlockNumber - fromBlockNumber) * 15 ~/ 86400;
    DateTime now = DateTime.now();
    DateTime dueDate =
        DateTime(now.year, now.month, now.day + diffDays, 0, 0, 0, 0);
    return dueDate;
  }
}
