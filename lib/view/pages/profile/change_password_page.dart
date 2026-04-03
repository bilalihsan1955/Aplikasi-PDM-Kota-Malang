import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import '../../../models/auth_user_model.dart';
import '../../../services/auth/auth_local_service.dart';
import '../../../utils/app_style.dart';
import '../../../utils/glass_confirm_dialog.dart';
import '../../../utils/top_snackbar.dart';
import '../../../view_models/auth_view_model.dart';
import '../../widgets/back_button_app.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  AuthUser? _cachedUser;
  bool _loadingUser = true;

  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  void _syncPopBlockingState() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_syncPopBlockingState);
    _confirmController.addListener(_syncPopBlockingState);
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthLocalService().getCachedUser();
    if (!mounted) return;
    setState(() {
      _cachedUser = user;
      _loadingUser = false;
    });
  }

  @override
  void dispose() {
    _passwordController.removeListener(_syncPopBlockingState);
    _confirmController.removeListener(_syncPopBlockingState);
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  bool _hasPasswordDraft() {
    return _passwordController.text.isNotEmpty || _confirmController.text.isNotEmpty;
  }

  Future<void> _onNavigateBack(BuildContext context) async {
    if (!_hasPasswordDraft()) {
      if (context.mounted) context.pop();
      return;
    }
    await _confirmDiscardPasswordAndPop();
  }

  Future<void> _confirmDiscardPasswordAndPop() async {
    final discard = await _showDiscardPasswordDraftDialog();
    if (discard != true || !mounted) return;
    _passwordController.clear();
    _confirmController.clear();
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  Future<bool?> _showDiscardPasswordDraftDialog() {
    return showGlassConfirmDialog(
      context: context,
      title: 'Batalkan perubahan?',
      message: 'Kata sandi yang diketik belum disimpan dan akan dibuang.',
      confirmText: 'Buang',
      cancelText: 'Lanjut mengisi',
      icon: RemixIcons.alert_line,
      iconColor: Colors.redAccent,
      confirmGradient: const RadialGradient(
        center: Alignment.topLeft,
        radius: 4,
        colors: [
          Color(0xFFFF5252),
          Color(0xFFB71C1C),
        ],
        stops: [0.0, 1.0],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSubmitting = context.watch<AuthViewModel>().isSubmitting;
    final overlayColor = isDark
        ? Colors.black.withOpacity(0.25)
        : Colors.black.withOpacity(0.12);

    final blockPopOnDraft = _hasPasswordDraft();

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (!_hasPasswordDraft()) return false;
        await _confirmDiscardPasswordAndPop();
        return true;
      },
      child: PopScope(
      canPop: !blockPopOnDraft,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _confirmDiscardPasswordAndPop();
      },
      child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AbsorbPointer(
              absorbing: isSubmitting,
              child: GestureDetector(
                onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                behavior: HitTestBehavior.translucent,
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 8),
                        _buildProfileStyleHeader(
                          context,
                          title: 'Ganti kata sandi',
                          subtitle: 'Perbarui kata sandi untuk login ke aplikasi',
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: AppStyle.hPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Masukkan kata sandi baru.',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.45,
                                  color: isDark ? Colors.white70 : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 28),
                              _buildPasswordField(
                                isDark: isDark,
                                label: 'Kata sandi baru',
                                hintText: 'Kata sandi baru',
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                onToggleObscure: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              const SizedBox(height: 20),
                              _buildPasswordField(
                                isDark: isDark,
                                label: 'Konfirmasi kata sandi',
                                hintText: 'Ulangi kata sandi',
                                controller: _confirmController,
                                obscureText: _obscureConfirm,
                                onToggleObscure: () =>
                                    setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                              const SizedBox(height: 32),
                              _buildSubmitButton(context, isSubmitting),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isSubmitting)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(color: overlayColor),
              ),
            ),
        ],
      ),
    ),
    ),
    );
  }

  Widget _buildProfileStyleHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: AppStyle.hPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackButtonApp(onTap: () => _onNavigateBack(context)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2D3142),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white70 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField({
    required bool isDark,
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleObscure,
  }) {
    final baseBorder = isDark ? Colors.white.withOpacity(0.12) : Colors.grey.shade300;
    final fill = isDark ? AppStyle.cardDark : Colors.white;
    final iconTint = AppStyle.formPrefixIconColor(isDark);
    final suffixTint = isDark ? const Color(0xFFC8C8C8) : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppStyle.formLabelColor(isDark),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: TextInputType.visiblePassword,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
          decoration: InputDecoration(
            prefixIcon: Icon(RemixIcons.lock_2_line, color: iconTint, size: 20),
            suffixIcon: IconButton(
              tooltip: obscureText ? 'Tampilkan kata sandi' : 'Sembunyikan kata sandi',
              onPressed: onToggleObscure,
              icon: Icon(
                obscureText ? RemixIcons.eye_line : RemixIcons.eye_off_line,
                color: suffixTint,
                size: 22,
              ),
            ),
            filled: true,
            fillColor: fill,
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey[500],
              fontSize: 13,
              height: 1.3,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: baseBorder, width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppStyle.primary, width: 2.2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: baseBorder, width: 1),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context, bool isSubmitting) {
    final enabled = !_loadingUser && _cachedUser != null && !isSubmitting;
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
          onTap: !enabled
              ? null
              : () async {
                  final pw = _passwordController.text;
                  final cf = _confirmController.text;
                  if (pw.isEmpty) {
                    showTopSnackBar(context, 'Kata sandi baru harus diisi.', isError: true);
                    return;
                  }
                  if (pw != cf) {
                    showTopSnackBar(
                      context,
                      'Konfirmasi tidak sama dengan kata sandi baru.',
                      isError: true,
                    );
                    return;
                  }

                  final ok = await showGlassConfirmDialog(
                    context: context,
                    title: 'Simpan kata sandi baru?',
                    message: 'Anda akan menggunakan kata sandi ini untuk login berikutnya.',
                    confirmText: 'Simpan',
                    cancelText: 'Batal',
                    icon: RemixIcons.lock_password_line,
                    iconColor: AppStyle.accent,
                    confirmGradient: const RadialGradient(
                      center: Alignment.topLeft,
                      radius: 4,
                      colors: [Color(0xFF39A658), Color(0xFF071D75)],
                      stops: [0.0, 1.0],
                    ),
                  );
                  if (ok != true) return;
                  if (!mounted) return;

                  final user = _cachedUser;
                  if (user == null) {
                    showTopSnackBar(context, 'Data pengguna tidak ditemukan.', isError: true);
                    return;
                  }

                  final result = await context.read<AuthViewModel>().updateProfile(
                        name: user.name,
                        email: user.email,
                        phone: user.phone,
                        nbm: user.nbm,
                        password: pw,
                        passwordConfirmation: cf,
                        avatarBytes: null,
                      );

                  if (!mounted) return;

                  if (result.success) {
                    showTopSnackBar(context, result.message);
                    await Future.delayed(const Duration(milliseconds: 400));
                    if (mounted) context.pop();
                  } else {
                    showTopSnackBar(context, result.message, isError: true);
                  }
                },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: isSubmitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Simpan kata sandi',
                      style: TextStyle(
                        color: Colors.white.withOpacity(enabled ? 1 : 0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
