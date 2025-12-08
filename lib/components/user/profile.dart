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
  bool isEditing = false;

  String userId = '';
  String userRole = 'user';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final user = await ApiService.getLoggedInUser();

    if (!mounted) return;

    if (user is Map && user['error'] == null) {
      // ApiService returns normalized keys: id, name, lastName, phone, email, role
      userId = (user['id'] ?? '').toString();
      userRole = (user['role'] ?? 'user').toString();

      nameController.text = (user['name'] ?? '').toString();
      lastNameController.text = (user['lastName'] ?? '').toString();
      phoneController.text = (user['phone'] ?? '').toString();
      emailController.text = (user['email'] ?? '').toString();
    } else {
      final msg = (user is Map && user['error'] != null) ? user['error'].toString() : 'Хэрэглэгчийн мэдээлэл олдсонгүй';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      nameController.text = '';
      lastNameController.text = '';
      phoneController.text = '';
      emailController.text = '';
      userId = '';
      userRole = 'user';
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _saveUserData() async {
    final phone = phoneController.text.trim();
    if (!RegExp(r'^\d{8}$').hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Утасны дугаар 8 оронтой байх ёстой')),
      );
      return;
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    final result = await ApiService.updateUser(
      name: nameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phone: phone,
      email: emailController.text.trim(),
    );

    if (!mounted) return;

    if (result is Map && result['error'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Мэдээлэл амжилттай шинэчлэгдлээ')));
      setState(() => isEditing = false);
      await _loadUserData();
    } else {
      final msg = (result is Map && result['error'] != null) ? result['error'].toString() : 'Хадгалах үед алдаа гарлаа';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  void _logout() async {
    await ApiService.logoutUser();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _toggleEdit() {
    if (isEditing) _loadUserData(); // cancel edits -> revert
    setState(() => isEditing = !isEditing);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        readOnly: !enabled,
        enabled: enabled,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          suffixIcon: enabled ? null : const Icon(Icons.lock_outline),
        ),
      ),
    );
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
              icon: const Icon(Icons.arrow_back, color: Colors.orange),
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            const Text('Хувийн мэдээлэл', style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          if (!isLoading) ...[
            IconButton(
              icon: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.orange),
              onPressed: _toggleEdit,
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.orange),
              onPressed: _logout,
            ),
          ]
        ],
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  CircleAvatar(
                    radius: 72,
                    backgroundColor: Colors.grey[200],
                    child: ClipOval(
                      child: Image.asset(
                        'images/profile_placeholder.png',
                        width: 140,
                        height: 140,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.person, size: 64),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: ListTile(
                      title: Text('Роль: $userRole'),
                      subtitle: Text('ID: ${userId.isNotEmpty ? userId : "—"}'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Овог',
                    controller: lastNameController,
                    enabled: isEditing,
                    hint: lastNameController.text.isEmpty ? 'Овог оруулаагүй' : '',
                  ),
                  _buildTextField(
                    label: 'Нэр',
                    controller: nameController,
                    enabled: isEditing,
                    hint: nameController.text.isEmpty ? 'Нэр оруулаагүй' : '',
                  ),
                  _buildTextField(
                    label: 'Утас',
                    controller: phoneController,
                    enabled: isEditing,
                    keyboardType: TextInputType.phone,
                    hint: phoneController.text.isEmpty ? 'Утасны дугаар оруулаагүй' : '',
                  ),
                  _buildTextField(
                    label: 'Имэйл',
                    controller: emailController,
                    enabled: isEditing,
                    keyboardType: TextInputType.emailAddress,
                    hint: emailController.text.isEmpty ? 'Имэйл оруулаагүй' : '',
                  ),
                  const SizedBox(height: 12),
                  if (isEditing)
                    ElevatedButton(
                      onPressed: isLoading ? null : _saveUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(360)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Хадгалах'),
                    ),
                ],
              ),
            ),
    );
  }
}