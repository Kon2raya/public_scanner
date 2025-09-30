class Item {
  final int itemId;
  final String itemCode;
  final String itemDescription;

  Item({
    required this.itemId,
    required this.itemCode,
    required this.itemDescription,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json['item_id'],
      itemCode: json['item_code'],
      itemDescription: json['item_description'],
    );
  }
}
