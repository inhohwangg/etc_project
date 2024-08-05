import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

class RtspTestPage extends StatefulWidget {
  const RtspTestPage({super.key});

  @override
  State<RtspTestPage> createState() => _RtspTestPageState();
}

class _RtspTestPageState extends State<RtspTestPage> {
  late VlcPlayerController vlcPlayerController;

  List<String> rtspLinks = [
    'rtsp://admin:123456@192.168.1.52:8554',
    'rtsp://admin:123456@192.168.0.220',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch33.stream/playlist.m3u8',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch41.stream/playlist.m3u8',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch42.stream/playlist.m3u8',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch43.stream/playlist.m3u8',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch44.stream/playlist.m3u8',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch45.stream/playlist.m3u8',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch46.stream/playlist.m3u8',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch47.stream/playlist.m3u8',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch48.stream/playlist.m3u8',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch49.stream/playlist.m3u8',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch50.stream/playlist.m3u8',
    // 'https://topiscctv1.eseoul.go.kr/sd2/ch60.stream/playlist.m3u8'
    // 'https://topiscctv1.eseoul.go.kr/edge6/ch103.stream/playlist.m3u8'
    // 'rtsp://210.99.70.120:1935/live/cctv001.stream',
    // 'rtsp://210.99.70.120:1935/live/cctv002.stream',
    // 'rtsp://210.99.70.120:1935/live/cctv003.stream',
  ];
  int currentIndex = 0;
  Timer? timer;
  int remainingTime = 60;

  void startTimer() {
    timer?.cancel();
    remainingTime = 60;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime > 0) {
          remainingTime--;
        } else {
          currentIndex = (currentIndex + 1) % rtspLinks.length;
          vlcPlayerController.setMediaFromNetwork(rtspLinks[currentIndex]);
          remainingTime = 60;
        }
      });
    });
  }

  void nextVideo() {
    timer?.cancel();
    setState(() {
      currentIndex = (currentIndex + 1) % rtspLinks.length;
      vlcPlayerController = VlcPlayerController.network(rtspLinks[currentIndex],
          hwAcc: HwAcc.full, autoPlay: true, options: VlcPlayerOptions());
      remainingTime = 60;
    });

    remainingTime = 60;
  }

  @override
  void initState() {
    super.initState();
    VlcPlayerOptions options = VlcPlayerOptions(
        advanced: VlcAdvancedOptions([
          '--network-caching=3000',
          '--clock-jitter=0',
          '--live-caching=3000'
        ]),
        video: VlcVideoOptions([
          '--no-drop-late-frames',
          '--no-skip-frames',
        ]));

    vlcPlayerController = VlcPlayerController.network(
      // 'rtsp://210.99.70.120:1935/live/cctv001.stream',
      rtspLinks[currentIndex],
      hwAcc: HwAcc.full,
      autoPlay: true,
      options: options,
    );
    startTimer();
  }

  @override
  void dispose() {
    vlcPlayerController.stop();
    vlcPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: PageTransitionSwitcher(
              duration: Duration(seconds: 1),
              transitionBuilder: (Widget child,
                  Animation<double> primaryAnimation,
                  Animation<double> secondaryAnimation) {
                return Stack(
                  children: [
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(0.0, 0.0),
                        end: Offset(1.0, 0.0),
                      ).animate(secondaryAnimation),
                      child: FadeTransition(
                        opacity: secondaryAnimation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1.0, end: 0.8)
                              .animate(secondaryAnimation),
                          child: child,
                        ),
                      ),
                    ),
                    SlideTransition(
                      position: Tween<Offset>(
                        begin: Offset(-1.0, 0.0),
                        end: Offset(0.0, 0.0),
                      ).animate(primaryAnimation),
                      child: FadeTransition(
                        opacity: primaryAnimation,
                        child: ScaleTransition(
                          scale: Tween<double>(begin: 1.2, end: 1.0)
                              .animate(primaryAnimation),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                );
              },
              child: VlcPlayer(
                key: ValueKey<int>(currentIndex),
                controller: vlcPlayerController,
                aspectRatio: 16 / 9,
                placeholder: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(10),
              // color: Colors.black54,
              child: Text(
                '남은 시간 : $remainingTime',
                style: TextStyle(color: Colors.black, fontSize: 20),
              ),
            ),
          )
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(height: 10),
          FloatingActionButton(
            onPressed: nextVideo,
            child: Icon(Icons.skip_next),
          ),
        ],
      ),
    );
  }
}

//rtsp://10.1.120.33:554/vurix/100122/0
//rtsp://10.1.120.35:554/vurix/100492/0