import 'package:flutter/material.dart';

void main() {
  runApp(const NftLendingApp());
}

class NftLendingApp extends StatelessWidget {
  const NftLendingApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: 'NFT LENDING'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(title),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Center(child: Text("Account")),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'You have pushed the button this many times:',
            ),
          ],
        ),
      ),
    );
  }
}
