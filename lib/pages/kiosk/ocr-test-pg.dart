import 'package:etc_test_project/controller/kiosk/ocr-test-pg-ctl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OcrTestPage extends GetView<OcrTestPageController> {
  OcrTestPage({super.key});

  @override
  Widget build(BuildContext context) {
    OcrTestPageController controller = Get.put(OcrTestPageController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Ocr Test Page'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      controller.extractText();
                    },
                    child: Text(
                      '사진 촬영하기',
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      controller.extractImage();
                    },
                    child: Text(
                      '앨범에서 가져오기',
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    '이미지 추출한 텍스트',
                  ),
                ),
              ),
              Obx(
                () => controller.isLoading.value
                    ? Text(
                        controller.extractedText.toString(),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
