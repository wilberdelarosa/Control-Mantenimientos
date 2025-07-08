import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isBottomMenu = true;
  bool _enableNotifications = true;
  
  bool get isDarkMode => _isDarkMode;
  bool get isBottomMenu => _isBottomMenu;
  bool get enableNotifications => _enableNotifications;
  
  static const String _darkModeKey = 'darkMode';
  static const String _bottomMenuKey = 'bottomMenu';
  static const String _notificationsKey = 'notifications';
  
  ThemeService() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_darkModeKey) ?? false;
    _isBottomMenu = prefs.getBool(_bottomMenuKey) ?? true;
    _enableNotifications = prefs.getBool(_notificationsKey) ?? true;
    notifyListeners();
  }
  
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, _isDarkMode);
    notifyListeners();
  }
  
  Future<void> toggleMenuType() async {
    _isBottomMenu = !_isBottomMenu;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bottomMenuKey, _isBottomMenu);
    notifyListeners();
  }
  
  Future<void> toggleNotifications() async {
    _enableNotifications = !_enableNotifications;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, _enableNotifications);
    notifyListeners();
  }
}
