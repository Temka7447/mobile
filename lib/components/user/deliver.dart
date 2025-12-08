import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobilebiydaalt/services/cart_service.dart';
import 'my_orders.dart'; // MyOrdersPage файлтай холбох

class DeliveryPage extends StatefulWidget {
  // receive order items and total from CheckoutPage
  final List<CartItem>? orderItems;
  final num? orderTotal;

  /// Optional store location passed from CheckoutPage/DetailPage
  /// expected shape: { 'address': '...', 'lat': 47.9, 'lng': 106.9 }
  final Map<String, dynamic>? storeLocation;

  const DeliveryPage({super.key, this.orderItems, this.orderTotal, this.storeLocation});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  final TextEditingController pickupController = TextEditingController();
  final TextEditingController deliverController = TextEditingController();
  final TextEditingController receiverController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  String weight = "0-5kg";
  String fragile = "Үгүй";
  int quantity = 1;

  File? mobileImage;
  Uint8List? webImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // If storeLocation provided, prefill pickup address with store.address
    if (widget.storeLocation != null) {
      final loc = widget.storeLocation!;
      final addr = (loc['address'] ?? loc['adress'] ?? '').toString();
      if (addr.isNotEmpty) pickupController.text = addr;
    }

    // If orderItems present, prefill quantity as sum for quick view (optional)
    if (widget.orderItems != null && widget.orderItems!.isNotEmpty) {
      final totalQty = widget.orderItems!.fold<int>(0, (s, e) => s + e.quantity);
      quantity = totalQty > 0 ? totalQty : 1;
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          webImage = bytes;
        });
      } else {
        setState(() {
          mobileImage = File(pickedFile.path);
        });
      }
    }
  }

  List<Map<String, dynamic>> _buildItemsPayload() {
    final List<Map<String, dynamic>> items = [];
    final orderItems = widget.orderItems ?? [];
    for (final ci in orderItems) {
      items.add({
        'productId': ci.product.id,
        'name': ci.product.name,
        'price': ci.product.price,
        'quantity': ci.quantity,
      });
    }
    return items;
  }

  Future<void> _submitForm() async {
    String? base64Image;
    if (kIsWeb && webImage != null) {
      base64Image = base64Encode(webImage!);
    } else if (!kIsWeb && mobileImage != null) {
      final bytes = await mobileImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final itemsPayload = _buildItemsPayload();

    final data = {
      "pickupAddress": pickupController.text,
      "deliverAddress": deliverController.text,
      "receiverName": receiverController.text,
      "receiverPhone": phoneController.text,
      "weight": weight,
      "fragile": fragile,
      "quantity": quantity,
      "imageBase64": base64Image ?? "",
      "orderTotal": widget.orderTotal ?? 0,
      "items": itemsPayload,
      "storeLocation": widget.storeLocation ?? {},
      "createdAt": DateTime.now().toIso8601String(),
    };

    // debug
    // ignore: avoid_print
    print("🚀 SEND DELIVERY DATA: $data");

    try {
      final response = await http.post(
        Uri.parse("http://localhost:5000/delivery"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Амжилттай хадгалагдлаа!")),
        );

        // Optionally clear only ordered items from global cart
        final cart = CartService.instance;
        if (widget.orderItems != null) {
          for (final ci in widget.orderItems!) {
            cart.removeItem(ci.product.id);
          }
        }

        // reset form
        pickupController.clear();
        deliverController.clear();
        receiverController.clear();
        phoneController.clear();
        setState(() {
          mobileImage = null;
          webImage = null;
          weight = "0-5kg";
          fragile = "Үгүй";
          quantity = 1;
        });

        // navigate to MyOrders or pop
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MyOrdersPage()));
      } else {
        // debug response
        // ignore: avoid_print
        print('Delivery Error ${response.statusCode}: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Алдаа гарлаа.")),
        );
      }
    } catch (e) {
      // ignore: avoid_print
      print('Network error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Сүлжээний алдаа: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderItems = widget.orderItems ?? [];
    final nf = NumberFormat('#,##0', 'en_US');
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3C9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Хүргэлт хийх"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFE6A4),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order summary (if items passed)
                if (orderItems.isNotEmpty) ...[
                  const Text('Захиалсан бараа', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    height: 120,
                    child: ListView.separated(
                      separatorBuilder: (_, __) => const SizedBox(height: 6),
                      itemCount: orderItems.length,
                      itemBuilder: (_, i) {
                        final ci = orderItems[i];
                        return Row(
                          children: [
                            Expanded(child: Text(ci.product.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                            Text('${ci.quantity} x ${ci.product.price} ₮'),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Нийт дүн:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(nf.format(widget.orderTotal ?? 0), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // My Orders Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyOrdersPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      "Миний захиалгууд",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // rest of the form...
                _label("Илгээмж авах хаяг"),
                _inputField(pickupController),
                _label("Илгээмж хүргэх хаяг"),
                _inputField(deliverController),
                _label("Хүлээн авагчийн нэр"),
                _inputField(receiverController),
                _label("Хүлээн авагчийн дугаар"),
                _inputField(phoneController, keyboard: TextInputType.phone),
                _label("Барааны хэмжээ (Жин)"),
                _radioGroup(["0-5kg", "5-15kg", "15kg+"], weight, (val) => setState(() => weight = val!)),
                _label("Хагарах уу?"),
                _radioGroup(["Тийм", "Үгүй"], fragile, (val) => setState(() => fragile = val!)),
                _label("Тоо ширхэг"),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() => quantity = (quantity > 1) ? quantity - 1 : 1);
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      "$quantity",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() => quantity++);
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                _label("Барааны зураг"),
                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.orange),
                    ),
                    child: kIsWeb
                        ? (webImage == null
                            ? const Center(child: Text("📷 Зураг авах эсвэл сонгох"))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.memory(webImage!, fit: BoxFit.cover),
                              ))
                        : (mobileImage == null
                            ? const Center(child: Text("📷 Зураг авах эсвэл сонгох"))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.file(mobileImage!, fit: BoxFit.cover),
                              )),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: const Text(
                      "Хадгалах",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 18, bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFEF5C4C),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

  Widget _inputField(TextEditingController controller, {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _radioGroup(List<String> items, String groupValue, Function(String?) onChanged) {
    return Column(
      children: items
          .map((item) => Row(
                children: [
                  Radio(
                    value: item,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    activeColor: Colors.orange,
                  ),
                  Text(item),
                ],
              ))
          .toList(),
    );
  }
}