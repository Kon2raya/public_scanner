// lib/features/inbound/screens/inbound_entry_screen.dart
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/models/receiving.dart';
import 'package:aai_scanner_epson/core/models/receiving_header.dart';
import 'package:aai_scanner_epson/core/models/receiving_item.dart';
import 'package:aai_scanner_epson/core/models/satellite.dart';
import 'package:aai_scanner_epson/core/models/customer.dart';
import 'package:aai_scanner_epson/core/services/receiving_info_service.dart';
import 'package:aai_scanner_epson/core/services/receiving_service.dart';
import 'package:aai_scanner_epson/core/services/satellite_service.dart';
import 'package:aai_scanner_epson/core/services/customer_service.dart';
import 'package:aai_scanner_epson/core/utils/dialog_utils.dart';
import 'package:aai_scanner_epson/core/utils/user_utils.dart';
import 'package:aai_scanner_epson/core/widgets/app_scaffold.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/widgets/receiving_form_widget.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/widgets/receiving_items_widget.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/widgets/scanned_items_widget.dart';
import 'package:aai_scanner_epson/features/scanning/presentations/screens/inbound/widgets/scanner_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class InboundEntryScreen extends StatefulWidget {
  const InboundEntryScreen({super.key});

  @override
  State<InboundEntryScreen> createState() => _InboundEntryScreenState();
}

class _InboundEntryScreenState extends State<InboundEntryScreen> {
  // Controllers
  final customerCtrl = TextEditingController();
  final satelliteCtrl = TextEditingController();
  final receivingCtrl = TextEditingController();

  // IDs
  int customerId = 0;
  int satelliteId = 0;
  int receivingId = 0;
  int userId = 0;

  // Selected objects
  Customer? selectedCustomer;
  Satellite? selectedSatellite;
  Receiving? selectedReceiving;
  ReceivingHeader? header;
  List<ReceivingItem> items = [];
  List<Map<String, dynamic>> scannedItems = []; // New list for scanned items

  // State
  bool showScanner = false;
  bool isLoading = false;
  bool isLoaded = false;

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

  Future<List<Receiving>> _receivingList(String query) =>
      (customerId == 0 || satelliteId == 0)
      ? Future.value([])
      : ReceivingService.fetchReceivingList(
          customerId: customerId,
          satelliteId: satelliteId,
          query: query,
        );

  void _clearField(TextEditingController ctrl, VoidCallback resetState) {
    setState(() {
      ctrl.clear();
      resetState();
      isLoaded = false;
      header = null;
      items = [];
      // Don't clear scannedItems here to preserve them across form changes
    });
  }

