import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/product.dart';

class EditProductPage extends StatefulWidget {
  final String shopId;
  final Product? product;

  const EditProductPage({super.key, required this.shopId, this.product});

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final String baseUrl = 'http://localhost:5000';

  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late TextEditingController _imageController;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _quantityController = TextEditingController(text: widget.product?.quantity.toString() ?? '');
    _imageController = TextEditingController(text: widget.product?.imagePath ?? '');
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final productData = {
      "name": _nameController.text,
      "price": int.tryParse(_priceController.text) ?? 0,
      "quantity": int.tryParse(_quantityController.text) ?? 0,
      "imagePath": _imageController.text,
    };

    try {
      http.Response response;
      if (widget.product == null) {
        // Add new product
        response = await http.post(
          Uri.parse('$baseUrl/shops/${widget.shopId}/products'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(productData),
        );
      } else {
        // Update product
        response = await http.put(
          Uri.parse('$baseUrl/shops/${widget.shopId}/products/${widget.product!.id}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(productData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null
                ? 'Бүтээгдэхүүн нэмэгдлээ'
                : 'Бүтээгдэхүүн шинэчлэгдлээ'),
          ),
        );
        Navigator.pop(context, true);
      } else {
        throw Exception('Алдаа гарлаа: ${response.statusCode}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Алдаа гарлаа: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Бүтээгдэхүүн засах' : 'Шинэ бүтээгдэхүүн')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Бүтээгдэхүүний нэр'),
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Нэрээ оруулна уу' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Үнэ'),
                      validator: (value) =>
                          value == null || int.tryParse(value) == null ? 'Үнийг оруулна уу' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Тоо хэмжээ'),
                      validator: (value) =>
                          value == null || int.tryParse(value) == null ? 'Тоо оруулна уу' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _imageController,
                      decoration: const InputDecoration(labelText: 'Зургийн URL'),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _saveProduct,
                      child: Text(isEdit ? 'Хадгалах' : 'Нэмэх'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
