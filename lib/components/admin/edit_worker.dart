import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/admins_service.dart';

class EditWorkerPage extends StatefulWidget {
  final Map<String, dynamic>? worker;
  final Future<void> Function()? refresh;

  const EditWorkerPage({super.key, this.worker, this.refresh});

  @override
  State<EditWorkerPage> createState() => _EditWorkerPageState();
}

class _EditWorkerPageState extends State<EditWorkerPage> {
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final vehicleCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final imageCtrl = TextEditingController();

  bool _saving = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    final w = widget.worker;
    if (w != null) {
      nameCtrl.text = (w['name'] ?? '') as String;
      phoneCtrl.text = (w['phone'] ?? '') as String;
      vehicleCtrl.text = (w['vehicle'] ?? w['carNumber'] ?? '') as String;
      emailCtrl.text = (w['email'] ?? '') as String;
      imageCtrl.text = (w['imageUrl'] ?? w['image'] ?? '') as String;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    vehicleCtrl.dispose();
    emailCtrl.dispose();
    imageCtrl.dispose();
    super.dispose();
  }

  Uri _uri(String path) => Uri.parse('${AdminService.baseUrl}$path');

  Future<void> _save() async {
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    final vehicle = vehicleCtrl.text.trim();
    final email = emailCtrl.text.trim();
    final imageUrl = imageCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ажилтны нэрийг оруулна уу')));
      return;
    }
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Утасны дугаарыг оруулна уу')));
      return;
    }

    final body = <String, dynamic>{
      'name': name,
      'phone': phone,
      'vehicle': vehicle,
      'email': email,
      'imageUrl': imageUrl,
    };

    setState(() => _saving = true);

    try {
      http.Response resp;
      if (widget.worker == null) {
        // Create
        resp = await http.post(
          _uri('/workers'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));
      } else {
        // Update
        final id = (widget.worker!['_id'] ?? widget.worker!['id'] ?? '').toString();
        if (id.isEmpty) {
          throw Exception('Worker id not found');
        }
        resp = await http.put(
          _uri('/workers/$id'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 15));
      }

      // ignore: avoid_print
      print('SAVE worker -> ${resp.statusCode}: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.worker == null ? 'Ажилтан амжилттай нэмэгдлээ' : 'Ажилтан амжилттай шинэчлэгдлээ')),
        );
        if (widget.refresh != null) await widget.refresh!.call();
        if (!mounted) return;
        Navigator.of(context).pop();
      } else {
        final bodySnippet = resp.body.length > 1000 ? resp.body.substring(0, 1000) + '…' : resp.body;
        throw Exception('Server returned ${resp.statusCode}: $bodySnippet');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сервертай холбогдох боломжгүй байна')));
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сервер хариу өгөхгүй байна')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Алдаа: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmAndDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ажилтан устгах'),
        content: const Text('Энэ ажилтныг устгахдаа итгэлтэй байна уу?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Болих')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Устгах')),
        ],
      ),
    );

    if (confirmed == true) {
      await _delete();
    }
  }

  Future<void> _delete() async {
    if (widget.worker == null) return;

    final id = (widget.worker!['_id'] ?? widget.worker!['id'] ?? '').toString();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ажилтны id олдсонгүй')));
      return;
    }

    setState(() => _deleting = true);

    try {
      final resp = await http.delete(
        _uri('/workers/$id'),
      ).timeout(const Duration(seconds: 10));

      // ignore: avoid_print
      print('DELETE worker -> ${resp.statusCode}: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ажилтан устгагдлаа')));
        if (widget.refresh != null) await widget.refresh!.call();
        if (!mounted) return;
        Navigator.of(context).pop();
      } else {
        final bodySnippet = resp.body.length > 1000 ? resp.body.substring(0, 1000) + '…' : resp.body;
        throw Exception('Server returned ${resp.statusCode}: $bodySnippet');
      }
    } on SocketException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сервертай холбогдох боломжгүй байна')));
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Сервер хариу өгөхгүй байна')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Алдаа: $e')));
    } finally {
      if (mounted) setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.worker != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(editing ? 'Ажилтан засах' : 'Ажилтан нэмэх'),
        actions: [
          if (editing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _deleting ? null : _confirmAndDelete,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Нэр")),
            const SizedBox(height: 12),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: "Утас"), keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextField(controller: vehicleCtrl, decoration: const InputDecoration(labelText: "Тээвэр / Машины дугаар")),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Имэйл"), keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 12),
            TextField(controller: imageCtrl, decoration: const InputDecoration(labelText: "Зургийн URL (Google link)")),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: (_saving || _deleting) ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _saving
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text(editing ? 'Хадгалах' : 'Нэмэх'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}