import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _editarDadosPessoais(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _mostrarMensagem(context, 'Faça login para acessar seus dados.');
      return;
    }

    final controller = TextEditingController(text: user.displayName ?? '');

    final nome = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dados pessoais'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('E-mail: ${user.email ?? "Não informado"}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final valor = controller.text.trim();

              if (valor.isEmpty) return;

              Navigator.pop(dialogContext, valor);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (nome == null) return;

    try {
      await user.updateDisplayName(nome);
      await user.reload();

      if (!context.mounted) return;

      _mostrarMensagem(context, 'Nome atualizado com sucesso.');
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;

      _mostrarMensagem(
        context,
        'Não foi possível atualizar o nome: ${e.message ?? e.code}',
      );
    } catch (_) {
      if (!context.mounted) return;

      _mostrarMensagem(context, 'Erro ao atualizar os dados.');
    }
  }

  Future<void> _mostrarNotificacoes(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Notificações'),
        content: const Text(
          'O PetCare poderá utilizar esta área para configurar '
          'lembretes de vacinas, consultas e medicamentos. '
          'A ativação e o agendamento de notificações ainda '
          'precisam ser integrados ao sistema de lembretes.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarConfiguracoes(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Configurações'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.palette_outlined),
              title: Text('Aparência'),
              subtitle: Text('Tema roxo e branco do PetCare'),
            ),
            Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.cloud_outlined),
              title: Text('Armazenamento'),
              subtitle: Text('Firebase Authentication e Firestore'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Future<void> _mostrarAjuda(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajuda — PetCare'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'O PetCare ajuda você a organizar os cuidados '
                'com seus animais de estimação.',
              ),
              SizedBox(height: 16),
              Text(
                '• Pets: cadastre e consulte seus animais.\n'
                '• Agenda: organize vacinas, consultas e medicamentos.\n'
                '• Perfil: consulte seus dados e encerre sua sessão.',
              ),
              SizedBox(height: 16),
              Text('Projeto escolar — Ensino Técnico em Informática.'),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _mostrarMensagem(BuildContext context, String mensagem) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Meu Perfil')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 48,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  Icons.person,
                  size: 52,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName!
                    : 'Meu Perfil',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                user?.email ?? 'Gerencie suas informações e preferências.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              _ProfileOption(
                icon: Icons.person_outline,
                title: 'Dados pessoais',
                subtitle: 'Nome e informações da conta',
                onTap: () => _editarDadosPessoais(context),
              ),
              const SizedBox(height: 12),
              _ProfileOption(
                icon: Icons.notifications_outlined,
                title: 'Notificações',
                subtitle: 'Informações sobre seus lembretes',
                onTap: () => _mostrarNotificacoes(context),
              ),
              const SizedBox(height: 12),
              _ProfileOption(
                icon: Icons.settings_outlined,
                title: 'Configurações',
                subtitle: 'Preferências do aplicativo',
                onTap: () => _mostrarConfiguracoes(context),
              ),
              const SizedBox(height: 12),
              _ProfileOption(
                icon: Icons.help_outline,
                title: 'Ajuda',
                subtitle: 'Informações sobre o PetCare',
                onTap: () => _mostrarAjuda(context),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await AuthService().logout();

                      if (!context.mounted) return;

                      _mostrarMensagem(
                        context,
                        'Sessão encerrada com sucesso.',
                      );

                      // A navegação para o login deve ser controlada
                      // pelo listener de estado de autenticação do app.
                    } catch (_) {
                      if (!context.mounted) return;

                      _mostrarMensagem(
                        context,
                        'Não foi possível sair da conta.',
                      );
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair da conta'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
