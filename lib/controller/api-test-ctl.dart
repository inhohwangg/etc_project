// ignore_for_file: file_names, unnecessary_overrides, avoid_print

import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:etc_test_project/util/g_dio.dart';
import 'package:get/get.dart';

class ApiTestPageController extends GetxController {
  RxList foodList = [].obs;
  int pageInt = 1;

  @override
  void onInit() {
    super.onInit();
    // getFoodData();
  }

  /// [음식점 정보]
  getFoodData() async {
    try {
      var res = await dio.get('https://dapi.kakao.com/v2/local/search/keyword.json',
          queryParameters: {"query": "의정부 가볼만한 곳", "page": pageInt}, options: Options(headers: {'Authorization': "KakaoAK 6a33bebe91fa6517dbf028353e37026a"}));
      if (res.statusCode == 200) {
        foodList.addAll(res.data['documents']);
      } else {
        throw Exception('api request error');
      }
      inspect(foodList);
    } catch (e) {
      print(e);
    }
  }

  getNaverLocationData() async {
    try {
      var res = await dio.get('https://openapi.naver.com/v1/datalab/search',
          queryParameters: {
            "query": "의정부 음식점",
            // "":"",
            // "":"",
            // "":"",
          },
          options: Options(headers: {
            "X-Naver-Client-Id": "jPqZaPDk8QZJyt9011q1",
            "X-Naver-Client-Secret": "5B88ZPJHCu",
          }));
      inspect(res.data);
    } catch (e) {
      print(e);
    }
  }
}
