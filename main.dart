import 'package:flutter/material.dart';
import 'camera_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UART Visual Decoder',
      home:
          CameraScreen(), // This tells flutter where our actual homepage widget is (inside camera_screen.dart)
    );
  }
}
