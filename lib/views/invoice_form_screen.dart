import 'dart:async';

import 'package:flutter/material.dart';
import 'package:manage_hive/models/customer.dart';
import 'package:manage_hive/models/product.dart';
import 'package:manage_hive/providers/customer_provider.dart';
import 'package:manage_hive/providers/product_provider.dart';
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
  bool _autoRefresh = true;

  List<SalesLineFormEntry> _salesLines = [SalesLineFormEntry()];
  Customer? _selectedCustomer; // Track selected customer for clarity

  bool _isSubmitting = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Fetch data for suggestions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // NOTE: In a real app, providers would be initialized here if needed, 
      // but assuming they are provided above the app.
      // We explicitly call fetch methods to simulate data readiness.
      Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_autoRefresh && mounted) {
        setState(() {
          _issueDate = DateTime.now().toLocal();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _paymentTermsController.dispose();
    _paymentMethodController.dispose();
    _discountController.dispose();
    for (var line in _salesLines) {
      line.dispose();
    }
    super.dispose();
  }

  // Calculates the total for a single line including tax
  double _calculateLineTotal(SalesLineFormEntry line) {
    final qty = double.tryParse(line.quantityController.text) ?? 0;
    final price = double.tryParse(line.unitPriceController.text) ?? 0;
    final taxRate = double.tryParse(line.taxController.text) ?? 0; // Tax is a percentage
    
    // Formula: Quantity * (Unit Price + (Unit Price * Tax Rate / 100))
    return qty * (price + (price * (taxRate / 100)));
  }

  // Calculates the total of all sales lines
  double _calculateSubtotal() {
    return _salesLines.fold(0.0, (total, line) {
      return total + _calculateLineTotal(line);
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
      if (_salesLines.length > 1) {
        _salesLines[index].dispose();
        _salesLines.removeAt(index);
      }
    });
  }

  void _resetForm(bool confirmed) async {
    bool? confirm = confirmed;
    if (!confirmed) {
      confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
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
      _selectedCustomer = null; // Clear selected customer
      setState(() {
        // Dispose of old controllers before creating new ones
        for (var line in _salesLines) {
          line.dispose();
        }
        _salesLines = [SalesLineFormEntry()];
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final invoice = Invoice(
      customerName: _customerNameController.text.trim(),
      customerAddress: _customerAddressController.text.trim().isEmpty
          ? null
          : _customerAddressController.text.trim(),
      issueDate: _issueDate,
      paymentDate: _paymentDate,
      paymentMethod: _paymentMethodController.text.trim().isEmpty
          ? null
          : _paymentMethodController.text.trim(),
      paymentTerms: _paymentTermsController.text.trim().isEmpty
          ? null
          : _paymentTermsController.text.trim(),
      discount: double.tryParse(_discountController.text) ?? 0,
      salesLines: _salesLines.map((line) {
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

        onConfirm(localDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: LayoutBuilder(
          builder: (ctx, constraints) => SingleChildScrollView(
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
                      icon: _isSubmitting
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
    // Watch for customer data changes to power Autocomplete
    final customerProvider = Provider.of<CustomerProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Customer Details",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
        ),
        // --- Customer Name Autocomplete ---
        Autocomplete<Customer>(
          initialValue: TextEditingValue(text: _customerNameController.text),
          fieldViewBuilder: (
            BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted,
          ) {
            _customerNameController.text = textEditingController.text;
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              onFieldSubmitted: (_) => onFieldSubmitted(),
              decoration: const InputDecoration(
                labelText: 'Customer Name * (Type to search)',
                suffixIcon: Icon(Icons.search),
              ),
              validator: (val) =>
                  val == null || val.trim().isEmpty ? 'Required' : null,
              onChanged: (value) {
                // Clear selected customer if the user manually types
                if (_selectedCustomer != null && _selectedCustomer!.name != value) {
                  setState(() {
                    _selectedCustomer = null;
                    _customerAddressController.clear();
                  });
                }
              },
            );
          },
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Customer>.empty();
            }
            // Filter customers based on input
            return customerProvider.customers.where((customer) {
              return customer.name!
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (Customer selection) {
            // Auto-fill on selection
            _customerNameController.text = selection.name!;
            _customerAddressController.text = selection.address!;
            setState(() {
              _selectedCustomer = selection;
            });
          },
          displayStringForOption: (Customer option) => option.name!,
        ),
        // --- Customer Address (Auto-filled on selection) ---
        TextFormField(
          controller: _customerAddressController,
          decoration: const InputDecoration(labelText: 'Customer Address'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Text("Issue Date: "),
            TextButton(
              onPressed: () => _pickDate(
                context: context,
                initialDate: _issueDate,
                onConfirm: (picked) => setState(() => _issueDate = picked),
              ),
              child: Text('${_issueDate.toLocal()}'.split('.')[0]),
            ),
            IconButton(
              tooltip: _autoRefresh
                  ? "Auto-refresh is ON (Lock)"
                  : "Refresh (Long press to toggle auto-refresh ON)",
              onLongPress: () {
                setState(() {
                  _autoRefresh = true;
                });
              },
              onPressed: () {
                setState(() {
                  if (_autoRefresh) {
                    _autoRefresh = false;
                  } else {
                    _issueDate = DateTime.now().toLocal();
                  }
                });
              },
              icon: _autoRefresh
                  ? const Icon(Icons.lock_open, color: Colors.green)
                  : const Icon(Icons.refresh),
            )
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
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
        ),
        const SizedBox(height: 8),
        ..._salesLines.asMap().entries.map((entry) {
          final index = entry.key;
          final line = entry.value;

          // Watch product provider to populate suggestions
          final productProvider = Provider.of<ProductProvider>(context);

          return Card(
            key: line.key, // Use key for efficient list updates
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Remove Line Button
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Colors.red),
                        onPressed: () => _removeSalesLine(index),
                      ),
                      // --- Product Description Autocomplete ---
                      Expanded(
                        child: Autocomplete<Product>(
                          initialValue: TextEditingValue(
                              text: line.descriptionController.text),
                          fieldViewBuilder: (
                            BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted,
                          ) {
                            line.descriptionController.text =
                                textEditingController.text;
                            return TextFormField(
                              controller: textEditingController,
                              focusNode: focusNode,
                              onFieldSubmitted: (_) => onFieldSubmitted(),
                              decoration: const InputDecoration(
                                  labelText: 'Description * (Search Product)'),
                              maxLines: null,
                              validator: (val) => val == null || val.trim().isEmpty
                                  ? 'Required'
                                  : null,
                              onChanged: (value) {
                                // Clear product details if description changes manually
                                if (line.selectedProduct != null &&
                                    line.selectedProduct!.productName != value) {
                                  setState(() {
                                    line.selectedProduct = null;
                                    // Optionally clear price/tax if you want to force re-entry
                                    // line.unitPriceController.clear(); 
                                    // line.taxController.text = '0';
                                  });
                                }
                                setState(() {
                                  // Trigger rebuild to update totals dynamically
                                });
                              },
                            );
                          },
                          optionsBuilder: (TextEditingValue textEditingValue) {
                            if (textEditingValue.text.isEmpty) {
                              return const Iterable<Product>.empty();
                            }
                            // Filter products based on input
                            return productProvider.products.where((product) {
                              return product.productName!
                                  .toLowerCase()
                                  .contains(textEditingValue.text.toLowerCase());
                            });
                          },
                          onSelected: (Product selection) {
                            setState(() {
                              // Auto-fill on selection
                              line.descriptionController.text =
                                  selection.productName!;
                              line.unitPriceController.text =
                                  selection.price!.toStringAsFixed(2);
                              line.taxController.text =
                                  selection.tax!.toStringAsFixed(2);
                              line.selectedProduct = selection;
                              // Force re-validation and total update
                              _formKey.currentState?.validate();
                            });
                          },
                          displayStringForOption: (Product option) =>
                              option.productName!,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: line.quantityController,
                          decoration:
                              const InputDecoration(labelText: 'Quantity *'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty)
                              ? 'Required'
                              : double.tryParse(val) == null
                                  ? 'Invalid'
                                  : null,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: line.unitPriceController,
                          decoration:
                              const InputDecoration(labelText: 'Unit Price *'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (val) => (val == null || val.trim().isEmpty)
                              ? 'Required'
                              : double.tryParse(val) == null
                                  ? 'Invalid'
                                  : null,
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: line.taxController,
                          decoration:
                              const InputDecoration(labelText: 'Tax (%)'),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Line Total (Incl. Tax): ₹${_calculateLineTotal(line).toStringAsFixed(2)}",
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
        const Text("Summary",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
        const SizedBox(height: 8),
        _buildSummaryRow("Subtotal (Total Lines):", subtotal),
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
              _discountController; // Trigger rebuild for total update
            });
          },
        ),
        const SizedBox(height: 8),
        _buildSummaryRow("Total Amount Due:", total, bold: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.w600 : FontWeight.normal)),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Payment Details",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue),
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
              onPressed: () => _pickDate(
                context: context,
                initialDate: _paymentDate ?? DateTime.now(),
                onConfirm: (picked) => setState(() => _paymentDate = picked),
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
}

class SalesLineFormEntry {
  final Key key = UniqueKey();
  final TextEditingController descriptionController = TextEditingController();
  // Set default quantity to '1' for fast entry
  final TextEditingController quantityController =
      TextEditingController(text: '1');
  final TextEditingController unitPriceController = TextEditingController();
  // Set default tax to '0' for fast entry
  final TextEditingController taxController = TextEditingController(text: '0');

  // Used to track if a product from the autocomplete was selected
  Product? selectedProduct;

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    unitPriceController.dispose();
    taxController.dispose();
  }
}
