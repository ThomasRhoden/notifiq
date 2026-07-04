import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

/// Ponto de entrada do aplicativo Notifiq.
///
/// A função main é executada primeira e inicializa:
/// 1. Os serviços necessários (notificações locais)
/// 2. A aparência do sistema (status bar)
/// 3. A aplicação Flutter
void main() async {
  // Garante que o Flutter está inicializado antes de usar serviços nativos.
  // Necessário para acessar SharedPreferences e plugins de notificação.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o serviço de notificações que será usado pela aplicação.
  // Configura canais Android, permissões iOS e fuso horário.
  // Deve ser chamado antes de renderizar qualquer interface.
  await NotificationService().init();

  // Customiza a aparência da barra de status do sistema.
  // Define: cor de fundo (transparente para se integrar ao design)
  // e brilho dos ícones (claro para contraste com o fundo escuro).
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Inicia a aplicação com suas configurações de tema e navegação.
  runApp(const NotifiqApp());
}

/// Widget raiz da aplicação que configura Material Design e tema global.
///
/// Define a estrutura fundamental: tema escuro, título, e tela inicial.
class NotifiqApp extends StatelessWidget {
  const NotifiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Título da aplicação (exibido em multitarefas do sistema)
      title: 'Notifiq',
      
      // Remove o banner de debug no canto superior direito
      debugShowCheckedModeBanner: false,
      
      // Aplica o tema escuro customizado do AppTheme
      theme: AppTheme.theme,
      
      // Define a primeira tela a ser exibida
      home: const HomeScreen(),
    );
  }
}
