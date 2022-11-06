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

  Future<int> _convertDueDateToBlockNumber(DateTime dueDate) async {
    DateTime now = DateTime.now();
    DateTime fromDate = DateTime(now.year, now.month, now.day, 0, 0, 0, 0);
    DateTime toDate =
        DateTime(dueDate.year, dueDate.month, dueDate.day, 0, 0, 0, 0);
    int diffBlocks = dueDate.difference(fromDate).inSeconds ~/ 15;
    int fromBlockNumber = await provider!.getBlockNumber();
    return fromBlockNumber + diffBlocks;
  }

  Future<bool> approve(String nftContractAddress, String tokenId) async {
    return true;
  }

  Future<bool> offerToLend(String nftContractAddress, String tokenId,
      DateTime dueDate, double rentalFee) async {
    final leaseContract = Contract(
      "0x61739f5ee253a554FeC6c727611c17DD9A24a3f7",
      Interface(jsonAbi),
      provider!.getSigner(),
    );

    int toBlockNumber = await _convertDueDateToBlockNumber(dueDate);
    BigInt rentalFeeWei = EthUtils.parseEther(rentalFee.toString()).toBigInt;
    try {
      TransactionResponse tx = await leaseContract.send(
        'offerLending',
        [nftContractAddress, tokenId, rentalFeeWei, toBlockNumber],
      );
      print(
          "TxHash: ${tx.hash}, NFT Contract Address : $nftContractAddress, Token ID : $tokenId,"
          " Rental Fee : $rentalFeeWei, Until : $toBlockNumber");
    } catch (ex) {
      print("Fail to offer. ${ex.toString()}");
      return false;
    }
    return true;
  }

  Future<bool> borrow(
      String nftContractAddress, String tokenId, DateTime dueDate) async {
    final leaseContract = Contract(
      "0x61739f5ee253a554FeC6c727611c17DD9A24a3f7",
      Interface(jsonAbi),
      provider!.getSigner(),
    );

    int toBlockNumber = await _convertDueDateToBlockNumber(dueDate);
    BigInt returnFeeWei = EthUtils.parseEther("0.005").toBigInt;
    try {
      TransactionResponse tx = await leaseContract.send(
        'borrow',
        [nftContractAddress, tokenId, toBlockNumber],
        TransactionOverride(value: returnFeeWei),
      );
      print(
          "TxHash: ${tx.hash}, Contract Address : $nftContractAddress, Token ID : $tokenId,"
          " Until : $toBlockNumber");
    } catch (ex) {
      print("Fail to offer. ${ex.toString()}");
      return false;
    }
    return true;
  }
}

const jsonAbi = '''[
    {
      "inputs": [],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "lender",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "collection",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "address",
          "name": "borrower",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "payment",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "expiration",
          "type": "uint256"
        }
      ],
      "name": "Lease",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "collection",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "price",
          "type": "uint256"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "until",
          "type": "uint256"
        }
      ],
      "name": "Offer",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": false,
          "internalType": "address",
          "name": "collection",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "OfferCanceled",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "previousOwner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "OwnershipTransferred",
      "type": "event"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "borrowCollection",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "period",
          "type": "uint256"
        }
      ],
      "name": "borrow",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "lendingCollection",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "cancelOffer",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "eoa",
          "type": "address"
        }
      ],
      "name": "leaseVaultOf",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "lendingCollection",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "price",
          "type": "uint256"
        },
        {
          "internalType": "uint256",
          "name": "until",
          "type": "uint256"
        }
      ],
      "name": "offerLending",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "owner",
      "outputs": [
        {
          "internalType": "address",
          "name": "",
          "type": "address"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "renounceOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "returnCollection",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "returnAsset",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "returnCollection",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "returnAssetBeforeExpiration",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "newOwner",
          "type": "address"
        }
      ],
      "name": "transferOwnership",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        }
      ],
      "name": "withdraw",
      "outputs": [],
      "stateMutability": "payable",
      "type": "function"
    }
  ]''';
