import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
}

final echoPointProvider = FutureProvider.family<String, String>((
  ref,
  arg,
) async {
  return api.echo(arg);
});
