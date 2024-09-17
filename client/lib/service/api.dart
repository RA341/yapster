import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;

final api = ApiService();

class ApiService {
  static final ApiService _instance = ApiService._internal();
  String basePath;
  late final Dio dio;

  factory ApiService() {
    return _instance;
  }

  void init(String basePath) {
    _instance.dio = Dio();
    _instance.basePath = basePath;
  }

  ApiService._internal() : basePath = '';

  Future<String> echo(String input) async {
    final resp = await dio.get<Map<String, dynamic>>('$basePath/echo/$input');

    if (resp.statusCode == 200) {
      return resp.data?["message"] ?? "Null response";
    } else {
      return 'No response';
    }
  }

  Future<String> uploadBlobUrlToServer(String blobUrl) async {
    final dio = Dio();

    try {
      // 1. Fetch the blob from the blob URL
      final response = await dio.getUri(Uri.parse(blobUrl));
      // print(response.data);
      if (response.statusCode == 200) {
        final uri = Uri.parse(blobUrl);
        final client = http.Client();
        final request = await client.get(uri);
        final bytes = request.bodyBytes;

        FormData formData = FormData.fromMap({
          "audio_file": MultipartFile.fromBytes(
            bytes,
            filename: "userfile.webm", // You can set an appropriate filename
          ),
        });

        final uploadResponse = await dio.post(
          '$basePath/upload',
          data: formData,
          options: Options(headers: {"Content-Type": "multipart/form-data"}),
        );

        if (uploadResponse.statusCode == 200 && uploadResponse.data != null) {
          print("Blob uploaded successfully");
          final res = uploadResponse.data;
          return res['job_id'] as String;
        } else {
          print("Failed to upload blob: ${uploadResponse.statusCode}");
          return '';
        }
      } else {
        print("Failed to download blob: ${response.statusCode}");
        return '';
      }
    } catch (e) {
      print('Error uploading file: $e');
      return '';
    }
  }
}

final echoPointProvider = FutureProvider.family<String, String>((
  ref,
  arg,
) async {
  return api.echo(arg);
});
