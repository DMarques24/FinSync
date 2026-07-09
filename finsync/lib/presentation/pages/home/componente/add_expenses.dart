import 'package:flutter/material.dart';

import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';

class AddExpenses extends StatefulWidget {
  const AddExpenses({super.key});

  @override
  State<AddExpenses> createState() => _AddExpensesState();
}

class _AddExpensesState extends State<AddExpenses> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? selectedDate;

  String selectedCategory = "Alimentação";

  final categories = const [
    "Alimentação",
    "Transportes",
    "Compras",
    "Subscrições",
    "Saúde",
    "Lazer",
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
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

  void _saveExpense() {
    Navigator.pop(context);
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

              Text("Nova Despesa", style: AppTextStyles.headingMedium),

              const SizedBox(height: 6),

              Text(
                "Adiciona uma nova despesa.",
                style: AppTextStyles.bodySmall,
              ),

              const SizedBox(height: 28),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Nome",
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                ),
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: "Valor (€)",
                  prefixIcon: Icon(Icons.euro_rounded),
                ),
              ),

              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                value: selectedCategory,

                decoration: const InputDecoration(
                  labelText: "Categoria",
                  prefixIcon: Icon(Icons.category_outlined),
                ),

                items: categories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),

                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
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

                onPressed: _saveExpense,

                icon: const Icon(Icons.save_outlined),

                label: const Text("Guardar Despesa"),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
