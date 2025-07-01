import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/expense_controller.dart';

class ExpenseBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExpenseController>(() => ExpenseController());
  }
}