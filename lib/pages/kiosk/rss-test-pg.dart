import 'package:Youtube_Stop/controller/kiosk/rss-test-pg-ctl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RssTestPage extends GetView<RssTestPageController> {
  RssTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RssTestPageController controller = Get.put(RssTestPageController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Rss Test Page'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.isTrue) {
          return Center(child: CircularProgressIndicator()); // 로딩 중 인디케이터 추가
        } else {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        controller.isLoading.value = true;
                        if (controller.selectedIndex.value == 0) {
                          controller.selectedIndex.value = 1;
                          controller.restoreOriginalData();
                          controller.isLoading.value = false;
                          controller.dataList.refresh();
                        } else if (controller.selectedIndex.value == 2) {
                          controller.selectedIndex.value = 1;
                          controller.restoreOriginalData();
                          controller.isLoading.value = false;
                          controller.dataList.refresh();
                        } else if (controller.selectedIndex.value == 1) {
                          controller.selectedIndex.value = 0;
                          controller.restoreOriginalData();
                          controller.isLoading.value = false;
                          controller.dataList.refresh();
                        }
                        controller.isLoading.value = false;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: controller.selectedIndex.value == 1 ? Colors.red[100]!.withOpacity(0.7) : Colors.grey[200],
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5))),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Center(
                          child: Text(
                            '한국어',
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        controller.isLoading.value = true;
                        if (controller.selectedIndex.value == 0) {
                          controller.selectedIndex.value = 2;
                          await Future.forEach(controller.dataList, (RssItem item) async {
                            await controller.translateText(item, 'en');
                          });
                        } else if (controller.selectedIndex.value == 1) {
                          controller.selectedIndex.value = 2;
                          await Future.forEach(controller.dataList, (RssItem item) async {
                            await controller.translateText(item, 'en');
                          });
                        } else if (controller.selectedIndex.value == 2) {
                          controller.selectedIndex.value = 0;
                          controller.restoreOriginalData();
                          controller.isLoading.value = false;
                          controller.dataList.refresh();
                        }
                        controller.isLoading.value = false;
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: controller.selectedIndex.value == 2 ? Colors.blue[100] : Colors.grey[200],
                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(5), topRight: Radius.circular(5))),
                        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                        child: Center(
                          child: Text(
                            '영어',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                !controller.isLoading.value
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: controller.dataList.length,
                          itemBuilder: (context, index) {
                            var item = controller.dataList[index];
                            return Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.blue[100]!.withOpacity(0.2),
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                margin: EdgeInsets.only(top: 10),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(vertical: 10),
                                      child: Text(
                                        item.title, // '.value'가 필요 없습니다.
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text(item.description),
                                    Text(item.link),
                                  ],
                                ));
                          },
                        ),
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
              ],
            ),
          );
        }
      }),
    );
  }
}