  Future<void> _retrieveReceivingInfo() async {
    if (customerId == 0 || satelliteId == 0 || receivingId == 0) {
      DialogUtils.showCustomDialog(
        context: context,
        title: 'Incomplete Data',
        icon: Icons.info,
        warning: false,
        success: false,
        message: "Please select all fields first.",
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final receivingInfo = await ReceivingInfoService.fetchReceivingInfo(
        rcvhdrId: receivingId,
      ).timeout(const Duration(seconds: 10));

      final box = await Hive.openBox('scanned_pallets');

      final storedPallet = box.values
          .map(
            (item) => Map<String, dynamic>.from(item as Map),
          ) // ✅ Safe conversion
          .toList();

      if (mounted) {
        for (final palletItem in storedPallet) {
          if (palletItem['rcvNumber'] == receivingInfo.header.rcvNo) {
            setState(() {
              scannedItems.add(palletItem); // use .add instead of .push
            });
          }
        }
        setState(() {
          header = receivingInfo.header;
          items = receivingInfo.details;
          isLoading = false;
          isLoaded = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoaded = false;
        });

        DialogUtils.showCustomDialog(
          context: context,
          title: 'Error',
          icon: Icons.error,
          warning: false,
          success: false,
          message: "Failed to load receiving info: $e",
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
      header = null;
      items = [];
    });
  }

  void _onSatelliteSelected(Satellite satellite) {
    setState(() {
      satelliteCtrl.text = satellite.satelliteName;
      satelliteId = satellite.satelliteId;
      selectedSatellite = satellite;
      isLoaded = false;
      header = null;
      items = [];
    });
  }

  void _onReceivingSelected(Receiving receiving) {
    setState(() {
      receivingCtrl.text = receiving.rcvNo;
      receivingId = receiving.rcvhdrId;
      selectedReceiving = receiving;
      isLoaded = false;
      header = null;
      items = [];
    });
  }

  void _onScanPressed() {
    setState(() => showScanner = true);
  }

  void _onScanDetected(String code) async {
    try {
      receivingCtrl.text = code;
      final results = await _receivingList(code);
      if (results.isNotEmpty) {
        final match = results.firstWhere(
          (r) => r.rcvNo == code,
          orElse: () => results.first,
        );
        setState(() {
          receivingId = match.rcvhdrId;
          selectedReceiving = match;
          showScanner = false;
          isLoaded = false;
          header = null;
          items = [];
        });
      } else {
        setState(() => showScanner = false);
      }
    } catch (e) {
      setState(() => showScanner = false);
    }
  }

  void _onScannerClose() {
    setState(() => showScanner = false);
  }

  // New callback to handle scanned items from scanning process
  void _onItemsScanned(List<Map<String, dynamic>> newScannedItems) {
    setState(() {
      scannedItems.addAll(newScannedItems);
    });
  }

  // New callback to clear all scanned items
  Future<void> _onClearAllScannedItems() async {
    final box = await Hive.openBox('scanned_pallets');

    // ✅ Filter out only the unsynced items (isSynced == false)
    final keysToDelete = <dynamic>[];

    for (final entry in box.toMap().entries) {
      final pallet = Map<String, dynamic>.from(entry.value as Map);
      if (pallet['isSynced'] == false && header!.rcvNo == pallet['rcvNumber']) {
        keysToDelete.add(entry.key);
      }
    }

    // ✅ Delete only unsynced pallets from Hive
    await box.deleteAll(keysToDelete);

    setState(() {
      // ✅ Keep only synced items in memory
      scannedItems.removeWhere((item) => item['isSynced'] == false);
    });
  }

  TabBar get _tabBar => const TabBar(
    indicator: BoxDecoration(color: Colors.white),
    indicatorSize: TabBarIndicatorSize.tab,
    labelColor: AppColors.primaryRed,
    unselectedLabelColor: Colors.white,
    tabs: [
      Tab(text: 'Detail', icon: Icon(Icons.receipt)),
      Tab(text: 'Received', icon: Icon(Icons.inventory_2)),
      Tab(
        text: 'Picked',
        icon: Icon(Icons.playlist_add_check_circle_rounded),
      ), // New tab
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppScaffold(
          title: 'Receiving',
          tabCount: 3,
          tabBarAtBottom: true,
          tabBar: _tabBar,
          body: TabBarView(
            children: [
              // Tab 1: Receiving Form
              SingleChildScrollView(
                padding: const EdgeInsets.all(5),
                child: RepaintBoundary(
                  child: ReceivingFormWidget(
                    customerController: customerCtrl,
                    satelliteController: satelliteCtrl,
                    receivingController: receivingCtrl,
                    customerListFuture: _customerList,
                    satelliteListFuture: _satelliteList,
                    receivingListFuture: _receivingList,
                    onCustomerSelected: _onCustomerSelected,
                    onSatelliteSelected: _onSatelliteSelected,
                    onReceivingSelected: _onReceivingSelected,
                    onCustomerClear: () => _clearField(customerCtrl, () {
                      selectedCustomer = null;
                      customerId = 0;
                    }),
                    onSatelliteClear: () => _clearField(satelliteCtrl, () {
                      selectedSatellite = null;
                      satelliteId = 0;
                    }),
                    onReceivingClear: () => _clearField(receivingCtrl, () {
                      selectedReceiving = null;
                      receivingId = 0;
                    }),
                    onScanPressed: _onScanPressed,
                    onRetrievePressed: _retrieveReceivingInfo,
                    isLoading: isLoading,
                    isLoaded: isLoaded,
                    header: header,
                  ),
                ),
              ),

              // Tab 2: Receiving Items
              Padding(
                padding: const EdgeInsets.all(5),
                child: ReceivingItemsWidget(
                  items: items,
                  isLoaded: isLoaded,
                  rcvNumber: header?.rcvNo,
                  onItemsScanned: _onItemsScanned, // New callback
                ),
              ),

              // Tab 3: Scanned Items (New)
              Padding(
                padding: const EdgeInsets.all(5),
                child: ScannedItemsWidget(
                  scannedItems: scannedItems,
                  rcvNumber: header?.rcvNo,
                  onClearAll: _onClearAllScannedItems,
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
    receivingCtrl.dispose();
    super.dispose();
  }
}
