import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EndrollDynamicScreen extends StatefulWidget {
  const EndrollDynamicScreen({super.key});

  @override
  _EndrollDynamicScreenState createState() => _EndrollDynamicScreenState();
}

class _EndrollDynamicScreenState extends State<EndrollDynamicScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> _lines = []; // 表示するテキストのリスト
  final int _chunkSize = 100; // 1回のチャンクの行数
  int _currentChunk = 0; // 現在のチャンクインデックス
  late List<String> _allLines; // 全行（逐次読み込み用）
  bool _isLoading = false; // 読み込み中フラグ
  double _scrollHeight = 0; // 全体の高さ

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // デフォルトのアニメーション時間
    );
    _animationController.addListener(_animateScroll);
    _scrollController.addListener(_loadMoreChunks);
    _loadInitialChunk();
  }

  // 初期チャンクを読み込む
  Future<void> _loadInitialChunk() async {
    _allLines = await _loadTextLines();
    _loadNextChunk();
  }

  // assets/texts/credits.txt を行単位で読み込む
  Future<List<String>> _loadTextLines() async {
    final text = await rootBundle.loadString('assets/credits.txt');
    return LineSplitter.split(text).toList(); // 行ごとに分割
  }

  // 次のチャンクを読み込む
  void _loadNextChunk() {
    if (_isLoading || _currentChunk * _chunkSize >= _allLines.length) return;

    setState(() {
      _isLoading = true;
    });

    // 現在のチャンクから次のチャンクをリストに追加
    final start = _currentChunk * _chunkSize;
    final end = (_currentChunk + 1) * _chunkSize;
    final nextChunk = _allLines.sublist(
        start, end > _allLines.length ? _allLines.length : end);

    setState(() {
      _lines.addAll(nextChunk);
      _currentChunk++;
      _isLoading = false;
      _updateScrollHeight();
    });
  }

  // スクロール範囲を更新
  void _updateScrollHeight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        setState(() {
          _scrollHeight = _scrollController.position.maxScrollExtent;
        });
      }
    });
  }

  // スクロールアニメーション
  void _animateScroll() {
    if (_scrollController.hasClients) {
      final position = _animation.value;
      if (position <= _scrollHeight) {
        _scrollController.jumpTo(position);
      } else {
        _animationController.stop();
      }
    }
  }

  // アニメーションをリセットして再生
  void _restartAnimation() {
    _animationController.reset();
    _animation = Tween<double>(
      begin: 0.0,
      end: _scrollHeight,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );
    _animationController.forward();
  }

  // スクロールが下部に近づいた際のチャンク読み込み
  void _loadMoreChunks() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading) {
      _loadNextChunk();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dynamic Endroll")),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: _lines.length + 1,
            itemBuilder: (context, index) {
              if (index < _lines.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 16.0),
                  child: Text(
                    _lines[index],
                    style: const TextStyle(
                        fontSize: 18, color: Colors.white, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                );
              } else {
                return _isLoading
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : const SizedBox.shrink();
              }
            },
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _restartAnimation,
        child: const Icon(Icons.refresh),
        tooltip: "Restart Animation",
      ),
    );
  }
}
