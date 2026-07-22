import 'dart:io';

import 'package:finsync/domain/entities/desire.dart';
import 'package:finsync/presentation/pages/desire/desire_bloc.dart';
import 'package:finsync/presentation/pages/desire/desire_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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

  final ImagePicker picker = ImagePicker();

  File? _image;

  DateTime? _selectedDate;

  Future<void> pickImage() async {
    final XFile? file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (file != null) {
      setState(() {
        _image = File(file.path);
      });
    }
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
    super.dispose();
  }

  void _saveDesire() {
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));

    if (_nameController.text.trim().isEmpty ||
        price == null ||
        _selectedDate == null) {
      return;
    }

    final desire = Desire(
      id: 0,
      name: _nameController.text.trim(),
      price: price,
      date: _selectedDate!,
      image: _image?.path,
    );

    context.read<DesireBloc>().add(AddDesireEvent(desire));

    Navigator.pop(context);
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
                onTap: pickImage,
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
                            const Text(
                              "Adicionar imagem",
                              style: TextStyle(fontWeight: FontWeight.w600),
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

              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: selectDate,
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
                onPressed: _saveDesire,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                icon: const Icon(Icons.save_outlined),
                label: const Text("Guardar Desejo"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
