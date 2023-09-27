import 'package:flutter/services.dart';

import 'xprinter_print_image_plugin_platform_interface.dart';

class XprinterPrintImagePlugin {
  static const MethodChannel _channel =
      MethodChannel('xprinter_print_image_plugin');
  static const EventChannel _eventChannel =
      EventChannel('xprinter_print_image_plugin/print_image');
  static Stream<dynamic>? _streamPayStatus;

  Future<String?> getPlatformVersion() {
    return XprinterPrintImagePluginPlatform.instance.getPlatformVersion();
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Stream<dynamic> onPrintStatus() {
    _streamPayStatus = _eventChannel.receiveBroadcastStream();
    return _streamPayStatus!;
  }

  static Future<String> connectDevice({required String macAddress}) async {
    final String data = await _channel.invokeMethod('connectDevice', {
      'macAddress': macAddress,
    });
    return data;
  }
}
