import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/statistics_controller.dart';
import 'package:fin_flow_pro/app/controllers/income_controller.dart';
import 'package:fin_flow_pro/app/controllers/expense_controller.dart';

class StatisticsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StatisticsController>(() => StatisticsController());
    
    // Убедимся, что income и expense контроллеры доступны
    if (!Get.isRegistered<IncomeController>()) {
      Get.lazyPut<IncomeController>(() => IncomeController());
    }
    
    if (!Get.isRegistered<ExpenseController>()) {
      Get.lazyPut<ExpenseController>(() => ExpenseController());
    }
  }
}