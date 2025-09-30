// lib/features/palletizing/presentation/screens/widgets/palletizing_form_widget.dart
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/models/customer.dart';
import 'package:aai_scanner_epson/core/models/satellite.dart';
import 'package:aai_scanner_epson/core/utils/global_searchfield.dart';
import 'package:aai_scanner_epson/core/widgets/app_button.dart';

class PalletizingFormWidget extends StatelessWidget {
  final TextEditingController customerController;
  final TextEditingController satelliteController;
  final TextEditingController palletIdController;
  final Future<List<Customer>> Function(String) customerListFuture;
  final Future<List<Satellite>> Function(String) satelliteListFuture;
  final void Function(Customer) onCustomerSelected;
  final void Function(Satellite) onSatelliteSelected;
  final VoidCallback onCustomerClear;
  final VoidCallback onSatelliteClear;
  final VoidCallback onScanPressed;
  final VoidCallback onCreatePressed;
  final bool isLoading;
  final bool isLoaded;
  final bool isPalletActive;
  final String? currentPalletId;

  const PalletizingFormWidget({
    super.key,
    required this.customerController,
    required this.satelliteController,
    required this.palletIdController,
    required this.customerListFuture,
    required this.satelliteListFuture,
    required this.onCustomerSelected,
    required this.onSatelliteSelected,
    required this.onCustomerClear,
    required this.onSatelliteClear,
    required this.onScanPressed,
    required this.onCreatePressed,
    required this.isLoading,
    required this.isLoaded,
    required this.isPalletActive,
    this.currentPalletId,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildCustomerField(),
          const SizedBox(height: 10),
          _buildSatelliteField(),
          const SizedBox(height: 10),
          _buildInstructionText(),
          const SizedBox(height: 10),
          _buildPalletIdRow(),
          const SizedBox(height: 10),
          _buildCreateButton(),
          const SizedBox(height: 10),
          if (isLoaded && currentPalletId != null) _buildPalletInfoCard(),
        ],
      ),
    );
  }

  Widget _buildCustomerField() {
    return GlobalSearchField<Customer>(
      controller: customerController,
      asyncSuggestions: customerListFuture,
      displayText: (c) => c.customerName,
      onSelected: onCustomerSelected,
      label: 'Customer',
      prefixIcon: Icons.person,
      onClear: onCustomerClear,
      enabled: !isPalletActive,
    );
  }

  Widget _buildSatelliteField() {
    return GlobalSearchField<Satellite>(
      controller: satelliteController,
      asyncSuggestions: satelliteListFuture,
      displayText: (s) => s.satelliteName,
      onSelected: onSatelliteSelected,
      label: 'Satellite',
      prefixIcon: Icons.satellite_alt_outlined,
      onClear: onSatelliteClear,
      enabled: !isPalletActive,
    );
  }

  Widget _buildInstructionText() {
    return const Text(
      'Enter or scan pallet ID to create a new pallet.',
      style: TextStyle(fontSize: 10),
    );
  }

  Widget _buildPalletIdRow() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: palletIdController,
            enabled: !isPalletActive,
            decoration: InputDecoration(
              labelText: 'Pallet ID',
              hintText: 'Enter pallet ID',
              prefixIcon: const Icon(Icons.inventory_2),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: isPalletActive ? Colors.grey.shade200 : Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        AppButton(
          label: 'Scan',
          icon: Icons.qr_code_scanner,
          onPressed: isPalletActive ? null : onScanPressed,
        ),
      ],
    );
  }

  Widget _buildCreateButton() {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: isLoading || isPalletActive ? null : onCreatePressed,
        child: _buildButtonContent(),
      ),
    );
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(width: 10),
          Text('Creating Pallet', style: TextStyle(color: Colors.white)),
        ],
      );
    }

    if (isPalletActive) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 18, color: Colors.white),
          SizedBox(width: 8),
          Text("Pallet Active", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_box, size: 18, color: Colors.white),
        SizedBox(width: 8),
        Text("Create New Pallet", style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildPalletInfoCard() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Active Pallet",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Pallet ID: $currentPalletId",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "You can now add items on the Items tab",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
