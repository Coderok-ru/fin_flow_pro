import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/expense_controller.dart';
import 'package:fin_flow_pro/app/controllers/home_controller.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';
import 'package:fin_flow_pro/app/routes/app_routes.dart';
import 'package:fin_flow_pro/app/constants/app_constants.dart';
import 'package:fin_flow_pro/app/widgets/custom_bottom_nav.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExpenseListView extends GetView<ExpenseController> {
  const ExpenseListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Группировка расходов по категориям
    final RxMap<String, List<dynamic>> groupedExpenses = <String, List<dynamic>>{}.obs;
    final homeController = Get.find<HomeController>();
    
    void updateGroupedExpenses() {
      final Map<String, List<dynamic>> newGrouped = {};
      
      // Группировка расходов по категориям
      for (final category in AppConstants.expenseCategories) {
        final expenses = controller.getExpensesByCategory(category);
        if (expenses.isNotEmpty) {
          newGrouped[category] = expenses;
        }
      }
      
      groupedExpenses.value = newGrouped;
    }
    
    // Обновляем группировку при каждом изменении списка расходов
    ever(controller.expenses, (_) => updateGroupedExpenses());
    
    // Инициализируем группировку
    updateGroupedExpenses();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расходы'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.expenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FontAwesomeIcons.moneyBillTransfer,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'У вас пока нет расходов',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.toNamed(AppRoutes.EXPENSE_FORM),
                  child: const Text('Добавить расход'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: groupedExpenses.length,
          itemBuilder: (context, index) {
            final category = groupedExpenses.keys.elementAt(index);
            final expenses = groupedExpenses[category]!;
            final categoryColor = ThemeConstants.categoryColors[category] ?? ThemeConstants.primaryColor;
            
            // Рассчитываем общую сумму расходов по категории
            final totalAmount = expenses.fold<double>(
              0, (sum, expense) => sum + expense.amount);
            
            return ExpansionTile(
              title: Text(
                category,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(category),
                  color: categoryColor,
                ),
              ),
              trailing: Text(
                '₽${totalAmount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              children: expenses.map<Widget>((expense) {
                final dateFormat = DateFormat(AppConstants.dateFormat);
                
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    title: Text(
                      expense.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Дата: ${dateFormat.format(expense.date)}'),
                        Text('Периодичность: ${expense.frequency}'),
                        if (expense.endDate != null)
                          Text('До: ${dateFormat.format(expense.endDate!)}'),
                        if (expense.bankName != null && expense.bankName!.isNotEmpty)
                          Text('Банк: ${expense.bankName}'),
                      ],
                    ),
                    trailing: Text(
                      '₽${expense.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    onTap: () {
                      // Редактирование расхода
                      Get.toNamed(
                        AppRoutes.EXPENSE_FORM,
                        arguments: expense,
                      );
                    },
                    onLongPress: () {
                      // Удаление расхода
                      Get.defaultDialog(
                        title: 'Удаление',
                        middleText: 'Вы уверены, что хотите удалить этот расход?',
                        textConfirm: 'Да',
                        textCancel: 'Нет',
                        confirmTextColor: Colors.white,
                        onConfirm: () {
                          controller.deleteExpense(expense.id);
                          Get.back();
                        },
                      );
                    },
                  ),
                );
              }).toList(),
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
  
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Кредиты':
        return FontAwesomeIcons.creditCard;
      case 'Транспорт':
        return FontAwesomeIcons.car;
      case 'Семья':
        return FontAwesomeIcons.peopleGroup;
      case 'Жилье':
        return FontAwesomeIcons.house;
      case 'Дом':
        return FontAwesomeIcons.couch;
      case 'Кредитные карты':
        return FontAwesomeIcons.ccVisa;
      case 'Подписки':
        return FontAwesomeIcons.play;
      case 'Медицина':
        return FontAwesomeIcons.hospitalUser;
      case 'Образование':
        return FontAwesomeIcons.graduationCap;
      case 'Дети':
        return FontAwesomeIcons.child;
      default:
        return FontAwesomeIcons.wallet;
    }
  }
}