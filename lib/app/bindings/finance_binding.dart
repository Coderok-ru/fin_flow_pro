import 'package:get/get.dart';
import '../controllers/budget_controller.dart';
import '../controllers/finance_controller.dart';

/// Биндинг для инъекции зависимостей на экране финансов
class FinanceBinding extends Bindings {
  @override
  void dependencies() {
    // Регистрируем контроллер бюджета
    Get.lazyPut<BudgetController>(
      () => BudgetController(),
      fenix: true, // Сохраняем экземпляр между экранами
    );
    
    // Регистрируем контроллер финансов
    Get.lazyPut<FinanceController>(
      () => FinanceController(),
      fenix: true, // Сохраняем экземпляр между экранами
    );
  }
}