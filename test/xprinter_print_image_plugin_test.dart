import 'package:flutter_test/flutter_test.dart';
import 'package:xprinter_print_image_plugin/xprinter_print_image_plugin.dart';
import 'package:xprinter_print_image_plugin/xprinter_print_image_plugin_platform_interface.dart';
import 'package:xprinter_print_image_plugin/xprinter_print_image_plugin_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockXprinterPrintImagePluginPlatform
    with MockPlatformInterfaceMixin
    implements XprinterPrintImagePluginPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final XprinterPrintImagePluginPlatform initialPlatform = XprinterPrintImagePluginPlatform.instance;

  test('$MethodChannelXprinterPrintImagePlugin is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelXprinterPrintImagePlugin>());
  });

  test('getPlatformVersion', () async {
    XprinterPrintImagePlugin xprinterPrintImagePlugin = XprinterPrintImagePlugin();
    MockXprinterPrintImagePluginPlatform fakePlatform = MockXprinterPrintImagePluginPlatform();
    XprinterPrintImagePluginPlatform.instance = fakePlatform;

    expect(await xprinterPrintImagePlugin.getPlatformVersion(), '42');
  });
}
