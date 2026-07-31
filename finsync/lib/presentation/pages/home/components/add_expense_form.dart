import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finsync/domain/entities/expense.dart';
import 'package:finsync/domain/entities/expense_category.dart';
import 'package:finsync/presentation/pages/home/home_bloc.dart';
import 'package:finsync/presentation/pages/home/home_event.dart';
import 'package:finsync/core/currency/app_currency.dart';
import 'package:finsync/core/i18n/app_translations.dart';
import 'package:finsync/core/theme/colors.dart';
import 'package:finsync/core/theme/text_styles.dart';
import 'package:finsync/presentation/pages/home/components/category_labels.dart';

class AddExpenseForm extends StatefulWidget {
  const AddExpenseForm({super.key});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  DateTime? selectedDate = DateTime.now();

  ExpenseCategory selectedCategory = ExpenseCategory.alimentacao;

  ExpenseType selectedType = ExpenseType.despesa;

  bool get _isIncome => selectedType == ExpenseType.receita;

  /// Numa receita não há categoria a escolher — o dinheiro entrou, ponto.
  /// A categoria fica sempre `rendimento` para a base de dados continuar a
  /// ter um valor válido em todas as linhas.
  ExpenseCategory get _categoryToSave =>
      _isIncome ? ExpenseCategory.income : selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
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
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.replaceAll(',', '.'));

    if (name.isEmpty || price == null || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('home.save_error'))),
      );
      return;
    }

    final expense = Expense(
      id: 0,
      name: name,
      price: AppCurrency.toBase(price),
      category: _categoryToSave,
      date: selectedDate!,
      type: selectedType,
    );

    context.read<HomeBloc>().add(AddExpenseEvent(expense));

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

              const SizedBox(height: 24),

              Text(tr('home.new_movement'), style: AppTextStyles.headingMedium),

              const SizedBox(height: 6),

              Text(
                tr('home.new_movement_subtitle'),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: SegmentedButton<ExpenseType>(
                  segments: [
                    ButtonSegment(
                      value: ExpenseType.despesa,
                      label: Text(tr('home.expense_type')),
                      icon: const Icon(Icons.arrow_downward_rounded),
                    ),
                    ButtonSegment(
                      value: ExpenseType.receita,
                      label: Text(tr('home.income_type')),
                      icon: const Icon(Icons.arrow_upward_rounded),
                    ),
                  ],
                  selected: {selectedType},
                  onSelectionChanged: (selection) {
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

              const SizedBox(height: 22),

              TextFormField(
                controller: _nameController,
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  labelText: tr('home.name_label'),
                  prefixIcon: Icon(
                    Icons.shopping_bag_outlined,
                    color: AppColors.secondary,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              TextFormField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AppTextStyles.bodyMedium,
                decoration: InputDecoration(
                  labelText: tr('home.value_label', {'symbol': AppCurrency.symbol}),
                  prefixIcon: Icon(AppCurrency.icon, color: AppColors.secondary),
                ),
              ),

              // A categoria só faz sentido numa despesa. Numa receita o
              // campo desaparece em vez de ficar desativado: um campo
              // cinzento que não se mexe levanta mais dúvidas do que campo
              // nenhum.
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
                              labelText: tr('home.category_label'),
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
                            onChanged: (value) {
                              setState(() {
                                selectedCategory = value!;
                              });
                            },
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 18),

              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: tr('home.date_label'),
                    prefixIcon: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.secondary,
                    ),
                  ),
                  child: Text(
                    selectedDate == null
                        ? tr('common.select_date')
                        : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _saveExpense,
                icon: const Icon(Icons.save_outlined),
                label: Text(tr('common.save')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
