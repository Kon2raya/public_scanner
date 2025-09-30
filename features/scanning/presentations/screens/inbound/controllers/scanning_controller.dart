// lib/features/scanning/presentations/screens/inbound/controllers/scanning_controller.dart
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/models/receiving_item.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum ScanningStep {
  searchRcv,
  scanPalletId,
  scanSkuPerPallet,
  scanBoxLabel,
  scanSerialNumber,
  save,
  addMoreSku, // New step for adding more SKUs to same pallet
  autoUpload,
  end,
}

class ScanningController extends ChangeNotifier {
  ScanningStep currentStep = ScanningStep.searchRcv;
  String? rcvNumber;
  List<ReceivingItem> items = [];
  ReceivingItem? currentItem;
  bool isCurrentItemSerialized =
      false; // Track current scanned item serialization

  // Scanned data
  String? scannedPalletId;
  String? scannedSku;
  int? scannedQuantity;
  String? scannedBoxLabel;
  List<String> scannedSerialNumbers =
      []; // Changed to list for multiple serials

  List<Map<String, dynamic>> scannedData = [];

  // Current pallet data
  String? currentPalletId;
  List<Map<String, dynamic>> currentPalletItems = []; // SKUs for current pallet

  void startScanning(String rcvNo, List<ReceivingItem> receivingItems) {
    rcvNumber = rcvNo;
    items = receivingItems;
    currentStep = ScanningStep.scanPalletId;
    notifyListeners();
  }

  void scanPalletId(String palletId) {
    scannedPalletId = palletId;
    currentPalletId = palletId; // Make sure this is set
    // Always go to SKU scanning after pallet ID
    currentPalletItems.clear(); // Clear previous pallet items
    currentStep = ScanningStep.scanSkuPerPallet;
    notifyListeners();
  }

  void scanSkuAndQuantity(String sku, int quantity) {
    // Check if quantity is valid (cannot be 0 or negative)
    if (quantity <= 0) {
      // Don't proceed with scanning if quantity is invalid
      return;
    }

    scannedSku = sku;
    scannedQuantity = quantity;

    // Find the item and check if it's serialized
    currentItem = items.firstWhere(
      (item) => item.itemCode.toLowerCase() == sku.toLowerCase(),
    );

    isCurrentItemSerialized = currentItem?.isSerialized == 1;

    if (isCurrentItemSerialized) {
      // Clear previous serials and start fresh
      scannedSerialNumbers.clear();
      currentStep = ScanningStep.scanSerialNumber;
    } else {
      currentStep = ScanningStep.scanBoxLabel;
    }
    notifyListeners();
  }

  // New method to validate and add serial number
  Future<String?> validateAndAddSerialNumber(String serialNumber) async {
    // Validation 1: Serial should not be the same as SKU
    if (serialNumber.toLowerCase() == scannedSku?.toLowerCase()) {
      return "Serial number cannot be the same as SKU";
    }
    // Validation 2: Serial should not be duplicate in current scan
    if (scannedSerialNumbers.contains(serialNumber)) {
      return "Serial number already scanned";
    }
    // Validation 3: Check against Hive stored data
    final box = await Hive.openBox('scanned_pallets');
    final existingPallets = box.values
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    for (final pallet in existingPallets) {
      final rawItems = pallet['items'] as List? ?? [];
      final items = rawItems.map((e) => Map<String, dynamic>.from(e)).toList();

      for (final item in items) {
        final existingSerials =
            (item['serialNumbers'] as List?)
                ?.map((s) => s.toString())
                .toList() ??
            [];
        if (existingSerials.contains(serialNumber)) {
          return "Serial number already exists in stored data";
        }
      }
    }

    // Validation 4: Serial should not be duplicate in current pallet items
    for (final palletItem in currentPalletItems) {
      final List<String>? palletSerials = palletItem['serialNumbers']
          ?.cast<String>();
      if (palletSerials != null && palletSerials.contains(serialNumber)) {
        return "Serial number already used in this pallet";
      }
    }
    // Validation 5: Cannot exceed quantity
    if (scannedSerialNumbers.length >= (scannedQuantity ?? 0)) {
      return "All serial numbers for this quantity have been scanned";
    }
    // Add serial number if all validations pass
    scannedSerialNumbers.add(serialNumber);
    notifyListeners();
    // Check if all serials are scanned
    if (scannedSerialNumbers.length == scannedQuantity) {
      currentStep = ScanningStep.save;
      notifyListeners();
    }
    return null; // Success
  }

