import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:remixicon/remixicon.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../view_models/auth_view_model.dart';
import '../../../utils/app_style.dart';
import '../../../utils/top_snackbar.dart';
import '../../../utils/glass_confirm_dialog.dart';
import '../../../utils/glass_image_source_dialog.dart';
import '../../../services/auth/auth_local_service.dart';
import '../../../models/auth_user_model.dart';
import '../../widgets/user_avatar.dart';
import '../../widgets/press_feedback.dart';
import '../../widgets/back_button_app.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool _isEditing = false;

  /// Skeleton sampai GET `/user` pertama selesai (satu kali per proses app); buka Akun berikutnya langsung cache.
  bool _showSkeleton = false;

  AuthUser? _cachedUser;
  final ImagePicker _imagePicker = ImagePicker();

  /// Byte gambar hasil pilih (tidak pakai path file — cache Android sering dihapus).
  Uint8List? _pickedAvatarBytes;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nbmController = TextEditingController();
  final _positionController = TextEditingController();

  void _syncPopBlockingState() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_syncPopBlockingState);
    _emailController.addListener(_syncPopBlockingState);
    _phoneController.addListener(_syncPopBlockingState);
    _nbmController.addListener(_syncPopBlockingState);
    _bootstrapAccountPage();
  }

  void _applyUserToControllers(AuthUser? user) {
    _nameController.text = user?.name ?? '';
    _emailController.text = user?.email ?? '';
    _phoneController.text = user?.phone ?? '';
    _nbmController.text = user?.nbm ?? '';
    _positionController.text = user?.position ?? '';
  }

  Future<void> _bootstrapAccountPage() async {
    if (!mounted) return;

    if (AuthViewModel.userEndpointFetchedThisProcess) {
      final local = AuthLocalService();
      final user =
          AuthLocalService.peekCachedUserSync() ?? await local.getCachedUser();
      if (!mounted) return;
      setState(() {
        _cachedUser = user;
        _applyUserToControllers(user);
        _showSkeleton = false;
      });
      return;
    }

    setState(() {
      _showSkeleton = true;
      _cachedUser = null;
      _applyUserToControllers(null);
    });

    final vm = context.read<AuthViewModel>();
    final result = await vm.fetchCurrentUser();
    if (!mounted) return;

    final u = result.user;
    if (result.success && u != null) {
      setState(() {
        _cachedUser = u;
        _applyUserToControllers(u);
        _showSkeleton = false;
      });
      return;
    }

    if (!mounted) return;
    setState(() => _showSkeleton = false);
    if (!context.mounted) return;
    showTopSnackBar(context, result.message, isError: true);
  }

  @override
  void dispose() {
    _nameController.removeListener(_syncPopBlockingState);
    _emailController.removeListener(_syncPopBlockingState);
    _phoneController.removeListener(_syncPopBlockingState);
    _nbmController.removeListener(_syncPopBlockingState);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nbmController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  bool _hasUnsavedEditChanges() {
    if (!_isEditing) return false;
    final u = _cachedUser;
    if (u == null) {
      return _pickedAvatarBytes != null;
    }
    return _pickedAvatarBytes != null ||
        _nameController.text.trim() != u.name.trim() ||
        _emailController.text.trim() != u.email.trim() ||
        _phoneController.text.trim() != (u.phone ?? '').trim() ||
        _nbmController.text.trim() != (u.nbm ?? '').trim();
  }

  Future<bool?> _showDiscardUnsavedDialog() {
    return showGlassConfirmDialog(
      context: context,
      title: 'Batalkan perubahan?',
      message: 'Perubahan yang belum disimpan akan dibuang.',
      confirmText: 'Buang',
      cancelText: 'Lanjut Edit',
      icon: RemixIcons.alert_line,
      iconColor: Colors.redAccent,
      confirmGradient: const RadialGradient(
        center: Alignment.topLeft,
        radius: 4,
        colors: [Color(0xFFFF5252), Color(0xFFB71C1C)],
        stops: [0.0, 1.0],
      ),
    );
  }

  void _discardEditingToCache() {
    setState(() {
      _isEditing = false;
      _pickedAvatarBytes = null;
      _applyUserToControllers(_cachedUser);
    });
  }

  /// GoRouter memanggil [context.pop] tanpa selalu menghormati [PopScope]; handler ini dipakai
  /// untuk tombol kembali di AppBar dan dilengkapi [BackButtonListener] untuk tombol sistem.
  Future<void> _onNavigateBack(BuildContext context) async {
    if (!(_isEditing && _hasUnsavedEditChanges())) {
      if (context.mounted) context.pop();
      return;
    }
    await _confirmDiscardAndPop();
  }

  Future<void> _confirmDiscardAndPop() async {
    final discard = await _showDiscardUnsavedDialog();
    if (discard != true || !mounted) return;
    _discardEditingToCache();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSubmitting = context.watch<AuthViewModel>().isSubmitting;
    final overlayColor = isDark
        ? Colors.black.withOpacity(0.25)
        : Colors.black.withOpacity(0.12);

    final blockPopOnDirtyEdit = _isEditing && _hasUnsavedEditChanges();

    return BackButtonListener(
      onBackButtonPressed: () async {
        if (!(_isEditing && _hasUnsavedEditChanges())) return false;
        await _confirmDiscardAndPop();
        return true;
      },
      child: PopScope(
        canPop: !blockPopOnDirtyEdit,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await _confirmDiscardAndPop();
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
                              title: 'Akun Saya',
                              subtitle: 'Kelola data profil Anda',
                            ),
                            const SizedBox(height: 24),
                            Padding(
                              padding: AppStyle.hPadding,
                              child: Column(
                                children: [
                                  Skeletonizer(
                                    enabled: _showSkeleton,
                                    child: Column(
                                      children: [
                                        _buildProfilePicture(),
                                        const SizedBox(height: 32),
                                        _buildAccountForm(isDark),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  _buildEditButton(
                                    context,
                                    isDark,
                                    isSubmitting,
                                  ),
                                  if (_isEditing) ...[
                                    const SizedBox(height: 14),
                                    _buildSaveButton(context, isSubmitting),
                                  ],
                                  if (!_isEditing && !_showSkeleton) ...[
                                    const SizedBox(height: 14),
                                    _buildChangePasswordButton(
                                      context,
                                      isDark,
                                      isSubmitting,
                                    ),
                                  ],
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
                  child: IgnorePointer(child: Container(color: overlayColor)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Sama gaya header dengan [ProfilePage]: BackButtonApp + judul besar + subtitle.
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

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppStyle.accent.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: SizedBox(
              height: 120,
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(60),
                child: _pickedAvatarBytes != null
                    ? Image.memory(
                        _pickedAvatarBytes!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      )
                    : UserAvatar(
                        user: _cachedUser,
                        size: 120,
                        borderRadius: BorderRadius.circular(60),
                      ),
              ),
            ),
          ),
          if (!_showSkeleton)
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () async {
                  final source = await showGlassImageSourceDialog(
                    context: context,
                  );
                  if (source == null || !mounted) return;
                  try {
                    final xfile = await _imagePicker.pickImage(
                      source: source,
                      imageQuality: 85,
                    );
                    if (xfile == null) return;
                    final Uint8List bytes;
                    try {
                      bytes = await xfile.readAsBytes();
                    } catch (e) {
                      // ignore: avoid_print
                      print('[AccountPage] Gagal baca foto: $e');
                      if (!mounted) return;
                      showTopSnackBar(
                        context,
                        'Gagal memproses gambar. Coba lagi.',
                        isError: true,
                      );
                      return;
                    }
                    if (!mounted) return;
                    setState(() {
                      _pickedAvatarBytes = bytes;
                      _isEditing = true;
                    });
                  } catch (e) {
                    // ignore: avoid_print
                    print('[AccountPage] Gagal pilih gambar: $e');
                    if (!mounted) return;
                    showTopSnackBar(
                      context,
                      'Gagal mengambil gambar. Coba lagi.',
                      isError: true,
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppStyle.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    RemixIcons.camera_line,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountForm(bool isDark) {
    final enabled = _isEditing && !_showSkeleton;
    return Column(
      children: [
        _buildTextField(
          label: 'Nama Lengkap',
          icon: RemixIcons.user_line,
          isDark: isDark,
          controller: _nameController,
          enabled: enabled,
          hintText: 'Nama lengkap',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Email',
          icon: RemixIcons.mail_line,
          isDark: isDark,
          controller: _emailController,
          enabled: enabled,
          keyboardType: TextInputType.emailAddress,
          hintText: 'Email',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'Nomor Telepon',
          icon: RemixIcons.phone_line,
          isDark: isDark,
          controller: _phoneController,
          enabled: enabled,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          hintText: 'Nomor telepon',
        ),
        const SizedBox(height: 20),
        _buildTextField(
          label: 'NBM',
          icon: RemixIcons.id_card_line,
          isDark: isDark,
          controller: _nbmController,
          enabled: enabled,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          hintText: 'NBM (opsional)',
        ),
        const SizedBox(height: 20),
        _buildReadOnlyField(
          label: 'Jabatan / Posisi',
          icon: RemixIcons.briefcase_2_line,
          isDark: isDark,
          value: (_positionController.text.trim().isEmpty)
              ? 'Anggota Organisasi'
              : _positionController.text.trim(),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required bool isDark,
    required TextEditingController controller,
    required bool enabled,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
  }) {
    final baseBorder = isDark
        ? Colors.white.withOpacity(0.12)
        : Colors.grey.shade300;
    final fill = isDark ? AppStyle.cardDark : Colors.white;

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
          enabled: enabled,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: AppStyle.formPrefixIconColor(isDark),
              size: 20,
            ),
            filled: true,
            fillColor: fill,
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey[500],
              fontSize: 13,
              height: 1.35,
            ),
            isDense: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
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
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.shade200,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.redAccent, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required IconData icon,
    required bool isDark,
    required String value,
  }) {
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: isDark ? AppStyle.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: AppStyle.formPrefixIconColor(isDark),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  RemixIcons.lock_2_line,
                  size: 18,
                  color: isDark ? const Color(0xFFB8B8B8) : Colors.grey[500]!,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditButton(
    BuildContext context,
    bool isDark,
    bool isSubmitting,
  ) {
    final borderColor = isDark
        ? Colors.white.withOpacity(0.05)
        : const Color(0xFFF1F4F9);
    final textColor = _isEditing
        ? Colors.redAccent
        : AppStyle.accentOnSurface(isDark);
    final icon = _isEditing
        ? RemixIcons.close_circle_line
        : RemixIcons.edit_2_line;
    final title = _isEditing ? 'Batal Edit' : 'Edit Data';
    final borderRadius = BorderRadius.circular(20);

    return PressFeedback(
      onTap: (_showSkeleton || isSubmitting)
          ? null
          : () async {
              // Masuk edit: tanpa dialog.
              if (!_isEditing) {
                setState(() => _isEditing = true);
                return;
              }

              // Batal edit: tampilkan dialog konfirmasi.
              final discard = await _showDiscardUnsavedDialog();
              if (discard != true) return;
              if (!mounted) return;
              _discardEditingToCache();
            },
      borderRadius: borderRadius,
      pressedOverlayColor: isDark
          ? Colors.white.withOpacity(0.04)
          : Colors.black.withOpacity(0.03),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: borderRadius,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, bool isSubmitting) {
    final enabled = _isEditing && !_showSkeleton && !isSubmitting;
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
                  final ok = await showGlassConfirmDialog(
                    context: context,
                    title: 'Simpan perubahan?',
                    message: 'Perubahan akan disimpan.',
                    confirmText: 'Simpan',
                    cancelText: 'Batal',
                    icon: RemixIcons.save_3_line,
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

                  if (_cachedUser == null) {
                    showTopSnackBar(
                      context,
                      'Data pengguna tidak ditemukan.',
                      isError: true,
                    );
                    return;
                  }

                  final result = await context
                      .read<AuthViewModel>()
                      .updateProfile(
                        name: _nameController.text.trim(),
                        email: _emailController.text.trim(),
                        phone: _phoneController.text.trim().isEmpty
                            ? null
                            : _phoneController.text.trim(),
                        nbm: _nbmController.text.trim().isEmpty
                            ? null
                            : _nbmController.text.trim(),
                        avatarBytes: _pickedAvatarBytes,
                      );

                  if (!mounted) return;

                  if (result.success && result.user != null) {
                    setState(() {
                      _cachedUser = result.user;
                      _applyUserToControllers(result.user);
                      _pickedAvatarBytes = null;
                      _isEditing = false;
                    });
                    showTopSnackBar(context, result.message);
                    await Future.delayed(const Duration(milliseconds: 450));
                    if (!mounted) return;
                    context.go('/profile');
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
                      'Simpan Perubahan',
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

  Widget _buildChangePasswordButton(
    BuildContext context,
    bool isDark,
    bool isSubmitting,
  ) {
    final borderRadius = BorderRadius.circular(20);
    final borderColor = isDark
        ? Colors.white.withOpacity(0.05)
        : const Color(0xFFF1F4F9);

    return PressFeedback(
      onTap: isSubmitting
          ? null
          : () => context.push('/profile/change-password'),
      borderRadius: borderRadius,
      pressedOverlayColor: isDark
          ? Colors.white.withOpacity(0.04)
          : Colors.black.withOpacity(0.03),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: borderRadius,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              RemixIcons.lock_password_line,
              color: AppStyle.accentOnSurface(isDark),
            ),
            const SizedBox(width: 8),
            Text(
              'Ganti kata sandi',
              style: TextStyle(
                color: AppStyle.accentOnSurface(isDark),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
