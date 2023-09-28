import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xprinter_print_image_plugin/connect_status.dart';
import 'package:xprinter_print_image_plugin/xprinter_print_image_plugin.dart';

import 'bluetooth_device_vo.dart';
import 'device_list_screen.dart';

class PrinterScreen extends StatefulWidget {
  const PrinterScreen({super.key});

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  String _platformVersion = 'Unknown';

  String bluetoothMacAddress = 'Unknown MAC';
  String connectStatus = "Disconnect";
  final TextEditingController textEditingController = TextEditingController();

  final _xprinterPrintImagePlugin = XprinterPrintImagePlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    XprinterPrintImagePlugin.onPrinterStatus().listen((event) {
      log('onPrinter Status $event');
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion = await _xprinterPrintImagePlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Text('Running on: $_platformVersion'),
                  Text('MAC ADDRESS $bluetoothMacAddress'),
                  Text('CONNECT STATUS $connectStatus'),
                ],
              ),
              TextField(
                controller: textEditingController,
              ),
              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return DeviceListScreen();
                    }),
                  );

                  BluetoothDeviceVO bluetoothDeviceVO = result;
                  bluetoothMacAddress = "${bluetoothDeviceVO.deviceIdentifier}";
                  log(">>>>> ${bluetoothDeviceVO.deviceIdentifier}");

                  log(">>>>> ${bluetoothDeviceVO.deviceName}");
                },
                child: const Text("Select Device"),
              ),
              ElevatedButton(
                onPressed: connectDevice,
                child: const Text("Connect Device"),
              ),
              ElevatedButton(
                onPressed: disconnectDevice,
                child: const Text("Disconnect Device"),
              ),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text("Select Image"),
              ),
              ElevatedButton(
                onPressed: printText,
                child: const Text("Print Text"),
              ),
              ElevatedButton(
                onPressed: selectImage,
                child: const Text("Print Image"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void selectImage() {
    XprinterPrintImagePlugin.platformVersion;
    log("Select Image");
  }

  void connectDevice() {
    XprinterPrintImagePlugin.connectDevice(
      macAddress: bluetoothMacAddress,
    ).then((res) {
      if (res == ConnectStatus.connectSuccess.code) {
        connectStatus = "Connected";
      } else {
        connectStatus = "Disconnect";
      }
      setState(() {});
    });
  }

  pickImage() async {
    final ImagePicker picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result != null) printImage(result.path);
  }

  printText() async {
    final text = textEditingController.text.toString().trim();
    if (text.isEmpty) {
      return;
    }
    XprinterPrintImagePlugin.printText(
      text: text,
      feedLine: 5,
      distance: 3,
    );
  }

  printImage(
    String filePath, {
    double? imageWidth,
  }) {
    XprinterPrintImagePlugin.printImage(filePath: filePath);
  }

  void disconnectDevice() {
    XprinterPrintImagePlugin.disconnectDevice();
  }
}