  void scanBoxLabel(String boxLabel) {
    scannedBoxLabel = boxLabel;
    currentStep = ScanningStep.save;
    notifyListeners();
  }

  void saveCurrentSku() {
    final skuData = {
      'sku': scannedSku,
      'quantity': scannedQuantity,
      'boxLabel': scannedBoxLabel,
      'serialNumbers': isCurrentItemSerialized
          ? List<String>.from(scannedSerialNumbers)
          : null,
      'isSerialized': isCurrentItemSerialized,
      'itemData': currentItem?.toJson(),
      'timestamp': DateTime.now().toIso8601String(), // Add this line if missing
    };

    currentPalletItems.add(skuData);
    _resetCurrentSku();
    currentStep = ScanningStep.addMoreSku;
    notifyListeners();
  }

  void addMoreSkuToPallet() {
    _resetCurrentSku();
    currentStep = ScanningStep.scanSkuPerPallet;
    notifyListeners();
  }

  Future<void> finalizePallet() async {
    if (currentPalletId == null || currentPalletItems.isEmpty) {
      throw Exception('Cannot save empty pallet data');
    }

    final palletData = {
      'rcvNumber': rcvNumber,
      'palletId': currentPalletId,
      'items': List<Map<String, dynamic>>.from(currentPalletItems),
      'timestamp': DateTime.now().toIso8601String(),
      'totalSkus': currentPalletItems.length,
      'isSynced': false,
    };

    // merge/validate
    await _validatePalletData(palletData);

    final box = await Hive.openBox('scanned_pallets');

    // ✅ use palletId as the key
    await box.put(currentPalletId, palletData);

    // update UI list
    scannedData.removeWhere((p) => p['palletId'] == currentPalletId);
    scannedData.add(palletData);

    _resetPallet();
    currentStep = ScanningStep.end;
    notifyListeners();
  }

