import 'package:dio/dio.dart';

String baseUrl = 'https://pb.fappworkspace.store';

Dio dio = Dio(BaseOptions(
  contentType: Headers.formUrlEncodedContentType,
  validateStatus: (status) => true,
));