import 'dart:developer';

import 'package:flutter/services.dart';

import 'xprinter_print_image_plugin_platform_interface.dart';

class XprinterPrintImagePlugin {
  static const MethodChannel _channel =
      MethodChannel('xprinter_print_image_plugin');
  static const EventChannel _eventChannel =
      EventChannel('xprinter_print_image_plugin/print');
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
    log("CONNECT $data");
    return data;
  }

  static Future<int> disconnectDevice() async {
    final data = await _channel.invokeMethod('disconnectDevice');
    log("DISCONNECT $data");
    return data;
  }

  static Future<int> printImage({
    required String filePath,
    int? imageWidth,
    int? feedLine,
    int? distance,
  }) async {
    final Map<String, dynamic> arguments = {
      'filePath': filePath,
    };
    if (imageWidth != null) {
      arguments["imageWidth"] = imageWidth;
    }
    if (distance != null) {
      arguments["distance"] = distance;
    }
    if (feedLine != null) {
      arguments["feedLine"] = feedLine;
    }
    final data = await _channel.invokeMethod(
      'printImage',
      arguments,
    );
    return data;
  }

  static Future<int> printText({
    required String text,
    int? feedLine,
    int? distance,
  }) async {
    final Map<String, dynamic> arguments = {
      'text': text,
    };

    if (feedLine != null) {
      arguments["feedLine"] = feedLine;
    }
    if (distance != null) {
      arguments["distance"] = distance;
    }

    final data = await _channel.invokeMethod(
      'printText',
      arguments,
    );
    return data;
  }
}
