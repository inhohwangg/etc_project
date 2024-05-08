import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ZabbixTestPage extends StatefulWidget {
  ZabbixTestPage({super.key});

  @override
  State<ZabbixTestPage> createState() => _ZabbixTestPageState();
}

class _ZabbixTestPageState extends State<ZabbixTestPage> {
  WebViewController? controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..loadRequest(
        Uri.parse(
          'http://192.168.0.208:3080/zabbix.php?action=dashboard.view&dashboardid=303',
          // 'https://pb.fappworkspace.store/_/'
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zabbix Dashboard'),
      ),
      body: WebViewWidget(
        controller: controller!,
      ),
    );
  }
}