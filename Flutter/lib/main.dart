import 'package:contour_ai_sdk/scan-check.dart';
import 'package:contour_ai_sdk/scan-id.dart';
import 'package:contour_ai_sdk/scan-passport.dart';
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
  String frontImageUri = '';
  String rearImageUri = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Contour Demo'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Check'),
                Tab(text: 'ID'),
                Tab(text: 'Passport'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              Center(child: ScanCheck()),
              Center(child: ScanID()),
              Center(child: ScanPassport()),
            ],
          ),
        ),
      ),
    );
  }
}
