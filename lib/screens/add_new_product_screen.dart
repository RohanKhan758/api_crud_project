//add_new_product

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart';

import '../widgets/snackbar_message.dart';

class AddNewProductScreen extends StatefulWidget {
  const AddNewProductScreen({super.key});

  @override
  State<AddNewProductScreen> createState() => _AddNewProductScreenState();
}

class _AddNewProductScreenState extends State<AddNewProductScreen> {
  bool _addProductInProgress = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameTEController = TextEditingController();
  final TextEditingController _codeTEController = TextEditingController();
  final TextEditingController _priceTEController = TextEditingController();
  final TextEditingController _quantityTEController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add new product')),
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
                  decoration: InputDecoration(
                    hintText: 'Product Name',
                    labelText: 'Product Name',
                  ),
                  validator: (String? value){
                    if (value?.trim().isEmpty ?? true){
                      return 'Enter your Value';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _codeTEController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Product Code',
                    labelText: 'Product Code',
                  ),
                  validator: (String? value){
                    if (value?.trim().isEmpty ?? true){
                      return 'Enter your Value';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _quantityTEController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Quantity',
                    labelText: 'Quantity',
                  ),
                  validator: (String? value){
                    if (value?.trim().isEmpty ?? true){
                      return 'Enter your Value';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _priceTEController,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    hintText: 'Unit Price',
                    labelText: 'Unit Price',
                  ),
                  validator: (String? value){
                    if (value?.trim().isEmpty ?? true){
                      return 'Enter your Value';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: InputDecoration(
                    hintText: 'Image Url',
                    labelText: 'Image Url',
                  ),
                  validator: (String? value){
                    if (value?.trim().isEmpty ?? true){
                      return 'Enter your Value';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Visibility(
                  visible: _addProductInProgress == false,
                  replacement: Center(
                    child: CircularProgressIndicator(),
                  ),
                  child: FilledButton(
                    onPressed: _onTapAddProductButton,
                    child: Text('Add Product'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onTapAddProductButton() async {

    if (_formKey.currentState!.validate() == false){
      return;
    }

    _addProductInProgress =true;

    setState(() {
      
    });

    Uri uri = Uri.parse('http://35.73.30.144:2008/api/v1/CreateProduct');

    int totalPrice =
        int.parse(_priceTEController.text) *
        int.parse(_quantityTEController.text);
    Map<String, dynamic> requestBody = {
      "ProductName": _nameTEController.text..trim(),
      "ProductCode": int.parse(_codeTEController.text.trim()),
      "Img": _imageUrlController.text.trim(),
      "Qty": int.parse(_quantityTEController.text.trim()),
      "UnitPrice": int.parse(_priceTEController.text.trim()),
      "TotalPrice": totalPrice,
    };

    Response response = await post(uri,
        headers: {
          'Content-Type' : 'application/json'
        },
        body: jsonEncode(requestBody));
    print(response.statusCode);
    print(response.body);



    if (response.statusCode == 200){
      final decodedJson = jsonDecode(response.body);
      if(decodedJson['status'] == 'success'){
        _clearTextFields();
        showSnackBarMessage(context,'Product Created Successfully');
      }else{
        String errorMessage = decodedJson['data'];

        showSnackBarMessage(context, errorMessage);
      }
    }

    _addProductInProgress =false;

    setState(() {

    });
  }

  void _clearTextFields(){
    _nameTEController.clear();
    _codeTEController.clear();
    _quantityTEController.clear();
    _priceTEController.clear();
    _imageUrlController.clear();
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
