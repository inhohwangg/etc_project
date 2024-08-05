import 'dart:io';
import 'package:Youtube_Stop/util/g_print.dart';
import 'package:dio/dio.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DummyPage extends StatefulWidget {
  const DummyPage({Key? key}) : super(key: key);

  @override
  State<DummyPage> createState() => _DummyPageState();
}

class _DummyPageState extends State<DummyPage> {
  bool isLoading = false;

  // Future<void> storeData() async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   var dio = Dio();  // Dio 인스턴스 생성
  //   int totalPages = 50;  // 전체 페이지 수를 설정합니다.
  //   List allItems = [];  // 모든 데이터를 저장할 리스트

  //   try {
  //     for (int page = 1; page <= totalPages; page++) {
  //       var response = await dio.get('https://uiriver-api.incase.link/api/collections/stores/records?page=$page');
  //       allItems.addAll(response.data['items']);
  //     }

  //     print('Total items collected: ${allItems.length}');
  //     await createExcelAndSave(allItems);  // Excel 파일 생성 및 저장 함수 호출
  //   } catch (e) {
  //     print("Error fetching data or writing file: $e");
  //   } finally {
  //     setState(() {
  //       isLoading = false;
  //     });
  //   }
  // }
Future<void> storeData() async {
    setState(() {
      isLoading = true;
    });

    var dio = Dio();  // Dio 인스턴스 생성
    int totalPages = 50;  // 전체 페이지 수를 설정합니다.
    List allItems = [];  // 모든 데이터를 저장할 리스트

    try {
      for (int page = 1; page <= totalPages; page++) {
        var response = await dio.get('https://uiriver-api.incase.link/api/collections/stores/records?page=$page');
        allItems.addAll(response.data['items']);
      }

      // enable 필드가 True인 항목만 필터링
      List filteredItems = allItems.where((item) => item['enable'] == true).toList();

      print('Total items collected: ${filteredItems.length}');
      await createExcelAndSave(filteredItems);  // Excel 파일 생성 및 저장 함수 호출
    } catch (e) {
      print("Error fetching data or writing file: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


 Future<void> createExcelAndSave(List<dynamic> items) async {
  var excel = Excel.createExcel();
  var sheet = excel['Sheet1'];

  // 헤더 추가
  List<String> headers = [
    'id', 'spaceId', 'facilityId', 'name', 'bNo', 'mgtNo', 'roadAddr',
    'siteAddr', 'postalCode', 'category', 'qrlink', 'storeTelNo', 'homepage',
    'desc','storeImg','itemImg','prmtItem','saleTarget','itemPriceList','enable',
    'geometry','unitList','created','updated'
  ];
  sheet.appendRow(headers.map((header) => TextCellValue(header)).toList());

  // 데이터 행 추가
  for (var item in items) {
    List<CellValue> row = headers.map((header) {
      var value = item[header];
      if (value == null) return TextCellValue('');
      if (value is bool) return BoolCellValue(value);
      if (value is int || value is double) return DoubleCellValue(value.toDouble());
      return TextCellValue(value.toString());
    }).toList();
    sheet.appendRow(row);
  }

  // 파일 저장
  var fileBytes = excel.encode();
  if (fileBytes != null) {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/Excel_File.xlsx';
    File file = File(filePath);

    // 파일 쓰기 권한 확인 및 쓰기
    await file.writeAsBytes(fileBytes, flush: true);
    print("Excel file created at $filePath");
  } else {
    print("Failed to encode Excel file.");
  }
}


  Future<void> uploadData() async {
    var dio = Dio();
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String filePath = '${appDocDir.path}/Excel_File.xlsx';  // 파일 경로 수정
    File file = File(filePath);

    if (!file.existsSync()) {
      printYellow("File does not exist at $filePath.");
      return;
    }

    // FormData 객체 생성
    FormData formData = FormData.fromMap({
      "facilityId": "test",
      "features": '{"type": "FeatureCollection", "features": []}',
      "field": await MultipartFile.fromFile(filePath, filename: 'Excel_File.xlsx')
    });

    try {
      var response = await dio.post('https://uiriver-api.incase.link/api/collections/geojson/records', data: formData);

      if (response.statusCode == 200) {
        print("Data uploaded successfully: ${response.data}");
      } else {
        print("Failed to upload data: ${response.statusCode}");
      }
    } catch (e) {
      print("Error uploading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            storeData();  // 데이터 저장 함수 호출
            uploadData();
          },
          child: Text('Download and Upload Data'),
        ),
      ),
    );
  }
}
