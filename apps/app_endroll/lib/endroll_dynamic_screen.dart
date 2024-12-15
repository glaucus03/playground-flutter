import 'package:flutter/material.dart';
import 'text_chunk_reader.dart';

class EndrollDynamicScreen extends StatefulWidget {
  const EndrollDynamicScreen({super.key});

  @override
  _EndrollDynamicScreenState createState() => _EndrollDynamicScreenState();
}

class _EndrollDynamicScreenState extends State<EndrollDynamicScreen>
    with SingleTickerProviderStateMixin {
  final List<String> _lines = []; // 表示するテキストのリスト
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  late TextChunkReader _textChunkReader;
  bool _isLoading = false;
  bool _isAtEnd = false;

  @override
  void initState() {
    super.initState();
    _textChunkReader = TextChunkReader('assets/credits.txt', chunkSize: 1024);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _animationController.addListener(_animateScroll);
    _scrollController.addListener(_onScroll);
    _loadInitialChunk();
  }

  // 初期チャンクをロード
  Future<void> _loadInitialChunk() async {
    final chunk = await _textChunkReader.readNextChunk();
    setState(() {
      _lines.addAll(chunk);
    });

    _startAnimation();
  }

  // 次のチャンクをロード
  Future<void> _loadNextChunk() async {
    if (_isLoading || _isAtEnd) return;

    setState(() {
      _isLoading = true;
    });

    final chunk = await _textChunkReader.readNextChunk();

    if (chunk.isEmpty) {
      setState(() {
        _isAtEnd = true;
      });
    }

    setState(() {
      _lines.addAll(chunk);
      _isLoading = false;
    });
  }

  // アニメーションを開始
  void _startAnimation() {
    final maxExtent = _scrollController.position.maxScrollExtent;
    final endValue = maxExtent + _scrollController.position.viewportDimension;

    _animation = Tween<double>(begin: 0, end: endValue).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.linear),
    );

    _animationController.reset();
    _animationController.forward();
  }

  // アニメーションによるスクロール
  void _animateScroll() {
    if (_scrollController.hasClients) {
      final position = _animation.value;
      if (position <= _scrollController.position.maxScrollExtent) {
        _scrollController.jumpTo(position);
      } else {
        _animationController.stop();
      }
    }
  }

  // スクロールイベントで次のチャンクをロード
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isLoading) {
      _loadNextChunk();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
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
                  padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0),
                  child: Text(
                    _lines[index],
                    style: const TextStyle(fontSize: 18, color: Colors.white, height: 1.5),
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startAnimation,
        child: const Icon(Icons.refresh),
        tooltip: "Restart Animation",
      ),
    );
  }
}
