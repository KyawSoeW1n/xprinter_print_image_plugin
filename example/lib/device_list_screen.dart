import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'bluetooth_device_vo.dart';

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
  final Set<BluetoothDeviceVO> seen = {};
  int _secondsRemaining = 5; // Initialize the timer with 5 seconds
  late Timer _timer;

  _stopScan() async {
    await FlutterBluePlus.stopScan();
    setState(() {});
  }

  void _startTimer() {
    _secondsRemaining = 5;
    _getBluetoothDeviceList();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_secondsRemaining > 0) {
        _secondsRemaining--;
      } else {
        _stopScan();
        // setState(() {});
        // Timer has completed, you can perform any action here
        _timer.cancel(); // Cancel the timer when it's no longer needed
      }
    });
  }

  void _getBluetoothDeviceList() async {
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
    } catch (e) {
      log('Error: $e');
    }

    await FlutterBluePlus.startScan();
    FlutterBluePlus.scanResults.listen((results) {
      for (ScanResult r in results) {
        final isExist = seen
            .any((element) => element.deviceIdentifier == r.device.remoteId);
        if (!isExist) {
          seen.add(BluetoothDeviceVO(r.device.remoteId, r.device.localName));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device List"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startTimer,
                    child: const Text("Start Scan"),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _stopScan,
                    child: const Text("Stop Scan"),
                  ),
                ),
              ],
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        // Build your list item here
                        return ListTile(
                          onTap: () {
                            Navigator.pop(
                              context,
                              seen.elementAt(index),
                            );
                          },
                          title: Text(seen.elementAt(index).deviceName),
                          subtitle:
                              Text("${seen.elementAt(index).deviceIdentifier}"),
                        );
                      },
                      childCount: seen.length, // Number of items in the list
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
