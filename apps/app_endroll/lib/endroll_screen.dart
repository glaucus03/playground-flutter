import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EndrollScreen extends StatefulWidget {
  const EndrollScreen({super.key});

  @override
  _EndrollScreenState createState() => _EndrollScreenState();
}

class _EndrollScreenState extends State<EndrollScreen> {
  String credits = ""; // ファイルから読み込んだテキスト
  late ScrollController _scrollController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadCredits();
  }

  // テキストファイルの読み込み
  Future<void> _loadCredits() async {
    final text = await rootBundle.loadString('assets/credits.txt');
    setState(() {
      credits = text;
    });

    // アニメーション開始
    _startScrolling();
  }

  // スクロールアニメーション
  void _startScrolling() {
    const scrollDuration = Duration(seconds: 15); // アニメーションの長さ
    const fps = 60;
    final interval = scrollDuration.inMilliseconds ~/ fps;

    _timer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (_scrollController.offset >= _scrollController.position.maxScrollExtent) {
        timer.cancel();
      } else {
        _scrollController.jumpTo(
          _scrollController.offset + _scrollController.position.maxScrollExtent / (scrollDuration.inMilliseconds / interval),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Endroll")),
      body: credits.isEmpty
          ? const Center(child: CircularProgressIndicator()) // 読み込み中
          : Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black, Colors.transparent, Colors.black],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  controller: _scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      credits,
                      style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
