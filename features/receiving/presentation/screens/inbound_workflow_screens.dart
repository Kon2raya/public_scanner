import 'package:aai_scanner_epson/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class InboundWorkflowScreen extends StatelessWidget {
  const InboundWorkflowScreen({super.key});

  final List<Map<String, String>> steps = const [
    {'title': 'PRE TALLY SHEET (PACKING LIST)', 'pic': 'Docs Clerk'},
    {'title': 'Generate Pallet ID & Label Each Pallet', 'pic': 'Docs Clerk'},
    {'title': 'UNLOADING', 'pic': 'Operator'},
    {'title': 'Scanning Process (Sku, Qty, Serial)', 'pic': 'WH Assistant'},
    {'title': 'Auto Send 861', 'pic': 'Docs Clerk'},
    {'title': 'Execute Put-away', 'pic': 'Operator / WH Assistant'},
  ];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Inbound Receiving Workflow',
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: steps.length,
        itemBuilder: (context, index) {
          final step = steps[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.grey[300],
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              title: Text(
                step['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('PIC: ${step['pic']}'),
              trailing: Icon(
                Icons.check_circle_outline,
                color: Colors.green[600],
              ),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
