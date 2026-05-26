import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FBFF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7FBFF),
        foregroundColor: const Color(0xFF0D5C9E),
        title: const Text('Daftar Akun Baru'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0D5C9E), Color(0xFF00A876)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.health_and_safety,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    const Center(
                      child: Text(
                        'Buat Akun Baru',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D5C9E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Daftar untuk mulai mendapatkan rekomendasi kesehatan personal.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF647D8C),
                          fontSize: 14,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    buildTextField(
                      controller: nameController,
                      hint: 'Nama lengkap',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: emailController,
                      hint: 'Email atau nomor HP',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: passwordController,
                      hint: 'Kata sandi',
                      icon: Icons.lock_outline,
                      obscure: obscurePassword,
                      suffix: IconButton(
                        icon: Icon(
                          obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            obscurePassword = !obscurePassword;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: confirmController,
                      hint: 'Konfirmasi kata sandi',
                      icon: Icons.lock_outline,
                      obscure: obscureConfirm,
                      suffix: IconButton(
                        icon: Icon(
                          obscureConfirm
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey[600],
                        ),
                        onPressed: () {
                          setState(() {
                            obscureConfirm = !obscureConfirm;
                          });
                        },
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
                      onPressed: isLoading
                          ? null
                          : () => _handleRegister(context),
                      child: isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Daftar Sekarang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        'Atau daftar dengan',
                        style: TextStyle(color: Color(0xFF647D8C)),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: socialButton(
                            'Google',
                            Icons.g_mobiledata,
                            () => _handleGoogleSignIn(context),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: socialButton('Apple', Icons.apple, () {}),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: 'Sudah punya akun? ',
                          style: const TextStyle(color: Color(0xFF647D8C)),
                          children: [
                            TextSpan(
                              text: 'Masuk sekarang',
                              style: const TextStyle(
                                color: Color(0xFF0D5C9E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F7F8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E6E8)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF0D5C9E)),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF8A9AA6)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget socialButton(String text, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E6E8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF0D5C9E)),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF0D5C9E),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi.')),
      );
      return;
    }

    if (password != confirm) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak sama.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final auth = context.read<AuthProvider>();

    try {
      final ok = await auth.registerWithEmail(name, email, password, confirm);

      if (ok) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Registrasi berhasil, silakan login.')),
        );
        if (!mounted) return;
        navigator.pop();
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Registrasi gagal.')),
        );
      }
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Tidak bisa terhubung ke server.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final auth = context.read<AuthProvider>();

    setState(() {
      isLoading = true;
    });

    try {
      final ok = await auth.loginWithGoogle();

      if (ok) {
        if (!mounted) return;
        navigator.pop();
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Login Google gagal.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
