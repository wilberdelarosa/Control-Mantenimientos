import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/theme_service.dart';
import 'services/data_service.dart';
import 'screens/dashboard_screen.dart';
import 'utils/app_theme.dart';
import 'desktop/desktop_window.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar ventana para escritorio
  try {
    setupDesktopWindow();
  } catch (e) {
    print('Error al configurar ventana de escritorio: $e');
  }

  // Forzar orientación vertical solo en dispositivos móviles
  if (!isDesktop()) {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    } catch (e) {
      print('Error al configurar orientación: $e');
    }
  }

  // Inicializar servicios
  final dataService = DataService();
  await dataService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeService()),
        Provider<DataService>.value(value: dataService),
      ],
      child: const MyApp(),
    ),
  );
}

// Función para detectar si estamos en escritorio
bool isDesktop() {
  try {
    return !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
  } catch (e) {
    print('Error al detectar plataforma: $e');
    return false;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        return MaterialApp(
          title: 'ALITO GROUP SRL',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const DashboardScreen(),
          builder: (context, child) {
            // Aplicar un MediaQuery para asegurar que la UI se adapte correctamente
            return MediaQuery(
              // Establecer el factor de escala de texto a 1.0 para evitar que el texto se escale automáticamente
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          },
        );
      },
    );
  }
}
