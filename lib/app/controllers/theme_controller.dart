import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:fin_flow_pro/app/services/storage_service.dart';
import 'package:fin_flow_pro/app/constants/app_constants.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';

class ThemeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadThemeMode();
  }
  
  // Загрузка темы из хранилища
  void loadThemeMode() {
    final savedTheme = _storageService.getThemeMode();
    
    switch (savedTheme) {
      case 'light':
        themeMode.value = ThemeMode.light;
        break;
      case 'dark':
        themeMode.value = ThemeMode.dark;
        break;
      default:
        themeMode.value = ThemeMode.system;
    }
  }
  
  // Изменение темы
  Future<void> changeThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    
    await _storageService.saveThemeMode(themeString);
  }
  
  // Получение текущей темы
  ThemeData get currentTheme {
    if (themeMode.value == ThemeMode.dark || 
        (themeMode.value == ThemeMode.system && 
         Get.isPlatformDarkMode)) {
      return ThemeConstants.darkTheme;
    }
    return ThemeConstants.lightTheme;
  }
  
  // Переключение между светлой и темной темой
  Future<void> toggleTheme() async {
    if (themeMode.value == ThemeMode.light) {
      await changeThemeMode(ThemeMode.dark);
    } else {
      await changeThemeMode(ThemeMode.light);
    }
  }
}