import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'account_info_screen.dart';
import 'history_screen.dart';
import 'landing_page.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _ageController;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  bool _isSaving = false;
  String? _pickedImagePath;
  bool _didInit = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _ageController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInit) {
      _didInit = true;
      final auth = context.read<AuthProvider>();
      _syncControllers(auth);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  void _syncControllers(AuthProvider auth) {
    final user = auth.user;
    _nameController.text = user?['name'] as String? ?? '';
    _emailController.text = user?['email'] as String? ?? '';
    _phoneController.text = user?['phone'] as String? ?? '';
    _ageController.text = user?['age']?.toString() ?? '';
    _pickedImagePath = auth.avatarPath;
  }

  void _startEditing() {
    final auth = context.read<AuthProvider>();
    _syncControllers(auth);
    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    final auth = context.read<AuthProvider>();
    _syncControllers(auth);
    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    setState(() {
      _pickedImagePath = picked.path;
    });
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final age = int.tryParse(_ageController.text.trim());

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan email tidak boleh kosong.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final success = await auth.updateProfile({
      'name': name,
      'email': email,
      'phone': phone.isEmpty ? null : phone,
      'age': age,
    });

    if (success && _pickedImagePath != null) {
      await auth.setProfilePhoto(_pickedImagePath!);
    }

    if (!mounted) return;
    setState(() {
      _isSaving = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui.')),
      );
      setState(() {
        _isEditing = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Gagal memperbarui profil.'),
        ),
      );
    }
  }

  Widget _buildAvatar(String? avatarPath, String? avatarUrl) {
    if (avatarPath != null &&
        avatarPath.isNotEmpty &&
        File(avatarPath).existsSync()) {
      return CircleAvatar(
        radius: 62,
        backgroundColor: const Color(0xFFE8F4ED),
        backgroundImage: FileImage(File(avatarPath)),
      );
    }

    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 62,
        backgroundColor: const Color(0xFFE8F4ED),
        backgroundImage: NetworkImage(avatarUrl),
      );
    }

    return const CircleAvatar(
      radius: 62,
      backgroundColor: Color(0xFFE8F4ED),
      child: Icon(Icons.person, size: 48, color: Color(0xFF0D5C9E)),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    TextInputType keyboardType,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF425255),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final name = user?['name'] as String? ?? 'Pengguna KuloSehat';
    final email = user?['email'] as String? ?? 'belum ada email';
    final phone = user?['phone'] as String? ?? '-';
    final age = user?['age']?.toString() ?? '-';
    final avatarUrl = user?['avatar'] as String? ?? user?['photo'] as String?;

    if (_isEditing) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7FBFF),
        appBar: AppBar(
          elevation: 0,
          backgroundColor: const Color(0xFFF7FBFF),
          foregroundColor: const Color(0xFF0D5C9E),
          title: const Text('Edit Profil'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _cancelEditing,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _buildAvatar(_pickedImagePath, avatarUrl),
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF0D5C9E),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField('Nama', _nameController, TextInputType.name),
                const SizedBox(height: 16),
                _buildTextField(
                  'Email',
                  _emailController,
                  TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'Telepon',
                  _phoneController,
                  TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField('Usia', _ageController, TextInputType.number),
                const SizedBox(height: 28),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0D5C9E),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveProfile,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Simpan Perubahan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FBFF),
        foregroundColor: const Color(0xFF0D5C9E),
        title: const Text('Profil Saya'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _startEditing,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          _buildAvatar(_pickedImagePath, avatarUrl),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF0D5C9E),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D5C9E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(email, style: TextStyle(color: Colors.grey[600])),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D5C9E),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: _startEditing,
                        child: const Text(
                          'Edit Profil',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  _infoCard(Icons.person, 'Usia', age),
                  const SizedBox(width: 12),
                  _infoCard(Icons.phone, 'Telepon', phone),
                ],
              ),
              const SizedBox(height: 22),
              _menuItem(
                Icons.info,
                'Informasi Akun',
                'Detail akun dan data kesehatan',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AccountInfoScreen(),
                    ),
                  );
                },
              ),
              _menuItem(
                Icons.history,
                'Riwayat Konsultasi',
                'Lihat jawaban dokter sebelumnya',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HistoryScreen()),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0D5C9E),
                    side: const BorderSide(color: Color(0xFF0D5C9E)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    auth.logout();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LandingPage()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Keluar Akun',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF0D5C9E)),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0D5C9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D5C9E).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF0D5C9E)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D5C9E),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Color(0xFF9DB7AF),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
