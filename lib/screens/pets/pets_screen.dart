import 'package:flutter/material.dart';

import '../../models/pet_model.dart';
import '../../repositories/firestore_pet_repository.dart';
import '../../widgets/pet_card.dart';
import 'pet_form_screen.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  final FirestorePetRepository _repository = FirestorePetRepository();

  List<PetModel> _pets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final pets = await _repository.getPets();

      if (!mounted) return;

      setState(() {
        _pets = pets;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage =
            'Não foi possível carregar os pets. '
            'Verifique sua conexão e tente novamente.';
      });
    }
  }

  Future<void> _openPetForm() async {
    final pet = await Navigator.of(
      context,
    ).push<PetModel>(MaterialPageRoute(builder: (_) => const PetFormScreen()));

    if (pet == null || !mounted) return;

    try {
      await _repository.createPet(pet);

      if (!mounted) return;

      await _loadPets();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet cadastrado com sucesso! 🐾')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível cadastrar o pet. Tente novamente.'),
        ),
      );
    }
  }

  Future<void> _editPet(PetModel pet) async {
    final updatedPet = await Navigator.of(context).push<PetModel>(
      MaterialPageRoute(builder: (_) => PetFormScreen(pet: pet)),
    );

    if (updatedPet == null || !mounted) return;

    try {
      await _repository.updatePet(updatedPet.copyWith(id: pet.id));

      if (!mounted) return;

      await _loadPets();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet atualizado com sucesso! 🐾')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar o pet.')),
      );
    }
  }

  Future<void> _deletePet(PetModel pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir pet'),
          content: Text('Deseja realmente excluir ${pet.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      await _repository.deletePet(pet.id);

      if (!mounted) return;

      await _loadPets();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pet excluído com sucesso.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível excluir o pet.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pets')),
      body: SafeArea(child: _buildBody(context)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _openPetForm,
        icon: const Icon(Icons.add),
        label: const Text('Adicionar Pet'),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off_outlined, size: 52),
              const SizedBox(height: 16),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _loadPets,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pets.isEmpty) {
      return _buildEmptyState(context);
    }

    return _buildPetsList(context);
  }

  Widget _buildEmptyState(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seus companheiros 🐾',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Cadastre e acompanhe as informações dos seus pets.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 28),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    child: Icon(
                      Icons.pets,
                      size: 38,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum pet cadastrado',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Quando você cadastrar um pet, ele aparecerá nesta área.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openPetForm,
                      icon: const Icon(Icons.add),
                      label: const Text('Cadastrar Pet'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetsList(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Seus companheiros 🐾',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Gerencie os dados dos seus pets.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        ..._pets.map(
          (pet) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PetCard(
              pet: pet,
              onEdit: () => _editPet(pet),
              onDelete: () => _deletePet(pet),
            ),
          ),
        ),
      ],
    );
  }
}
