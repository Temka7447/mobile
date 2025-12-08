import 'package:flutter/material.dart';
import '../services/api.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  bool _showPassword = false;
  bool _showConfirm = false;

  void _register() async {
    final name = nameController.text.trim();
    final lastName = lastNameController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    // 1️⃣ Check all fields are filled
    if (name.isEmpty || lastName.isEmpty || phone.isEmpty || password.isEmpty || confirm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Бүх талбарыг бөглөнө үү")),
      );
      return;
    }

    // 2️⃣ Check phone length (8 digits)
    if (phone.length != 8 || int.tryParse(phone) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Утасны дугаар 8 тоон тэмдэгттэй байх ёстой")),
      );
      return;
    }

    // 3️⃣ Check password matches confirmation
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Нууц үг таарахгүй байна")),
      );
      return;
    }

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$'
    );
    if (!passwordRegex.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Нууц үг дор хаяж 8 тэмдэгт, том жижиг үсэг, тоо, тусгай тэмдэгттэй байх ёстой"
          ),
        ),
      );
      return;
    }

    // 5️⃣ Call API
    final result = await ApiService.registerUser(name, lastName, phone, password);

    if (!context.mounted) return;

    // 6️⃣ Show result
    if (result.containsKey("error")) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["error"])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Амжилттай бүртгэгдлээ")),
      );
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Бүртгүүлэх',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 20),
                  TextField(controller: lastNameController, decoration: const InputDecoration(labelText: 'Овог')),
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Нэр')),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Утас'),
                    keyboardType: TextInputType.number,
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: 'Нууц үг',
                      suffixIcon: IconButton(
                        icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off,size: 14,),
                        onPressed: () => setState(() => _showPassword = !_showPassword),
                      ),
                    ),
                  ),
                  TextField(
                    controller: confirmController,  
                    obscureText: !_showConfirm,
                    decoration: InputDecoration(
                      labelText: 'Нууц үг баталгаажуулах',
                      suffixIcon: IconButton(
                        icon: Icon(_showConfirm ? Icons.visibility : Icons.visibility_off,size: 14,),
                        onPressed: () => setState(() => _showConfirm = !_showConfirm),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(onPressed: () => Navigator.pushNamed(context, '/login'), child: const Text('Нэвтрэх')),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(360)),
                    ),
                    child: const Text('Бүртгүүлэх'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}