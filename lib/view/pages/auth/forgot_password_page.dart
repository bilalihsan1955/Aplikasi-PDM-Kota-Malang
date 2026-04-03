import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';

import '../../../utils/app_style.dart';
import '../../../utils/top_snackbar.dart';
import '../../../view_models/auth_view_model.dart';
import '../../widgets/back_button_app.dart';

/// Alur: email → OTP ([Pinput]) → kata sandi baru → kembali ke login.
class ForgotPasswordPage extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordPage({
    super.key,
    this.initialEmail = '',
  });

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  int _step = 0;
  String _email = '';
  String? _verificationToken;

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (_step == 0) {
      context.pop();
      return;
    }
    setState(() {
      if (_step == 1) {
        _step = 0;
        _otpController.clear();
      } else if (_step == 2) {
        _step = 1;
        _verificationToken = null;
        _otpController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    });
  }

  PinTheme _pinTheme(bool isDark) {
    final border = isDark ? Colors.white24 : Colors.grey.shade300;
    return PinTheme(
      width: 48,
      height: 52,
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : Colors.black87,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(12),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      ),
    );
  }

  PinTheme _focusedPinTheme(PinTheme base) {
    return base.copyWith(
      decoration: base.decoration?.copyWith(
            border: Border.all(color: AppStyle.primary, width: 2),
          ) ??
          BoxDecoration(
            border: Border.all(color: AppStyle.primary, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
    );
  }

  Future<void> _sendOtp() async {
    final vm = context.read<AuthViewModel>();
    final result = await vm.sendPasswordResetOtp(_emailController.text);
    if (!mounted) return;
    showTopSnackBar(context, result.message, isError: !result.success);
    if (result.success) {
      setState(() {
        _email = _emailController.text.trim();
        _step = 1;
        _otpController.clear();
      });
    }
  }

  Future<void> _verifyOtp() async {
    final vm = context.read<AuthViewModel>();
    final otp = _otpController.text.trim();
    final result = await vm.verifyPasswordResetOtp(email: _email, otp: otp);
    if (!mounted) return;
    showTopSnackBar(context, result.message, isError: !result.success);
    if (result.success && result.verificationToken != null) {
      setState(() {
        _verificationToken = result.verificationToken;
        _step = 2;
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    }
  }

  Future<void> _submitNewPassword() async {
    final token = _verificationToken;
    if (token == null || token.isEmpty) {
      showTopSnackBar(context, 'Sesi verifikasi tidak valid. Ulangi dari OTP.', isError: true);
      return;
    }
    final vm = context.read<AuthViewModel>();
    final result = await vm.submitPasswordReset(
      verificationToken: token,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
    if (!mounted) return;
    showTopSnackBar(context, result.message, isError: !result.success);
    if (result.success) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final busy = context.watch<AuthViewModel>().passwordResetBusy;
    final overlayColor = isDark
        ? Colors.black.withOpacity(0.25)
        : Colors.black.withOpacity(0.12);

    final defaultPin = _pinTheme(isDark);
    final focusedPin = _focusedPinTheme(defaultPin);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            BackButtonApp(onTap: _goBack),
                            const SizedBox(width: 12),
                            Expanded(child: _buildTitleBlock(isDark)),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: AbsorbPointer(
                    absorbing: busy,
                    child: _step == 1
                        ? LayoutBuilder(
                            builder: (context, constraints) {
                              return SingleChildScrollView(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 24),
                                physics: const AlwaysScrollableScrollPhysics(),
                                child: ConstrainedBox(
                                  constraints: BoxConstraints(
                                    minHeight: constraints.maxHeight,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      _buildOtpStepContent(
                                        isDark,
                                        defaultPin,
                                        focusedPin,
                                        busy,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : SingleChildScrollView(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_step == 0)
                                  _buildEmailStepContent(isDark),
                                if (_step == 2)
                                  _buildPasswordStepContent(isDark),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: AbsorbPointer(
                    absorbing: busy,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                      child: _stepPrimaryButton(busy),
                    ),
                  ),
                ),
              ],
            ),
            if (busy)
              Positioned.fill(
                child: Container(color: overlayColor),
              ),
          ],
        ),
      ),
    );
  }

  Widget _stepPrimaryButton(bool busy) {
    switch (_step) {
      case 0:
        return _primaryButton(
          busy: busy,
          label: 'Kirim kode OTP',
          icon: RemixIcons.mail_send_line,
          onTap: _sendOtp,
        );
      case 1:
        return _primaryButton(
          busy: busy,
          label: 'Verifikasi OTP',
          icon: RemixIcons.shield_check_line,
          onTap: _verifyOtp,
        );
      case 2:
        return _primaryButton(
          busy: busy,
          label: 'Simpan kata sandi baru',
          icon: RemixIcons.save_3_line,
          onTap: _submitNewPassword,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTitleBlock(bool isDark) {
    String title;
    String subtitle;
    switch (_step) {
      case 0:
        title = 'Lupa kata sandi';
        subtitle = 'Masukkan email terdaftar untuk menerima kode OTP.';
        break;
      case 1:
        title = 'Konfirmasi OTP';
        subtitle = 'Kode dikirim ke $_email';
        break;
      default:
        title = 'Kata sandi baru';
        subtitle = 'Buat kata sandi baru untuk akun Anda.';
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppStyle.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 15,
            color: isDark ? Colors.white70 : Colors.grey[600],
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStepContent(bool isDark) {
    return _labeledField(
      isDark: isDark,
      label: 'Email',
      child: _roundedField(
        isDark: isDark,
        child: TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autocorrect: false,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            hintText: 'nama@email.com',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            prefixIcon: Icon(RemixIcons.mail_line, color: AppStyle.primary, size: 22),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpStepContent(
    bool isDark,
    PinTheme defaultPin,
    PinTheme focusedPin,
    bool busy,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        Pinput(
          length: 6,
          controller: _otpController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          defaultPinTheme: defaultPin,
          focusedPinTheme: focusedPin,
          submittedPinTheme: defaultPin,
          pinAnimationType: PinAnimationType.scale,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          onCompleted: (_) => _verifyOtp(),
          autofocus: true,
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: busy ? null : _sendOtp,
          child: Text(
            'Kirim ulang OTP',
            style: TextStyle(
              color: AppStyle.accent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildPasswordStepContent(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _labeledField(
          isDark: isDark,
          label: 'Kata sandi baru',
          child: _roundedField(
            isDark: isDark,
            child: TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Kata sandi baru',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(RemixIcons.lock_line, color: AppStyle.primary, size: 22),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? RemixIcons.eye_line : RemixIcons.eye_off_line,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        _labeledField(
          isDark: isDark,
          label: 'Konfirmasi kata sandi',
          child: _roundedField(
            isDark: isDark,
            child: TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirm,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87),
              decoration: InputDecoration(
                hintText: 'Ulangi kata sandi baru',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                prefixIcon: Icon(RemixIcons.lock_line, color: AppStyle.primary, size: 22),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? RemixIcons.eye_line : RemixIcons.eye_off_line,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _labeledField({
    required bool isDark,
    required String label,
    required Widget child,
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
        child,
      ],
    );
  }

  Widget _roundedField({required bool isDark, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF1F4F9),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }

  Widget _primaryButton({
    required bool busy,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
          onTap: busy ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: busy
                ? const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(icon, color: Colors.white, size: 20),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
