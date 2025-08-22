import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/invoice.dart';
import '../models/sales_line.dart';
import '../providers/invoice_provider.dart';

class InvoiceFormScreen extends StatefulWidget {
  const InvoiceFormScreen({super.key});

  @override
  State<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends State<InvoiceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _customerNameController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _discountController = TextEditingController(text: '0');

  DateTime _issueDate = DateTime.now().toLocal();
  DateTime? _paymentDate;
  bool _autoRefresh=true;

  List<SalesLineFormEntry> _salesLines = [SalesLineFormEntry()];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _paymentTermsController.dispose();
    _paymentMethodController.dispose();
    _discountController.dispose();
    super.dispose();
  }
 
  //  @override
  // void initState() {
  //   super.initState();
  //   Timer.periodic(Duration(seconds: 2), (timer) {
        
  //     });
  // }
  

  double _calculateSubtotal() {
    return _salesLines.fold(0.0, (total, line) {
      final qty = double.tryParse(line.quantityController.text) ?? 0;
      final price = double.tryParse(line.unitPriceController.text) ?? 0;
      final tax = double.tryParse(line.taxController.text) ?? 0;
      return total + (qty * price + tax);
    });
  }

  double _calculateTotal() {
    final subtotal = _calculateSubtotal();
    final discount = double.tryParse(_discountController.text) ?? 0;
    return subtotal - discount;
  }

  void _addSalesLine() {
    setState(() {
      _salesLines.add(SalesLineFormEntry());
    });
  }

  void _removeSalesLine(int index) {
    setState(() {
      if (_salesLines.length > 1) _salesLines.removeAt(index);
    });
  }

  void _resetForm(bool confirmed) async {
    bool? confirm = confirmed;
    if (!confirmed) {
      confirm = await showDialog<bool>(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text("Reset Form?"),
              content: const Text(
                "This will clear all form fields. Are you sure?",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text("Reset"),
                ),
              ],
            ),
      );
    }
    if (confirm == true) {
      _formKey.currentState?.reset();
      _customerNameController.clear();
      _customerAddressController.clear();
      _paymentMethodController.clear();
      _paymentTermsController.clear();
      _discountController.text = '0';
      _issueDate = DateTime.now();
      _paymentDate = null;
      setState(() {
        _salesLines = [SalesLineFormEntry()];
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final invoice = Invoice(
      customerName: _customerNameController.text.trim(),
      customerAddress:
          _customerAddressController.text.trim().isEmpty
              ? null
              : _customerAddressController.text.trim(),
      issueDate: _issueDate,
      paymentDate: _paymentDate,
      paymentMethod:
          _paymentMethodController.text.trim().isEmpty
              ? null
              : _paymentMethodController.text.trim(),
      paymentTerms:
          _paymentTermsController.text.trim().isEmpty
              ? null
              : _paymentTermsController.text.trim(),
      discount: double.tryParse(_discountController.text) ?? 0,
      salesLines:
          _salesLines.map((line) {
            return SalesLine(
              description: line.descriptionController.text.trim(),
              quantity: double.tryParse(line.quantityController.text) ?? 0,
              unitPrice: double.tryParse(line.unitPriceController.text) ?? 0,
              tax: double.tryParse(line.taxController.text) ?? 0,
            );
          }).toList(),
      subtotal: _calculateSubtotal(),
      totalAmount: _calculateTotal(),
    );

    try {
      await Provider.of<InvoiceProvider>(
        context,
        listen: false,
      ).createInvoice(invoice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invoice created successfully")),
        );
        _resetForm(true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to create invoice: $e")));
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _pickDate({
    required BuildContext context,
    required DateTime initialDate,
    required Function(DateTime) onConfirm,
  }) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        // Combine picked date & time
        final localDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        ).toLocal();

        // Convert to UTC, then add IST offset (+5:30)
        // final istDateTime = localDateTime.subtract(const Duration(hours: 5, minutes: 30));
        // final utcDateTime = istDateTime.subtract(
        //   const Duration(hours: 5, minutes: 30),
        // );
        
        onConfirm(localDateTime);
      }
    }
  }

  

  @override
  Widget build(BuildContext context) {
    Timer.periodic(Duration(seconds: 1), (timer) {
        if(_autoRefresh){
          setState(() {  
          _issueDate=DateTime.now().toLocal();
          });
        }
      });
    return Scaffold(
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder:
              (ctx, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection1(),
                    const SizedBox(height: 16),
                    _buildSection2(),
                    const SizedBox(height: 16),
                    _buildSection3(),
                    const SizedBox(height: 16),
                    _buildSection4(),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          icon:
                              _isSubmitting
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.check),
                          label: const Text("Submit"),
                          onPressed: _isSubmitting ? null : _submitForm,
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text("Reset"),
                          onPressed: () => _resetForm(false),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
        ),
      ),
    );
  }

  Widget _buildSection1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customer Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          controller: _customerNameController,
          decoration: const InputDecoration(labelText: 'Customer Name *'),
          validator:
              (val) => val == null || val.trim().isEmpty ? 'Required' : null,
        ),
        TextFormField(
          controller: _customerAddressController,
          decoration: const InputDecoration(labelText: 'Customer Address'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("Issue Date: "),
            TextButton(
              onPressed:
                  () => _pickDate(
                    context: context,
                    initialDate: _issueDate,
                    onConfirm: (picked) => setState(() => _issueDate = picked),
                  ),
              child: Text('${_issueDate.toLocal()}'.split('.')[0]),
            ),
            IconButton(
              tooltip: _autoRefresh?"toggle auto refresh off":"Refresh\nLong press to toggle auto refresh on",
              onLongPress: () {
                setState(() {
                  _autoRefresh=true;
                });
              },
              onPressed: (){
              setState(() {
                if(_autoRefresh){
                  _autoRefresh=false;
                }else{
                _issueDate=DateTime.now().toLocal();
                }
              });
            }, icon: _autoRefresh?Icon(Icons.lock):Icon(Icons.refresh))
          ],
        ),
      ],
    );
  }

  Widget _buildSection2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sales Lines",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._salesLines.asMap().entries.map((entry) {
          final index = entry.key;
          final line = entry.value;
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => _removeSalesLine(index),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: line.descriptionController,
                          decoration: const InputDecoration(
                            labelText: 'Description *',
                          ),
                          maxLines: null,
                          validator:
                              (val) =>
                                  val == null || val.trim().isEmpty
                                      ? 'Required'
                                      : null,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: line.quantityController,
                          decoration: const InputDecoration(
                            labelText: 'Quantity *',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator:
                              (val) =>
                                  (val == null || val.trim().isEmpty)
                                      ? 'Required'
                                      : double.tryParse(val) == null
                                      ? 'Invalid'
                                      : null,
                          onChanged: (value) {
                            setState(() {
                              line.quantityController;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: line.unitPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Unit Price *',
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator:
                              (val) =>
                                  (val == null || val.trim().isEmpty)
                                      ? 'Required'
                                      : double.tryParse(val) == null
                                      ? 'Invalid'
                                      : null,
                          onChanged: (value) {
                            setState(() {
                              line.unitPriceController;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: line.taxController,
                          decoration: const InputDecoration(labelText: 'Tax'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            setState(() {
                              line.taxController;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Line Total: ₹${_calculateLineTotal(line).toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 10),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add Line"),
            onPressed: _addSalesLine,
          ),
        ),
      ],
    );
  }

  Widget _buildSection3() {
    final subtotal = _calculateSubtotal();
    final discount = double.tryParse(_discountController.text) ?? 0;
    final total = subtotal - discount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Summary", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        _buildSummaryRow("Subtotal:", subtotal),
        TextFormField(
          controller: _discountController,
          decoration: const InputDecoration(labelText: 'Discount'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return null;
            final number = double.tryParse(value);
            if (number == null) return 'Please enter a valid number';
            if (number < 0) return 'Discount cannot be negative';
            return null;
          },
          onChanged: (value) {
            setState(() {
              _discountController;
            });
          },
        ),
        const SizedBox(height: 8),
        _buildSummaryRow("Total Amount:", total, bold: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          "₹${value.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSection4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        TextFormField(
          controller: _paymentTermsController,
          decoration: const InputDecoration(labelText: 'Payment Terms'),
        ),
        TextFormField(
          controller: _paymentMethodController,
          decoration: const InputDecoration(labelText: 'Payment Method'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("Payment Date: "),
            TextButton(
              onPressed:
                  () => _pickDate(
                    context: context,
                    initialDate: _paymentDate ?? DateTime.now(),
                    onConfirm:
                        (picked) => setState(() => _paymentDate = picked),
                  ),
              child: Text(
                _paymentDate == null
                    ? 'Select Date'
                    : '${_paymentDate!.toLocal()}'.split('.')[0],
              ),
            ),
          ],
        ),
      ],
    );
  }

  double _calculateLineTotal(SalesLineFormEntry line) {
    final qty = double.tryParse(line.quantityController.text) ?? 0;
    final price = double.tryParse(line.unitPriceController.text) ?? 0;
    final tax = double.tryParse(line.taxController.text) ?? 0;
    return qty * (price + price * (tax / 100));
  }
}

class SalesLineFormEntry {
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController unitPriceController = TextEditingController();
  final TextEditingController taxController = TextEditingController();

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    taxController.dispose();
  }
}
