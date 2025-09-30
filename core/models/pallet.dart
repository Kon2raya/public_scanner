// lib/core/models/pallet.dart
class Pallet {
  final String palletId;
  final int customerId;
  final String customerName;
  final int satelliteId;
  final String satelliteName;
  final int userId;
  final String createdAt;
  final String? completedAt;
  final String status;
  final List<Map<String, dynamic>> items;
  final bool isSynced;

  Pallet({
    required this.palletId,
    required this.customerId,
    required this.customerName,
    required this.satelliteId,
    required this.satelliteName,
    required this.userId,
    required this.createdAt,
    this.completedAt,
    required this.status,
    required this.items,
    this.isSynced = false,
  });

  factory Pallet.fromJson(Map<String, dynamic> json) {
    return Pallet(
      palletId: json['palletId'] ?? '',
      customerId: json['customerId'] ?? 0,
      customerName: json['customerName'] ?? '',
      satelliteId: json['satelliteId'] ?? 0,
      satelliteName: json['satelliteName'] ?? '',
      userId: json['userId'] ?? 0,
      createdAt: json['createdAt'] ?? '',
      completedAt: json['completedAt'],
      status: json['status'] ?? 'active',
      items: List<Map<String, dynamic>>.from(json['items'] ?? []),
      isSynced: json['isSynced'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'palletId': palletId,
      'customerId': customerId,
      'customerName': customerName,
      'satelliteId': satelliteId,
      'satelliteName': satelliteName,
      'userId': userId,
      'createdAt': createdAt,
      'completedAt': completedAt,
      'status': status,
      'items': items,
      'isSynced': isSynced,
    };
  }

  Pallet copyWith({
    String? palletId,
    int? customerId,
    String? customerName,
    int? satelliteId,
    String? satelliteName,
    int? userId,
    String? createdAt,
    String? completedAt,
    String? status,
    List<Map<String, dynamic>>? items,
    bool? isSynced,
  }) {
    return Pallet(
      palletId: palletId ?? this.palletId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      satelliteId: satelliteId ?? this.satelliteId,
      satelliteName: satelliteName ?? this.satelliteName,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      items: items ?? this.items,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}

// lib/core/models/pallet_item.dart
class PalletItem {
  final String itemCode;
  final int quantity;
  final String scannedAt;
  final String? description;
  final String? uom;

  PalletItem({
    required this.itemCode,
    required this.quantity,
    required this.scannedAt,
    this.description,
    this.uom,
  });

  factory PalletItem.fromJson(Map<String, dynamic> json) {
    return PalletItem(
      itemCode: json['itemCode'] ?? '',
      quantity: json['quantity'] ?? 0,
      scannedAt: json['scannedAt'] ?? '',
      description: json['description'],
      uom: json['uom'],
    );
  }

  factory PalletItem.fromMap(Map<String, dynamic> map) {
    return PalletItem(
      itemCode: map['itemCode'] ?? '',
      quantity: map['quantity'] ?? 0,
      scannedAt: map['scannedAt'] ?? '',
      description: map['description'],
      uom: map['uom'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemCode': itemCode,
      'quantity': quantity,
      'scannedAt': scannedAt,
      'description': description,
      'uom': uom,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'itemCode': itemCode,
      'quantity': quantity,
      'scannedAt': scannedAt,
      'description': description,
      'uom': uom,
    };
  }

  PalletItem copyWith({
    String? itemCode,
    int? quantity,
    String? scannedAt,
    String? description,
    String? uom,
  }) {
    return PalletItem(
      itemCode: itemCode ?? this.itemCode,
      quantity: quantity ?? this.quantity,
      scannedAt: scannedAt ?? this.scannedAt,
      description: description ?? this.description,
      uom: uom ?? this.uom,
    );
  }
}
