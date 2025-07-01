import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/theme_controller.dart';
import 'package:fin_flow_pro/app/controllers/home_controller.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';
import 'package:fin_flow_pro/app/services/storage_service.dart';
import 'package:fin_flow_pro/app/widgets/custom_bottom_nav.dart';
import 'package:fin_flow_pro/app/routes/app_routes.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SettingsView extends GetView<ThemeController> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final storageService = Get.find<StorageService>();
    final homeController = Get.find<HomeController>();
    final RxString appVersion = ''.obs;
    
    // Установка версии приложения
    appVersion.value = '1.0.0';
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // Секция внешнего вида
          _buildSectionHeader('Внешний вид'),
          
          // Переключатель темы
          Obx(() => ListTile(
            title: const Text('Тема приложения'),
            subtitle: Text(
              controller.themeMode.value == ThemeMode.light
                  ? 'Светлая'
                  : controller.themeMode.value == ThemeMode.dark
                      ? 'Темная'
                      : 'Системная',
            ),
            leading: Icon(
              controller.themeMode.value == ThemeMode.light
                  ? Icons.light_mode
                  : controller.themeMode.value == ThemeMode.dark
                      ? Icons.dark_mode
                      : Icons.settings_suggest,
              color: ThemeConstants.primaryColor,
            ),
            onTap: () {
              Get.bottomSheet(
                Container(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: Wrap(
                    children: [
                      ListTile(
                        title: const Text('Светлая тема'),
                        leading: const Icon(Icons.light_mode),
                        onTap: () {
                          controller.changeThemeMode(ThemeMode.light);
                          Get.back();
                        },
                      ),
                      ListTile(
                        title: const Text('Темная тема'),
                        leading: const Icon(Icons.dark_mode),
                        onTap: () {
                          controller.changeThemeMode(ThemeMode.dark);
                          Get.back();
                        },
                      ),
                      ListTile(
                        title: const Text('Системная тема'),
                        leading: const Icon(Icons.settings_suggest),
                        onTap: () {
                          controller.changeThemeMode(ThemeMode.system);
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          )),
          
          const Divider(),
          
          // Секция данных
          _buildSectionHeader('Управление данными'),
          
          ListTile(
            title: const Text('Очистить все данные'),
            subtitle: const Text('Удалить все доходы и расходы'),
            leading: const Icon(
              Icons.delete_forever,
              color: Colors.red,
            ),
            onTap: () {
              Get.defaultDialog(
                title: 'Очистка данных',
                middleText: 'Вы уверены, что хотите удалить все данные приложения? Это действие невозможно отменить.',
                textConfirm: 'Да, удалить',
                textCancel: 'Отмена',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red,
                onConfirm: () {
                  storageService.clearAll();
                  Get.back();
                  Get.snackbar(
                    'Готово',
                    'Все данные очищены',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              );
            },
          ),
          
          const Divider(),
          
          // О приложении
          _buildSectionHeader('О приложении'),
          
          ListTile(
            title: const Text('FinFlow PRO'),
            subtitle: Obx(() => Text('Версия ${appVersion.value}')),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: ThemeConstants.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                FontAwesomeIcons.wallet,
                color: ThemeConstants.primaryColor,
              ),
            ),
          ),
          
          const ListTile(
            title: Text('Описание'),
            subtitle: Text('Приложение для отслеживания личных финансов, доходов и расходов. Разработано с использованием Flutter и GetX.'),
          ),
          
          const SizedBox(height: 30),
          
          // Копирайт
          Center(
            child: Text(
              '© ${DateTime.now().year} FinFlow PRO',
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Показываем выбор между добавлением дохода или расхода
          showModalBottomSheet(
            context: context,
            builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_upward,
                        color: Colors.green,
                      ),
                    ),
                    title: const Text('Добавить доход'),
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.INCOME_FORM);
                    },
                  ),
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_downward,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text('Добавить расход'),
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.EXPENSE_FORM);
                    },
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: ThemeConstants.primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Obx(() => CustomBottomNav(
        currentIndex: homeController.currentNavIndex.value,
        onNavIndexChanged: homeController.changeNavIndex,
      )),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: ThemeConstants.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}