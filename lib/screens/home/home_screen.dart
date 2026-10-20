import 'package:flutter/material.dart';

import '../../models/care_record_model.dart';
import '../../models/pet_model.dart';
import '../../repositories/firestore_care_record_repository.dart';
import '../../repositories/firestore_pet_repository.dart';
import '../pets/care_records_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onOpenPets;
  final VoidCallback onOpenAgenda;
  final VoidCallback onOpenProfile;

  const HomeScreen({
    super.key,
    required this.onOpenPets,
    required this.onOpenAgenda,
    required this.onOpenProfile,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _petRepository = FirestorePetRepository();
  final _careRepository = FirestoreCareRecordRepository();

  late Future<_DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = _loadDashboard();
  }

  Future<_DashboardData> _loadDashboard() async {
    final pets = await _petRepository.getPets();

    final recordsByPet = await Future.wait(
      pets.map((pet) => _careRepository.getRecords(pet.id)),
    );

    final items = <_DashboardCare>[];

    for (var i = 0; i < pets.length; i++) {
      for (final record in recordsByPet[i]) {
        items.add(_DashboardCare(pet: pets[i], record: record));
      }
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    items.sort((a, b) {
      final aUpcoming = !a.record.date.isBefore(today);
      final bUpcoming = !b.record.date.isBefore(today);

      if (aUpcoming != bUpcoming) {
        return aUpcoming ? -1 : 1;
      }

      return aUpcoming
          ? a.record.date.compareTo(b.record.date)
          : b.record.date.compareTo(a.record.date);
    });

    return _DashboardData(pets: pets, careItems: items);
  }

  Future<void> _refresh() async {
    final future = _loadDashboard();

    setState(() {
      _dashboardFuture = future;
    });

    try {
      await future;
    } catch (_) {
      // O FutureBuilder apresenta o estado de erro.
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _careTypeLabel(CareType type) {
    switch (type) {
      case CareType.vaccine:
        return 'Vacina';
      case CareType.veterinaryAppointment:
        return 'Consulta veterinária';
      case CareType.medication:
        return 'Medicamento';
    }
  }

  IconData _careTypeIcon(CareType type) {
    switch (type) {
      case CareType.vaccine:
        return Icons.vaccines_outlined;
      case CareType.veterinaryAppointment:
        return Icons.medical_services_outlined;
      case CareType.medication:
        return Icons.medication_outlined;
    }
  }

  Color _careTypeColor(CareType type) {
    switch (type) {
      case CareType.vaccine:
        return const Color(0xFF4778D0);
      case CareType.veterinaryAppointment:
        return const Color(0xFF168C78);
      case CareType.medication:
        return const Color(0xFFE69A32);
    }
  }

  Future<void> _openCareHistory(PetModel pet) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CareRecordsScreen(petId: pet.id, petName: pet.name),
      ),
    );

    if (mounted) {
      await _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6FB),
        titleSpacing: 20,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.pets, color: colors.primary),
            ),
            const SizedBox(width: 10),
            const Text(
              'PetCare',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            tooltip: 'Atualizar informações',
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            onPressed: widget.onOpenProfile,
            tooltip: 'Perfil',
            icon: const Icon(Icons.account_circle_outlined),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<_DashboardData>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 220),
                    Center(child: CircularProgressIndicator()),
                  ],
                );
              }

              if (snapshot.hasError) {
                return ListView(
                  padding: const EdgeInsets.all(24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 100),
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 52,
                      color: colors.error,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Não foi possível carregar seus dados.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Confira sua conexão e tente novamente.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: FilledButton.icon(
                        onPressed: _refresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ),
                  ],
                );
              }

              final data = snapshot.data;
              if (data == null) return const SizedBox.shrink();

              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final upcoming = data.careItems
                  .where((item) => !item.record.date.isBefore(today))
                  .take(3)
                  .toList();

              final overdue = data.careItems
                  .where((item) => item.record.date.isBefore(today))
                  .length;

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                children: [
                  _WelcomeBanner(
                    petCount: data.pets.length,
                    overdueCount: overdue,
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Meus pets',
                          value: '${data.pets.length}',
                          description: data.pets.length == 1
                              ? 'companheiro cadastrado'
                              : 'companheiros cadastrados',
                          icon: Icons.pets_rounded,
                          color: const Color(0xFF7650C8),
                          onTap: widget.onOpenPets,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Atenção',
                          value: '$overdue',
                          description: overdue == 1
                              ? 'cuidado com data passada'
                              : 'cuidados com data passada',
                          icon: Icons.notifications_active_outlined,
                          color: const Color(0xFFE28A36),
                          onTap: widget.onOpenAgenda,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const _SectionHeading(
                    title: 'Acesso rápido',
                    subtitle: 'O que você precisa fazer?',
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.add_circle_outline_rounded,
                          label: 'Cadastrar pet',
                          color: const Color(0xFF7650C8),
                          onTap: widget.onOpenPets,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _QuickAction(
                          icon: Icons.calendar_month_rounded,
                          label: 'Ver agenda',
                          color: const Color(0xFF168C78),
                          onTap: widget.onOpenAgenda,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),
                  _SectionHeading(
                    title: 'Meus pets',
                    subtitle: data.pets.isEmpty
                        ? 'Cadastre seu primeiro companheiro'
                        : 'Seus companheiros de todos os dias',
                    trailing: TextButton(
                      onPressed: widget.onOpenPets,
                      child: const Text('Ver todos'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (data.pets.isEmpty)
                    _EmptySection(
                      icon: Icons.pets_rounded,
                      title: 'Sua família começa aqui',
                      message: 'Cadastre seu pet para organizar vacinas, consultas e medicamentos.',
                      buttonLabel: 'Cadastrar primeiro pet',
                      onPressed: widget.onOpenPets,
                    )
                  else
                    ...data.pets
                        .take(3)
                        .map(
                          (pet) => _PetPreview(
                            pet: pet,
                            onTap: () => _openCareHistory(pet),
                          ),
                        ),

                  const SizedBox(height: 24),
                  _SectionHeading(
                    title: 'Próximos cuidados',
                    subtitle: 'Datas para acompanhar de perto',
                    trailing: TextButton(
                      onPressed: widget.onOpenAgenda,
                      child: const Text('Ver agenda'),
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (upcoming.isEmpty)
                    _EmptySection(
                      icon: Icons.event_available_rounded,
                      title: 'Tudo organizado por aqui?',
                      message: data.pets.isEmpty
                          ? 'Cadastre um pet para começar a organizar os cuidados.'
                          : 'Não há cuidados futuros registrados. Consulte o histórico ou adicione um novo cuidado.',
                      buttonLabel: data.pets.isEmpty
                          ? 'Cadastrar pet'
                          : 'Abrir agenda',
                      onPressed: data.pets.isEmpty
                          ? widget.onOpenPets
                          : widget.onOpenAgenda,
                    )
                  else
                    ...upcoming.map((item) {
                      final isToday =
                          item.record.date.year == today.year &&
                          item.record.date.month == today.month &&
                          item.record.date.day == today.day;

                      return _CarePreview(
                        title: item.record.title,
                        petName: item.pet.name,
                        date: _formatDate(item.record.date),
                        typeLabel: _careTypeLabel(item.record.type),
                        icon: _careTypeIcon(item.record.type),
                        color: _careTypeColor(item.record.type),
                        isToday: isToday,
                        onTap: () => _openCareHistory(item.pet),
                      );
                    }),

                  if (overdue > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF1E3),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFF3D2B1)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFFAD641D),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Você tem $overdue ${overdue == 1 ? 'cuidado com data passada' : 'cuidados com datas passadas'}. Confira a agenda para verificar se precisam ser atualizados.',
                              style: const TextStyle(
                                color: Color(0xFF784516),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  final int petCount;
  final int overdueCount;

  const _WelcomeBanner({required this.petCount, required this.overdueCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6D45BC), Color(0xFF925DE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7650C8).withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -12,
            top: -8,
            bottom: -8,
            width: 164,
            child: Image.network(
              'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=500&q=85',
              fit: BoxFit.cover,
              alignment: Alignment.center,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(
                  Icons.pets_rounded,
                  size: 90,
                  color: Colors.white38,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF6D45BC),
                    const Color(0xFF6D45BC).withValues(alpha: 0.94),
                    const Color(0xFF6D45BC).withValues(alpha: 0.12),
                  ],
                  stops: const [0.0, 0.48, 1.0],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: 230,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'CUIDADO COM CARINHO 🐾',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Seu pet, sua prioridade.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      height: 1.15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    overdueCount > 0
                        ? 'Confira os cuidados que precisam da sua atenção.'
                        : petCount == 0
                        ? 'Organize a rotina de quem você ama.'
                        : 'Tudo organizado para cuidar melhor.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.4,
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
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF29233A),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: Color(0xFF817B8D)),
              ),
            ],
          ),
        ),
        trailing ?? const SizedBox.shrink(),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          constraints: const BoxConstraints(minHeight: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF29233A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 10,
                  height: 1.3,
                  color: Color(0xFF817B8D),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.09),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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

class _PetPreview extends StatelessWidget {
  final PetModel pet;
  final VoidCallback onTap;

  const _PetPreview({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final detail = [
      pet.species,
      pet.breed,
    ].where((value) => value.trim().isNotEmpty).join(' • ');

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFECE8F3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  _petPhotoUrl(pet.species),
                  width: 66,
                  height: 66,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 66,
                    height: 66,
                    color: const Color(0xFFF0E9FC),
                    child: const Icon(
                      Icons.pets_rounded,
                      color: Color(0xFF7650C8),
                      size: 30,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF29233A),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      detail.isEmpty ? 'Pet cadastrado' : detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF817B8D),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Ver histórico de cuidados',
                      style: TextStyle(
                        color: Color(0xFF7650C8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9C93AD)),
            ],
          ),
        ),
      ),
    );
  }

  String _petPhotoUrl(String species) {
    final normalized = species.toLowerCase();

    if (normalized.contains('gato') || normalized.contains('cat')) {
      return 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=240&q=80';
    }

    return 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&w=240&q=80';
  }
}

class _CarePreview extends StatelessWidget {
  final String title;
  final String petName;
  final String date;
  final String typeLabel;
  final IconData icon;
  final Color color;
  final bool isToday;
  final VoidCallback onTap;

  const _CarePreview({
    required this.title,
    required this.petName,
    required this.date,
    required this.typeLabel,
    required this.icon,
    required this.color,
    required this.isToday,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFECE8F3)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '$petName • $typeLabel\n${isToday ? 'Hoje' : date}',
            style: const TextStyle(
              height: 1.5,
              fontSize: 11,
              color: Color(0xFF817B8D),
            ),
          ),
        ),
        isThreeLine: true,
        trailing: const Icon(
          Icons.chevron_right_rounded,
          color: Color(0xFF9C93AD),
        ),
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _EmptySection({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFECE8F3)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFF0E9FC),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, size: 30, color: const Color(0xFF7650C8)),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF29233A),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF817B8D),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
        ],
      ),
    );
  }
}

class _DashboardData {
  final List<PetModel> pets;
  final List<_DashboardCare> careItems;

  const _DashboardData({required this.pets, required this.careItems});
}

class _DashboardCare {
  final PetModel pet;
  final CareRecordModel record;

  const _DashboardCare({required this.pet, required this.record});
}
