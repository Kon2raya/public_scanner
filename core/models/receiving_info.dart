class ReceivingInfo {
  final String rcvhdrId;
  final String rcvNo;

  ReceivingInfo({required this.rcvhdrId, required this.rcvNo});

  factory ReceivingInfo.fromJson(Map<String, dynamic> json) {
    return ReceivingInfo(
      rcvhdrId: json['rcvhdr_id'].toString(),
      rcvNo: json['rcv_no'],
    );
  }
}
