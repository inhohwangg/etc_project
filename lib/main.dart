import 'package:etc_test_project/pages/kiosk/ocr-demo-pg.dart';
import 'package:etc_test_project/pages/kiosk/ocr-demo-test-pg.dart';
import 'package:etc_test_project/pages/kiosk/pic-test-pg.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final androidConfig = FlutterBackgroundAndroidConfig(
      notificationTitle: '근태관리 테스트 앱',
      notificationText: 'GPS를 이용하여 근태관리 처리',
      notificationImportance: AndroidNotificationImportance.High,
      notificationIcon: AndroidResource(name: 'background_icon', defType: 'drawable'));
  await FlutterBackground.initialize(androidConfig: androidConfig);

  // 권한 요청
  await requestPermissions();

  runApp(
    MyApp(),
  );
}

Future<void> requestPermissions() async {
  // 위치 권한 상태를 체크합니다.
  PermissionStatus locationPermissionStatus = await Permission.location.status;

  // 필요한 권한을 여기에 추가하세요.
  List<Permission> requiredPermissions = [Permission.location];

  if (locationPermissionStatus.isDenied) {
    // 권한 요청
    Map<Permission, PermissionStatus> statuses = await requiredPermissions.request();

    // 모든 권한이 허용되지 않았다면 사용자에게 안내합니다.
    if (statuses.containsValue(PermissionStatus.denied)) {
      showPermissionDialog();
    }
  }
}

void showPermissionDialog() {
  showDialog(
    context: Get.context!, // GetX를 사용하는 경우 context를 이렇게 가져올 수 있습니다.
    barrierDismissible: false, // 사용자가 다이얼로그 밖의 영역을 탭해도 닫히지 않게 합니다.
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('권한 필요'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('이 앱을 사용하기 위해서는 위치 권한이 필요합니다.'),
              Text('설정에서 권한을 허용해 주세요.'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('거부'),
            onPressed: () {
              Navigator.of(context).pop(); // 대화상자를 닫습니다.
            },
          ),
          TextButton(
            child: Text('설정'),
            onPressed: () {
              openAppSettings(); // 앱 설정 화면을 엽니다.
            },
          ),
        ],
      );
    },
  );
}

class MyServiceBridge {
  static const _channel = MethodChannel('com.example.etc_test_project/service');

  static Future<String?> getSomeData() async {
    final String? data = await _channel.invokeMethod('getSomeData');
    return data;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // home: GeoFenceTestPage(),
      home: PicTestPage(),
      //K89332290388957
    );
  }
}
