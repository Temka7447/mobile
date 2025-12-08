import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'my_orders.dart'; // MyOrdersPage файлтай холбох

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

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

  Future<void> _submitForm() async {
    String? base64Image;
    if (kIsWeb && webImage != null) {
      base64Image = base64Encode(webImage!);
    } else if (!kIsWeb && mobileImage != null) {
      final bytes = await mobileImage!.readAsBytes();
      base64Image = base64Encode(bytes);
    }

    final data = {
      "pickupAddress": pickupController.text,
      "deliverAddress": deliverController.text,
      "receiverName": receiverController.text,
      "receiverPhone": phoneController.text,
      "weight": weight,
      "fragile": fragile,
      "quantity": quantity,
      "imageBase64": base64Image ?? "",
    };

    print("🚀 SEND DATA: $data");

    final response = await http.post(
      Uri.parse("http://localhost:5000/delivery"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Амжилттай хадгалагдлаа!")),
      );
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Алдаа гарлаа.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                _label("Илгээмж авах хаяг"),
                _inputField(pickupController),
                _label("Илгээмж хүргэх хаяг"),
                _inputField(deliverController),
                _label("Хүлээн авагчийн нэр"),
                _inputField(receiverController),
                _label("Хүлээн авагчийн дугаар"),
                _inputField(phoneController, keyboard: TextInputType.phone),
                _label("Барааны хэмжээ (Жин)"),
                _radioGroup(["0-5kg", "5-15kg", "15kg+"], weight,
                    (val) => setState(() => weight = val!)),
                _label("Хагарах уу?"),
                _radioGroup(["Тийм", "Үгүй"], fragile,
                    (val) => setState(() => fragile = val!)),
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
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                )
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

  Widget _inputField(TextEditingController controller,
      {TextInputType keyboard = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _radioGroup(
      List<String> items, String groupValue, Function(String?) onChanged) {
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
