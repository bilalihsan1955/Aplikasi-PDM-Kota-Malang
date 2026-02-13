import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:remixicon/remixicon.dart';
import '../../../utils/app_style.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(isDark),
                  const SizedBox(height: 48),
                  _buildForm(isDark),
                  const SizedBox(height: 32),
                  _buildRegisterButton(context),
                  const SizedBox(height: 24),
                  _buildLoginLink(context, isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daftar Akun Baru',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppStyle.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Lengkapi data diri Anda untuk bergabung bersama kami.',
          style: TextStyle(
            fontSize: 16,
            color: isDark ? Colors.white70 : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildForm(bool isDark) {
    return Column(
      children: [
        _buildTextField(
          label: 'Nama Lengkap',
          hint: 'Masukkan nama lengkap Anda',
          icon: RemixIcons.user_line,
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Email',
          hint: 'Masukkan alamat email Anda',
          icon: RemixIcons.mail_line,
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Password',
          hint: 'Masukkan password Anda',
          icon: RemixIcons.lock_line,
          isPassword: true,
          isPasswordVisible: _isPasswordVisible,
          onToggleVisibility: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
          isDark: isDark,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Konfirmasi Password',
          hint: 'Ulangi password Anda',
          icon: RemixIcons.lock_password_line,
          isPassword: true,
          isPasswordVisible: _isConfirmPasswordVisible,
          onToggleVisibility: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool? isPasswordVisible,
    VoidCallback? onToggleVisibility,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9),
              width: 1.5,
            ),
          ),
          child: TextField(
            obscureText: isPassword && !(isPasswordVisible ?? false),
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: Icon(icon, color: AppStyle.primary, size: 22),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible! ? RemixIcons.eye_off_line : RemixIcons.eye_line,
                        color: Colors.grey,
                        size: 20,
                      ),
                      onPressed: onToggleVisibility,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          center: Alignment.topLeft,
          radius: 6,
          colors: [Color(0xFF39A658), Color(0xFF4A6FDB), Color(0XFF071D75)],
          stops: [0.0, 0.4, 0.9],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppStyle.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.go('/'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 8),
                Icon(RemixIcons.user_add_line, color: Colors.white, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Sudah punya akun? ',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.grey[600]),
        ),
        GestureDetector(
          onTap: () => context.pop(),
          child: const Text(
            'Masuk Sekarang',
            style: TextStyle(
              color: AppStyle.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
