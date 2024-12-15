
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EndrollScreen extends StatefulWidget {
  const EndrollScreen({super.key});

  @override
  _EndrollScreenState createState() => _EndrollScreenState();
}

   
class _EndrollScreenState extends State<EndrollScreen> with SingleTickerProviderStateMixin {
  String credits = ""; // ファイルから読み込むテキスト
  late AnimationController _animationController;
  late Animation<double> _animation;
  late ScrollController _scrollController;
  double _scrollHeight = 0; // 全体の高さ
  double _screenHeight = 0; // 画面の高さ

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

    // ウィジェットのレンダリング完了後にスクロールアニメーションを開始
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimation();
    });
  }

  // アニメーションの設定と開始
  void _startAnimation() {
    _screenHeight = MediaQuery.of(context).size.height;

    // 全体のスクロール高さを取得
    setState(() {
         
      _scrollHeight = _scrollController.position.maxScrollExtent + _screenHeight;
    });

    // AnimationControllerの初期化
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15), // アニメーションの総時間
    );

    // Tweenでスクロール位置を設定
    _animation = Tween<double>(begin: 0.0, end:_scrollController.position.maxScrollExtent ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear, // なめらかにスクロールするカーブ
    ));

    // アニメーションの値をScrollControllerに反映
    _animation.addListener(() {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_animation.value);
      }
    });

    // アニメーション終了時の動作
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // アニメーション終了時にスクロール位置を固定
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      }
    });

    // アニメーション開始
    _animationController.forward();
  }

  // アニメーションをリセットして再生
  void _restartAnimation() {
    _animationController.reset(); // 最初の状態に戻す
    _animationController.forward(); // 再度アニメーション開始
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
      appBar: AppBar(title: const Text("Smooth Endroll")),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _restartAnimation, // ボタンが押されたときの動作
        child: const Icon(Icons.refresh), // 再生マークとしてリフレッシュアイコンを使用
        tooltip: "Restart Animation", // ツールチップ（ボタンの説明）
      ),
    );
  }
}
