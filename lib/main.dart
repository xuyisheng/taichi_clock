import 'package:flutter/material.dart';
import 'package:taichi_clock/taichi_clock.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Taichi Clock',
      home: Scaffold(
        body: ClockWidget(),
      ),
    );
  }
}
