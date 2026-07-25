import 'dart:async';
import 'dart:io';

import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/presentation/pages/desire/desire_bloc.dart';
import 'package:finsync/presentation/pages/desire/desire_event.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

class AddDesireForm extends StatefulWidget {
  const AddDesireForm({super.key});

  @override
  State<AddDesireForm> createState() => _AddDesireFormState();
}

class _AddDesireFormState extends State<AddDesireForm> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _savedController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  File? _image;

  DateTime? _selectedDate;
  bool _isSaving = false;

  Future<void> pickImage() async {
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

    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (file != null) {
      setState(() {
        _image = File(file.path);
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
          "Para adicionares uma foto precisamos de acesso à câmara/galeria. "
          "Podes ativar isso nas Definições do teu dispositivo.",
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

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2035),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _savedController.dispose();
    super.dispose();
  }

  Future<void> _saveDesire() async {
    if (_isSaving) return;

    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));
    final savedText = _savedController.text.trim().replaceAll(',', '.');
    final saved = savedText.isEmpty ? 0.0 : double.tryParse(savedText);

    if (_nameController.text.trim().isEmpty ||
        price == null ||
        saved == null ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preenche nome, preço e data antes de guardar.'),
        ),
      );
      return;
    }

    final desire = Desire(
      id: 0,
      name: _nameController.text.trim(),
      price: price,
      date: _selectedDate!,
      saved: saved,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      final completer = Completer<void>();
      context.read<DesireBloc>().add(
        AddDesireEvent(desire, imageFile: _image, completer: completer),
      );

      await completer.future.timeout(const Duration(seconds: 20));

      if (!mounted) return;

      context.read<ProfileBloc>().add(LoadProfileEvent());

      Navigator.pop(context);
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

              Text("Novo Desejo", style: AppTextStyles.headingMedium),

              const SizedBox(height: 6),

              Text(
                "Cria um novo objetivo financeiro.",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 30),

              GestureDetector(
                onTap: _isSaving ? null : pickImage,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 42,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Adicionar imagem",
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),

              const SizedBox(height: 30),

              TextField(
                controller: _nameController,
                enabled: !_isSaving,
                decoration: InputDecoration(
                  labelText: "Nome do desejo",
                  prefixIcon: Icon(
                    Icons.favorite_border_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _priceController,
                enabled: !_isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Preço (${AppCurrency.symbol})",
                  prefixIcon: Icon(
                    AppCurrency.icon,
                    color: AppColors.secondary,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: _savedController,
                enabled: !_isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Já guardado (${AppCurrency.symbol})",
                  hintText: "0",
                  prefixIcon: Icon(
                    Icons.savings_outlined,
                    color: AppColors.secondary,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _isSaving ? null : selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: "Data objetivo",
                    prefixIcon: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? "Selecionar data"
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _isSaving ? null : _saveDesire,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
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
                label: const Text("Guardar Desejo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
