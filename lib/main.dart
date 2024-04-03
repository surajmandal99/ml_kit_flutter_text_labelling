import 'package:flutter/material.dart';
import 'package:ml_kit_flutter_text_labelling/text_labelling.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TextLabelling(),
    );
  }
}
