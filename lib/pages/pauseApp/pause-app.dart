import 'dart:async';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';

class AppBlocker extends StatefulWidget {
  @override
  _AppBlockerState createState() => _AppBlockerState();
}

class _AppBlockerState extends State<AppBlocker> {
  TimeOfDay _startTime = TimeOfDay.now();
  Duration _duration = Duration(minutes: 2);
  String _selectedApp = 'com.google.android.youtube';
  bool _isRestricted = false;

  static const platform = MethodChannel('com.example.appblocker/channel');

  @override
  void initState() {
    super.initState();
  }

  void _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  void _selectDuration(BuildContext context) async {
    Duration? picked = await showDialog<Duration>(
      context: context,
      builder: (BuildContext context) {
        return DurationPickerDialog(initialDuration: _duration);
      },
    );
    if (picked != null && picked != _duration) {
      setState(() {
        _duration = picked;
      });
    }
  }

  void _selectApp() async {
    // 기기에 설치된 앱 목록 가져오기
    List<Application> apps = await DeviceApps.getInstalledApplications(
        includeSystemApps: false, onlyAppsWithLaunchIntent: true);
    // 앱 선택 UI 표시
    String? selectedApp = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AppPickerDialog(apps: apps);
      },
    );
    if (selectedApp != null && selectedApp.isNotEmpty) {
      setState(() {
        _selectedApp = selectedApp;
      });
    }
  }

  void _startRestriction() {
  setState(() {
    _isRestricted = true;
  });

  final durationMillis = _duration.inMilliseconds;

  platform
      .invokeMethod('setBlockedApp', {"packageName": _selectedApp, "duration": durationMillis}).then((_) {
    print("setBlockedApp method invoked successfully");
  }).catchError((error) {
    print("Error invoking setBlockedApp: $error");
  });

  _restrictAppUsage();
}

  void _restrictAppUsage() async {
    platform.invokeMethod('setBlockedApp', {"packageName": _selectedApp});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App Blocker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('시작 시간: ${_startTime.format(context)}'),
            ElevatedButton(
              onPressed: () => _selectStartTime(context),
              child: Text('시작 시간 선택'),
            ),
            Text('지속 시간: ${_duration.inMinutes}분'),
            ElevatedButton(
              onPressed: () => _selectDuration(context),
              child: Text('지속 시간 선택'),
            ),
            Text('차단할 앱: $_selectedApp'),
            ElevatedButton(
              onPressed: _selectApp,
              child: Text('차단할 앱 선택'),
            ),
            SizedBox(height: 20),
            _isRestricted
                ? Text(
                    '앱 사용이 제한되었습니다.',
                    style: TextStyle(color: Colors.red),
                  )
                : ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isRestricted = true;
                      });
                      _startRestriction();
                    },
                    child: Text('앱 사용 제한 시작'),
                  ),
          ],
        ),
      ),
    );
  }
}

class DurationPickerDialog extends StatefulWidget {
  final Duration? initialDuration;

  DurationPickerDialog({this.initialDuration});

  @override
  _DurationPickerDialogState createState() => _DurationPickerDialogState();
}

class _DurationPickerDialogState extends State<DurationPickerDialog> {
  Duration? _duration;

  @override
  void initState() {
    super.initState();
    _duration = widget.initialDuration;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('지속 시간 선택'),
      content: Row(
        children: <Widget>[
          Expanded(
            child: NumberPicker(
              value: _duration!.inMinutes,
              minValue: 1,
              maxValue: 180,
              onChanged: (value) {
                setState(() {
                  _duration = Duration(minutes: value);
                });
              },
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('취소'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(_duration);
          },
          child: Text('확인'),
        ),
      ],
    );
  }
}

class AppPickerDialog extends StatelessWidget {
  final List<Application>? apps;

  AppPickerDialog({this.apps});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('차단할 앱 선택'),
      content: Container(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: apps?.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(apps![index].appName),
              onTap: () {
                Navigator.of(context).pop(apps![index].packageName);
              },
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('취소'),
        ),
      ],
    );
  }
}
