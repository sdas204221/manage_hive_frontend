import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:manage_hive/models/product.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
// NOTE: Assuming Product class is defined in '../models/customer.dart' or a dedicated product file.

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch products when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  // Dialog for adding or editing a product
  void _showProductForm(Product? product) {
    final isEditing = product != null;
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController =
        TextEditingController(text: product?.productName);
    final TextEditingController priceController =
        TextEditingController(text: product?.price?.toString() ?? '');
    // Provide 0.0 as default for tax if creating a new product
    final TextEditingController taxController =
        TextEditingController(text: product?.tax?.toString() ?? '0.0');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Edit Product' : 'Add New Product',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                        labelText: 'Product Name', border: OutlineInputBorder()),
                    validator: (value) =>
                        value!.isEmpty ? 'Product name is required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                        suffixText: 'INR'),
                    validator: (value) {
                      if (value!.isEmpty) return 'Price is required';
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: taxController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Tax Rate',
                        border: OutlineInputBorder(),
                        suffixText: '%'),
                    validator: (value) {
                      if (value!.isEmpty) return 'Tax is required';
                      if (double.tryParse(value) == null) {
                        return 'Enter a valid number';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final price = double.tryParse(priceController.text.trim())!;
                  final tax = double.tryParse(taxController.text.trim())!;

                  final newProduct = Product(
                    id: isEditing ? product.id : null,
                    productName: nameController.text.trim(),
                    price: price,
                    tax: tax,
                    user: null, // Handled by backend
                  );

                  final provider =
                      Provider.of<ProductProvider>(context, listen: false);

                  if (isEditing) {
                    await provider.updateProduct(product.id as int, newProduct);
                  } else {
                    await provider.createProduct(newProduct);
                  }

                  if (provider.errorMessage == null) {
                    // Success: close dialog
                    Navigator.pop(context);
                  } else {
                    // Show error feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(provider.errorMessage!)),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(isEditing ? 'Save Changes' : 'Add Product'),
            ),
          ],
        );
      },
    );
  }

  // Confirmation dialog for deletion
  void _confirmDelete(int id, String name) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content:
            Text('Are you sure you want to delete product: $name? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<ProductProvider>(context, listen: false)
                  .deleteProduct(id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go("/home"),
        ),
        title: const Text('Product Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${provider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: provider.fetchProducts,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (provider.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      color: Colors.grey, size: 60),
                  const SizedBox(height: 16),
                  const Text('No products found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text('Tap the + button to add a new product.'),
                ],
              ),
            );
          }

          // List of Products
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: provider.products.length,
            itemBuilder: (context, index) {
              final product = provider.products[index];
              // Use the actual ID if available, otherwise use index as fallback for UI purposes
              final int productId =
                  product.id is int ? product.id as int : index;

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    child: const Icon(Icons.shopping_bag_outlined, color: Colors.white)
                  ),
                  title: Text(
                    product.productName ?? 'No Name',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Price: ₹${product.price?.toStringAsFixed(2) ?? 'N/A'}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text('Tax: ${product.tax?.toStringAsFixed(2) ?? 'N/A'}%'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Edit Button
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showProductForm(product),
                      ),
                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(
                            productId, product.productName ?? 'this product'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Floating Action Button for adding a new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductForm(null),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
