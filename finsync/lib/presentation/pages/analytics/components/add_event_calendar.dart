import 'dart:async';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/calendar_event.dart';
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
        const SnackBar(
          content: Text('Preenche nome, valor e data antes de guardar.'),
        ),
      );
      return;
    }

    final calendarEvent = CalendarEventEntity(
      id: 0,
      name: _nameEventController.text.trim(),
      price: price,
      date: selectedDate!,
      type: selectedType,
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
        const SnackBar(content: Text('Evento guardado com sucesso.')),
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
                    child: const Icon(
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
                          "Novo evento",
                          style: AppTextStyles.headingMedium.copyWith(
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "Adiciona um evento ao teu calendário.",
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
                decoration: const InputDecoration(
                  labelText: "Nome do evento",
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _priceEventController,
                enabled: !_isSaving,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Valor (€)",
                  prefixIcon: Icon(Icons.euro_rounded),
                ),
              ),
              const SizedBox(height: 18),

              Text(
                "Tipo",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<CalendarEventType>(
                  segments: const [
                    ButtonSegment(
                      value: CalendarEventType.despesa,
                      label: Text("Despesa"),
                      icon: Icon(Icons.arrow_upward_rounded),
                    ),
                    ButtonSegment(
                      value: CalendarEventType.receita,
                      label: Text("Receita"),
                      icon: Icon(Icons.arrow_downward_rounded),
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

              const SizedBox(height: 18),

              InkWell(
                borderRadius: BorderRadius.circular(16),

                onTap: _isSaving ? null : _selectDate,

                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Data",

                    prefixIcon: Icon(Icons.calendar_month_rounded),
                  ),

                  child: Text(
                    selectedDate == null
                        ? "Selecionar data"
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
              const SizedBox(height: 30),

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

                label: const Text("Guardar Evento"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
