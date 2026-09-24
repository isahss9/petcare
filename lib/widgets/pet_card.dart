import 'package:flutter/material.dart';

import '../models/pet_model.dart';

class PetCard extends StatelessWidget {
  final PetModel pet;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PetCard({super.key, required this.pet, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
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
                  Text(
                    '${pet.species} • ${pet.breed}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Nascimento: ${_formatDate(pet.birthDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
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
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}
