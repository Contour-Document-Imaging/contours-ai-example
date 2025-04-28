import 'package:contouraisdk/contouraisdk_contours_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:contouraisdk/contouraisdk.dart';
import 'dart:io';

class ScanPassport extends StatefulWidget {
  const ScanPassport({super.key});

  @override
  State<ScanPassport> createState() => _ScanPassportState();
}

class _ScanPassportState extends State<ScanPassport> {
  String frontImageUri = '';

  @override
  void initState() {
    super.initState();
    Contouraisdk.registerCallbacks(onDataReceived, onEventCaptured, onContourClosed);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> callContour(String face) async {
    try {
      var contoursModel = ContoursModel(clientID: "<CLIENT_ID>", type: "passport", captureSide: face, captureType: "both", enableMultipleCapturing: false);
      await Contouraisdk.startContour(contoursModel);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void onDataReceived(Map<String, String> data) {
    String? croppedFront = data['croppedFrontUri'];
    if (croppedFront != null) {
      setState(() {
        frontImageUri = data['croppedFrontUri']!;
      });
    }
  }

  void onEventCaptured(String data) {
    print('Received data in onEventCaptured: $data');
  }

  void onContourClosed() {
    print('Received data in onContourClosed');
  }

  Widget _buildImageWidget(
      String uri, double width, double height, String face) {
    if (uri.isNotEmpty) {
      return GestureDetector(
        onTap: () {
          callContour(face);
        }, // Define the click handler function
        child: Image.file(
          File(uri),
          width: width,
          height: height,
        ),
      );
    } else {
      return GestureDetector(
        onTap: () {
          callContour(face);
        },
        child: Image.asset(
          'assets/placeholder.png',
          width: width,
          height: height,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Center(
              child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          const SizedBox(height: 24),
          const Text("Front",
              style: TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 16),
          _buildImageWidget(frontImageUri, 400, 200, 'front'),
        ],
      ))),
    );
  }
}
