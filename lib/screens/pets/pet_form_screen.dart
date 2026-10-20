import 'package:flutter/material.dart';

import '../../models/pet_model.dart';

class PetFormScreen extends StatefulWidget {
  final PetModel? pet;

  const PetFormScreen({super.key, this.pet});

  bool get isEditing => pet != null;

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();

  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();

    if (widget.pet != null) {
      _nameController.text = widget.pet!.name;
      _speciesController.text = widget.pet!.species;
      _breedController.text = widget.pet!.breed;
      _birthDate = widget.pet!.birthDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();

    super.dispose();
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();

    final firstDate = DateTime(1900);

    final initialDate =
        _birthDate != null &&
            !_birthDate!.isBefore(firstDate) &&
            !_birthDate!.isAfter(now)
        ? _birthDate!
        : now;

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now,
      helpText: 'Selecione a data de nascimento',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (selectedDate != null) {
      setState(() {
        _birthDate = selectedDate;
      });
    }
  }

  void _savePet() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data de nascimento do pet.')),
      );

      return;
    }

    final pet = PetModel(
      id: widget.pet?.id ?? '',
      name: _nameController.text.trim(),
      species: _speciesController.text.trim(),
      breed: _breedController.text.trim(),
      birthDate: _birthDate!,
    );

    Navigator.of(context).pop(pet);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Pet' : 'Cadastrar Pet')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing
                      ? 'Atualize as informações do seu pet. 🐾'
                      : 'Cadastre seu companheiro. 🐾',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),

                const SizedBox(height: 8),

                Text(
                  'Preencha os dados abaixo para continuar.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                const SizedBox(height: 28),

                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Nome do pet',
                    hintText: 'Ex.: Mel',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do pet.';
                    }

                    if (value.trim().length < 2) {
                      return 'O nome deve ter pelo menos 2 caracteres.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _speciesController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Espécie',
                    hintText: 'Ex.: Cachorro',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a espécie.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _breedController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Raça',
                    hintText: 'Ex.: Golden Retriever',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe a raça.';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                InkWell(
                  onTap: _selectBirthDate,
                  borderRadius: BorderRadius.circular(14),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Data de nascimento',
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                    ),
                    child: Text(
                      _birthDate == null
                          ? 'Selecione a data'
                          : _formatDate(_birthDate!),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _savePet,
                    icon: Icon(isEditing ? Icons.save_outlined : Icons.add),
                    label: Text(
                      isEditing ? 'Salvar alterações' : 'Cadastrar Pet',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
