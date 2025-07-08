import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:window_size/window_size.dart';

// Función para configurar la ventana en escritorio
Future<void> setupDesktopWindow() async {
  // Solo ejecutar en plataformas de escritorio
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    try {
      // Establecer tamaño mínimo de ventana
      setWindowMinSize(const Size(800, 600));

      // Obtener información de la pantalla
      final screens = await getScreenList();
      if (screens.isNotEmpty) {
        final screen = screens[0];

        // Calcular tamaño inicial (80% del tamaño de la pantalla)
        final windowWidth = screen.visibleFrame.width * 0.8;
        final windowHeight = screen.visibleFrame.height * 0.8;

        // Establecer tamaño inicial de ventana
        setWindowMaxSize(Size(windowWidth, windowHeight));

        // Centrar la ventana en la pantalla
        final left = (screen.visibleFrame.width - windowWidth) / 2;
        final top = (screen.visibleFrame.height - windowHeight) / 2;
        setWindowFrame(Rect.fromLTWH(left, top, windowWidth, windowHeight));
      } else {
        // Si no se puede obtener información de la pantalla, usar valores predeterminados
        setWindowMaxSize(const Size(1280, 800));
      }

      // Establecer título de la ventana
      setWindowTitle('ALITO GROUP SRL - Control de Mantenimiento');
    } catch (e) {
      print('Error al configurar la ventana: $e');
    }
  }
}

// Función simplificada para maximizar la ventana
Future<void> toggleMaximizeWindow() async {
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    try {
      final windowInfo = await getWindowInfo();
      final screens = await getScreenList();

      if (screens.isNotEmpty) {
        final screen = screens[0];

        // Verificar si la ventana está cerca del tamaño máximo
        final windowSize = windowInfo.frame.size;
        final screenSize = screen.visibleFrame.size;

        final isMaximized = (windowSize.width >= screenSize.width * 0.9) &&
            (windowSize.height >= screenSize.height * 0.9);

        if (isMaximized) {
          // Restaurar a un tamaño más pequeño (70% de la pantalla)
          final windowWidth = screen.visibleFrame.width * 0.7;
          final windowHeight = screen.visibleFrame.height * 0.7;

          // Centrar la ventana
          final left = (screen.visibleFrame.width - windowWidth) / 2;
          final top = (screen.visibleFrame.height - windowHeight) / 2;

          setWindowFrame(Rect.fromLTWH(left, top, windowWidth, windowHeight));
        } else {
          // Maximizar al tamaño de la pantalla
          setWindowFrame(screen.visibleFrame);
        }
      }
    } catch (e) {
      print('Error al cambiar el tamaño de la ventana: $e');
    }
  }
}
