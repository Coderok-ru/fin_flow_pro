import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/budget_controller.dart';
import '../../controllers/finance_controller.dart';
import '../../models/budget_model.dart';
import '../../widgets/budget_card.dart';
import '../../constants/theme_constants.dart';

/// Экран для отслеживания бюджетов
class BudgetTrackingView extends GetView<FinanceController> {
  const BudgetTrackingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final budgetController = Get.find<BudgetController>();
    
    // Состояние фильтров
    final RxString periodFilter = 'all'.obs;
    final RxString statusFilter = 'all'.obs;
    
    // Форматирование дат
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    // Фильтрация бюджетов
    List<BudgetModel> getFilteredBudgets() {
      List<BudgetModel> budgets = List.from(budgetController.budgets);
      
      // Фильтрация по периоду
      if (periodFilter.value != 'all') {
        final BudgetPeriod period;
        switch (periodFilter.value) {
          case 'month':
            period = BudgetPeriod.month;
            break;
          case 'quarter':
            period = BudgetPeriod.quarter;
            break;
          case 'year':
            period = BudgetPeriod.year;
            break;
          default:
            period = BudgetPeriod.month;
        }
        
        budgets = budgets.where((budget) => budget.period == period).toList();
      }
      
      // Фильтрация по статусу
      if (statusFilter.value != 'all') {
        final now = DateTime.now();
        
        switch (statusFilter.value) {
          case 'active':
            budgets = budgets.where((budget) => 
              budget.startDate.isBefore(now) && budget.endDate.isAfter(now)
            ).toList();
            break;
          case 'upcoming':
            budgets = budgets.where((budget) => 
              budget.startDate.isAfter(now)
            ).toList();
            break;
          case 'completed':
            budgets = budgets.where((budget) => 
              budget.endDate.isBefore(now)
            ).toList();
            break;
        }
      }
      
      // Сортировка: сначала активные, затем предстоящие, затем завершенные
      budgets.sort((a, b) {
        final now = DateTime.now();
        final aIsActive = a.startDate.isBefore(now) && a.endDate.isAfter(now);
        final bIsActive = b.startDate.isBefore(now) && b.endDate.isAfter(now);
        
        if (aIsActive && !bIsActive) return -1;
        if (!aIsActive && bIsActive) return 1;
        
        final aIsUpcoming = a.startDate.isAfter(now);
        final bIsUpcoming = b.startDate.isAfter(now);
        
        if (aIsUpcoming && !bIsUpcoming) return -1;
        if (!aIsUpcoming && bIsUpcoming) return 1;
        
        // По умолчанию сортируем по дате начала (сначала новые)
        return b.startDate.compareTo(a.startDate);
      });
      
      return budgets;
    }
    
    // Расчет потраченной суммы для бюджета
    double getSpentAmount(BudgetModel budget) {
      if (controller.activeBudget?.id == budget.id) {
        // Для активного бюджета берем фактические расходы
        return controller.actualExpenses.values.fold(0.0, (sum, amount) => sum + amount);
      } else {
        // Для неактивных бюджетов могли бы загружать исторические данные
        // Пока используем случайные значения для демонстрации
        return budget.allocatedAmount * 0.7; // 70% от распределенной суммы
      }
    }
    
    // Определение статуса бюджета
    String getBudgetStatus(BudgetModel budget) {
      final now = DateTime.now();
      if (budget.startDate.isBefore(now) && budget.endDate.isAfter(now)) {
        return 'Активный';
      } else if (budget.startDate.isAfter(now)) {
        return 'Предстоящий';
      } else {
        return 'Завершенный';
      }
    }
    
    // Цвет статуса бюджета
    Color getBudgetStatusColor(String status) {
      switch (status) {
        case 'Активный':
          return Colors.green;
        case 'Предстоящий':
          return Colors.blue;
        case 'Завершенный':
          return Colors.grey;
        default:
          return Colors.grey;
      }
    }
    
    return Scaffold(
      body: Column(
        children: [
          // Панель фильтров
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Фильтр по периоду
                Row(
                  children: [
                    const Text(
                      'Период:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8.0),
                    Obx(() => DropdownButton<String>(
                      value: periodFilter.value,
                      onChanged: (value) {
                        if (value != null) {
                          periodFilter.value = value;
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('Все'),
                        ),
                        DropdownMenuItem(
                          value: 'month',
                          child: Text('Месяц'),
                        ),
                        DropdownMenuItem(
                          value: 'quarter',
                          child: Text('Квартал'),
                        ),
                        DropdownMenuItem(
                          value: 'year',
                          child: Text('Год'),
                        ),
                      ],
                    )),
                  ],
                ),
                
                const SizedBox(height: 8.0),
                
                // Фильтр по статусу
                Row(
                  children: [
                    const Text(
                      'Статус:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8.0),
                    Obx(() => DropdownButton<String>(
                      value: statusFilter.value,
                      onChanged: (value) {
                        if (value != null) {
                          statusFilter.value = value;
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('Все'),
                        ),
                        DropdownMenuItem(
                          value: 'active',
                          child: Text('Активные'),
                        ),
                        DropdownMenuItem(
                          value: 'upcoming',
                          child: Text('Предстоящие'),
                        ),
                        DropdownMenuItem(
                          value: 'completed',
                          child: Text('Завершенные'),
                        ),
                      ],
                    )),
                  ],
                ),
              ],
            ),
          ),
          
          // Список бюджетов
          Expanded(
            child: Obx(() {
              final budgets = getFilteredBudgets();
              
              if (budgets.isEmpty) {
                return const Center(
                  child: Text(
                    'Нет бюджетов, соответствующих фильтрам',
                    textAlign: TextAlign.center,
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: budgets.length,
                itemBuilder: (context, index) {
                  final budget = budgets[index];
                  final spentAmount = getSpentAmount(budget);
                  final status = getBudgetStatus(budget);
                  final statusColor = getBudgetStatusColor(status);
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Stack(
                      children: [
                        BudgetCard(
                          budget: budget,
                          spentAmount: spentAmount,
                          onTap: () => Get.toNamed('/finance/budget/${budget.id}'),
                        ),
                        
                        // Статус бюджета
                        Positioned(
                          top: 8,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: statusColor),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}