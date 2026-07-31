import 'dart:async';

import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/dimensions.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/presentation/pages/desire/desire_bloc.dart';
import 'package:finsync/presentation/pages/desire/desire_event.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddSavingSheet extends StatefulWidget {
  final Desire desire;

  const AddSavingSheet({super.key, required this.desire});

  @override
  State<AddSavingSheet> createState() => _AddSavingSheetState();
}

class _AddSavingSheetState extends State<AddSavingSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  double? get _amount {
    final raw = _controller.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) return null;
    return double.tryParse(raw);
  }

  Future<void> _submit() async {
    if (_isSaving) return;

    final amount = _amount;

    if (amount == null || amount <= 0) {
      setState(() => _error = tr('desire.add_saving_invalid'));
      return;
    }

    setState(() {
      _error = null;
      _isSaving = true;
    });

    try {
      final completer = Completer<void>();
      context.read<DesireBloc>().add(
        AddDesireSavingEvent(
          widget.desire,
          // O valor escrito está na moeda selecionada; a base de dados
          // guarda tudo em euros.
          AppCurrency.toBase(amount),
          completer: completer,
        ),
      );

      await completer.future.timeout(const Duration(seconds: 15));

      if (!mounted) return;

      // O movimento em Poupança alterou o que a Home mostra.
      context.read<ProfileBloc>().add(LoadProfileEvent());

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            tr('desire.add_saving_done', {
              'amount': AppCurrency.format(AppCurrency.toBase(amount)),
              'name': widget.desire.name,
            }),
          ),
        ),
      );
    } on TimeoutException {
      if (!mounted) return;
      setState(() => _error = tr('desire.operation_timeout'));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = AppErrorTranslator.translate(e));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.desire.remaining;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.xl,
          AppSpacing.xxl,
          MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.disabled,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              Text(
                tr('desire.add_saving_title', {'name': widget.desire.name}),
                style: AppTextStyles.headingMedium.copyWith(fontSize: 20),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                tr('desire.add_saving_subtitle'),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),

              TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: !_isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                onChanged: (_) {
                  if (_error == null) return;
                  setState(() => _error = null);
                },
                style: AppTextStyles.headingMedium.copyWith(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*[.,]?\d{0,2}'),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: tr('desire.add_saving_label', {
                    'symbol': AppCurrency.symbol,
                  }),
                  errorText: _error,
                  prefixIcon: Icon(
                    Icons.savings_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ),

              // Atalho para o que falta. É o valor que a maioria das
              // pessoas quer no último depósito, e poupa-lhes a conta.
              if (remaining > 0) ...[
                const SizedBox(height: AppSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: ActionChip(
                    avatar: Icon(
                      Icons.flag_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    label: Text(
                      tr('desire.detail_remaining') +
                          ': ${AppCurrency.format(remaining)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: _isSaving
                        ? null
                        : () {
                            _controller.text = AppCurrency.convert(
                              remaining,
                            ).toStringAsFixed(2);
                            setState(() => _error = null);
                          },
                    backgroundColor: AppColors.secondary.withValues(
                      alpha: .08,
                    ),
                    side: BorderSide(
                      color: AppColors.secondary.withValues(alpha: .30),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: AppSpacing.xxl),

              FilledButton.icon(
                onPressed: _isSaving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(
                    double.infinity,
                    AppSizes.primaryButton,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.all(AppRadius.lg),
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
                    : const Icon(Icons.check_rounded),
                label: Text(tr('desire.add_saving_confirm')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
