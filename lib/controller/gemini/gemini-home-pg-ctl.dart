// import 'dart:io';
// import 'dart:typed_data';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import 'gemini-pg-ctl.dart';

// class DisplayPictureScreen extends StatelessWidget {
//   final String imagePath;
//   final Uint8List? annotatedImage;

//   DisplayPictureScreen({required this.imagePath, this.annotatedImage});

//   @override
//   Widget build(BuildContext context) {
//     final GeminiPageController controller = Get.find();

//     return Scaffold(
//       appBar: AppBar(title: Text('Display Picture')),
//       body: Column(
//         children: [
//           if (annotatedImage != null)
//             Image.memory(annotatedImage!),
//           if (annotatedImage == null)
//             Image.file(File(imagePath)),
//           ElevatedButton(
//             onPressed: () => controller.processImage(),
//             child: Text('Process Image'),
//           ),
//           Obx(() => Text('Detected LCD Text: ${controller.detectedText.value}')),
//           ElevatedButton(
//             onPressed: () => controller.confirmText(),
//             child: Text('확인'),
//           ),
//           ElevatedButton(
//             onPressed: () => Get.back(),
//             child: Text('취소'),
//           ),
//         ],
//       ),
//     );
//   }
// }
