import 'package:flutter/material.dart';

import '../models/pet_model.dart';
import '../screens/pets/care_records_screen.dart';

class PetCard extends StatelessWidget {
  final PetModel pet;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PetCard({super.key, required this.pet, this.onEdit, this.onDelete});

  void _openCareRecords(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CareRecordsScreen(petId: pet.id, petName: pet.name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .primaryContainer,
                  child: Icon(
                    Icons.pets,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('${pet.species} • ${pet.breed}'),
                      const SizedBox(height: 4),
                      Text(
                        'Nascimento: ${_formatDate(pet.birthDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _openCareRecords(context),
                  icon: const Icon(Icons.event_note_outlined),
                  label: const Text('Cuidados'),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    tooltip: 'Editar pet',
                    icon: const Icon(Icons.edit_outlined),
                  ),
                if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'Excluir pet',
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}
