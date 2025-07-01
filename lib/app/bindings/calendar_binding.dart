import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/calendar_controller.dart';
import 'package:fin_flow_pro/app/controllers/income_controller.dart';
import 'package:fin_flow_pro/app/controllers/expense_controller.dart';

class CalendarBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalendarController>(() => CalendarController());
    
    // Убедимся, что контроллеры доходов и расходов доступны
    if (!Get.isRegistered<IncomeController>()) {
      Get.lazyPut<IncomeController>(() => IncomeController());
    }
    
    if (!Get.isRegistered<ExpenseController>()) {
      Get.lazyPut<ExpenseController>(() => ExpenseController());
    }
  }
}