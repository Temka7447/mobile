import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/store.dart';

class EditStorePage extends StatefulWidget {
  final Store? store;
  const EditStorePage({super.key, this.store});

  @override
  State<EditStorePage> createState() => _EditStorePageState();
}

class _EditStorePageState extends State<EditStorePage> {
  final _formKey = GlobalKey<FormState>();
  final String baseUrl = 'http://localhost:5000';

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController imageController;

  bool get isEdit => widget.store != null;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.store?.name ?? "");
    phoneController = TextEditingController(text: widget.store?.phone ?? "");
    imageController = TextEditingController(text: widget.store?.imagePath ?? "");
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) return;

    Map<String, dynamic> data = {
      "name": nameController.text,
      "phone": phoneController.text,
      "imagePath": imageController.text,
    };

    late http.Response response;

    if (isEdit) {
      response = await http.put(
        Uri.parse("$baseUrl/shops/${widget.store!.id}"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
    } else {
      response = await http.post(
        Uri.parse("$baseUrl/shops"),
        headers: {"Content-Type": "application/json"},
        body: json.encode(data),
      );
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context, true);
    } else {
      print("SAVE ERROR: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Дэлгүүр засах" : "Дэлгүүр нэмэх")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Дэлгүүрийн нэр"),
                validator: (v) => v!.isEmpty ? "Нэр оруулна уу" : null,
              ),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Утас"),
                validator: (v) => v!.isEmpty ? "Утас оруулна уу" : null,
              ),
              TextFormField(
                controller: imageController,
                decoration: const InputDecoration(labelText: "Зургийн URL (Google Image)"),
                validator: (v) => v!.isEmpty ? "Зурагны URL оруулна уу" : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveStore,
                child: Text(isEdit ? "Хадгалах" : "Нэмэх"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
