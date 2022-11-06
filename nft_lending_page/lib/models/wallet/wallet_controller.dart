import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/constants.dart';
import 'package:nft_lending_page/data/abis.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';
import 'package:web3dart/crypto.dart';

import 'wallet_state.dart';

class WalletController extends StateNotifier<WalletState> {
  WalletController() : super(const WalletState());

  String getLoginAddress() {
    if (isLogin()) {
      return state.loginAddress;
    }
    return "";
  }

  bool isLogin() {
    return state.loginAddress.isEmpty ? false : true;
  }

  logout() {
    state = state.copyWith(loginAddress: "");
  }

  Future<bool> login() async {
    final accounts = await ethereum!.requestAccount();
    String selectedAddress = accounts.first;
    print("Address : $selectedAddress");
    int selectedChainId = await ethereum!.getChainId();
    print("ChainId : $selectedChainId");

    ethereum!.onAccountsChanged((List<String> accounts) {
      print("Address is changed. Address(New): ${accounts.first}");
    });
    ethereum!.onChainChanged((int chainId) {
      print("Chain is changed. ChainId(New): $chainId");
    });
    ethereum!.onDisconnect((ProviderRpcError error) {
      logout();
    });

    if (selectedChainId != 5) {
      await ethereum!.walletSwitchChain(5);
    }
    String signedMessage =
        await provider!.getSigner().signMessage("Login to NFTRental");

    //TODO 署名の検証

    //Login成功
    state = state.copyWith(loginAddress: selectedAddress);

    return true;
  }

  Future<bool> connectDapps(String url) async {
    // TODO: Dappsへ接続する処理を記述
    final connector = WalletConnect(
      uri: url,
      clientMeta: const PeerMeta(
        name: 'NFTRental',
        description: 'NFTRental Wallet App',
        url: '',
        icons: [''],
      ),
    );

    connector.on('connect', (SessionStatus session) {
      print("Connected.");
      print("Address : ${session.accounts}");
      print("ChainId : ${session.chainId}");
    });

    connector.on('session_request', (payload) async {
      print(payload);
      final borrowerAddress = state.loginAddress;
      final address = await _getContractWalletAddress(borrowerAddress);
      await connector.approveSession(chainId: 5, accounts: [address]);
    });

    connector.on('session_update', (payload) async {
      print('session_update');
      print(payload);
    });

    connector.on('personal_sign', (payload) async {
      print('personal_sign');
      print(payload);
      try {
        final jsonRpcRequest = payload as JsonRpcRequest;
        Map<String, dynamic> json = jsonRpcRequest.toJson();
        final id = json["id"] as int;
        String message = json["params"][0] as String;
        message = String.fromCharCodes(hexToBytes(message));
        String signedMessage = await provider!.getSigner().signMessage(message);
        await connector.sendCustomResponse(id: id, result: signedMessage);
      } catch (ex) {
        print(ex);
      }
    });

    connector.on('wallet_switch_ethereum_chain', (payload) async {
      print('wallet_switch_ethereum_chain');
      print(payload);
    });

    connector.on('switch_ethereum_chain', (payload) async {
      print('switch_ethereum_chain');
      print(payload);
    });

    connector.on('disconnect', (session) {
      print("Disconnected. $session");
    });
    return true;
  }

  Future<String> _getContractWalletAddress(String borrowerAddress) async {
    final web3provider = Web3Provider(ethereum!);
    const leaseContractAddress = AppConst.leaseServiceContractAddress;
    final contract = Contract(
      leaseContractAddress,
      Interface(leaseServiceAbi),
      web3provider,
    );
    try {
      return await contract.call<String>(
        'leaseVaultOf',
        [
          borrowerAddress,
        ],
      );
    } catch (ex) {
      print(borrowerAddress);
      print("failed. ${ex.toString()}");
      return "";
    }
  }

  Future<String> getApproved(String nftContractAddress, String tokenId) async {
    final nftContract = Contract(
      nftContractAddress,
      Interface(erc721jsonAbi),
      provider,
    );

    try {
      return await nftContract.call(
        'getApproved',
        [tokenId],
      );
    } catch (ex) {
      print("Fail to getApproved. ${ex.toString()}");
      return "0x0000000000000000000000000000000000000000";
    }
  }

  Future<bool> approve(String nftContractAddress, String tokenId) async {
    final nftContract = Contract(
      nftContractAddress,
      Interface(erc721jsonAbi),
      provider!.getSigner(),
    );

    try {
      TransactionResponse tx = await nftContract.send(
        'approve',
        [AppConst.leaseServiceContractAddress, tokenId],
      );
      print(
          "TxHash: ${tx.hash}, NFT Contract Address : $nftContractAddress, Token ID : $tokenId,");
    } catch (ex) {
      print("Fail to offer. ${ex.toString()}");
      return false;
    }
    return true;
  }
}
