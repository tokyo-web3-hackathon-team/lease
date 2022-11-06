import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web3/ethereum.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nft_lending_page/constants.dart';
import 'package:nft_lending_page/data/abis.dart';
import 'package:walletconnect_dart/walletconnect_dart.dart';

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
    await provider!.getSigner().signMessage("Login to NFT Fi");

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
        name: 'NFT Fi',
        description: 'NFT Fi Wallet App',
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
      await connector.approveSession(
          chainId: 5, accounts: [address]);
    });

    connector.on('session_update', (payload) async {
      print('session_update');
      print(payload);
    });

    connector.on('personal_sign', (payload) async {
      print('personal_sign');
      print(payload);
      try {
        final a = payload as JsonRpcRequest;
        print(a.toJson());
        // 以下出力結果
        // {id: 1667733237761071, jsonrpc: 2.0, method: personal_sign, params: [0x57656c636f6d6520746f204f70656e536561210a0a436c69636b20746f207369676e20696e20616e642061636365707420746865204f70656e536561205465726d73206f6620536572766963653a2068747470733a2f2f6f70656e7365612e696f2f746f730a0a5468697320726571756573742077696c6c206e6f742074726967676572206120626c6f636b636861696e207472616e73616374696f6e206f7220636f737420616e792067617320666565732e0a0a596f75722061757468656e7469636174696f6e207374617475732077696c6c20726573657420616674657220323420686f7572732e0a0a57616c6c657420616464726573733a0a3078663035353063346531323166313865336438313831333731626530313131373864326565613464660a0a4e6f6e63653a0a35393634313339342d646531362d343863632d393333392d383836346635313562326335, 0xf0550c4e121f18e3d8181371be011178d2eea4df]}
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
          "TxHash: ${tx
              .hash}, NFT Contract Address : $nftContractAddress, Token ID : $tokenId,");
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

const erc721jsonAbi = '''[
    {
      "inputs": [
        {
          "internalType": "string",
          "name": "name",
          "type": "string"
        },
        {
          "internalType": "string",
          "name": "symbol",
          "type": "string"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "constructor"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "approved",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "Approval",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "owner",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "operator",
          "type": "address"
        },
        {
          "indexed": false,
          "internalType": "bool",
          "name": "approved",
          "type": "bool"
        }
      ],
      "name": "ApprovalForAll",
      "type": "event"
    },
    {
      "anonymous": false,
      "inputs": [
        {
          "indexed": true,
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "indexed": true,
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "Transfer",
      "type": "event"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "approve",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "owner",
          "type": "address"
        }
      ],
      "name": "balanceOf",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "getApproved",
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
          "name": "owner",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "operator",
          "type": "address"
        }
      ],
      "name": "isApprovedForAll",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "string",
          "name": "tokenURI",
          "type": "string"
        }
      ],
      "name": "mint",
      "outputs": [
        {
          "internalType": "uint256",
          "name": "",
          "type": "uint256"
        }
      ],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "name",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "ownerOf",
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
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "safeTransferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        },
        {
          "internalType": "bytes",
          "name": "data",
          "type": "bytes"
        }
      ],
      "name": "safeTransferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "operator",
          "type": "address"
        },
        {
          "internalType": "bool",
          "name": "approved",
          "type": "bool"
        }
      ],
      "name": "setApprovalForAll",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "bytes4",
          "name": "interfaceId",
          "type": "bytes4"
        }
      ],
      "name": "supportsInterface",
      "outputs": [
        {
          "internalType": "bool",
          "name": "",
          "type": "bool"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [],
      "name": "symbol",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "tokenURI",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string"
        }
      ],
      "stateMutability": "view",
      "type": "function"
    },
    {
      "inputs": [
        {
          "internalType": "address",
          "name": "from",
          "type": "address"
        },
        {
          "internalType": "address",
          "name": "to",
          "type": "address"
        },
        {
          "internalType": "uint256",
          "name": "tokenId",
          "type": "uint256"
        }
      ],
      "name": "transferFrom",
      "outputs": [],
      "stateMutability": "nonpayable",
      "type": "function"
    }
  ]''';
