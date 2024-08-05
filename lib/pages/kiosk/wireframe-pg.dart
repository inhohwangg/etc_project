import 'package:Youtube_Stop/controller/kiosk/widget/effect.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WireFramePage extends StatefulWidget {
  WireFramePage({super.key});

  @override
  _WireFramePageState createState() => _WireFramePageState();
}

class _WireFramePageState extends State<WireFramePage> {
  List<Offset> _hoverPositions = [];

  void _handleHover(PointerEvent details) {
    setState(() {
      _hoverPositions.add(details.localPosition);
    });
  }

  void _handleExit(PointerEvent details) {
    setState(() {
      _hoverPositions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: MouseRegion(
          onHover: _handleHover,
          onExit: _handleExit,
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  first(),
                  // second(),
                ],
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: RipplePainter(_hoverPositions),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget first() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '안녕하세요!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              Text('의정부의 자랑 의돌이에요!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text('제일시장에 오신 것을 환영해요',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Center(
          child: Image.asset(
            'assets/images/기본1.png',
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                  child: Center(
                    child: Text(
                      '시작하기',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                  child: Center(
                    child: Text(
                      '간편모드',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget second() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '저랑 재미있는 놀이 하실래요?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Center(
          child: Image.asset(
            'assets/images/기본1.png',
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 50),
                  child: Center(
                    child: Text(
                      '그래! 좋아',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey[400]!),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 35),
                  child: Center(
                    child: Text(
                      '아니..그냥 뭐 좀 찾을래',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
