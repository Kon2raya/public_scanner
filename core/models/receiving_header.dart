class ReceivingHeader {
  final String rcvhdrId;
  final String rcvNo;
  final String receivedBy;
  final String receiveDate;
  final String status;
  final String createdBy;
  final String poRef;
  final String invNo;

  ReceivingHeader({
    required this.rcvhdrId,
    required this.rcvNo,
    required this.receivedBy,
    required this.receiveDate,
    required this.status,
    required this.createdBy,
    required this.poRef,
    required this.invNo,
  });

  factory ReceivingHeader.fromJson(Map<String, dynamic> json) {
    return ReceivingHeader(
      rcvhdrId: json['rcvhdr_id'].toString(),
      rcvNo: json['rcv_no'],
      receivedBy: json['receive_by'] ?? '',
      receiveDate: json['receive_date'] ?? '',
      status: json['status'],
      createdBy: json['created_by'] ?? '',
      poRef: json['po_ref'].toString(),
      invNo: json['invoice_no'].toString(),
    );
  }
}
