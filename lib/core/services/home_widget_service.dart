import 'package:flutter/services.dart';

class HomeWidgetService {
  HomeWidgetService._();

  static const _channel = MethodChannel('com.hustlerdev.splittr/deeplink');

  static void Function(String uri)? _onDeepLink;

  static void initialize({required void Function(String uri) onDeepLink}) {
    _onDeepLink = onDeepLink;
    _channel.setMethodCallHandler(_handleMethod);
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    if (call.method == 'deeplink') {
      final uri = call.arguments as String?;
      if (uri != null) {
        _onDeepLink?.call(uri);
      }
    }
  }
}
