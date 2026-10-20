import 'package:flutter/material.dart';

import '../../models/care_record_model.dart';

class CareRecordFormScreen extends StatefulWidget {
  final String petId;
  final String petName;
  final CareRecordModel? record;

  const CareRecordFormScreen({
    super.key,
    required this.petId,
    required this.petName,
    this.record,
  });

  bool get isEditing => record != null;

  @override
  State<CareRecordFormScreen> createState() => _CareRecordFormScreenState();
}

class _CareRecordFormScreenState extends State<CareRecordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  CareType _selectedType = CareType.vaccine;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    final record = widget.record;

    if (record != null) {
      _titleController.text = record.title;
      _descriptionController.text = record.description;
      _selectedType = record.type;
      _selectedDate = record.date;
    } else {
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _typeLabel(CareType type) {
    switch (type) {
      case CareType.vaccine:
        return 'Vacina';
      case CareType.veterinaryAppointment:
        return 'Consulta veterinária';
      case CareType.medication:
        return 'Medicamento';
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      helpText: 'Selecione a data do cuidado',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (selected != null && mounted) {
      setState(() => _selectedDate = selected);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final date = _selectedDate;

    if (date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a data do cuidado.')),
      );
      return;
    }

    final record = CareRecordModel(
      id: widget.record?.id ?? '',
      petId: widget.petId,
      title: _titleController.text.trim(),
      type: _selectedType,
      description: _descriptionController.text.trim(),
      date: date,
    );

    Navigator.of(context).pop(record);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar cuidado' : 'Novo cuidado'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                widget.petName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Registre as informações de saúde do seu pet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<CareType>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de cuidado',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: CareType.values.map((type) {
                  return DropdownMenuItem<CareType>(
                    value: type,
                    child: Text(_typeLabel(type)),
                  );
                }).toList(),
                onChanged: (type) {
                  if (type != null) {
                    setState(() => _selectedType = type);
                  }
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ex.: Vacina antirrábica',
                  prefixIcon: Icon(Icons.edit_note_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe o título do cuidado.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data do cuidado',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Selecione a data'
                        : _formatDate(_selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 3,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Descrição ou observações',
                  hintText: 'Ex.: próxima dose, orientações...',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: Icon(isEditing ? Icons.save_outlined : Icons.add),
                  label: Text(
                    isEditing ? 'Salvar alterações' : 'Registrar cuidado',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
