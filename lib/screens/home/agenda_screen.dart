import 'package:flutter/material.dart';

import '../../models/care_record_model.dart';
import '../../models/pet_model.dart';
import '../../repositories/firestore_care_record_repository.dart';
import '../../repositories/firestore_pet_repository.dart';
import '../pets/care_records_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final FirestorePetRepository _petRepository = FirestorePetRepository();

  final FirestoreCareRecordRepository _careRepository =
      FirestoreCareRecordRepository();

  late Future<List<_AgendaItem>> _agendaFuture;

  @override
  void initState() {
    super.initState();
    _agendaFuture = _loadAgenda();
  }

  Future<List<_AgendaItem>> _loadAgenda() async {
    final pets = await _petRepository.getPets();

    final results = await Future.wait(
      pets.map((pet) async {
        final records = await _careRepository.getRecords(pet.id);

        return records.map((record) => _AgendaItem(pet: pet, record: record));
      }),
    );

    final items = results.expand((records) => records).toList();

    final now = DateTime.now();

    items.sort((a, b) {
      final aUpcoming = !a.record.date.isBefore(
        DateTime(now.year, now.month, now.day),
      );
      final bUpcoming = !b.record.date.isBefore(
        DateTime(now.year, now.month, now.day),
      );

      if (aUpcoming != bUpcoming) {
        return aUpcoming ? -1 : 1;
      }

      if (aUpcoming) {
        return a.record.date.compareTo(b.record.date);
      }

      return b.record.date.compareTo(a.record.date);
    });

    return items;
  }

  Future<void> _refreshAgenda() async {
    setState(() {
      _agendaFuture = _loadAgenda();
    });

    try {
      await _agendaFuture;
    } catch (_) {
      // O FutureBuilder apresenta o estado de erro.
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            onPressed: _refreshAgenda,
            tooltip: 'Atualizar agenda',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAgenda,
          child: FutureBuilder<List<_AgendaItem>>(
            future: _agendaFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 80),
                    const Icon(Icons.cloud_off_outlined, size: 56),
                    const SizedBox(height: 16),
                    Text(
                      'Não foi possível carregar a agenda.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Verifique sua conexão e tente novamente.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: FilledButton.icon(
                        onPressed: _refreshAgenda,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ),
                  ],
                );
              }

              final items = snapshot.data ?? [];

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                children: [
                  Text(
                    'Cuidados dos seus pets',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Acompanhe vacinas, consultas e medicamentos '
                    'em um só lugar.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.event_note_outlined,
                          size: 36,
                          color: colors.onPrimaryContainer,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${items.length} '
                                '${items.length == 1 ? 'registro' : 'registros'}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: colors.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Cuidados registrados dos seus pets',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colors.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Histórico de cuidados',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (items.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.calendar_month_outlined,
                              size: 48,
                              color: colors.primary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Sua agenda está vazia',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Para registrar um cuidado, acesse '
                              'Pets, escolha um animal e abra Cuidados.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...items.map((item) {
                      final isPast = item.record.date.isBefore(
                        DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                        ),
                      );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: colors.primaryContainer,
                            child: Icon(
                              _typeIcon(item.record.type),
                              color: colors.primary,
                            ),
                          ),
                          title: Text(
                            item.record.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Pet: ${item.pet.name}'),
                                const SizedBox(height: 4),
                                Text(_typeLabel(item.record.type)),
                                const SizedBox(height: 4),
                                Text('Data: ${_formatDate(item.record.date)}'),
                                if (isPast) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    'Registro anterior',
                                    style: TextStyle(
                                      color: colors.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) => CareRecordsScreen(
                                      petId: item.pet.id,
                                      petName: item.pet.name,
                                    ),
                                  ),
                                )
                                .then((_) => _refreshAgenda());
                          },
                        ),
                      );
                    }),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AgendaItem {
  final PetModel pet;
  final CareRecordModel record;

  const _AgendaItem({required this.pet, required this.record});
}
