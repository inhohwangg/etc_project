import 'dart:io';
import 'dart:typed_data';
import 'package:Youtube_Stop/pages/gemini/gemini-pg.dart';
import 'package:Youtube_Stop/util/g_print.dart';
import 'package:image/image.dart' as img;  // 이미지 처리 라이브러리 추가
import 'package:flutter/widgets.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class GeminiPageController extends GetxController {
  final gemini = Gemini.instance;
  TextEditingController message = TextEditingController();
  var messages = <String>[].obs;
  final ImagePicker picker = ImagePicker();
  RxBool loading = false.obs;
  RxString detectedText = ''.obs;

  sendMessage() {
    if (message.text.isNotEmpty) {
      final userMessage = message.text;
      messages.add("You: $userMessage");
      gemini.streamGenerateContent(userMessage).listen((event) {
        messages.add("Gemini: ${event.output}");
      }).onError((e) {
        messages.add("Error: $e");
      });
      message.clear();
    }
  }

  void pictureCamera(context) async {
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      Get.to(() => DisplayPictureScreen(imagePath: image.path));
    }
  }

  // 이미지 전처리 함수 추가
  Future<Uint8List> preprocessImage(String imagePath) async {
    final image = img.decodeImage(await File(imagePath).readAsBytes())!;
    final resized = img.copyResize(image, width: 800);  // 이미지 크기 조정
    final grayscale = img.grayscale(resized);  // 흑백 변환
    return Uint8List.fromList(img.encodeJpg(grayscale));
  }

  void processImage(String imagePath) async {
    try {
      loading.value = true;
      messages.clear();
      final Uint8List imageBytes = await preprocessImage(imagePath);

      // 첫 번째 질문: LCD 패널을 찾기
      final String firstQuestion = "Locate the LCD panel in the image.";
      final firstResult = await gemini.textAndImage(
        text: firstQuestion,
        images: [imageBytes],
      );

      final lcdPanelCoordinates = firstResult?.output ?? "LCD 패널을 찾을 수 없습니다.";

      if (lcdPanelCoordinates == "LCD 패널을 찾을 수 없습니다.") {
        messages.add(lcdPanelCoordinates);
        loading.value = false;
        return;
      }

      // 두 번째 질문: 찾은 LCD 패널 안의 숫자를 인식하기
      final String secondQuestion = "Recognize only the values inside the LCD panel you find. Tell me all the numbers in the LCD panel";
      final secondResult = await gemini.textAndImage(
        text: secondQuestion,
        images: [imageBytes],
      );

      final lcdText = secondResult?.output ?? "LCD 패널 안의 숫자를 인식할 수 없습니다.";
      messages.add('Detected LCD Text: $lcdText');
      detectedText.value = lcdText;
      loading.value = false;
    } catch (e) {
      printRed('processImage Error Message: $e');
      messages.add("Error: $e");
      loading.value = false;
    }
  }

  void confirmText() {
    messages.add('Confirmed Text: ${detectedText.value}');
  }

  void retryProcess(String imagePath) {
    final String falseResultQuestion = "Please don't keep saying the same thing over and over again, the picture doesn't show the numbers inside the LCD panel, please check and get back to me.";
    processImage(imagePath);
  }
}
