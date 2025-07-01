import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/calendar_controller.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';
import 'package:fin_flow_pro/app/models/expense_model.dart';
import 'package:fin_flow_pro/app/models/income_model.dart';
import 'package:fin_flow_pro/app/routes/app_routes.dart';
import 'package:fin_flow_pro/app/controllers/home_controller.dart';
import 'package:fin_flow_pro/app/widgets/custom_bottom_nav.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dayWidth = (screenWidth - 32) / 7; // 32 - это общий padding
    final homeController = Get.find<HomeController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Календарь платежей'),
        centerTitle: true,
      ),
      body: GetBuilder<CalendarController>(
        builder: (_) {
          return Column(
            children: [
              // Заголовок с месяцем и кнопками навигации
              Container(
                padding: const EdgeInsets.all(16),
                color: ThemeConstants.primaryColor.withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: controller.previousMonth,
                    ),
                    Text(
                      controller.getMonthTitle(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: controller.nextMonth,
                    ),
                  ],
                ),
              ),

              // Дни недели
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: _buildWeekdayHeaders(),
                ),
              ),

              // Календарная сетка
              Expanded(
                child: Obx(() {
                  final daysInMonth = controller.getDaysInMonth();
                  final firstDayOfMonth = daysInMonth.first;
                  final firstWeekday = firstDayOfMonth.weekday;
                  
                  // Создаем список дней для отображения, добавляя пустые места для дней предыдущего месяца
                  final List<DateTime?> calendarDays = List.generate(firstWeekday - 1, (_) => null);
                  for (var day in daysInMonth) {
                    calendarDays.add(day);
                  }
                  
                  return GridView.builder(
                    padding: const EdgeInsets.all(8),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: dayWidth / (dayWidth * 1.4), // Соотношение сторон для ячеек
                    ),
                    itemCount: calendarDays.length,
                    itemBuilder: (context, index) {
                      final day = calendarDays[index];
                      if (day == null) {
                        return Container(); // Пустая ячейка для дней предыдущего месяца
                      }
                      
                      final isToday = _isToday(day);
                      final payments = controller.getPaymentsForDay(day);
                      final totalForDay = controller.getTotalForDay(day);
                      
                      return InkWell(
                        onTap: () {
                          if (payments.isNotEmpty) {
                            _showPaymentsDialog(context, day, payments);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isToday ? ThemeConstants.primaryColor.withOpacity(0.2) : null,
                            border: Border.all(
                              color: isToday ? ThemeConstants.primaryColor : Colors.grey[300]!,
                              width: isToday ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // День месяца
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: isToday ? ThemeConstants.primaryColor : Colors.grey[300],
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(7),
                                    topRight: Radius.circular(7),
                                  ),
                                ),
                                child: Text(
                                  '${day.day}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                    color: isToday ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                              
                              // Индикаторы платежей
                              if (payments.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_hasIncomes(payments))
                                      Icon(
                                        FontAwesomeIcons.arrowTrendUp,
                                        color: Colors.green,
                                        size: 10,
                                      ),
                                    if (_hasIncomes(payments) && _hasExpenses(payments))
                                      const SizedBox(width: 4),
                                    if (_hasExpenses(payments))
                                      Icon(
                                        FontAwesomeIcons.arrowTrendDown,
                                        color: Colors.red,
                                        size: 10,
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '₽${totalForDay.abs().toStringAsFixed(0)}',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: totalForDay >= 0 ? Colors.green : Colors.red,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          );
        },
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
        currentIndex: homeController.currentNavIndex.value,
        onNavIndexChanged: homeController.changeNavIndex,
      )),
    );
  }

  // Построение заголовков дней недели
  List<Widget> _buildWeekdayHeaders() {
    final weekdays = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return weekdays.map((day) {
      final isWeekend = day == 'Сб' || day == 'Вс';
      return SizedBox(
        width: 40,
        child: Text(
          day,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isWeekend ? Colors.red : Colors.black87,
          ),
        ),
      );
    }).toList();
  }

  // Проверка на сегодняшний день
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Проверка наличия доходов в списке платежей
  bool _hasIncomes(List<dynamic> payments) {
    return payments.any((payment) => payment is IncomeModel);
  }

  // Проверка наличия расходов в списке платежей
  bool _hasExpenses(List<dynamic> payments) {
    return payments.any((payment) => payment is ExpenseModel);
  }

  // Отображение диалога с платежами для выбранного дня
  void _showPaymentsDialog(BuildContext context, DateTime day, List<dynamic> payments) {
    final dateFormatter = DateFormat('dd MMMM yyyy', 'ru_RU');
    final formattedDate = dateFormatter.format(day);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Платежи на $formattedDate'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: payments.length,
              itemBuilder: (context, index) {
                final payment = payments[index];
                if (payment is ExpenseModel) {
                  return _buildExpenseListItem(payment);
                } else if (payment is IncomeModel) {
                  return _buildIncomeListItem(payment);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Закрыть'),
            ),
          ],
        );
      },
    );
  }

  // Построение элемента списка для расхода
  Widget _buildExpenseListItem(ExpenseModel expense) {
    final color = ThemeConstants.categoryColors[expense.category] ?? ThemeConstants.primaryColor;
    
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          FontAwesomeIcons.arrowTrendDown,
          color: color,
          size: 16,
        ),
      ),
      title: Text(
        expense.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(expense.category),
      trailing: Text(
        '-₽${expense.amount.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Построение элемента списка для дохода
  Widget _buildIncomeListItem(IncomeModel income) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          FontAwesomeIcons.arrowTrendUp,
          color: Colors.green,
          size: 16,
        ),
      ),
      title: Text(
        income.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text('Доход'),
      trailing: Text(
        '+₽${income.amount.toStringAsFixed(2)}',
        style: const TextStyle(
          color: Colors.green,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}