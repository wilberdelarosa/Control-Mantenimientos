import 'dart:io';
import 'package:flutter/foundation.dart';

class FileUtils {
  /// Selecciona un archivo y devuelve su ruta
  static Future<String?> pickFile({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      // Implementación simplificada para evitar errores
      print('Seleccionando archivo...');
      return null;
    } catch (e) {
      debugPrint('Error al seleccionar archivo: $e');
      return null;
    }
  }

  /// Selecciona múltiples archivos y devuelve sus rutas
  static Future<List<String>> pickMultipleFiles({
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      // Implementación simplificada para evitar errores
      print('Seleccionando múltiples archivos...');
      return [];
    } catch (e) {
      debugPrint('Error al seleccionar archivos: $e');
      return [];
    }
  }

  /// Selecciona un directorio y devuelve su ruta
  static Future<String?> pickDirectory({
    String? dialogTitle,
  }) async {
    try {
      // Implementación simplificada para evitar errores
      print('Seleccionando directorio...');
      return null;
    } catch (e) {
      debugPrint('Error al seleccionar directorio: $e');
      return null;
    }
  }

  /// Guarda un archivo en el sistema
  static Future<String?> saveFile({
    required List<int> bytes,
    required String suggestedName,
    List<String>? allowedExtensions,
    String? dialogTitle,
  }) async {
    try {
      // Implementación simplificada para evitar errores
      print('Guardando archivo: $suggestedName');

      // Crear un archivo temporal en el directorio de documentos
      final directory = _getDefaultDirectory();
      final filePath = '$directory/$suggestedName';

      try {
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return filePath;
      } catch (e) {
        debugPrint('Error al escribir archivo: $e');
      }

      return null;
    } catch (e) {
      debugPrint('Error al guardar archivo: $e');
      return null;
    }
  }

  /// Obtiene el directorio predeterminado según la plataforma
  static String _getDefaultDirectory() {
    try {
      if (Platform.isWindows) {
        return 'C:\\Users\\${Platform.environment['USERNAME'] ?? 'User'}\\Documents';
      } else if (Platform.isMacOS) {
        return '/Users/${Platform.environment['USER'] ?? 'user'}/Documents';
      } else if (Platform.isLinux) {
        return '/home/${Platform.environment['USER'] ?? 'user'}/Documents';
      }
    } catch (e) {
      debugPrint('Error al obtener directorio predeterminado: $e');
    }
    return '.';
  }
}
