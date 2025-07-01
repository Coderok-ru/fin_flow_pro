import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/home_controller.dart';
import 'package:fin_flow_pro/app/controllers/income_controller.dart';
import 'package:fin_flow_pro/app/controllers/expense_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    // Сначала инициализируем контроллеры данных
    Get.lazyPut<IncomeController>(() => IncomeController());
    Get.lazyPut<ExpenseController>(() => ExpenseController());
    
    // Затем инициализируем контроллер главного экрана, который зависит от предыдущих
    Get.lazyPut<HomeController>(() => HomeController());
  }
}