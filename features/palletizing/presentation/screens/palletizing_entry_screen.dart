// lib/features/palletizing/presentation/screens/palletizing_entry_screen.dart
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/models/customer.dart';
import 'package:aai_scanner_epson/core/models/satellite.dart';
import 'package:aai_scanner_epson/core/models/pallet.dart';
import 'package:aai_scanner_epson/core/services/customer_service.dart';
import 'package:aai_scanner_epson/core/services/satellite_service.dart';
import 'package:aai_scanner_epson/core/services/pallet_service.dart';
import 'package:aai_scanner_epson/core/utils/dialog_utils.dart';
import 'package:aai_scanner_epson/core/utils/user_utils.dart';
import 'package:aai_scanner_epson/core/widgets/app_scaffold.dart';
import 'package:aai_scanner_epson/features/palletizing/presentation/screens/widgets/palletizing_form_widget.dart';
import 'package:aai_scanner_epson/features/palletizing/presentation/screens/widgets/pallet_items_widget.dart';
import 'package:aai_scanner_epson/features/palletizing/presentation/screens/widgets/active_pallets_widget.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/widgets/scanner_overlay_widget.dart';
import 'package:flutter/material.dart';

class PalletizingEntryScreen extends StatefulWidget {
  const PalletizingEntryScreen({super.key});

  @override
  State<PalletizingEntryScreen> createState() => _PalletizingEntryScreenState();
}

class _PalletizingEntryScreenState extends State<PalletizingEntryScreen> {
  // Controllers
  final customerCtrl = TextEditingController();
  final satelliteCtrl = TextEditingController();
  final palletIdCtrl = TextEditingController();

  // IDs
  int customerId = 0;
  int satelliteId = 0;
  int userId = 0;

  // Selected objects
  Customer? selectedCustomer;
  Satellite? selectedSatellite;
  String? currentPalletId;
  List<PalletItem> currentPalletItems = [];
  List<Map<String, dynamic>> activePallets = [];
  Map<String, int>? statistics;

