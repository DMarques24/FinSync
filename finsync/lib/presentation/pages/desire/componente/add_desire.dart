import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddDesire extends StatefulWidget {
  const AddDesire({super.key});

  @override
  State<AddDesire> createState() => _AddDesireState();
}

class _AddDesireState extends State<AddDesire> {
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Novo Desejo",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: _image == null
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40),
                            SizedBox(height: 8),
                            Text("Adicionar imagem"),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(_image!, fit: BoxFit.cover),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Nome do desejo",
                prefixIcon: Icon(Icons.shopping_bag_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _priceController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: "Preço (€)",
                prefixIcon: Icon(Icons.euro),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            InkWell(
              onTap: selectDate,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: "Data objetivo",
                  prefixIcon: Icon(Icons.calendar_month),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _selectedDate == null
                      ? "Selecionar data"
                      : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                ),
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  // Guardar desejo
                },
                icon: const Icon(Icons.save),
                label: const Text("Guardar desejo"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
