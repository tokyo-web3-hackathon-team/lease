## 処理シーケンス

### NFT 貸し出し申請

```mermaid
sequenceDiagram
  actor Lender
  participant Browser
  participant Wallet as Wallet(MetaMask)
  participant WebUI as Web UI(Github Pages)
  participant LeaseContract
  participant NFTContract as NFT Contract

  Lender ->> Browser: ;
  Browser ->> WebUI: ;
  WebUI --> Browser: 貸し出し登録画面
  Browser ->> Wallet: WalletConnect
  Wallet --> Browser: ;
  Browser --> Lender: ;
  Lender ->> Browser: 貸し出し条件入力
  Browser ->> Browser: 貸し出し期間の保存（TODO 保存先）
  Browser ->> Wallet: 署名のリクエスト
  Lender ->> Wallet: 署名
  Wallet --> Browser: ;
  Browser ->> NFTContract: approve
  NFTContract --> Browser: ;
  Browser ->> Wallet: 署名（略）
  Wallet --> Browser: ;
  Browser ->> LeaseContract: offerLending実行
  LeaseContract --> Browser: ;
  Browser --> Lender: ;
```

### NFT 借り入れ

```mermaid
sequenceDiagram
  actor Borrower
  participant Browser
  participant Wallet as Wallet(MetaMask)
  participant WebUI as Web UI(Github Pages)
  participant LeaseContract
  participant ContractWallet
  participant NFTContract as NFT Contract

  Borrower ->> Browser: ;
  Browser ->> WebUI: ;
  WebUI --> Browser: NFT借り入れ画面
  Browser ->> Wallet: WalletConnect
  Wallet --> Browser: ;
  Browser --> Borrower: ;
  Borrower ->> Browser: 借り入れ対象NFTの選択
  Browser ->> Wallet: 署名（略）
  Wallet --> Browser: ;
  Browser ->> LeaseContract: borrow実行
  alt ContractWallet未デプロイ
    LeaseContract ->> ContractWallet: deploy borrower wallet
    ContractWallet --> LeaseContract: ;
  end
  LeaseContract ->> ContractWallet: 借り入れ情報の登録
  ContractWallet --> LeaseContract: ;
  LeaseContract ->> NFTContract: transfer実行（Lender Wallet -> Borrower Contract Wallet）
  NFTContract --> LeaseContract: ;
  LeaseContract ->> LeaseContract: Lenderアドレスに貸し出し料金の支払い
  LeaseContract --> Browser: ;
  Browser --> Borrower: ;
```

### 貸し出した NFT の回収

```mermaid
sequenceDiagram
  actor Lender
  participant Browser
  participant Wallet as Wallet(MetaMask)
  participant WebUI as Web UI(Github Pages)
  participant LeaseContract
  participant ContractWallet
  participant NFTContract as NFT Contract

  Lender ->> Browser: ;
  Browser ->> WebUI: ;
  WebUI --> Browser: NFT回収画面
  Browser ->> Wallet: WalletConnect
  Wallet --> Browser: ;
  Browser --> Lender: ;
  Lender ->> Browser: 回収対象NFTの選択
  Browser ->> Wallet: 署名（略）
  Wallet --> Browser: ;
  Browser ->> LeaseContract: returnNft実行
  LeaseContract ->> ContractWallet: transfer指示
  ContractWallet ->> NFTContract: transfer実行（Borrower Contract Wallet -> Lender Wallet）
  ContractWallet --> NFTContract: ;
  ContractWallet --> LeaseContract: ;
  LeaseContract --> Browser: ;
  Browser --> Lender: ;
```

### Lease Contract 概要

#### ファイル名： LeaseService.sol

#### メソッド一覧

- offerLending

  - input
    - lendingAddress: address（貸し出し対象 NFT のスマコンアドレスアドレス）
    - tokenId: uint256
    - price: uint256（貸し出し金額）
  - output
    - なし
  - バリデーション
    - msg.sender のアドレスが input の NFT を保有していない場合、エラー

- borrow
  - input
    - borrowAddress: address（借り入れ対象 NFT のスマコンアドレス）
    - tokenId: uint256
  - output
    - なし
  - バリデーション
    - msg.sender のあアドレスが借り入れ金額を保有していない場合、エラー
    - offerLending で登録した貸し出し者のアドレスが NFT を保有していない場合、エラー
  - returnNft
    - input
      - returnAddress: address（返却対象 NFT のスマコンアドレス）
      - tokenId: uint256
    - output
      - なし
    - バリデーション
      - 対象の NFT が借り入れ済み NFT でない場合、エラー
