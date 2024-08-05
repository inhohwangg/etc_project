import 'dart:io';
import 'dart:typed_data';

import 'package:Youtube_Stop/controller/gemini/gemini-pg-ctl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

//AIzaSyBDM-IIo_Ch1TX13mN4dlfgSzVtzY5ZCSE

class GeminiPage extends GetView {
  GeminiPage({super.key});

  @override
  Widget build(BuildContext context) {
    GeminiPageController controller = Get.put(GeminiPageController());
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Obx(() {
                return ListView.builder(
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(controller.messages[index]),
                    );
                  },
                );
              }),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      controller: controller.message,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // showModalBottomSheet(
                      //   context: context,
                      //   builder: (context) {
                      //     return SizedBox(
                      //       height: 100,
                      //       child: Center(
                      //         child: Column(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             Row(
                      //               mainAxisAlignment: MainAxisAlignment.spaceAround,
                      //               children: [
                      //                 GestureDetector(
                      //                   onTap: () {

                      //                   },
                      //                   child: Container(
                      //                     padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      //                     decoration: BoxDecoration(
                      //                       color: Colors.blue[200],
                      //                       borderRadius: BorderRadius.circular(15)
                      //                     ),
                      //                     child: Center(
                      //                       child: Column(
                      //                         children: [
                      //                           Icon(Icons.photo_camera,color: Colors.white,),
                      //                           Text('사진 촬영',style: TextStyle(color: Colors.white),)
                      //                         ],
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //                 Container(
                      //                   padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                      //                   decoration: BoxDecoration(
                      //                     color: Colors.blue[200],
                      //                     borderRadius: BorderRadius.circular(15)
                      //                   ),
                      //                   child: Center(
                      //                     child: Column(
                      //                       children: [
                      //                         Icon(Icons.photo_library,color: Colors.white,),
                      //                         Text('앨범 선택',style: TextStyle(color: Colors.white),)
                      //                       ],
                      //                     ),
                      //                   ),
                      //                 ),
                      //               ],
                      //             )
                      //           ],
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // );
                      controller.pictureCamera(context);
                    },
                    icon: Icon(
                      Icons.add_box,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      controller.sendMessage();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final GeminiPageController controller = Get.put(GeminiPageController());

  DisplayPictureScreen({required this.imagePath, Uint8List? annotatedImage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display Picture')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 450,
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Image.file(
              File(imagePath),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              controller.processImage(imagePath);
            },
            child: Text('Process Image'),
          ),
          Obx(() {
            if (controller.loading.value) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (controller.detectedText.isNotEmpty) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Text('Detected LCD Text: ${controller.detectedText.value}'),
                    Text('값이 맞습니까?'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            controller.confirmText();
                          },
                          child: Text('확인'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            controller.retryProcess(imagePath);
                          },
                          child: Text('취소'),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return Container();
            }
          }),
        ],
      ),
    );
  }
}

