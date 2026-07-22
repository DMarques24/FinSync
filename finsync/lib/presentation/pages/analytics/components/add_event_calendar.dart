import 'dart:async';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/domain/entities/calendar_event.dart';
import 'package:finsync/presentation/pages/analytics/analytics_bloc.dart';
import 'package:finsync/presentation/pages/analytics/analytics_event.dart';
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
              Text(
                "Adiciona Evento no calendário",
                style: AppTextStyles.headingMedium,
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _nameEventController,
                decoration: const InputDecoration(labelText: "Evento nome"),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _priceEventController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Valor (€)",
                  prefixIcon: Icon(Icons.euro_rounded),
                ),
              ),
              const SizedBox(height: 18),

              InkWell(
                borderRadius: BorderRadius.circular(16),

                onTap: _selectDate,

                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Data",

                    prefixIcon: Icon(Icons.calendar_month),
                  ),

                  child: Text(
                    selectedDate == null
                        ? "Selecionar data"
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),

                label: const Text("Guardar Despesa"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
