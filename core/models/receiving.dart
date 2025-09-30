class Receiving {
  final int rcvhdrId;
  final String rcvNo;

  Receiving({required this.rcvhdrId, required this.rcvNo});

  factory Receiving.fromJson(Map<String, dynamic> json) {
    return Receiving(rcvhdrId: json['rcvhdr_id'], rcvNo: json['rcv_no']);
  }
}
