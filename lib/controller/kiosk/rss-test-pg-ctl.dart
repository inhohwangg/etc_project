import 'package:etc_test_project/util/g_dio.dart';
import 'package:etc_test_project/util/g_print.dart';
import 'package:get/get.dart';
import 'package:translator/translator.dart';
import 'package:xml/xml.dart' as xml;

class RssTestPageController extends GetxController {
  RxList<RssItem> dataList = <RssItem>[].obs;
  RxInt selectedIndex = 1.obs;
  RxBool isLoading = false.obs;
  final translator = GoogleTranslator();

  @override
  void onInit() {
    super.onInit();
    getRssData();
  }

  void getRssData() async {
    isLoading.value = true;
    try {
      var response = await dio.get(
        'https://www.ui4u.go.kr/portal/rssservice/RssServiceDetail.do?rssId=10000000000000000001',
      );
      var document = xml.XmlDocument.parse(response.data);
      var items = document.findAllElements('item').map((node) => RssItem.fromXml(node)).toList();
      dataList.value = items;
      for (var item in items) {
        item.originalTitle = item.title;
        item.originalDescription = item.description;
      }
    } catch (e) {
      printRed('Error fetching RSS data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void restoreOriginalData() {
    for (var item in dataList) {
      item.title = item.originalTitle ?? item.title;
      item.description = item.originalDescription ?? item.description;
    }
    dataList.refresh();
  }

  Future<void> translateText(RssItem item, String targetLang) async {
    isLoading.value = true; 
    try {
      // 제목 번역
      var titleTranslation = await translator.translate(item.title, to: targetLang);
      item.title = titleTranslation.text; // 번역된 제목으로 업데이트

      // 설명 번역
      var descriptionTranslation = await translator.translate(item.description, to: targetLang);
      item.description = descriptionTranslation.text; // 번역된 설명으로 업데이트
    } catch (e) {
      printRed('Translation Error: $e');
    } finally {
      isLoading.value = false;
      dataList.refresh(); // dataList 업데이트를 트리거하여 UI를 새로 고침
    }
  }

  void translateData(String targetLanguage) async {
    if (selectedIndex.value == 0) {
      // 한국어 선택 시, 원본 데이터 복원
      for (var item in dataList) {
        item.title = item.originalTitle ?? '';
        item.description = item.originalDescription ?? '';
      }
    } else if (selectedIndex.value == 1) {
      // 영어로 번역
      isLoading.value = true;
      var newItems = await Future.wait(dataList.map((item) {
        return translateItem(item, targetLanguage);
      }).toList());
      dataList.value = newItems;
      isLoading.value = false;
    }
    dataList.refresh(); // UI 갱신
  }

  Future<RssItem> translateItem(RssItem item, String targetLang) async {
    var title = await translator.translate(item.title, to: targetLang);
    var description = await translator.translate(item.description, to: targetLang);
    return RssItem(
      title: title.text,
      description: description.text,
      link: item.link,
      originalTitle: item.originalTitle,
      originalDescription: item.originalDescription,
    );
  }
}

class RssItem {
  String title;
  String description;
  String link;
  String? originalTitle; // 원본 제목
  String? originalDescription; // 원본 설명

  RssItem({required this.title, required this.description, required this.link, this.originalTitle, this.originalDescription});

  factory RssItem.fromXml(xml.XmlElement node) {
    return RssItem(
      title: node.findElements('title').first.text,
      description: node.findElements('description').first.text,
      link: node.findElements('link').first.text,
    );
  }
}
