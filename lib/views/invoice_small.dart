import 'package:flutter/material.dart';
import 'package:manage_hive/models/invoice.dart';
import 'package:manage_hive/providers/invoice_provider.dart';
import 'package:manage_hive/utils/downloader.dart';
import 'package:manage_hive/utils/print_utils.dart';
import 'package:provider/provider.dart';

class InvoiceSmall extends StatefulWidget {
  final Invoice invoice;
  final TextStyle titleStyle;
  final TextStyle bodyStyle;
  final String date;
  final Function showDeleteConfirmation;

  const InvoiceSmall({
    super.key,
    required this.invoice,
    required this.titleStyle,
    required this.bodyStyle,
    required this.date,
    required this.showDeleteConfirmation,
  });

  @override
  State<InvoiceSmall> createState() => _InvoiceSmallState();
}

class _InvoiceSmallState extends State<InvoiceSmall> {
  bool _isDownloading = false;
  bool _isPrinting = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<InvoiceProvider>(
      builder: (context, provider, child) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              vertical: 8.0,
              horizontal: 16.0,
            ),
            title: Text(
              'Invoice ${widget.invoice.invoiceNumber ?? ''} - ${widget.invoice.customerName ?? ''}',
              style: widget.titleStyle,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.invoice.issueDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(widget.date, style: widget.bodyStyle),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    'Total: ₹${(widget.invoice.totalAmount ?? 0).toStringAsFixed(2)}',
                    style: widget.bodyStyle,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete Invoice',
                  onPressed:
                      () => widget.showDeleteConfirmation(
                        context,
                        widget.invoice,
                      ),
                ),
                _isDownloading
                    ? const CircularProgressIndicator()
                    : IconButton(
                      icon: const Icon(Icons.download),
                      tooltip: 'Download Invoice',
                      onPressed: () async {
                        // The download action is mocked; no behavior is defined.
                        setState(() {
                          _isDownloading = true;
                        });
                        final pdfBytes = await provider.getInvoicePdf(
                          widget.invoice.invoiceNumber!,
                        ); // or whatever ID

                        if (pdfBytes != null) {
                          try {
                            await download(
                              pdfBytes,
                              'invoice_${widget.invoice.invoiceNumber!}.pdf',
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Download complete!')),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('PDF not available')),
                          );
                        }
                        setState(() {
                          _isDownloading = false;
                        });
                      },
                    ),
                _isPrinting
                    ? const CircularProgressIndicator()
                    : IconButton(
                      icon: const Icon(Icons.print),
                      tooltip: 'Print Invoice',
                      onPressed: () async {
                        setState(() {
                          _isPrinting = true;
                        });
                        final pdfBytes = await provider.getInvoicePdf(
                          widget.invoice.invoiceNumber!,
                        );
                        setState(() {
                          _isPrinting = false;
                        });
                         if (pdfBytes != null) {
                          try {
                            await startPrinting(pdfBytes);
                          } catch (e) {
                            print(e);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed: $e')),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('PDF not available')),
                          );
                        }
                      },
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
