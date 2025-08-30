// update_product_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:api_crud_project/models/product_model.dart';
import '../widgets/snackbar_message.dart';

class UpdateProductScreen extends StatefulWidget {
  const UpdateProductScreen({super.key, required this.product});
  final ProductModel product;

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameTEController = TextEditingController();
  final _codeTEController = TextEditingController();
  final _priceTEController = TextEditingController();
  final _quantityTEController = TextEditingController();
  final _imageUrlController = TextEditingController();

  bool _updateInProgress = false;

  @override
  void initState() {
    super.initState();
    _nameTEController.text = widget.product.name;
    _codeTEController.text = widget.product.code.toString();
    _quantityTEController.text = widget.product.quantity.toString();
    _priceTEController.text = widget.product.unitPrice.toString(); // <-- FIX
    _imageUrlController.text = widget.product.image ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update product')),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 8,
              children: [
                TextFormField(
                  controller: _nameTEController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Product Name',
                    labelText: 'Product Name',
                  ),
                  validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Enter your Value' : null,
                ),
                TextFormField(
                  controller: _codeTEController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Product Code',
                    labelText: 'Product Code',
                  ),
                  validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Enter your Value' : null,
                ),
                TextFormField(
                  controller: _quantityTEController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Quantity',
                    labelText: 'Quantity',
                  ),
                  validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Enter your Value' : null,
                ),
                TextFormField(
                  controller: _priceTEController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    hintText: 'Unit Price',
                    labelText: 'Unit Price',
                  ),
                  validator: (v) =>
                  (v?.trim().isEmpty ?? true) ? 'Enter your Value' : null,
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(
                    hintText: 'Image Url',
                    labelText: 'Image Url',
                  ),
                ),
                const SizedBox(height: 8),

                Visibility(
                  visible: _updateInProgress == false,
                  replacement: const Center(child: CircularProgressIndicator()),
                  child: FilledButton(
                    onPressed: _updateProduct,
                    child: const Text('Update Product'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _updateProduct() async {
    if (_formKey.currentState!.validate() == false) return;

    FocusScope.of(context).unfocus();
    setState(() => _updateInProgress = true);

    try {
      final name = _nameTEController.text.trim();
      final code = int.parse(_codeTEController.text.trim());      // keep as int to match your Create
      final qty = int.parse(_quantityTEController.text.trim());
      final unitPrice = int.parse(_priceTEController.text.trim());
      final img = _imageUrlController.text.trim();
      final totalPrice = qty * unitPrice;

      final body = jsonEncode({
        "ProductName": name,
        "ProductCode": code,
        "Img": img.isEmpty ? null : img,
        "Qty": qty,
        "UnitPrice": unitPrice,
        "TotalPrice": totalPrice,
      });

      final id = widget.product.id.toString(); // adjust if your field is different
      final uri = Uri.parse('http://35.73.30.144:2008/api/v1/UpdateProduct/$id');

      // IMPORTANT: use POST because server says "Cannot PUT ..."
      final resp = await post(
        uri,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: body,
      );

      final ok = resp.statusCode == 200 || resp.statusCode == 201 || resp.statusCode == 204;
      if (!ok) {
        showSnackBarMessage(context, 'Update failed: ${resp.statusCode}\n${resp.body}');
        return;
      }

      if (resp.statusCode != 204 && resp.body.isNotEmpty) {
        final decoded = jsonDecode(resp.body);
        if (decoded is Map && decoded['status'] == 'success') {
          showSnackBarMessage(context, 'Product Updated Successfully');
        } else {
          showSnackBarMessage(context, 'Updated (server: ${decoded.toString()})');
        }
      } else {
        showSnackBarMessage(context, 'Product Updated Successfully');
      }

      if (mounted) Navigator.pop(context, true); // tell previous screen to refresh
    } catch (e) {
      showSnackBarMessage(context, 'Error: $e');
    } finally {
      if (mounted) setState(() => _updateInProgress = false);
    }
  }

  @override
  void dispose() {
    _nameTEController.dispose();
    _codeTEController.dispose();
    _quantityTEController.dispose();
    _priceTEController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }
}
