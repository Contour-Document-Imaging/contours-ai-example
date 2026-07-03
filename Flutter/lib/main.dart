import 'package:contour_ai_sdk/scannerConfig.dart';
import 'package:contour_ai_sdk/view.dart';
import 'package:contouraisdk/contouraisdk.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Contouraisdk.initialize(contourClientId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const DocumentScannerScreen(),
    );
  }
}
