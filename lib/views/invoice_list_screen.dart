import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manage_hive/views/invoice_small.dart';
import 'package:provider/provider.dart';

import '../models/invoice.dart';
import '../providers/invoice_provider.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch invoices after the first frame is rendered.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<InvoiceProvider>(context, listen: false).fetchInvoices();
    });
  }

  /// Formats the [date] to a string like "Apr 10, 2025 · 3:45 PM".
  String _formatDate(DateTime date) {
    return DateFormat("MMM dd, yyyy · h:mm a").format(date);
  }

  /// Presents a confirmation dialog before deleting an invoice.
  void _showDeleteConfirmation(BuildContext context, Invoice invoice) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text(
              'Are you sure you want to delete this invoice?',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<InvoiceProvider>(
                    context,
                    listen: false,
                  ).deleteInvoice(invoice);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the current theme. Fallback to defaults if needed.
    final textTheme = Theme.of(context).textTheme;
    final titleStyle =
        textTheme.titleMedium ??
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
    final bodyStyle = textTheme.bodyMedium ?? const TextStyle(fontSize: 14);

    return Scaffold(
      body: Consumer<InvoiceProvider>(
        builder: (context, provider, child) {
          // Create a sorted copy of the invoices with the newest first.
          final sortedInvoices =
              provider.invoices.toList()..sort((a, b) {
                // Treat null issueDate as older than any date.
                final aDate =
                    a.issueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
                final bDate =
                    b.issueDate ?? DateTime.fromMillisecondsSinceEpoch(0);
                return bDate.compareTo(aDate);
              });

          return ListView.builder(
            itemCount: sortedInvoices.length,
            itemBuilder: (context, index) {
              final invoice = sortedInvoices[index];

              return InvoiceSmall(
                invoice: invoice,
                titleStyle: titleStyle,
                bodyStyle: bodyStyle,
                date: _formatDate(invoice.issueDate!),
                showDeleteConfirmation: _showDeleteConfirmation,
              );
            },
          );
        },
      ),
    );
  }
}
