// lib/features/inbound/widgets/receiving_form_widget.dart
import 'package:flutter/material.dart';
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:aai_scanner_epson/core/models/customer.dart';
import 'package:aai_scanner_epson/core/models/satellite.dart';
import 'package:aai_scanner_epson/core/models/receiving.dart';
import 'package:aai_scanner_epson/core/models/receiving_header.dart';
import 'package:aai_scanner_epson/core/utils/global_searchfield.dart';
import 'package:aai_scanner_epson/core/widgets/app_button.dart';

class ReceivingFormWidget extends StatelessWidget {
  final TextEditingController customerController;
  final TextEditingController satelliteController;
  final TextEditingController receivingController;
  final Future<List<Customer>> Function(String) customerListFuture;
  final Future<List<Satellite>> Function(String) satelliteListFuture;
  final Future<List<Receiving>> Function(String) receivingListFuture;
  final Function(Customer) onCustomerSelected;
  final Function(Satellite) onSatelliteSelected;
  final Function(Receiving) onReceivingSelected;
  final VoidCallback onCustomerClear;
  final VoidCallback onSatelliteClear;
  final VoidCallback onReceivingClear;
  final VoidCallback onScanPressed;
  final VoidCallback onRetrievePressed;
  final bool isLoading;
  final bool isLoaded;
  final ReceivingHeader? header;

  const ReceivingFormWidget({
    super.key,
    required this.customerController,
    required this.satelliteController,
    required this.receivingController,
    required this.customerListFuture,
    required this.satelliteListFuture,
    required this.receivingListFuture,
    required this.onCustomerSelected,
    required this.onSatelliteSelected,
    required this.onReceivingSelected,
    required this.onCustomerClear,
    required this.onSatelliteClear,
    required this.onReceivingClear,
    required this.onScanPressed,
    required this.onRetrievePressed,
    required this.isLoading,
    required this.isLoaded,
    this.header,
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
          _buildReceivingRow(),
          const SizedBox(height: 10),
          _buildRetrieveButton(),
          const SizedBox(height: 10),
          if (isLoaded && header != null) _buildReceivingInfoCard(),
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
    );
  }

  Widget _buildInstructionText() {
    return const Text(
      'Search or scan receiving number to proceed.',
      style: TextStyle(fontSize: 10),
    );
  }

  Widget _buildReceivingRow() {
    return Row(
      children: [
        Expanded(
          child: GlobalSearchField<Receiving>(
            controller: receivingController,
            asyncSuggestions: receivingListFuture,
            displayText: (r) => r.rcvNo,
            onSelected: onReceivingSelected,
            label: 'Receiving',
            prefixIcon: Icons.receipt_long,
            onClear: onReceivingClear,
          ),
        ),
        const SizedBox(width: 8),
        AppButton(
          label: 'Scan',
          icon: Icons.qr_code_scanner,
          onPressed: onScanPressed,
        ),
      ],
    );
  }

  Widget _buildRetrieveButton() {
    return SizedBox(
      height: 45,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onPressed: isLoading || isLoaded ? null : onRetrievePressed,
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
          Text('Retrieving Data', style: TextStyle(color: Colors.white)),
        ],
      );
    }

    if (isLoaded) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 18, color: Colors.white),
          SizedBox(width: 8),
          Text("Data Retrieved", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.download, size: 18, color: Colors.white),
        SizedBox(width: 8),
        Text(
          "Retrieve Receiving Information",
          style: TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildReceivingInfoCard() {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 3,
        color: Colors.grey.shade100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Receiving Information",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  Text(
                    header!.status.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryRed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Receiving No: ${header!.rcvNo}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "PO Reference: ${header!.poRef}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Invoice Number: ${header!.invNo}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Received By: ${header!.receivedBy}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                "Received Date: ${header!.receiveDate}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Created By: ${header!.createdBy}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
