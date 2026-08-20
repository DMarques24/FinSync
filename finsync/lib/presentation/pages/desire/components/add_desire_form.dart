import 'dart:async';
import 'dart:io';

import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/domain/entities/desire_reflection.dart';
import 'package:finsync/domain/entities/desire_review.dart';
import 'package:finsync/presentation/pages/desire/components/reflection_step.dart';
import 'package:finsync/presentation/pages/desire/desire_bloc.dart';
import 'package:finsync/presentation/pages/desire/desire_event.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
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

  DesireReflection _reflection = DesireReflection.empty;
  ReviewInterval _reviewInterval = ReviewInterval.monthly;

  void _answer(ReflectionQuestion question, bool answer) {
    setState(() {
      _reflection = _reflection.copyWith(question: question, answer: answer);
    });
  }

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
                  tr('desire.gallery'),
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
                  tr('desire.camera'),
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

    // Redimensionada antes de sair do telemóvel: a imagem do desejo é
    // mostrada num cartão, não precisa da resolução original da câmara.
    final XFile? file = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1440,
      maxHeight: 1440,
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
        title: Text(tr('desire.permission_required_title')),
        content: Text(tr('desire.permission_required_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(tr('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text(
              tr('desire.open_settings'),
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
        SnackBar(content: Text(tr('desire.fill_fields'))),
      );
      return;
    }

    // Exigimos as cinco respostas, mas nunca julgamos o resultado: uma
    // pontuação baixa não impede nada. O que se pede é que a pessoa pare
    // um minuto, não que responda o que nós queremos ouvir.
    if (!_reflection.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('desire.reflection_incomplete'))),
      );
      return;
    }

    final desire = Desire(
      id: 0,
      name: _nameController.text.trim(),
      // Os valores escritos estão na moeda selecionada — converte para
      // EUR (moeda-base guardada na BD) antes de guardar.
      price: AppCurrency.toBase(price),
      date: _selectedDate!,
      saved: AppCurrency.toBase(saved),
      reflection: _reflection.copyWith(answeredAt: DateTime.now()),
      reviewInterval: _reviewInterval,
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
        SnackBar(content: Text(tr('desire.operation_timeout'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppErrorTranslator.translate(e))));
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

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: .10),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.flag_rounded,
                      color: AppColors.secondary,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('desire.new_desire'),
                          style: AppTextStyles.headingMedium.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr('desire.new_desire_subtitle'),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
                              tr('desire.add_image'),
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
                  labelText: tr('desire.desire_name_label'),
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
                  labelText: tr('desire.price_label', {'symbol': AppCurrency.symbol}),
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
                  labelText: tr('desire.saved_label', {'symbol': AppCurrency.symbol}),
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
                    labelText: tr('desire.goal_date_label'),
                    prefixIcon: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? tr('common.select_date')
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              Divider(color: AppColors.border),

              const SizedBox(height: 20),

              ReflectionStep(
                reflection: _reflection,
                enabled: !_isSaving,
                onAnswer: _answer,
              ),

              const SizedBox(height: 24),

              _ReviewIntervalPicker(
                selected: _reviewInterval,
                enabled: !_isSaving,
                onChanged: (interval) {
                  setState(() => _reviewInterval = interval);
                },
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
                label: Text(tr('desire.save_desire')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// De quanto em quanto tempo a app volta a perguntar se a compra ainda faz
/// sentido. Poucas opções de propósito — um campo livre em dias obrigava a
/// pessoa a inventar um número que não sabe justificar.
class _ReviewIntervalPicker extends StatelessWidget {
  final ReviewInterval selected;
  final bool enabled;
  final ValueChanged<ReviewInterval> onChanged;

  const _ReviewIntervalPicker({
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          tr('desire.interval_title'),
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          tr('desire.interval_subtitle'),
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        SizedBox(
          width: double.infinity,
          child: SegmentedButton<ReviewInterval>(
            showSelectedIcon: false,
            segments: [
              for (final interval in ReviewInterval.values)
                ButtonSegment(
                  value: interval,
                  label: Text(tr(interval.labelKey)),
                ),
            ],
            selected: {selected},
            onSelectionChanged: enabled
                ? (selection) => onChanged(selection.first)
                : null,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.secondary,
              selectedForegroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: AppRadius.all(AppRadius.md),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
