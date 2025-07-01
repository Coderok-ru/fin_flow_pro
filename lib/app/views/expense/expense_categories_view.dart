import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/expense_controller.dart';
import 'package:fin_flow_pro/app/controllers/home_controller.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';
import 'package:fin_flow_pro/app/routes/app_routes.dart';
import 'package:fin_flow_pro/app/widgets/custom_bottom_nav.dart';
import 'package:fin_flow_pro/app/widgets/category_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class ExpenseCategoriesView extends GetView<ExpenseController> {
  const ExpenseCategoriesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Расходы по категориям'),
        centerTitle: true,
      ),
      body: Obx(() {
        final categoryExpenses = controller.getCategoryExpensesForChart(
          DateTime(DateTime.now().year, DateTime.now().month, 1),
          DateTime(DateTime.now().year, DateTime.now().month + 1, 0),
        );
        
        if (categoryExpenses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  FontAwesomeIcons.chartPie,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'У вас пока нет расходов по категориям',
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
        
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Круговая диаграмма
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Распределение расходов',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: _buildPieChartSections(categoryExpenses),
                              centerSpaceRadius: 40,
                              sectionsSpace: 2,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Список категорий
                const Text(
                  'Категории',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ...categoryExpenses.entries.map((entry) {
                  final IconData icon = _getCategoryIcon(entry.key);
                  final color = ThemeConstants.categoryColors[entry.key] ?? Colors.grey;
                  
                  return CategoryCard(
                    title: entry.key,
                    amount: entry.value,
                    icon: icon,
                    onTap: () {
                      Get.toNamed(AppRoutes.EXPENSE_LIST);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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

  List<PieChartSectionData> _buildPieChartSections(Map<String, double> data) {
    final List<PieChartSectionData> sections = [];
    
    data.forEach((category, amount) {
      final color = ThemeConstants.categoryColors[category] ?? Colors.grey;
      
      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: category,
          radius: 60,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      );
    });
    
    return sections;
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