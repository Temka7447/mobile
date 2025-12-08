import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditWorkerPage extends StatefulWidget {
  final Map? worker;
  final Function refresh;

  const EditWorkerPage({super.key, required this.worker, required this.refresh});

  @override
  State<EditWorkerPage> createState() => _EditWorkerPageState();
}

class _EditWorkerPageState extends State<EditWorkerPage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final vehicleCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final imageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.worker != null) {
      nameCtrl.text = widget.worker!["name"];
      phoneCtrl.text = widget.worker!["phone"] ?? "";
      vehicleCtrl.text = widget.worker!["vehicle"] ?? "";
      emailCtrl.text = widget.worker!["email"] ?? "";
      imageCtrl.text = widget.worker!["imageUrl"] ?? "";
    }
  }

  Future<void> save() async {
    final body = {
      "name": nameCtrl.text,
      "phone": phoneCtrl.text,
      "vehicle": vehicleCtrl.text,
      "email": emailCtrl.text,
      "imageUrl": imageCtrl.text,
    };

    if (widget.worker == null) {
      await http.post(
        Uri.parse("http://10.0.2.2:3000/api/workers"),
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json"},
      );
    } else {
      await http.put(
        Uri.parse("http://10.0.2.2:3000/api/workers/${widget.worker!["_id"]}"),
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json"},
      );
    }

    widget.refresh();
    Navigator.pop(context);
  }

  Future<void> deleteWorker() async {
    await http.delete(
      Uri.parse("http://10.0.2.2:3000/api/workers/${widget.worker!["_id"]}"),
    );
    widget.refresh();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.worker == null ? "Ажилтан нэмэх" : "Ажилтан засах"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Нэр")),
          TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Утас")),
          TextField(controller: vehicleCtrl, decoration: const InputDecoration(labelText: "Тээвэр")),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Имэйл")),
          TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: "Зургийн URL (Google link)")),

          const SizedBox(height: 25),
          ElevatedButton(onPressed: save, child: const Text("Хадгалах")),

          if (widget.worker != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: deleteWorker,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Устгах"),
            ),
          ]
        ],
      ),
    );
  }
}
