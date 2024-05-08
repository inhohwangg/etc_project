import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

// FFmpeg 명령 실행
test () async{
  FFmpegKit.execute('-i file1.mp4 -c:v mpeg4 file2.mp4').then((session) async {
  final returnCode = await session.getReturnCode();

  if (ReturnCode.isSuccess(returnCode)) {
    // 성공 처리
  } else if (ReturnCode.isCancel(returnCode)) {
    // 취소 처리
  } else {
    // 에러 처리
  }
});
}

