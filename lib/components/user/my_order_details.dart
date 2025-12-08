import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyOrdersPageDetail extends StatelessWidget {
  final Map<String, dynamic> delivery;

  const MyOrdersPageDetail({super.key, required this.delivery});

  Widget _buildHeaderImage(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) {
      return Container(
        height: 180,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image, size: 64, color: Colors.grey)),
      );
    }
    try {
      final bytes = base64Decode(base64Str);
      return Image.memory(bytes, height: 180, width: double.infinity, fit: BoxFit.cover);
    } catch (_) {
      return Container(
        height: 180,
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.broken_image, size: 64, color: Colors.grey)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final nf = NumberFormat('#,##0', 'en_US');

    final imageBase64 = (delivery['imageBase64'] ?? '').toString();
    final items = (delivery['items'] is List) ? List<Map<String, dynamic>>.from(delivery['items']) : <Map<String, dynamic>>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Захиалгын дэлгэрэнгүй'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderImage(imageBase64),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Хүлээн авагч: ${delivery['receiverName'] ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text('Утас: ${delivery['receiverPhone'] ?? '-'}'),
                const SizedBox(height: 6),
                Text('Авах хаяг: ${delivery['pickupAddress'] ?? '-'}'),
                const SizedBox(height: 6),
                Text('Хүргэх хаяг: ${delivery['deliverAddress'] ?? '-'}'),
                const SizedBox(height: 6),
                Text('Жин: ${delivery['weight'] ?? '-'}'),
                const SizedBox(height: 6),
                Text('Хагарах уу?: ${delivery['fragile'] ?? '-'}'),
                const SizedBox(height: 6),
                Text('Тоо: ${delivery['quantity'] ?? '-'}'),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Бараанууд', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (items.isEmpty)
                  const Text('Бараа мэдээлэл алга')
                else
                  GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: items.length,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 0.9,
                    ),
                    itemBuilder: (context, index) {
                      final it = items[index];
                      final name = (it['name'] ?? '-').toString();
                      final qty = (it['quantity'] ?? 0);
                      final price = it['price'] != null ? num.tryParse(it['price'].toString()) ?? 0 : 0;
                      final imagePlaceholder = Container(
                        height: 80,
                        color: Colors.grey[100],
                        child: const Center(child: Icon(Icons.image, color: Colors.grey)),
                      );

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 6, offset: const Offset(2, 4))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // No product image in order item payload by default; keep placeholder
                            ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(12)), child: imagePlaceholder),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('x$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('${nf.format(price)} ₮', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('Нийт дүн:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${nf.format(delivery['orderTotal'] ?? 0)} ₮', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ]),
                const SizedBox(height: 12),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}