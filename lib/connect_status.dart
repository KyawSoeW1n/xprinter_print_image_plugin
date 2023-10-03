enum ConnectStatus {
  connectSuccess(1),
  connectFail(2),
  sendFail(3),
  connectInterrupt(4),
  usbAttached(5),
  bluetoothInterrupt(6),
  disconnect(888);

  final int code;

  const ConnectStatus(this.code);
}
