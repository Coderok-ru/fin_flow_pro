import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/home_controller.dart';
import 'package:fin_flow_pro/app/routes/app_routes.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';
import 'package:fin_flow_pro/app/widgets/category_card.dart';
import 'package:fin_flow_pro/app/widgets/custom_bottom_nav.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinFlow PRO'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Obx(() {
          final totalIncome = controller.getTotalIncome();
          final totalExpense = controller.getTotalExpense();
          final remaining = controller.getRemainingAmount();
          final categoryExpenses = controller.getCategoryExpenses();
          
          return RefreshIndicator(
            onRefresh: () async {
              // Обновление данных
              controller.update();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Финансовая сводка
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
                              'Финансовая сводка',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                GestureDetector(
                                  onTap: () => Get.toNamed(AppRoutes.INCOME_LIST),
                                  child: buildFinancialInfoCard(
                                    title: 'Доходы',
                                    value: totalIncome,
                                    color: Colors.green,
                                    icon: FontAwesomeIcons.arrowTrendUp,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Get.toNamed(AppRoutes.EXPENSE_LIST),
                                  child: buildFinancialInfoCard(
                                    title: 'Расходы',
                                    value: totalExpense,
                                    color: Colors.red,
                                    icon: FontAwesomeIcons.arrowTrendDown,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                buildFinancialInfoCard(
                                  title: 'Остаток',
                                  value: remaining,
                                  color: remaining >= 0 ? Colors.blue : Colors.redAccent,
                                  icon: FontAwesomeIcons.wallet,
                                ),
                                buildFinancialInfoCard(
                                  title: 'Расходы/Доходы',
                                  value: controller.getExpensePercentage(),
                                  color: Colors.amber,
                                  icon: FontAwesomeIcons.percent,
                                  isPercentage: true,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Дополнительная финансовая информация
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
                              'Дополнительная информация',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Средний дневной расход
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.calendar,
                                  color: Colors.orange,
                                ),
                              ),
                              title: const Text('Средний дневной расход'),
                              trailing: Text(
                                '₽${controller.getAverageDailyExpense().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            // Крупнейшая категория расходов
                            if (categoryExpenses.isNotEmpty)
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.chartPie,
                                    color: Colors.purple,
                                  ),
                                ),
                                title: const Text('Основная категория расходов'),
                                trailing: Text(
                                  controller.getLargestExpenseCategory(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            // Прогноз расходов на месяц
                            ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.teal.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  FontAwesomeIcons.chartLine,
                                  color: Colors.teal,
                                ),
                              ),
                              title: const Text('Прогноз расходов на месяц'),
                              trailing: Text(
                                '₽${controller.getMonthlyExpenseForecast().toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Карточка доступа к финансовому модулю
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => Get.toNamed(AppRoutes.FINANCE),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet,
                                  color: Colors.blue,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Управление бюджетом',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    const Text(
                                      'Планирование, анализ и отслеживание бюджета',
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
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
        currentIndex: controller.currentNavIndex.value,
        onNavIndexChanged: controller.changeNavIndex,
      )),
    );
  }

  Widget buildFinancialInfoCard({
    required String title,
    required double value,
    required Color color,
    required IconData icon,
    bool isPercentage = false
  }) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isPercentage 
                    ? '${value.toStringAsFixed(1)}%' 
                    : '₽${value.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
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