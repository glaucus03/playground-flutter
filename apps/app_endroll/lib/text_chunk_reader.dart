import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';

class TextChunkReader {
  final String filePath; // ファイルパス
  final int chunkSize; // 1回に読み込むバイト数
  int _currentOffset = 0; // 現在の読み込み位置

  TextChunkReader(this.filePath, {this.chunkSize = 1024}); // デフォルトで1KB単位

  // 次のチャンクを非同期で読み込む
  Future<List<String>> readNextChunk() async {
    final ByteData byteData = await rootBundle.load(filePath);

    // ファイルの終端に達している場合、空リストを返す
    if (_currentOffset >= byteData.lengthInBytes) {
      return [];
    }

    // 読み込み範囲を計算
    final end = (_currentOffset + chunkSize > byteData.lengthInBytes)
        ? byteData.lengthInBytes
        : _currentOffset + chunkSize;

    // 現在のチャンクを取得
    final chunk = byteData.buffer.asUint8List(_currentOffset, end - _currentOffset);

    // チャンクを文字列として処理
    final text = utf8.decode(chunk);

    // 行ごとに分割してリストを生成
    final lines = LineSplitter.split(text).toList();

    // 読み込み位置を更新
    _currentOffset = end;

    return lines;
  }

  // 全体が読み終わったか確認
  bool isEndOfFile(ByteData byteData) {
    return _currentOffset >= byteData.lengthInBytes;
  }
}
