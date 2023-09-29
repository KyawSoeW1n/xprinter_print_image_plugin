import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

final Map<DeviceIdentifier, ValueNotifier<bool>> isConnectingOrDisconnecting =
    {};

class DeviceListScreen extends StatefulWidget {
  const DeviceListScreen({super.key});

  @override
  State<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends State<DeviceListScreen> {
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Device List"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<bool>(
              stream: FlutterBluePlus.isScanning,
              initialData: false,
              builder: (c, snapshot) {
                if (snapshot.data ?? false) {
                  return ElevatedButton(
                    onPressed: () async {
                      try {
                        FlutterBluePlus.stopScan();
                      } catch (e) {
                        log("Stop Scan Error $e");
                      }
                    },
                    child: const Icon(Icons.stop),
                  );
                } else {
                  return ElevatedButton(
                    child: const Text("SCAN"),
                    onPressed: () async {
                      try {
                        await FlutterBluePlus.startScan(
                            timeout: const Duration(seconds: 15),
                            androidUsesFineLocation: false);
                      } catch (e) {
                        log("Stop Scan Error $e");
                      }
                      setState(
                        () {},
                      ); // force refresh of connectedSystemDevices
                    },
                  );
                }
              },
            ),
            StreamBuilder<List<ScanResult>>(
              stream: FlutterBluePlus.scanResults,
              initialData: const [],
              builder: (c, snapshot) => snapshot.data != null
                  ? Expanded(
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
                                      snapshot.data![index],
                                    );
                                  },
                                  title: Text(
                                      snapshot.data![index].device.localName),
                                  subtitle: Text(
                                      "${snapshot.data![index].device.remoteId}"),
                                );
                              },
                              childCount: snapshot
                                  .data!.length, // Number of items in the list
                            ),
                          ),
                        ],
                      ),
                  )
                  : const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
