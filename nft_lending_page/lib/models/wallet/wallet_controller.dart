import 'package:flutter_web3/ethereum.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'wallet_state.dart';

class WalletController extends StateNotifier<WalletState> {
  WalletController() : super(const WalletState());

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
        await provider!.getSigner().signMessage("Login to NFT Fi");

    //TODO 署名の検証

    //Login成功
    state = state.copyWith(loginAddress: selectedAddress);

    return true;
  }

  Future<bool> connectDapps() async {
    // TODO: Dappsへ接続する処理を記述
    return true;
  }

  Future<bool> lend(String contractAddress, String tokenId, DateTime dueDate,
      double rentalFee, double returnFee) async {
    contractAddress = '0x751A28264d7cC0fc3f7Db0936d08e094E616c3B7';

    final contract = Contract(
      contractAddress,
      Interface(""),
      provider!.getSigner(),
    );

    String contractWalletAddress = await contract.call<String>(
      'leaseVaultOf',
      [state.loginAddress],
    ); // 2886780594123782414119
    print("Contract Wallet Address : $contractWalletAddress");

    return true;
  }
}
