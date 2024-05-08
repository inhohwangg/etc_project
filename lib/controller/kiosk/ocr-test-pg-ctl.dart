import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class OcrTestPageController extends GetxController {
  RxString extractedText = ''.obs;
  RxBool isLoading = true.obs;
  final picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
  }

  extractText() async {
    extractedText.value = '';
    
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    isLoading.value = false;
    if (pickedFile != null) {
      String text = await FlutterTesseractOcr.extractText(pickedFile.path, language: 'eng');
      extractedText.value = text;
      isLoading.value = true;
    }
  }

  extractImage()async {
    extractedText.value = '';

    final imagePic = await picker.pickImage(source: ImageSource.gallery);
    isLoading.value = false;
    if (imagePic != null) {
      String text = await FlutterTesseractOcr.extractText(imagePic.path, language: 'eng');
      extractedText.value = text;
      isLoading.value = true;
    }
  }
}