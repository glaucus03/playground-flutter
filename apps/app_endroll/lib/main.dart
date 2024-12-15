import 'package:flutter/material.dart';
import 'endroll_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Endroll App',
      theme: ThemeData.dark(),
      home: const EndrollScreen(),
    );
  }
}
