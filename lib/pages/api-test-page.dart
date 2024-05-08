// ignore_for_file: file_names, avoid_print, avoid_function_literals_in_foreach_calls
import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';
import 'package:etc_test_project/models/sensor_data.dart';
import 'package:etc_test_project/util/g_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class ApiTestPage extends StatefulWidget {
  const ApiTestPage({super.key});

  @override
  State<ApiTestPage> createState() => _ApiTestPageState();
}

class _ApiTestPageState extends State<ApiTestPage> {
  RxList devicesList = [].obs;
  String deviceId = '';
  RxBool deviceLoading = false.obs;
  bool clickLoading = false;
  BluetoothDevice? device;
  RxBool isLoading = false.obs;

  //! 안드로이드 권한 설정
  Future requestPermission() async {
    var bluetoothScanStatus = await Permission.bluetoothScan.status;
    if (!bluetoothScanStatus.isGranted) {
      await Permission.bluetoothScan.request();
    }

    var bluetoothConnectStatus = await Permission.bluetoothConnect.status;
    if (!bluetoothConnectStatus.isGranted) {
      await Permission.bluetoothConnect.request();
    }

    var status = await Permission.location.status;
    if (!status.isGranted) {
      await Permission.location.request();
    }
  }

  void scanForDevices() async {
    isLoading.value = true;
    devicesList.clear();

    var scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.platformName != '') {
          var device = {
            'device': result.device,
            'uuid': result.device.remoteId.toString(),
            'name': result.device.platformName,
          };
          if (!devicesList.any((element) => element['uuid'] == device['uuid'])) {
            devicesList.add(device);
          }
        }
      }
    });

    await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));
    await Future.delayed(Duration(seconds: 4));
    await scanSubscription.cancel();

    isLoading.value = false;
    deviceLoading.value = true;
  }

  //! 장치 연결
  Future connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      print('Device connected');
      await discoverServices(device);
      await discoverServicesAndSubscribe(device);
    } catch (e) {
      print('Error connecting to device : $e');
    }
  }

  Future<void> discoverServices(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    services.forEach((service) {
      // print("Service UUID: ${service.uuid}");
      service.characteristics.forEach((characteristic) {
        // print("Characteristic UUID: ${characteristic.uuid}");
      });
    });
  }

  // 사용자가 설정한 서비스와 특성의 UUID를 저장할 변수
  String targetServiceUuid = "";
  String targetCharacteristicUuid = "";

  // 서비스와 특성의 UUID를 동적으로 설정하는 메서드
  void setTargetUuids(String serviceUuid, String characteristicUuid) {
    setState(() {
      targetServiceUuid = serviceUuid;
      targetCharacteristicUuid = characteristicUuid;
    });
  }

  Future<void> discoverServicesAndSubscribe(BluetoothDevice device) async {
    inspect(device);
    try {
      List<BluetoothService> services = await device.discoverServices();
      for (BluetoothService service in services) {
        inspect(service);
        // Flower Care의 실시간 데이터 서비스 UUID
        if (service.uuid.toString() == "00001204-0000-1000-8000-00805f9b34fb") {
          for (BluetoothCharacteristic characteristic in service.characteristics) {
            // 실시간 데이터를 얻기 위한 특성 UUID
            if (characteristic.uuid.toString() == "00001a01-0000-1000-8000-00805f9b34fb") {
              await characteristic.setNotifyValue(true);
              characteristic.lastValueStream.listen((data) {
                // 동적으로 설정된 특성의 데이터를 처리합니다.
                final sensorData = SensorData.fromByteArray(Uint8List.fromList(data));
                // 변환된 SensorData 객체 사용
                printCyan("Temperature: ${sensorData.temperature} °C");
                printCyan("Light: ${sensorData.light} lux");
                printCyan("Moisture: ${sensorData.moisture} %");
                printCyan("Conductivity: ${sensorData.conductivity} µS/cm");
              }, onError: (error) {
                print("Error processing sensor data: $error");
              });
              print('Notification activated on real-time data characteristic');
            }
          }
        }
      }
    } catch (e) {
      print('Error discovering services and characteristics: $e');
    }
  }

  // 장치 연결 버튼 클릭 시 호출되는 이벤트 핸들러
  void onConnectButtonPressed(BluetoothDevice device) {
    connectToDevice(device).then((_) {
      // 연결 후 UI 업데이트 등의 후속 처리
    });
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: ElevatedButton(
                onPressed: () {
                  scanForDevices();
                },
                child: Text('장치 검색'),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Obx(
              () => isLoading.value
                  ? CircularProgressIndicator()
                  : deviceLoading.value == true
                      ? Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          width: double.infinity,
                          height: 500,
                          child: ListView.builder(
                            itemCount: devicesList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                margin: EdgeInsets.only(top: 15),
                                width: double.infinity,
                                child: Row(
                                  children: [
                                    Text(
                                      '장치 :  ${devicesList[index]['name']}',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Spacer(),
                                    Text(devicesList[index]['uuid'].toString(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400)),
                                    Spacer(),
                                    Container(
                                      // padding: EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.blue[200]!.withOpacity(0.75)),
                                      child: TextButton(
                                        onPressed: () {
                                          connectToDevice(devicesList[index]['device']);
                                        },
                                        child: Text(
                                          '연결',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        )
                      : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
