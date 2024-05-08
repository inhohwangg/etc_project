// ignore_for_file: file_names
// import 'dart:async';

// import 'package:etc_test_project/util/g_print.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// class BleTestPage extends StatefulWidget {
//   const BleTestPage({super.key});

//   @override
//   State<BleTestPage> createState() => _BleTestPageState();
// }

// class _BleTestPageState extends State<BleTestPage> {
//   final ble = FlutterReactiveBle();
//   List<DiscoveredDevice> devicesList = [];
//   StreamSubscription? connectionSubscription;
//   StreamSubscription? dataSubscription;

//   void searchForDevices() async {
//     ble.scanForDevices(withServices: []).listen((device) {
//       setState(() {
//         devicesList.add(device); // 여기를 수정했습니다.
//       });
//     });
//   }

//   void connectToDevice(String deviceId) {
//     ble.connectToDevice(id: deviceId, connectionTimeout: Duration(seconds: 5)).listen((connectionState) {
//       printCyan(connectionState);
//       if (connectionState.connectionState == DeviceConnectionState.connected) {
//         subscribeToCharacteristic(deviceId);
//       }
//     }, onError: (dynamic error) {
//       printRed("connectToDevice Error Message : $error");
//     });
//   }

//   void subscribeToCharacteristic(String deviceId) {
//     final serviceUuid = Uuid.parse("00001204-0000-1000-8000-00805f9b34fb");

//     // 모드 변경 특성
//     final modeChangeCharacteristic = QualifiedCharacteristic(
//       serviceId: serviceUuid,
//       characteristicId: Uuid.parse("00001a00-0000-1000-8000-00805f9b34fb"),
//       deviceId: deviceId,
//     );

//     final realTimeDataCharacteristic = QualifiedCharacteristic(
//       serviceId: serviceUuid,
//       characteristicId: Uuid.parse("00001a01-0000-1000-8000-00805f9b34fb"),
//       deviceId: deviceId,
//     );

//     // 모드 변경 (센서 값 읽기 활성화)
//     ble.writeCharacteristicWithResponse(modeChangeCharacteristic, value: [0xa0, 0x1f]);

//     // 실시간 데이터 구독
//     dataSubscription = ble.subscribeToCharacteristic(realTimeDataCharacteristic).listen((data) {
//       var temperature = (data[0] | data[1] << 8) / 10;
//       var timestamp = data[0] | data[1] << 8 | data[2] << 16 | data[3] << 24;
//       var brightness = data[3] | data[4] << 8 | data[5] << 16; // 데이터 위치 조정 필요
//       var moisture = data[11];
//       var conductivity = data[12] | data[13] << 8;
      
//       printGreen(temperature);
//       printGreen(timestamp);
//       printPurple(brightness);
//       printGreen('$moisture %');
//       printGreen("Conductivity: $conductivity µS/cm");
//       printYellow("Received real-time data: $data");
//     }, onError: (dynamic error) {
//       printRed("Error: $error");
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Scaffold(
//         body: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: EdgeInsets.symmetric(vertical: 10),
//               child: Center(
//                 child: ElevatedButton(
//                   onPressed: searchForDevices,
//                   child: Text('블루투스 검색'),
//                 ),
//               ),
//             ),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: devicesList.length,
//                 itemBuilder: (context, index) {
//                   // return
//                   return ListTile(
//                     title: Text(devicesList[index].name.toString()),
//                     subtitle: Text(devicesList[index].id),
//                     onTap: () => connectToDevice(devicesList[index].id),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
