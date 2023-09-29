enum ConnectStatus {
  printTextSuccess(111),
  printImageSuccess(222);

  final int code;

  const ConnectStatus(this.code);
}
