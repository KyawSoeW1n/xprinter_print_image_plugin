import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xprinter_print_image_plugin/connect_status.dart';
import 'package:xprinter_print_image_plugin/xprinter_print_image_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String bluetoothMacAddress = 'Unknown MAC';
  String connectStatus = "Disconnect";

  final _xprinterPrintImagePlugin = XprinterPrintImagePlugin();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    XprinterPrintImagePlugin.onPrintStatus().listen((event) {
      log('onPrint Status $event');
    });
    _getBluetoothMacAddress();
  }

  void _getBluetoothMacAddress() async {
    try {
      if (await FlutterBluePlus.isAvailable == false) {
        log("Bluetooth not supported by this device");
        return;
      }
      if (Platform.isAndroid) {
        await FlutterBluePlus.turnOn();
      }

// wait bluetooth to be on & print states
// note: for iOS the initial state is typically BluetoothAdapterState.unknown
// note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
      await FlutterBluePlus.adapterState
          .map((s) {
            log(">>> $s ${s.name}");
            return s;
          })
          .where((s) => s == BluetoothAdapterState.on)
          .first;
    } catch (e) {
      print('Error: $e');
      setState(() {
        bluetoothMacAddress = 'Error: $e';
      });
    }

    Set<DeviceIdentifier> seen = {};
    await FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (seen.contains(r.device.remoteId) == false) {
          log('SCAN RESULT ${r.device.remoteId}: "${r.device.localName}" found! rssi: ${r.rssi} .. ${r.device}');
          seen.add(r.device.remoteId);
        }
      }
    });
    bluetoothMacAddress = "10:22:33:EB:63:16";
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              Text('Running on: $_platformVersion\n'),
              Text('MAC ADDRESS $bluetoothMacAddress'),
              Text('CONNECT STATUS $connectStatus'),
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

  printImage(String filePath) {
    XprinterPrintImagePlugin.printImage(filePath: filePath);
  }

  void disconnectDevice() {
    XprinterPrintImagePlugin.disconnectDevice();
  }
}
