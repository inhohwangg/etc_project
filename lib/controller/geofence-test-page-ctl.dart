// ignore_for_file: unused_local_variable, file_names

import 'package:Youtube_Stop/util/g_print.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../util/g_dio.dart';

class GeoFenceTestPageController extends GetxController {
  RxBool isInTestPlace = false.obs;
  DateTime now = DateTime.now();

  test() async {
    try {
      var res = await dio.post('https://pb.fappworkspace.store/api/collections/geofence/records',
          data: {'come_in_data': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()).toString(), 'text': '들어왔음'},
          options: Options(headers: {'Content-type': 'application/json'}));
      Get.snackbar('Post Success', 'Come In Success', backgroundColor: Color(0xFF089bcc), colorText: Colors.white);
    } catch (e) {
      printRed('geofence-test-page-ctl.dart test function Error Message : $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    isInTestPlace.listen(
      (isIn) {
        if (isIn) {
          test();
        }
      },
    );
  }
}


// 안드로이드의 배터리 최적화 기능들은 백그라운드에서 실행되는 앱의 활동을 제한하여 배터리 수명을 연장합니다.
// 이러한 기능들 중 Doze 모드와 App Standby가 대표적입니다. 하지만 특정 앱이 백그라운드에서도 작업을 수행해야 한다면
// 시스템의 제한을 우회하는 방법들이 있습니다:

// 1. **Foreground Service 사용**: Foreground Service는 사용자에게 눈에 보이는 알림(Notification)을
// 제공하며 실행되기 때문에 시스템에 의해 종료될 가능성이 낮습니다. 이는 백그라운드 작업이 중요한 경우 사용됩니다.

// 2. **배터리 최적화 예외 처리**: 사용자가 직접 앱을 배터리 최적화의 예외로 설정할 수 있도록 안내합니다.
// 이는 시스템 설정에서 `설정 > 배터리 > 배터리 최적화` 메뉴를 통해 할 수 있으며
// 앱에서 사용자를 해당 설정 화면으로 안내할 수 있습니다.

// 3. **AlarmManager의 setAndAllowWhileIdle 및 setExactAndAllowWhileIdle 사용**: 이 메소드들은
// Doze 모드에서도 알람이 실행되도록 합니다. `setAndAllowWhileIdle` 메소드는 시간이 지남에 따라 정확도가 감소하지만
// `setExactAndAllowWhileIdle` 메소드는 정확한 시간에 실행되도록 보장합니다.

// 4. **WorkManager의 제약 조건 활용**: `WorkManager`를 사용하여 작업을 스케줄링할 때
// `setRequiresBatteryNotLow`와 같은 제약 조건을 사용하여 배터리가 충분히 남아 있을 때만
// 작업이 실행되도록 설정할 수 있습니다.

// 5. **Doze 모드를 감지하고 대응하기**: `PowerManager`를 통해 Doze 모드가 활성화되었는지 감지하고
// `isDeviceIdleMode()` 메서드를 통해 확인한 뒤에 특정 로직을 실행하거나, 대기 상태에서 벗어나 작업을
// 수행할 수 있는 로직을 추가할 수 있습니다.

// 6. **네트워크 접근 허용**: `setRequiredNetworkType(NetworkType.CONNECTED)`
// 같은 제약을 사용하여 네트워크에 연결되어 있을 때만 작업을 실행하도록 설정할 수 있습니다.

// 백그라운드 작업에 대한 시스템 제한을 우회하는 것은 사용자의 기기 배터리에 부정적인 영향을 줄 수 있으므로
// 이러한 우회 방법은 반드시 필요한 경우에만 사용해야 하며, 사용자에게 명확한 안내가 필요합니다.
// 또한, 이러한 방법들은 안드로이드 버전마다 다르게 동작할 수 있으므로 다양한 버전에서의 테스트가 필요합니다.