import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'edit_worker.dart';

class WorkersAdmin extends StatefulWidget {
  const WorkersAdmin({super.key});

  @override
  State<WorkersAdmin> createState() => _WorkersAdminState();
}

class _WorkersAdminState extends State<WorkersAdmin> {
  List workers = [];

  @override
  void initState() {
    super.initState();
    fetchWorkers();
  }

  Future<void> fetchWorkers() async {
    final res = await http.get(Uri.parse("http://localhost:5000/api/workers"));
    setState(() => workers = jsonDecode(res.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ажилчид")),
      body: ListView.builder(
        itemCount: workers.length,
        itemBuilder: (context, i) {
          final w = workers[i];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: w["imageUrl"] != ""
                  ? NetworkImage(w["imageUrl"])
                  : null,
              child: w["imageUrl"] == "" ? const Icon(Icons.person) : null,
            ),
            title: Text(w["name"]),
            subtitle: Text(w["phone"] ?? ""),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditWorkerPage(
                  worker: w,
                  refresh: fetchWorkers,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditWorkerPage(
              worker: null,
              refresh: fetchWorkers,
            ),
          ),
        ),
      ),
    );
  }
}
