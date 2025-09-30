// lib/features/palletizing/presentation/screens/widgets/active_pallets_widget.dart
import 'package:aai_scanner_epson/core/config/theme/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ActivePalletsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> pallets;
  final void Function(String) onDeletePallet;
  final VoidCallback onSyncPallets;
  final bool isSyncing;
  final int unsyncedCount;

  const ActivePalletsWidget({
    super.key,
    required this.pallets,
    required this.onDeletePallet,
    required this.onSyncPallets,
    required this.isSyncing,
    required this.unsyncedCount,
  });

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'in_progress':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'in_progress':
        return Icons.hourglass_empty;
      default:
        return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (pallets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No pallets yet',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Create a pallet in the Setup tab',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Separate pallets by status
    final activePallets = pallets
        .where((p) => p['status'] != 'completed')
        .toList();
    final completedPallets = pallets
        .where((p) => p['status'] == 'completed')
        .toList();

    // Calculate statistics from pallets
    final totalCount = pallets.length;
    final activeCount = activePallets.length;
    final completedCount = completedPallets.length;

    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // Statistics Card
        Card(
          color: AppColors.primaryRed.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total',
                  totalCount.toString(),
                  Icons.all_inbox,
                  Colors.blue,
                ),
                _buildStatItem(
                  'Active',
                  activeCount.toString(),
                  Icons.pending_actions,
                  Colors.orange,
                ),
                _buildStatItem(
                  'Completed',
                  completedCount.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Active Pallets Section
        if (activePallets.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Active Pallets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...activePallets.map((pallet) => _buildPalletCard(context, pallet)),
          const SizedBox(height: 16),
        ],

        // Completed Pallets Section
        if (completedPallets.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              'Completed Pallets',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...completedPallets.map(
            (pallet) => _buildPalletCard(context, pallet),
          ),
        ],
      ],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPalletCard(BuildContext context, Map<String, dynamic> pallet) {
    final status = pallet['status'] ?? 'active';
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final itemCount = (pallet['items'] as List?)?.length ?? 0;
    final isSynced = pallet['isSynced'] ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: Icon(statusIcon, color: Colors.white, size: 20),
        ),
        title: Text(
          pallet['palletId'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${pallet['customerName'] ?? 'N/A'}'),
            Text('Items: $itemCount'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isSynced)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Local',
                  style: TextStyle(fontSize: 10, color: Colors.orange),
                ),
              ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                _showDeleteConfirmation(context, pallet['palletId']);
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Satellite:', pallet['satelliteName'] ?? 'N/A'),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Created:',
                  _formatDateTime(pallet['createdAt']),
                ),
                if (pallet['completedAt'] != null) ...[
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'Completed:',
                    _formatDateTime(pallet['completedAt']),
                  ),
                ],
                const SizedBox(height: 8),
                _buildDetailRow('Status:', status.toUpperCase()),
                const SizedBox(height: 8),
                _buildDetailRow(
                  'Sync Status:',
                  isSynced ? 'Synced' : 'Pending',
                ),

                // Items List
                if (itemCount > 0) ...[
                  const Divider(height: 24),
                  const Text(
                    'Items:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...(pallet['items'] as List).map((item) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16, bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${item['itemCode']} - Qty: ${item['quantity']}',
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, String palletId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pallet'),
        content: Text('Are you sure you want to delete pallet "$palletId"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDeletePallet(palletId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
