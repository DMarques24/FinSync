import 'dart:async';

import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/errors/app_error_translator.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/domain/entities/expense_category.dart';
import 'package:finsync/presentation/pages/home/components/category_labels.dart';
import 'package:finsync/presentation/pages/analytics/analytics_bloc.dart';
import 'package:finsync/presentation/pages/analytics/analytics_event.dart';
import 'package:finsync/presentation/pages/profile/profile_bloc.dart';
import 'package:finsync/presentation/pages/profile/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddEventCalendar extends StatefulWidget {
  const AddEventCalendar({super.key});

  @override
  State<StatefulWidget> createState() => _AddEventCalendarState();
}

class _AddEventCalendarState extends State<AddEventCalendar> {
  final _nameEventController = TextEditingController();
  final _priceEventController = TextEditingController();

  DateTime? selectedDate;
  bool _isSaving = false;

  CalendarEventType selectedType = CalendarEventType.despesa;
  ExpenseCategory selectedCategory = ExpenseCategory.alimentacao;
  bool repeatMonthly = false;

  bool get _isIncome => selectedType == CalendarEventType.receita;

  /// Mesma regra do formulário de movimentos: uma receita não se
  /// categoriza, fica sempre em `rendimento`.
  ExpenseCategory get _categoryToSave =>
      _isIncome ? ExpenseCategory.income : selectedCategory;

  @override
  void dispose() {
    _nameEventController.dispose();
    _priceEventController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime(2024),

      lastDate: DateTime(2035),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_isSaving) return;

    final price = double.tryParse(
      _priceEventController.text.replaceAll(',', '.'),
    );

    if (_nameEventController.text.trim().isEmpty ||
        price == null ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('analytics.fill_event_fields'))),
      );
      return;
    }

    final calendarEvent = CalendarEventEntity(
      id: 0,
      name: _nameEventController.text.trim(),
      price: AppCurrency.toBase(price),
      date: selectedDate!,
      type: selectedType,
      category: _categoryToSave,
      repeatMonthly: repeatMonthly,
    );

    setState(() {
      _isSaving = true;
    });

    try {
      final completer = Completer<void>();
      context.read<AnalyticsBloc>().add(
        AddEventCalendarEvent(calendarEvent, completer: completer),
      );

      await completer.future.timeout(const Duration(seconds: 12));

      if (!mounted) return;
      context.read<ProfileBloc>().add(LoadProfileEvent());

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text(tr('analytics.event_saved'))),
      );
    } on TimeoutException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('analytics.operation_timeout'))),
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
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
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
                    borderRadius: BorderRadius.circular(20),
                  ),
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
                      Icons.event_available_rounded,
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
                          tr('analytics.new_event'),
                          style: AppTextStyles.headingMedium.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tr('analytics.new_event_subtitle'),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              TextFormField(
                controller: _nameEventController,
                enabled: !_isSaving,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  labelText: tr('analytics.event_name_label'),
                  prefixIcon: Icon(
                    Icons.title_rounded,
                    color: AppColors.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _priceEventController,
                enabled: !_isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  labelText: tr('analytics.value_label', {'symbol': AppCurrency.symbol}),
                  prefixIcon: Icon(AppCurrency.icon, color: AppColors.secondary),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                tr('analytics.type_label'),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<CalendarEventType>(
                  segments: [
                    ButtonSegment(
                      value: CalendarEventType.despesa,
                      label: Text(tr('analytics.expense_type')),
                      icon: const Icon(Icons.arrow_downward_rounded),
                    ),
                    ButtonSegment(
                      value: CalendarEventType.receita,
                      label: Text(tr('analytics.income_type')),
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                  ],
                  selected: {selectedType},
                  onSelectionChanged: _isSaving
                      ? null
                      : (selection) {
                          setState(() {
                            selectedType = selection.first;
                          });
                        },
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.secondary,
                    selectedForegroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              // Só as despesas têm categoria. Numa receita o campo
              // desaparece, tal como no formulário de movimentos.
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _isIncome
                    ? const SizedBox(width: double.infinity)
                    : Column(
                        children: [
                          const SizedBox(height: 18),
                          DropdownButtonFormField<ExpenseCategory>(
                            initialValue: selectedCategory,
                            style: AppTextStyles.bodyMedium,
                            decoration: InputDecoration(
                              labelText: tr('analytics.category_label'),
                              prefixIcon: Icon(
                                Icons.category_outlined,
                                color: AppColors.secondary,
                              ),
                            ),
                            items: [
                              for (final category
                                  in ExpenseCategory.selectable)
                                DropdownMenuItem(
                                  value: category,
                                  child: Row(
                                    children: [
                                      Icon(
                                        category.icon,
                                        size: 18,
                                        color: AppColors.secondary,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(categoryLabel(category)),
                                    ],
                                  ),
                                ),
                            ],
                            onChanged: _isSaving
                                ? null
                                : (value) {
                                    setState(() {
                                      selectedCategory = value!;
                                    });
                                  },
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 18),

              // `Material` e não `Container`: o ListTile pinta o fundo e a
              // onda do toque no Material mais próximo acima dele, e um
              // Container colorido pelo meio esconde-o.
              Material(
                color: AppColors.background,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: AppColors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: repeatMonthly,
                    onChanged: _isSaving
                        ? null
                        : (value) {
                            setState(() {
                              repeatMonthly = value;
                            });
                          },
                    activeThumbColor: AppColors.secondary,
                    title: Text(tr('analytics.repeat_monthly')),
                    subtitle: Text(
                      tr('analytics.repeat_monthly_subtitle'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              InkWell(
                borderRadius: BorderRadius.circular(16),

                onTap: _isSaving ? null : _selectDate,

                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: tr('analytics.date_label'),
                    prefixIcon: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.secondary,
                    ),
                  ),

                  child: Text(
                    selectedDate == null
                        ? tr('common.select_date')
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    style: selectedDate == null
                        ? AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          )
                        : AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sem esta frase, criar um evento para daqui a um mês e ver o
              // saldo na mesma parece um bug. É a regra menos óbvia do ecrã.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tr('analytics.event_scheduled_note'),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),

                onPressed: _isSaving ? null : _saveEvent,

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

                label: Text(tr('analytics.save_event')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
