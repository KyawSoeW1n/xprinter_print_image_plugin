import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xprinter_print_image_plugin/xprinter_print_image_plugin_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelXprinterPrintImagePlugin platform = MethodChannelXprinterPrintImagePlugin();
  const MethodChannel channel = MethodChannel('xprinter_print_image_plugin');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        return '42';
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
