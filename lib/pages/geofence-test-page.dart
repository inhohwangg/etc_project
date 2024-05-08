// ignore_for_file: file_names, avoid_print

import 'dart:async';

import 'package:etc_test_project/controller/geofence-test-page-ctl.dart';
import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:get/get.dart';

class GeoFenceTestPage extends StatefulWidget {
  const GeoFenceTestPage({super.key});

  @override
  State<GeoFenceTestPage> createState() => _GeoFenceTestPageState();
}

class _GeoFenceTestPageState extends State<GeoFenceTestPage> with WidgetsBindingObserver {
  GeoFenceTestPageController controller = Get.put(GeoFenceTestPageController());
  final StreamController<Geofence> _geofenceStreamController = StreamController<Geofence>();
  final StreamController<Activity> _activityStreamController = StreamController<Activity>();

  Location? currentLocation;
  // bool isInTestPlace = false;

  final geofenceService = GeofenceService.instance.setup(
    interval: 1000,
    accuracy: 100,
    loiteringDelayMs: 60000,
    statusChangeDelayMs: 10000,
    useActivityRecognition: true,
    allowMockLocations: false,
    printDevLog: false,
    geofenceRadiusSortType: GeofenceRadiusSortType.DESC,
  );

  final geofenceList = <Geofence>[
    Geofence(
      id: 'test_place',
      latitude: 37.51138,
      longitude: 127.07977,
      radius: [
        // GeofenceRadius(id: 'radius_100m', length: 100),
        GeofenceRadius(id: 'radius_5m', length: 5),
        // GeofenceRadius(id: 'radius_250m', length: 250),
        // GeofenceRadius(id: 'radius_200m', length: 200),
      ],
    ),
  ];

  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(Geofence geofence, GeofenceRadius geofenceRadius, GeofenceStatus geofenceStatus, Location location) async {
    // print('geofence: ${geofence.toJson()}');
    // print('geofenceRadius: ${geofenceRadius.toJson()}');
    // print('geofenceStatus: ${geofenceStatus.toString()}');
    // _geofenceStreamController.sink.add(geofence);
    if (geofence.id == 'test_place' && geofenceStatus == GeofenceStatus.ENTER) {
      setState(() {
        controller.isInTestPlace.value = true;
      });
    } else if (geofence.id == 'test_place' && geofenceStatus == GeofenceStatus.EXIT) {
      setState(() {
        controller.isInTestPlace.value = false;
      });
    }
  }

// This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    // print('prevActivity: ${prevActivity.toJson()}');
    // print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

// This function is to be called when the location has changed.
  void _onLocationChanged(Location location) {
    setState(() {
      currentLocation = location;
    });
    // printCyan('location: ${location.toJson()}');
  }

// This function is to be called when a location services status change occurs
// since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

// This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  @override
  void dispose() {
    _geofenceStreamController.close();
    _activityStreamController.close();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      geofenceService.addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      geofenceService.addLocationChangeListener(_onLocationChanged);
      geofenceService.addLocationServicesStatusChangeListener(_onLocationServicesStatusChanged);
      geofenceService.addActivityChangeListener(_onActivityChanged);
      geofenceService.addStreamErrorListener(_onError);
      geofenceService.start(geofenceList).catchError(_onError);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillStartForegroundTask(
      onWillStart: () async {
        return geofenceService.isRunningService;
      },
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'geofence service notification channel',
        channelName: 'Geofence Service Notification',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
        isSticky: true,
      ),
      iosNotificationOptions: IOSNotificationOptions(),
      foregroundTaskOptions: ForegroundTaskOptions(
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
      notificationTitle: '백그라운드로 이동',
      notificationText: '탭하여 앱으로 이동',
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'GeoFenceTestPage',
            ),
            backgroundColor: Colors.purple[100],
            centerTitle: true,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text('GeoLatitudeData : ${currentLocation?.latitude}'),
              ),
              SizedBox(
                height: 10,
              ),
              Center(
                child: Text('GeoLongitudeData : ${currentLocation?.longitude}'),
              ),
              SizedBox(
                height: 20,
              ),
              Obx(
                () => controller.isInTestPlace.value == true
                    ? Text(
                        'come in',
                        style: TextStyle(
                          color: Colors.blue[300],
                          fontSize: 20,
                        ),
                      )
                    : Text(
                        'out',
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: 20,
                        ),
                      ),
              ),
              Obx(
                () => Text(
                  controller.isInTestPlace.value.toString(),
                  style: TextStyle(fontSize: 30, color: Colors.amber),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
