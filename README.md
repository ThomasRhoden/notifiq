# Notifiq 🔔
> A única notificação que você precisa.

App de notificações 100% personalizáveis. Texto livre, cor, ícone, som e repetição — tudo configurável por notificação.

---

## Stack
- **Flutter 3.x** (Dart)
- `flutter_local_notifications` — agendamento e envio de notificações
- `shared_preferences` — persistência local (sem servidor)
- `timezone` — agendamento com fuso horário correto
- `uuid` — IDs únicos para cada notificação
- `url_launcher` — links externos (doações)

---

## Como rodar

### Pré-requisitos
- [Flutter SDK](https://flutter.dev/docs/get-started/install) instalado
- Android Studio ou VS Code com extensão Flutter
- Emulador Android / iOS ou dispositivo físico

### Passos

```bash
# 1. Instalar dependências
flutter pub get

# 2. Rodar no dispositivo/emulador
flutter run

# 3. Build APK (Android)
flutter build apk --release

# 4. Build para iOS
flutter build ios --release
```

---

## Estrutura do projeto

```
lib/
├── main.dart                    # Entrada do app
├── theme/
│   └── app_theme.dart           # Cores, fontes, tema dark
├── models/
│   └── notification_model.dart  # Modelo de notificação + serialização
├── services/
│   └── notification_service.dart # Persistência + agendamento
├── screens/
│   ├── home_screen.dart         # Lista de notificações
│   ├── editor_screen.dart       # Editor modular (criar/editar)
│   └── donate_screen.dart       # PIX / Bitcoin / Projeto social
└── widgets/
    └── notifiq_preview.dart     # Preview da notificação (dark/light)
```

---

## Permissões necessárias

### Android (`android/app/src/main/AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### iOS (`ios/Runner/Info.plist`)
Adicionado automaticamente pelo `flutter_local_notifications`.

---

## Personalizar doações (`donate_screen.dart`)

```dart
static const String _pixKey = 'SEU_PIX_AQUI';
static const String _bitcoinAddress = 'SEU_BITCOIN_AQUI';
static const String _projectUrl = 'https://seusite.com.br/projeto';
```

---

## Roadmap v2
- [ ] Temas visuais da notificação (bordas, animações)
- [ ] Suporte a imagens e GIFs
- [ ] Efeitos (brilho, glitter, partículas)
- [ ] Sons personalizados (upload do usuário)
- [ ] Marketplace de temas
- [ ] Sincronização em nuvem (backup)
- [ ] Widget na tela inicial

---

*Feito com ❤️ em Campo Bom, RS*
