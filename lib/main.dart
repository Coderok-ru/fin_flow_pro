import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:fin_flow_pro/app/routes/app_pages.dart';
import 'package:fin_flow_pro/app/routes/app_routes.dart';
import 'package:fin_flow_pro/app/services/storage_service.dart';
import 'package:fin_flow_pro/app/controllers/theme_controller.dart';
import 'package:fin_flow_pro/app/controllers/home_controller.dart';
import 'package:fin_flow_pro/app/controllers/income_controller.dart';
import 'package:fin_flow_pro/app/controllers/expense_controller.dart';
import 'package:fin_flow_pro/app/controllers/statistics_controller.dart';
import 'package:fin_flow_pro/app/controllers/budget_controller.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация форматирования даты для русского языка
  await initializeDateFormatting('ru_RU', null);
  
  // Инициализация сервиса хранения данных
  await Get.putAsync(() => StorageService().init());
  
  // Явная инициализация всех контроллеров в правильном порядке
  Get.put(ThemeController());
  Get.put(BudgetController()); // Инициализируем BudgetController до FinanceController
  Get.put(IncomeController());
  Get.put(ExpenseController());
  Get.put(HomeController());
  Get.put(StatisticsController());
  
  // Задаем предпочтительную ориентацию устройства
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();
    
    return Obx(() => GetMaterialApp(
      title: 'FinFlow PRO',
      theme: ThemeConstants.lightTheme,
      darkTheme: ThemeConstants.darkTheme,
      themeMode: themeController.themeMode.value,
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.HOME,
      getPages: AppPages.pages,
      defaultTransition: Transition.fade,
      locale: const Locale('ru', 'RU'),
    ));
  }
}
