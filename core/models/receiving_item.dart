class ReceivingItem {
  final String itemCode;
  final String itemDescripion;
  final int isSerialized;
  final String invUom;

  ReceivingItem({
    required this.itemCode,
    required this.itemDescripion,
    required this.isSerialized,
    required this.invUom,
  });

  factory ReceivingItem.fromJson(Map<String, dynamic> json) {
    return ReceivingItem(
      itemCode: json['item_code'],
      itemDescripion: json['item_description'],
      isSerialized: json['serialize'],
      invUom: json['uom_inv'],
    );
  }

  toJson() {}
}
