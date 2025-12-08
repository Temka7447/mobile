import 'package:flutter/material.dart';
import 'package:mobilebiydaalt/services/api.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await ApiService.getLoggedInUser();

    if (!mounted) return;

    if (userData.containsKey('error')) {
      // No token or failed to fetch user
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    setState(() {
      nameController.text = userData['name'] ?? '';
      lastNameController.text = userData['lastName'] ?? '';
      phoneController.text = userData['phone'] ?? '';
      emailController.text = userData['email'] ?? '';
      isLoading = false;
    });
  }

  Future<void> _saveUserData() async {
    final result = await ApiService.updateUser(
      name: nameController.text,
      lastName: lastNameController.text,
      phone: phoneController.text,
      email: emailController.text,
    );

    if (!mounted) return;

    if (result.containsKey('error')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result['error'])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Мэдээлэл хадгалагдлаа")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFADA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBFADA),
        title: Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.orange,
              ),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/home');
              },
            ),
            const Text(
              "Хувийн мэдээлэл",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(75),
                        child: Image.asset(
                          'images/profile_placeholder.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildTextField("Овог", lastNameController),
                  _buildTextField("Нэр", nameController),
                  _buildTextField("Утас", phoneController,
                      keyboardType: TextInputType.phone),
                  _buildTextField("Имэйл", emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveUserData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(360),
                      ),
                    ),
                    child: const Text('Хадгалах'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}
