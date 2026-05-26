import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'profile_screen.dart';

class AccountInfoScreen extends StatelessWidget {
  const AccountInfoScreen({super.key});

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF677C74), fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF1D4B8F),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String? avatarPath, String? avatarUrl) {
    if (avatarPath != null &&
        avatarPath.isNotEmpty &&
        File(avatarPath).existsSync()) {
      return CircleAvatar(
        radius: 56,
        backgroundColor: const Color(0xFFE8F4ED),
        backgroundImage: FileImage(File(avatarPath)),
      );
    }
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 56,
        backgroundColor: const Color(0xFFE8F4ED),
        backgroundImage: NetworkImage(avatarUrl),
      );
    }
    return const CircleAvatar(
      radius: 56,
      backgroundColor: Color(0xFFE8F4ED),
      child: Icon(Icons.person, size: 40, color: Color(0xFF0D5C9E)),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FBFF),
        foregroundColor: const Color(0xFF0D5C9E),
        title: const Text('Informasi Akun'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _buildAvatar(auth.avatarPath, avatarUrl)),
              const SizedBox(height: 20),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0D5C9E),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF677C74)),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Nama', name),
                    const Divider(),
                    _buildDetailRow('Email', email),
                    const Divider(),
                    _buildDetailRow('Telepon', phone),
                    const Divider(),
                    _buildDetailRow('Usia', age),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D5C9E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ProfileScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Edit Profil',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
