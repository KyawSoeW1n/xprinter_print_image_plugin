import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'xprinter_print_image_plugin_method_channel.dart';

abstract class XprinterPrintImagePluginPlatform extends PlatformInterface {
  /// Constructs a XprinterPrintImagePluginPlatform.
  XprinterPrintImagePluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static XprinterPrintImagePluginPlatform _instance = MethodChannelXprinterPrintImagePlugin();

  /// The default instance of [XprinterPrintImagePluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelXprinterPrintImagePlugin].
  static XprinterPrintImagePluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [XprinterPrintImagePluginPlatform] when
  /// they register themselves.
  static set instance(XprinterPrintImagePluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
