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

  bool isLoading = true;
  bool isEditing = false;

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
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final user = await ApiService.getLoggedInUser();

    if (!mounted) return;

    if (user is Map && user['error'] == null) {
      nameController.text = (user['name'] ?? '').toString();
      lastNameController.text = (user['lastName'] ?? '').toString();
      phoneController.text = (user['phone'] ?? '').toString();
    } else {
      final msg = (user is Map && user['error'] != null) ? user['error'].toString() : 'Хэрэглэгчийн мэдээлэл олдсонгүй';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      nameController.text = '';
      lastNameController.text = '';
      phoneController.text = '';
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
    if (isEditing) {
      // Cancel edits: restore values
      _loadUserData();
    }
    setState(() => isEditing = !isEditing);
  }

  Widget _displayRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: const InputDecoration(
          labelText: null,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.orange),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Text('Хувийн мэдээлэл', style: TextStyle(color: Colors.black)),
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

                  // If editing -> show editable text fields.
                  // If not editing -> show simple rows (no lock icons, simple plain text).
                  if (isEditing) ...[
                    _editableField(label: 'Овог', controller: lastNameController),
                    _editableField(label: 'Нэр', controller: nameController),
                    _editableField(label: 'Утас', controller: phoneController, keyboardType: TextInputType.phone),
                    const SizedBox(height: 12),
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
                  ] else ...[
                    // Simple, read-only view without lock icons and without outline.
                    _displayRow('Овог', lastNameController.text),
                    _displayRow('Нэр', nameController.text),
                    _displayRow('Утас', phoneController.text),
                    const SizedBox(height: 12),
                    // small hint to inform how to edit
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: _toggleEdit,
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        label: const Text('Засах', style: TextStyle(color: Colors.orange)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}