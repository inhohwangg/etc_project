// import 'package:etc_test_project/controller/gemini/gemini-pg-ctl.dart';
// import 'package:etc_test_project/util/g_print.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:babylonjs_viewer/babylonjs_viewer.dart';
// import 'package:sentry_flutter/sentry_flutter.dart';

// class GeminiHomePage extends StatefulWidget {
//   const GeminiHomePage({super.key});

//   @override
//   State<GeminiHomePage> createState() => _GeminiHomePageState();
// }

// class _GeminiHomePageState extends State<GeminiHomePage> {

//   @override
//   Widget build(BuildContext context) {
//   GeminiPageController controller = Get.put(GeminiPageController());
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     controller.pickImage(ImageSource.camera);
//                   },
//                   child: Text('사진 촬영'),
//                 ),
//                 SizedBox(width: 20),
//                 ElevatedButton(
//                   onPressed: () {
//                     controller.pickImage(ImageSource.gallery);
//                   },
//                   child: Text('앨범 선택'),
//                 ),
//               ],
//             ),
//             Obx(() {
//               return controller.loading.value
//                   ? CircularProgressIndicator()
//                   : controller.modelData.isNotEmpty
//                       ? ElevatedButton(
//                           onPressed: () {
//                             Get.to(ModelViewerPage(controller.modelData.value));
//                           },
//                           child: Text('3D 모델 보기'),
//                         )
//                       : Container();
//             }),
//             GestureDetector(
//               onTap: () async {
//                 try {
//                   printYellow('work!');
//                   throw Error();
//                   // aMethodThatMightFail();
//                 } catch (exception, stackTrace) {
//                   await Sentry.captureException(
//                     exception,
//                     stackTrace: stackTrace,
//                   );
//                 }
//               },
//               child: Text(
//                 'setry Test',
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   aMethodThatMightFail() {
//     printYellow('click work');
//     throw Error();
//     print('now work');
//   }
// }

// class ModelViewerPage extends StatelessWidget {
//   final String modelData;

//   ModelViewerPage(this.modelData);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('3D 모델 보기')),
//       body: Center(
//         child: BabylonJSViewer(src: modelData),
//       ),
//     );
//   }
// }
