// lib/core/services/pallet_service.dart
import 'package:aai_scanner_epson/core/models/pallet.dart';
import 'package:aai_scanner_epson/features/auth/services/auth_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PalletService {
  static const String _boxName = 'palletizing_data';
  static final AuthService _authService = AuthService();

  // ==================== LOCAL STORAGE OPERATIONS ====================

  static Future<List<Pallet>> getLocalPallets() async {
    try {
      final box = await Hive.openBox(_boxName);
      final pallets = box.values
          .map(
            (item) => Pallet.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
      return pallets;
    } catch (e) {
      throw Exception('Failed to load local pallets: $e');
    }
  }

  static Future<void> savePallet(Pallet pallet) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(pallet.palletId, pallet.toJson());
    } catch (e) {
      throw Exception('Failed to save pallet: $e');
    }
  }

  static Future<void> updatePallet(
    String palletId,
    Pallet updatedPallet,
  ) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.put(palletId, updatedPallet.toJson());
    } catch (e) {
      throw Exception('Failed to update pallet: $e');
    }
  }

  static Future<void> deletePallet(String palletId) async {
    try {
      final box = await Hive.openBox(_boxName);
      await box.delete(palletId);
    } catch (e) {
      throw Exception('Failed to delete pallet: $e');
    }
  }

  static Future<Map<String, dynamic>?> getPalletById(String palletId) async {
    try {
      final box = await Hive.openBox(_boxName);
      final pallet = box.get(palletId);
      return pallet != null ? Map<String, dynamic>.from(pallet as Map) : null;
    } catch (e) {
      throw Exception('Failed to get pallet: $e');
    }
  }

  // ==================== ITEM OPERATIONS ====================

  static Future<void> addItemToPallet(
    String palletId,
    Map<String, dynamic> item,
  ) async {
    try {
      final box = await Hive.openBox(_boxName);
      final palletData = box.get(palletId);

      if (palletData != null) {
        final pallet = Map<String, dynamic>.from(palletData as Map);
        final items = List<Map<String, dynamic>>.from(pallet['items'] ?? []);
        items.add(item);
        pallet['items'] = items;
        pallet['updatedAt'] = DateTime.now().toIso8601String();
        await box.put(palletId, pallet);
      }
    } catch (e) {
      throw Exception('Failed to add item to pallet: $e');
    }
  }

  static Future<void> removeItemFromPallet(
    String palletId,
    int itemIndex,
  ) async {
    try {
      final box = await Hive.openBox(_boxName);
      final palletData = box.get(palletId);

      if (palletData != null) {
        final pallet = Map<String, dynamic>.from(palletData as Map);
        final items = List<Map<String, dynamic>>.from(pallet['items'] ?? []);
        if (itemIndex >= 0 && itemIndex < items.length) {
          items.removeAt(itemIndex);
          pallet['items'] = items;
          pallet['updatedAt'] = DateTime.now().toIso8601String();
          await box.put(palletId, pallet);
        }
      }
    } catch (e) {
      throw Exception('Failed to remove item from pallet: $e');
    }
  }

  // ==================== PALLET STATUS OPERATIONS ====================

  static Future<void> completePallet(String palletId) async {
    try {
      final box = await Hive.openBox(_boxName);
      final palletData = box.get(palletId);

      if (palletData != null) {
        final pallet = Map<String, dynamic>.from(palletData as Map);
        pallet['status'] = 'completed';
        pallet['completedAt'] = DateTime.now().toIso8601String();
        pallet['isSynced'] = false;
        await box.put(palletId, pallet);
      }
    } catch (e) {
      throw Exception('Failed to complete pallet: $e');
    }
  }

  // ==================== API SYNC OPERATIONS ====================

  static Future<Map<String, dynamic>> syncPallets() async {
    try {
      final box = await Hive.openBox(_boxName);
      final unsyncedPallets = <Map<String, dynamic>>[];

      for (final key in box.keys) {
        final pallet = Map<String, dynamic>.from(box.get(key) as Map);
        if (pallet['isSynced'] == false) {
          unsyncedPallets.add(pallet);
        }
      }

      if (unsyncedPallets.isEmpty) {
        return {'success': true, 'message': 'No pallets to sync', 'count': 0};
      }

      final response = await _authService.post({
        'pallets': unsyncedPallets,
      }, 'app_pallets_sync');

      if (response is Map && response['status'] == true) {
        // Mark pallets as synced
        for (final key in box.keys) {
          final pallet = Map<String, dynamic>.from(box.get(key) as Map);
          if (pallet['isSynced'] == false) {
            pallet['isSynced'] = true;
            pallet['syncedAt'] = DateTime.now().toIso8601String();
            await box.put(key, pallet);
          }
        }

        return {
          'success': true,
          'message': 'Pallets synced successfully',
          'count': unsyncedPallets.length,
        };
      }

      throw Exception('Sync failed');
    } catch (e) {
      throw Exception('Failed to sync pallets: $e');
    }
  }

  // ==================== STATISTICS & UTILITY ====================

  static Future<Map<String, int>> getPalletStatistics() async {
    try {
      final box = await Hive.openBox(_boxName);
      int total = box.length;
      int active = 0;
      int completed = 0;
      int synced = 0;
      int totalItems = 0;

      for (final key in box.keys) {
        final pallet = Map<String, dynamic>.from(box.get(key) as Map);
        if (pallet['status'] == 'completed') {
          completed++;
        } else {
          active++;
        }
        if (pallet['isSynced'] == true) {
          synced++;
        }
        final items = pallet['items'] as List? ?? [];
        totalItems += items.length;
      }

      return {
        'total': total,
        'active': active,
        'completed': completed,
        'synced': synced,
        'unsynced': total - synced,
        'totalItems': totalItems,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  static Future<int> clearSyncedPallets() async {
    try {
      final box = await Hive.openBox(_boxName);
      final keysToDelete = <dynamic>[];

      for (final key in box.keys) {
        final pallet = Map<String, dynamic>.from(box.get(key) as Map);
        if (pallet['isSynced'] == true) {
          keysToDelete.add(key);
        }
      }

      await box.deleteAll(keysToDelete);
      return keysToDelete.length;
    } catch (e) {
      throw Exception('Failed to clear synced pallets: $e');
    }
  }

  static Future<bool> palletIdExists(String palletId) async {
    try {
      final box = await Hive.openBox(_boxName);
      return box.containsKey(palletId);
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> validatePallet(String palletId) async {
    try {
      final pallet = await getPalletById(palletId);

      if (pallet == null) {
        return {
          'valid': false,
          'errors': ['Pallet not found'],
        };
      }

      final errors = <String>[];

      if (pallet['customerId'] == null || pallet['customerId'] == 0) {
        errors.add('Customer is required');
      }

      if (pallet['satelliteId'] == null || pallet['satelliteId'] == 0) {
        errors.add('Satellite is required');
      }

      final items = pallet['items'] as List? ?? [];
      if (items.isEmpty) {
        errors.add('Pallet must have at least one item');
      }

      return {'valid': errors.isEmpty, 'errors': errors};
    } catch (e) {
      return {
        'valid': false,
        'errors': ['Validation error: $e'],
      };
    }
  }
}