  // State
  bool showScanner = false;
  bool isLoading = false;
  bool isLoaded = false;
  bool isPalletActive = false;
  bool isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadUserAndData();
  }

  Future<void> _loadUserAndData() async {
    try {
      final user = await UserUtils.getUserInfo();
      if (mounted) {
        setState(() {
          userId = user['id'] ?? 0;
        });
        await _loadActivePallets();
        await _loadStatistics();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadActivePallets() async {
    try {
      final pallets = await PalletService.getLocalPallets();
      if (mounted) {
        setState(() {
          activePallets = pallets.map((p) => p.toJson()).toList();
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadStatistics() async {
    try {
      final stats = await PalletService.getPalletStatistics();
      if (mounted) {
        setState(() {
          statistics = stats;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<List<Customer>> _customerList(String query) => userId == 0
      ? Future.value([])
      : CustomerService.fetchCustomerList(userId: userId, query: query);

  Future<List<Satellite>> _satelliteList(String query) => userId == 0
      ? Future.value([])
      : SatelliteService.fetchSatelliteList(userId: userId, query: query);

  void _clearField(TextEditingController ctrl, VoidCallback resetState) {
    setState(() {
      ctrl.clear();
      resetState();
      isLoaded = false;
      currentPalletItems = [];
    });
  }

  Future<void> _createNewPallet() async {
    if (customerId == 0 || satelliteId == 0 || palletIdCtrl.text.isEmpty) {
      DialogUtils.showCustomDialog(
        context: context,
        title: 'Incomplete Data',
        icon: Icons.info,
        warning: false,
        success: false,
        message: "Please fill all fields to create a new pallet.",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Check if pallet ID already exists
      final exists = await PalletService.palletIdExists(palletIdCtrl.text);

      if (exists) {
        if (mounted) {
          DialogUtils.showCustomDialog(
            context: context,
            title: 'Duplicate Pallet',
            icon: Icons.warning,
            warning: true,
            success: false,
            message: "A pallet with this ID already exists.",
          );
          setState(() => isLoading = false);
        }
        return;
      }

      final newPallet = Pallet(
        palletId: palletIdCtrl.text,
        customerId: customerId,
        customerName: selectedCustomer?.customerName ?? '',
        satelliteId: satelliteId,
        satelliteName: selectedSatellite?.satelliteName ?? '',
        userId: userId,
        createdAt: DateTime.now().toIso8601String(),
        items: [],
        status: 'active',
        isSynced: false,
      );

      // Save to local storage
      await PalletService.savePallet(newPallet);

      await _loadActivePallets();
      await _loadStatistics();

      if (mounted) {
        setState(() {
          currentPalletId = palletIdCtrl.text;
          isPalletActive = true;
          isLoaded = true;
          isLoading = false;
        });

        DialogUtils.showCustomDialog(
          context: context,
          title: 'Success',
          icon: Icons.check_circle,
          warning: false,
          success: true,
          message: "Pallet created successfully!",
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        DialogUtils.showCustomDialog(
          context: context,
          title: 'Error',
          icon: Icons.error,
          warning: false,
          success: false,
          message: "Failed to create pallet: $e",
        );
      }
    }
  }

  void _onCustomerSelected(Customer customer) {
    setState(() {
      customerCtrl.text = customer.customerName;
      customerId = customer.customerId;
      selectedCustomer = customer;
      isLoaded = false;
      currentPalletItems = [];
    });
  }

  void _onSatelliteSelected(Satellite satellite) {
    setState(() {
      satelliteCtrl.text = satellite.satelliteName;
      satelliteId = satellite.satelliteId;
      selectedSatellite = satellite;
      isLoaded = false;
      currentPalletItems = [];
    });
  }

  void _onScanPressed() {
    setState(() => showScanner = true);
  }

  void _onScanDetected(String code) async {
    setState(() {
      palletIdCtrl.text = code;
      showScanner = false;
    });
  }

  void _onScannerClose() {
    setState(() => showScanner = false);
  }

  Future<void> _onItemsScanned(List<Map<String, dynamic>> newItems) async {
    try {
      for (final item in newItems) {
        await PalletService.addItemToPallet(currentPalletId!, item);
      }

      // Reload current pallet data
      final pallet = await PalletService.getPalletById(currentPalletId!);
      if (pallet != null) {
        final items = List<Map<String, dynamic>>.from(pallet['items'] ?? []);
        setState(() {
          currentPalletItems = items.map((i) => PalletItem.fromMap(i)).toList();
        });
      }

      await _loadStatistics();
    } catch (e) {
      if (mounted) {
        DialogUtils.showCustomDialog(
          context: context,
          title: 'Error',
          icon: Icons.error,
          warning: false,
          success: false,
          message: "Failed to add items: $e",
        );
      }
    }
  }

  Future<void> _onDeleteItem(int index) async {
    try {
      await PalletService.removeItemFromPallet(currentPalletId!, index);

      setState(() {
        currentPalletItems.removeAt(index);
      });

      await _loadStatistics();
    } catch (e) {
      if (mounted) {
        DialogUtils.showCustomDialog(
          context: context,
          title: 'Error',
          icon: Icons.error,
          warning: false,
          success: false,
          message: "Failed to delete item: $e",
        );
      }
    }
  }

  Future<void> _onCompletePallet() async {
    if (currentPalletId == null) return;

    // Validate pallet before completing
    final validation = await PalletService.validatePallet(currentPalletId!);
    if (!validation['valid']) {
      if (mounted) {
        DialogUtils.showCustomDialog(
          context: context,
          title: 'Validation Error',
          icon: Icons.warning,
          warning: true,
          success: false,
          message: (validation['errors'] as List).join('\n'),
        );
      }
      return;
    }

    try {
      await PalletService.completePallet(currentPalletId!);
      await _loadActivePallets();
      await _loadStatistics();

      if (mounted) {
        setState(() {
          currentPalletId = null;
          isPalletActive = false;
          isLoaded = false;
          currentPalletItems = [];
          palletIdCtrl.clear();
        });

        DialogUtils.showCustomDialog(
          context: context,
          title: 'Success',
          icon: Icons.check_circle,
          warning: false,
          success: true,
          message: "Pallet completed successfully!",
        );
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showCustomDialog(
          context: context,
          title: 'Error',
          icon: Icons.error,
          warning: false,
          success: false,
          message: "Failed to complete pallet: $e",
        );
      }
    }
  }

  Future<void> _onDeletePallet(String palletId) async {
    try {
      await PalletService.deletePallet(palletId);
      await _loadActivePallets();
      await _loadStatistics();

      if (mounted) {
        if (currentPalletId == palletId) {
          setState(() {
            currentPalletId = null;
            isPalletActive = false;
            isLoaded = false;
            currentPalletItems = [];
            palletIdCtrl.clear();
          });
        }

        DialogUtils.showCustomDialog(
          context: context,
          title: 'Success',
          icon: Icons.check_circle,
          warning: false,
          success: true,
          message: "Pallet deleted successfully!",
        );
      }
    } catch (e) {
      if (mounted) {
        DialogUtils.showCustomDialog(
          context: context,
          title: 'Error',
          icon: Icons.error,
          warning: false,
          success: false,
          message: "Failed to delete pallet: $e",
        );
      }
    }
  }

  Future<void> _onSyncPallets() async {
    setState(() => isSyncing = true);

    try {
      final result = await PalletService.syncPallets();

      await _loadActivePallets();
      await _loadStatistics();

      if (mounted) {
        setState(() => isSyncing = false);

        DialogUtils.showCustomDialog(
          context: context,
          title: 'Sync Complete',
          icon: Icons.cloud_done,
          warning: false,
          success: true,
          message: result['message'] ?? 'Pallets synced successfully',
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSyncing = false);

        DialogUtils.showCustomDialog(
          context: context,
          title: 'Sync Error',
          icon: Icons.cloud_off,
          warning: false,
          success: false,
          message: "Failed to sync pallets: $e",
        );
      }
    }
  }

  TabBar get _tabBar => const TabBar(
    indicator: BoxDecoration(color: Colors.white),
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: AppColors.primaryRed,
    unselectedLabelColor: Colors.white,
    tabs: [
      Tab(text: 'Setup', icon: Icon(Icons.settings)),
      Tab(text: 'Items', icon: Icon(Icons.inventory)),
      Tab(text: 'Pallets', icon: Icon(Icons.view_list)),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppScaffold(
          title: 'Palletizing',
          tabCount: 3,
          tabBarAtBottom: true,
          tabBar: _tabBar,
          body: TabBarView(
            children: [
              // Tab 1: Palletizing Form
              SingleChildScrollView(
                padding: const EdgeInsets.all(5),
                child: RepaintBoundary(
                  child: PalletizingFormWidget(
                    customerController: customerCtrl,
                    satelliteController: satelliteCtrl,
                    palletIdController: palletIdCtrl,
                    customerListFuture: _customerList,
                    satelliteListFuture: _satelliteList,
                    onCustomerSelected: _onCustomerSelected,
                    onSatelliteSelected: _onSatelliteSelected,
                    onCustomerClear: () => _clearField(customerCtrl, () {
                      selectedCustomer = null;
                      customerId = 0;
                    }),
                    onSatelliteClear: () => _clearField(satelliteCtrl, () {
                      selectedSatellite = null;
                      satelliteId = 0;
                    }),
                    onScanPressed: _onScanPressed,
                    onCreatePressed: _createNewPallet,
                    isLoading: isLoading,
                    isLoaded: isLoaded,
                    isPalletActive: isPalletActive,
                    currentPalletId: currentPalletId,
                  ),
                ),
              ),

              // Tab 2: Pallet Items
              Padding(
                padding: const EdgeInsets.all(5),
                child: PalletItemsWidget(
                  items: currentPalletItems,
                  isLoaded: isLoaded,
                  palletId: currentPalletId,
                  onItemsScanned: _onItemsScanned,
                  onCompletePallet: _onCompletePallet,
                  onDeleteItem: _onDeleteItem,
                ),
              ),

              // Tab 3: Active Pallets
              Padding(
                padding: const EdgeInsets.all(5),
                child: ActivePalletsWidget(
                  pallets: activePallets,
                  onDeletePallet: _onDeletePallet,
                  onSyncPallets: _onSyncPallets,
                  isSyncing: isSyncing,
                  unsyncedCount: statistics?['unsynced'] ?? 0,
                ),
              ),
            ],
          ),
        ),
        if (showScanner)
          ScannerOverlayWidget(
            onDetected: _onScanDetected,
            onClose: _onScannerClose,
          ),
      ],
    );
  }

  @override
  void dispose() {
    customerCtrl.dispose();
    satelliteCtrl.dispose();
    palletIdCtrl.dispose();
    super.dispose();
  }
}
