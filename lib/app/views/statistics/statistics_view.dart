import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/statistics_controller.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StatisticsView extends GetView<StatisticsController> {
  const StatisticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика'),
        centerTitle: true,
      ),
      body: GetBuilder<StatisticsController>(
        builder: (_) {
          final expensesByCategory = controller.getExpensesByCategory();
          final totalIncome = controller.getTotalIncome();
          final totalExpense = controller.getTotalExpense();
          final balance = totalIncome - totalExpense;
        
        return Column(
          children: [
            // Переключатель периода
            Container(
              padding: const EdgeInsets.all(16),
              color: ThemeConstants.primaryColor.withOpacity(0.1),
              child: Column(
                children: [
                  // Навигация по периодам
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: controller.previousPeriod,
                      ),
                      Text(
                        controller.getPeriodTitle(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: controller.nextPeriod,
                      ),
                    ],
                  ),
                  
                  // Выбор типа периода
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: controller.periods.map((period) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ChoiceChip(
                            label: Text(period),
                            selected: controller.selectedPeriod.value == period,
                            onSelected: (selected) {
                              if (selected) {
                                controller.changePeriod(period);
                              }
                            },
                            selectedColor: ThemeConstants.primaryColor,
                            labelStyle: TextStyle(
                              color: controller.selectedPeriod.value == period
                                  ? Colors.white
                                  : Colors.black,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            // Финансовая сводка
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 2,
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
                          _buildFinancialInfoCard(
                            'Доходы',
                            totalIncome,
                            Colors.green,
                            FontAwesomeIcons.arrowTrendUp,
                          ),
                          _buildFinancialInfoCard(
                            'Расходы',
                            totalExpense,
                            Colors.red,
                            FontAwesomeIcons.arrowTrendDown,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildFinancialInfoCard(
                        'Баланс',
                        balance,
                        balance >= 0 ? Colors.blue : Colors.redAccent,
                        FontAwesomeIcons.wallet,
                        isFullWidth: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // График расходов
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
                child: Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: expensesByCategory.isEmpty
                        ? const Center(
                            child: Text(
                              'Нет данных для отображения',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Структура расходов',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: PieChart(
                                  PieChartData(
                                    sections: _buildPieChartSections(expensesByCategory),
                                    centerSpaceRadius: 40,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                              // Легенда графика
                              SizedBox(
                                height: 100,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: expensesByCategory.entries.map((entry) {
                                    final color = ThemeConstants.categoryColors[entry.key] ?? 
                                        ThemeConstants.primaryColor;
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(right: 16),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 16,
                                            height: 16,
                                            color: color,
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                entry.key,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '₽${entry.value.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: color,
                                                ),
                                              ),
                                              Text(
                                                '${((entry.value / totalExpense) * 100).toStringAsFixed(1)}%',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
      
      // Добавляем кнопку назад на главный экран
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.back(),
        backgroundColor: ThemeConstants.primaryColor,
        child: const Icon(Icons.home),
      ),
    );
  }
  
  Widget _buildFinancialInfoCard(
    String title, 
    double value, 
    Color color, 
    IconData icon, 
    {bool isFullWidth = false}
  ) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
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
          const Spacer(),
          Text(
            '₽${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
        ],
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
          title: '',  // Не выводим текст на самом графике
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
}