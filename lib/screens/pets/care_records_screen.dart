import 'package:flutter/material.dart';

import '../../models/care_record_model.dart';
import '../../repositories/firestore_care_record_repository.dart';
import 'care_record_form_screen.dart';

class CareRecordsScreen extends StatefulWidget {
  final String petId;
  final String petName;

  const CareRecordsScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<CareRecordsScreen> createState() => _CareRecordsScreenState();
}

class _CareRecordsScreenState extends State<CareRecordsScreen> {
  final FirestoreCareRecordRepository _repository =
      FirestoreCareRecordRepository();

  List<CareRecordModel> _records = [];
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await _repository.getRecords(widget.petId);

      if (!mounted) return;

      setState(() {
        _records = records;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Não foi possível carregar o histórico. Tente novamente.';
      });
    }
  }

  Future<void> _openForm({CareRecordModel? record}) async {
    final result = await Navigator.of(context).push<CareRecordModel>(
      MaterialPageRoute(
        builder: (_) => CareRecordFormScreen(
          petId: widget.petId,
          petName: widget.petName,
          record: record,
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() => _isSaving = true);

    try {
      if (record == null) {
        await _repository.createRecord(result);
      } else {
        await _repository.updateRecord(
          result.copyWith(id: record.id, petId: widget.petId),
        );
      }

      if (!mounted) return;

      await _loadRecords();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            record == null
                ? 'Cuidado registrado com sucesso! 🐾'
                : 'Cuidado atualizado com sucesso!',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível salvar. Verifique sua conexão e tente novamente.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _deleteRecord(CareRecordModel record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir cuidado'),
        content: Text(
          'Deseja excluir "${record.title}" do histórico de '
          '${widget.petName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _repository.deleteRecord(petId: widget.petId, recordId: record.id);

      if (!mounted) return;

      await _loadRecords();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuidado excluído com sucesso.')),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o cuidado.')),
      );
    }
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

  IconData _typeIcon(CareType type) {
    switch (type) {
      case CareType.vaccine:
        return Icons.vaccines_outlined;
      case CareType.veterinaryAppointment:
        return Icons.medical_services_outlined;
      case CareType.medication:
        return Icons.medication_outlined;
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cuidados de ${widget.petName}')),
      body: SafeArea(child: _buildBody()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Novo cuidado'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 48),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadRecords,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_records.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_note_outlined,
                size: 64,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhum cuidado registrado',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Registre vacinas, consultas e medicamentos de '
                '${widget.petName}.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _isSaving ? null : () => _openForm(),
                icon: const Icon(Icons.add),
                label: const Text('Registrar primeiro cuidado'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRecords,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _records.length,
        itemBuilder: (context, index) {
          final record = _records[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  _typeIcon(record.type),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(record.title),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${_typeLabel(record.type)} • '
                  '${_formatDate(record.date)}'
                  '${record.description.trim().isEmpty ? '' : '\n${record.description}'}',
                ),
              ),
              isThreeLine: record.description.trim().isNotEmpty,
              trailing: PopupMenuButton<String>(
                tooltip: 'Ações do cuidado',
                onSelected: (action) {
                  if (action == 'edit') {
                    _openForm(record: record);
                  } else if (action == 'delete') {
                    _deleteRecord(record);
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Excluir'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
