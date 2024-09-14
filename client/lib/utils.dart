import 'package:client/service/api.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as html;

void setupApiPath() {
  String basePath;
  if (kDebugMode) {
    basePath = 'http://localhost:8000';
  } else {
    if (kIsWeb) {
      basePath = html.window.location.href;
    } else {
      basePath = 'https://yap.dumbapps.org';
    }
  }

  if (basePath.endsWith('/')) {
    basePath = basePath.substring(0, basePath.length - 1);
  }

  print('Base path is $basePath');
  api.init(basePath);
}
