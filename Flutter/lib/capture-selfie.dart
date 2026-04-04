import 'package:contouraisdk/contouraisdk_contours_model.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:contouraisdk/contouraisdk.dart';
import 'dart:io';

class Selfie extends StatefulWidget {
  const Selfie({super.key});

  @override
  State<Selfie> createState() => _SelfieState();
}

class _SelfieState extends State<Selfie> {
  String frontImageUri = '';

  @override
  void initState() {
    super.initState();
    Contouraisdk.registerCallbacks(null, onEventCaptured, onContourClosed, onSelfieCaptured);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> callContour(String face) async {
    try {
      var contoursModel = ContoursModel(clientID: "<CLIENT_ID>", type: "Selfie", captureSide: face, captureType: "both", enableMultipleCapturing: false);
      await Contouraisdk.startContour(contoursModel);
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  void onEventCaptured(String data) {
    print('Received data in onEventCaptured: $data');
  }

  void onContourClosed() {
    print('Received data in onContourClosed');
  }

  void onSelfieCaptured(String? capturedSelfie) {
    print('Received data in onSelfieCaptured: $capturedSelfie');
    if (capturedSelfie != null) {
      setState(() {
        frontImageUri = capturedSelfie;
      });
    }
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
          const Text("Selfie",
              style: TextStyle(fontSize: 16, color: Colors.black87)),
          const SizedBox(height: 16),
          _buildImageWidget(frontImageUri, 400, 200, 'front'),
        ],
      ))),
    );
  }
}
