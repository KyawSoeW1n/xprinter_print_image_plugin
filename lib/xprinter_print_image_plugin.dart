import 'dart:developer';

import 'package:flutter/services.dart';

import 'xprinter_print_image_plugin_platform_interface.dart';

class XprinterPrintImagePlugin {
  static const MethodChannel _channel =
      MethodChannel('xprinter_print_image_plugin');
  static const EventChannel _eventChannel =
      EventChannel('xprinter_print_image_plugin/print_image');
  static Stream<dynamic>? _streamPrintStatus;

  Future<String?> getPlatformVersion() {
    return XprinterPrintImagePluginPlatform.instance.getPlatformVersion();
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    log("VERSION $version");
    return version;
  }

  static Stream<dynamic> onPrintStatus() {
    _streamPrintStatus = _eventChannel.receiveBroadcastStream();
    return _streamPrintStatus!;
  }

  static Future<int> connectDevice({required String macAddress}) async {
    final data = await _channel.invokeMethod('connectDevice', {
      'macAddress': macAddress,
    });
    return data;
  }

  static Future<int> printImage({required String filePath}) async {
    final data = await _channel.invokeMethod('printImage', {
      'bitmap': filePath,
    });
    return data;
  }

  static Future<void> disconnectDevice() async {
    await _channel.invokeMethod('disconnectDevice');
  }
}
