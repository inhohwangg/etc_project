import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class OcrDemoTestPage extends StatefulWidget {
  const OcrDemoTestPage({super.key});

  @override
  State<OcrDemoTestPage> createState() => _OcrDemoTestPageState();
}

class _OcrDemoTestPageState extends State<OcrDemoTestPage> {
  Future getImagePick() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    var bytes = await File(pickedFile.path).readAsBytes();
    String img64 = base64Encode(bytes);

    String url = 'https://api.ocr.space/parse/image';
    Map<String, dynamic> payload = {
      "base64Image": "data:image/jpg;base64,$img64",
      "language": "kor",
      "filetype": "image/jpg"  // MIME 타입을 사용해 보세요.
    };
    var header = {"apikey": 'K89332290388957'};

    var dio = Dio();
    dio.options.headers.addAll(header);
    try {
      var res = await dio.post(url, data: payload);
      print("Response data: ${res.data}");
    } catch (e) {
      print("Error sending OCR request: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            getImagePick();
          },
          child: Text('OCR Text'),
        ),
      ),
    );
  }
}
