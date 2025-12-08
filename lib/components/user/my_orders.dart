import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyOrdersPage extends StatefulWidget {
  const MyOrdersPage({super.key});

  @override
  State<MyOrdersPage> createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List deliveries = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchDeliveries();
  }

  Future<void> fetchDeliveries() async {
    try {
      final response = await http.get(Uri.parse("http://localhost:5000/delivery"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          deliveries = data['deliveries'];
          loading = false;
        });
      } else {
        setState(() => loading = false);
      }
    } catch (e) {
      print("Error fetching deliveries: $e");
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Миний захиалгууд"),
        backgroundColor: Colors.orange,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: deliveries.length,
              itemBuilder: (context, index) {
                final delivery = deliveries[index];
                final imageBase64 = delivery['imageBase64'] ?? '';
                final imageWidget = imageBase64.isNotEmpty
                    ? Image.memory(
                        base64Decode(imageBase64),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 50),
                      );

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: imageWidget,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Хүлээн авагч: ${delivery['receiverName']}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text("Утас: ${delivery['receiverPhone']}"),
                              Text(
                                  "Авах хаяг: ${delivery['pickupAddress']}"),
                              Text(
                                  "Хүргэх хаяг: ${delivery['deliverAddress']}"),
                              Text("Жин: ${delivery['weight']}"),
                              Text("Хагарах уу?: ${delivery['fragile']}"),
                              Text("Тоо: ${delivery['quantity']}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
