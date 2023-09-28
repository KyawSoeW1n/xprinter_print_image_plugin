import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BluetoothDeviceVO {
  final DeviceIdentifier deviceIdentifier;
  final String deviceName;

  BluetoothDeviceVO(
    this.deviceIdentifier,
    this.deviceName,
  );
}
