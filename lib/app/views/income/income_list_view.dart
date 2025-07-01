import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/income_controller.dart';
import 'package:fin_flow_pro/app/controllers/home_controller.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';
import 'package:fin_flow_pro/app/routes/app_routes.dart';
import 'package:fin_flow_pro/app/constants/app_constants.dart';
import 'package:fin_flow_pro/app/widgets/custom_bottom_nav.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IncomeListView extends GetView<IncomeController> {
  const IncomeListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Доходы'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.incomes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FontAwesomeIcons.moneyBillTrendUp,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'У вас пока нет доходов',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.INCOME_FORM),
                  child: const Text('Добавить доход'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.incomes.length,
          itemBuilder: (context, index) {
            final income = controller.incomes[index];
            final dateFormat = DateFormat(AppConstants.dateFormat);
            
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    FontAwesomeIcons.arrowTrendUp,
                    color: Colors.green,
                  ),
                ),
                title: Text(
                  income.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Дата: ${dateFormat.format(income.date)}'),
                    Text('Периодичность: ${income.frequency}'),
                    if (income.endDate != null)
                      Text('До: ${dateFormat.format(income.endDate!)}'),
                  ],
                ),
                trailing: Text(
                  '₽${income.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                onTap: () {
                  // Редактирование дохода
                  Get.toNamed(
                    AppRoutes.INCOME_FORM,
                    arguments: income,
                  );
                },
                onLongPress: () {
                  // Удаление дохода
                  Get.defaultDialog(
                    title: 'Удаление',
                    middleText: 'Вы уверены, что хотите удалить этот доход?',
                    textConfirm: 'Да',
                    textCancel: 'Нет',
                    confirmTextColor: Colors.white,
                    onConfirm: () {
                      controller.deleteIncome(income.id);
                      Get.back();
                    },
                  );
                },
              ),
            );
          },
        );
      }),
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
}