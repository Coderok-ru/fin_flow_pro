import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/income_controller.dart';

class IncomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IncomeController>(() => IncomeController());
  }
}