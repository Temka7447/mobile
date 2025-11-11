import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final lastNameController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();

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
                  const Text('Бүртгүүлэх',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: lastNameController,
                    decoration: const InputDecoration(labelText: 'Овог'),
                  ),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Нэр'),
                  ),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(labelText: 'Утас'),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: passwordController,
                    decoration: const InputDecoration(labelText: 'Нууц үг'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 20),
                  TextButton(onPressed: () =>
                  Navigator.pushNamed(context, '/login'), 
                  child: const Text('Нэвтрэх'),),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(360))),
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
