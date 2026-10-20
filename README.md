# PetCare

Aplicativo Flutter para apoiar o gerenciamento de animais de estimação e a organização de cuidados, como vacinas, consultas veterinárias e medicamentos.

## Tecnologias

- Flutter e Dart
- Firebase Authentication para autenticação
- Cloud Firestore para persistência dos dados
- Git e GitHub para versionamento

## Funcionalidades previstas no projeto

- Cadastro e login de usuários
- Área principal e navegação entre telas
- Cadastro, consulta, edição e exclusão de pets
- Registro e consulta de cuidados dos animais
- Perfil do usuário
- Tema visual centralizado em `lib/theme/app_theme.dart`

> Observação: valide cada fluxo no aplicativo antes da apresentação. A existência de uma tela no código não garante, por si só, que todas as ações estejam concluídas.

## Requisitos

- Flutter SDK instalado
- Android Studio ou VS Code com extensões Flutter/Dart
- Projeto Firebase configurado
- Dispositivo Android, emulador ou outro destino suportado pelo Flutter

## Como executar

1. Abra o terminal na raiz do projeto.
2. Instale as dependências:

   ```bash
   flutter pub get
   ```

3. Confira a configuração do Flutter:

   ```bash
   flutter doctor
   ```

4. Execute a análise estática:

   ```bash
   flutter analyze
   ```

5. Inicie o aplicativo:

   ```bash
   flutter run
   ```

O projeto contém `lib/firebase_options.dart`. Confirme se esse arquivo corresponde ao projeto Firebase correto e se a plataforma de execução está habilitada no Firebase Console.

## Estrutura principal

```text
lib/
├── main.dart
├── firebase_options.dart
├── models/
│   ├── pet_model.dart
│   └── care_record_model.dart
├── repositories/
│   ├── pet_repository.dart
│   ├── firestore_pet_repository.dart
│   ├── care_record_repository.dart
│   └── firestore_care_record_repository.dart
├── screens/
│   ├── auth/
│   │   ├── auth_gate.dart
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   ├── home_screen.dart
│   │   ├── agenda_screen.dart
│   │   └── main_navigation_screen.dart
│   ├── pets/
│   │   ├── pets_screen.dart
│   │   ├── pet_form_screen.dart
│   │   ├── care_records_screen.dart
│   │   └── care_record_form_screen.dart
│   └── profile/
│       └── profile_screen.dart
├── services/
│   └── auth_service.dart
├── theme/
│   └── app_theme.dart
└── widgets/
    └── pet_card.dart
```

## Firebase e dados

O aplicativo usa Firebase Authentication e Cloud Firestore. Revise as configurações em `lib/firebase_options.dart` e as regras do Firestore no Firebase Console antes de publicar.

Uma organização comum para dados isolados por usuário é:

```text
users/{userId}
  pets/{petId}
    careRecords/{careRecordId}
```

Confirme os caminhos efetivamente usados nos repositórios `firestore_pet_repository.dart` e `firestore_care_record_repository.dart`. As regras do Firestore devem exigir autenticação e garantir que cada usuário só leia ou altere os próprios registros. Nunca use regras abertas em produção.

## Testes rápidos antes da entrega

- [ ] Cadastro de usuário com dados válidos
- [ ] Login e logout
- [ ] Mensagens de validação para dados inválidos
- [ ] Criar, editar, listar e excluir um pet
- [ ] Criar e consultar registros de cuidados
- [ ] Confirmar persistência no Firestore
- [ ] Conferir comportamento dos botões do perfil
- [ ] Executar `flutter analyze` sem problemas
- [ ] Registrar capturas de tela reais para a apresentação

## Capturas de tela

Adicione imagens reais do aplicativo em uma pasta como `docs/screenshots/` e inclua-as aqui, por exemplo:

```markdown
![Tela inicial](docs/screenshots/tela-inicial.png)
```

Não deixe imagens ilustrativas no lugar de capturas reais do aplicativo entregue.

## Versionamento com Git

```bash
git status
git add README.md manual/
git commit -m "docs: adiciona documentação do PetCare"
git push
```

Execute os comandos na raiz do repositório e confira o destino remoto antes de enviar.

## Projeto escolar

Projeto AV1 — Ensino Técnico em Informática. A documentação deve ser atualizada se a arquitetura, os caminhos do banco ou as funcionalidades mudarem.