  Future<void> _validatePalletData(Map<String, dynamic> newPalletData) async {
    final box = await Hive.openBox('scanned_pallets');
    final newPalletId = newPalletData['palletId'];

    if (box.containsKey(newPalletId)) {
      final existingPallet = Map<String, dynamic>.from(box.get(newPalletId));
      final existingItems = (existingPallet['items'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      final newItems = (newPalletData['items'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      for (final newItem in newItems) {
        final idx = existingItems.indexWhere(
          (e) => e['itemCode'] == newItem['itemCode'],
        );
        if (idx != -1) {
          existingItems[idx]['quantity'] =
              (existingItems[idx]['quantity'] ?? 0) +
              (newItem['quantity'] ?? 0);

          if (newItem['isSerialized'] == true) {
            final existingSerials =
                ((existingItems[idx]['serialNumbers'] as List?) ?? [])
                    .map((s) => s.toString())
                    .toSet();
            final newSerials = ((newItem['serialNumbers'] as List?) ?? []).map(
              (s) => s.toString(),
            );
            existingSerials.addAll(newSerials);
            existingItems[idx]['serialNumbers'] = existingSerials.toList();
          }
        } else {
          existingItems.add(newItem);
        }
      }

      existingPallet['items'] = existingItems;
      await box.put(newPalletId, existingPallet);
    } else {
      await box.put(newPalletId, newPalletData);
    }
  }

  void _resetCurrentSku() {
    scannedSku = null;
    scannedQuantity = null;
    scannedBoxLabel = null;
    scannedSerialNumbers.clear();
    currentItem = null;
    isCurrentItemSerialized = false;
  }

  void _resetPallet() {
    currentPalletId = null;
    currentPalletItems.clear();
    _resetCurrentSku();
  }

  void _resetCurrentScan() {
    scannedPalletId = null;
    scannedSku = null;
    scannedQuantity = null;
    scannedBoxLabel = null;
    scannedSerialNumbers.clear();
    currentItem = null;
    isCurrentItemSerialized = false;
  }

  Future<void> autoUploadToWMS() async {
    currentStep = ScanningStep.autoUpload;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));

      currentStep = ScanningStep.end;
    } catch (e) {
      // Handle upload error
    }
    notifyListeners();
  }

  void endScanning() {
    currentStep = ScanningStep.end;
    _resetCurrentScan();
    scannedData.clear();
    notifyListeners();
  }

  void continueScanning() {
    _resetCurrentScan();
    currentStep = ScanningStep.scanPalletId;
    notifyListeners();
  }

  // Add to scanning_controller.dart
  bool canGoToPreviousStep() {
    switch (currentStep) {
      case ScanningStep.scanPalletId:
        return false; // First step, can't go back
      case ScanningStep.scanSkuPerPallet:
        return true; // Can go back to pallet ID
      case ScanningStep.scanBoxLabel:
      case ScanningStep.scanSerialNumber:
        return true; // Can go back to SKU scan
      case ScanningStep.save:
        return true; // Can go back to previous scan step
      case ScanningStep.addMoreSku:
        return true; // Can go back to save step
      case ScanningStep.end:
        return true; // Can go back to add more SKU
      default:
        return false;
    }
  }

  void goToPreviousStep() {
    switch (currentStep) {
      case ScanningStep.scanSkuPerPallet:
        currentStep = ScanningStep.scanPalletId;
        // Clear current SKU data
        scannedSku = null;
        scannedQuantity = null;
        break;
      case ScanningStep.scanBoxLabel:
      case ScanningStep.scanSerialNumber:
        currentStep = ScanningStep.scanSkuPerPallet;
        // Keep SKU data but clear box label or serials
        scannedBoxLabel = null;
        scannedSerialNumbers.clear();
        break;
      case ScanningStep.save:
        // Go back to either box label or serial number based on item type
        if (isCurrentItemSerialized) {
          currentStep = ScanningStep.scanSerialNumber;
        } else {
          currentStep = ScanningStep.scanBoxLabel;
        }
        break;
      case ScanningStep.addMoreSku:
        currentStep = ScanningStep.save;
        break;
      case ScanningStep.end:
        currentStep = ScanningStep.addMoreSku;
        break;
      default:
        break;
    }
    notifyListeners();
  }

  // Helper getters
  int get remainingSerials =>
      (scannedQuantity ?? 0) - scannedSerialNumbers.length;
  bool get allSerialsScanned =>
      isCurrentItemSerialized && scannedSerialNumbers.length == scannedQuantity;
  int get currentPalletSkuCount => currentPalletItems.length;
  int get totalScannedPallets => scannedData.length;

  // Get all scanned pallets from Hive
  Future<List<Map<String, dynamic>>> getAllScannedItems() async {
    final box = await Hive.openBox('scanned_pallets');
    return box.values.cast<Map<String, dynamic>>().toList();
  }

  // Get pallets that haven't been synced to server
  Future<List<Map<String, dynamic>>> getUnsyncedItems() async {
    final box = await Hive.openBox('scanned_pallets');
    return box.values
        .cast<Map<String, dynamic>>()
        .where((pallet) => pallet['isSynced'] == false)
        .toList();
  }

  // Mark pallet as synced
  Future<void> markItemAsSynced(String palletId) async {
    final box = await Hive.openBox('scanned_pallets');
    final pallet = box.get(palletId);
    if (pallet != null) {
      pallet['isSynced'] = true;
      await box.put(palletId, pallet);
    }
  }

  // Load previous scanned data on app start
  Future<void> loadPreviousData() async {
    scannedData.clear();
    scannedData.addAll(await getAllScannedItems());
    notifyListeners();
  }
}
