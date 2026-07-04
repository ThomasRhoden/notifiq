import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

void main() async {
  // Garante que o ambiente Flutter esteja pronto antes de inicializar recursos nativos.
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o serviço de notificações locais antes da primeira renderização.
  await NotificationService().init();

  // Torna a barra de status visualmente integrada ao design do app.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Sobe a aplicação com o tema e a navegação configurados.
  runApp(const NotifiqApp());
}

class NotifiqApp extends StatelessWidget {
  const NotifiqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notifiq',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const HomeScreen(),
    );
  }
}
