import 'dart:async';
import 'dart:io';

import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';


class EditProfileForm extends StatefulWidget {
  final String currentUsername;
  final String? currentAvatarUrl;

  const EditProfileForm({
    super.key,
    required this.currentUsername,
    this.currentAvatarUrl,
  });

  @override
  State<EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<EditProfileForm> {
  late final TextEditingController _usernameController;
  final ImagePicker _picker = ImagePicker();

  File? _newAvatar;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.currentUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  bool get _hasRemoteAvatar =>
      widget.currentAvatarUrl != null &&
      (widget.currentAvatarUrl!.startsWith('http://') ||
          widget.currentAvatarUrl!.startsWith('https://'));

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: AppColors.secondary,
                ),
                title: Text(
                  "Escolher da galeria",
                  style: AppTextStyles.bodyMedium,
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: AppColors.secondary,
                ),
                title: Text(
                  "Tirar fotografia",
                  style: AppTextStyles.bodyMedium,
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    final permission = source == ImageSource.camera
        ? Permission.camera
        : Permission.photos;

    final granted = await _ensurePermission(permission);
    if (!granted || !mounted) return;

    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (file != null) {
      setState(() {
        _newAvatar = File(file.path);
      });
    }
  }

  Future<bool> _ensurePermission(Permission permission) async {
    var status = await permission.status;

    if (status.isGranted || status.isLimited) return true;

    status = await permission.request();

    if (status.isGranted || status.isLimited) return true;

    if (!mounted) return false;

    if (status.isPermanentlyDenied || status.isRestricted) {
      await _showPermissionDeniedDialog();
    }

    return false;
  }

  Future<void> _showPermissionDeniedDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permissão necessária"),
        content: const Text(
          "Para alterares a foto de perfil precisamos de acesso à "
          "câmara/galeria. Podes ativar isso nas Definições do teu "
          "dispositivo.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              "Abrir Definições",
              style: TextStyle(color: AppColors.secondary),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("O nome de utilizador não pode ficar vazio.")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final completer = Completer<void>();
      context.read<ProfileBloc>().add(
        UpdateProfileEvent(username, avatarFile: _newAvatar, completer: completer),
      );

      await completer.future.timeout(const Duration(seconds: 20));

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso.')),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A operação demorou demasiado. Tenta novamente.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          20,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: 45,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.disabled,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),

              const SizedBox(height: 24),

              Text("Editar perfil", style: AppTextStyles.headingMedium),

              const SizedBox(height: 6),

              Text(
                "Atualiza o teu nome e a foto de perfil.",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              GestureDetector(
                onTap: _isSaving ? null : _pickImage,
                child: Stack(
                  children: [
                    ClipOval(
                      child: Container(
                        width: 110,
                        height: 110,
                        color: AppColors.background,
                        child: _buildAvatarPreview(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.surface,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              TextFormField(
                controller: _usernameController,
                enabled: !_isSaving,
                maxLength: 25,
                style: AppTextStyles.bodyMedium,
                inputFormatters: [LengthLimitingTextInputFormatter(25)],
                decoration: InputDecoration(
                  labelText: "Nome de utilizador",
                  counterText: "",
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text("Guardar alterações"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPreview() {
    if (_newAvatar != null) {
      return Image.file(_newAvatar!, fit: BoxFit.cover);
    }

    if (_hasRemoteAvatar) {
      return Image.network(
        widget.currentAvatarUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
      );
    }

    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Icon(
      Icons.person_rounded,
      size: 48,
      color: AppColors.secondary,
    );
  }
}
