import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/finance_controller.dart';
import '../../controllers/budget_controller.dart';
import '../../widgets/budget_progress.dart';

/// Основной экран финансов с вкладками для работы с бюджетами
class FinanceView extends GetView<FinanceController> {
  const FinanceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Финансы'),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.pie_chart),
                text: 'Обзор',
              ),
              Tab(
                icon: Icon(Icons.trending_up),
                text: 'Планирование',
              ),
              Tab(
                icon: Icon(Icons.list),
                text: 'Бюджеты',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Вкладка Обзор - показывает текущий активный бюджет
            _buildOverviewTab(context),

            // Вкладка Планирование - интерфейс для создания нового бюджета
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Создание нового бюджета',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () => Get.toNamed('/finance/budget/planning'),
                      child: const Text('Создать новый бюджет'),
                    ),
                  ],
                ),
              ),
            ),

            // Вкладка Бюджеты - список всех существующих бюджетов
            _buildBudgetListTab(context),
          ],
        ),
        floatingActionButton: Obx(() {
          // Показываем FAB только на вкладке с бюджетами
          if (DefaultTabController.of(context).index == 2) {
            return FloatingActionButton(
              onPressed: () => Get.toNamed('/finance/budget/planning'),
              child: const Icon(Icons.add),
              tooltip: 'Добавить новый бюджет',
            );
          }
          // Показываем FAB для управления категориями на вкладке Обзор
          if (DefaultTabController.of(context).index == 0) {
            return FloatingActionButton(
              onPressed: () => Get.toNamed('/finance/categories'),
              child: const Icon(Icons.category),
              tooltip: 'Управление категориями',
            );
          }
          return const SizedBox.shrink();
        }),
      ),
    );
  }

  /// Строит содержимое вкладки "Обзор"
  Widget _buildOverviewTab(BuildContext context) {
    return Obx(() {
      final activeBudget = controller.activeBudget;
      
      if (activeBudget == null) {
        return const Center(
          child: Text(
            'Нет активного бюджета.\nСоздайте новый бюджет на вкладке "Планирование".',
            textAlign: TextAlign.center,
          ),
        );
      }

      // Получаем категории и строим список с прогрессом
      final categories = controller.categories;
      
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Общий прогресс бюджета
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Активный бюджет: ${activeBudget.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Период: ${_formatPeriod(activeBudget.period)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16.0),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: LinearProgressIndicator(
                        value: controller.getTotalBudgetCompletionPercentage() / 100,
                        minHeight: 10.0,
                        backgroundColor: Colors.grey[200],
                        color: _getProgressColor(controller.getTotalBudgetCompletionPercentage()),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Израсходовано: ${controller.getTotalBudgetCompletionPercentage().toStringAsFixed(1)}%',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Осталось: ${controller.getTotalRemainingBudget().toStringAsFixed(0)} ₽',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Заголовок для списка категорий
            Text(
              'Расходы по категориям',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),

            // Список категорий с прогрессом
            if (categories.isEmpty)
              const Center(
                child: Text('Нет доступных категорий'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryId = category.id;
                  final allocatedAmount = activeBudget.getBudgetForCategory(categoryId);
                  final spentAmount = controller.actualExpenses[categoryId] ?? 0.0;

                  // Пропускаем категории с нулевым бюджетом
                  if (allocatedAmount <= 0) return const SizedBox.shrink();

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: InkWell(
                      onTap: () {
                        // Здесь можно добавить действие при нажатии на категорию
                        // Например, переход к детальной информации
                      },
                      child: BudgetProgress(
                        category: category,
                        allocatedAmount: allocatedAmount,
                        spentAmount: spentAmount,
                      ),
                    ),
                  );
                },
              ),

            // Раздел для категорий с превышением бюджета
            const SizedBox(height: 24.0),
            _buildOverspentCategoriesSection(context),

            // Раздел для категорий с низким использованием бюджета
            const SizedBox(height: 16.0),
            _buildUnderspentCategoriesSection(context),
          ],
        ),
      );
    });
  }

  /// Строит вкладку со списком бюджетов
  Widget _buildBudgetListTab(BuildContext context) {
    return Obx(() {
      // Получаем BudgetController через Get
      final budgetController = Get.find<BudgetController>();
      final budgets = budgetController.budgets;
      
      if (budgets.isEmpty) {
        return const Center(
          child: Text(
            'Нет созданных бюджетов.\nСоздайте новый бюджет с помощью кнопки внизу.',
            textAlign: TextAlign.center,
          ),
        );
      }
      
      return ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: budgets.length,
        itemBuilder: (context, index) {
          final budget = budgets[index];
          final isActive = controller.activeBudget?.id == budget.id;
          
          // Расчет потраченной суммы для этого бюджета
          double spentAmount = 0;
          if (isActive) {
            spentAmount = controller.actualExpenses.values.fold(
              0, (sum, amount) => sum + amount
            );
          } else {
            // Для неактивных бюджетов можно было бы загружать данные из истории
            // Пока используем случайные значения для демонстрации
            spentAmount = budget.totalAmount * 0.7;
          }
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Card(
                    child: InkWell(
                      onTap: () => Get.toNamed('/finance/budget/${budget.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              budget.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Период: ${_formatPeriod(budget.period)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: (spentAmount / budget.totalAmount).clamp(0.0, 1.0),
                              backgroundColor: Colors.grey[200],
                              color: _getProgressColor((spentAmount / budget.totalAmount) * 100),
                              minHeight: 8,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Сумма: ${budget.totalAmount.toStringAsFixed(0)} ₽',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Text(
                                  'Потрачено: ${spentAmount.toStringAsFixed(0)} ₽',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: _getProgressColor((spentAmount / budget.totalAmount) * 100),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Метка для активного бюджета
                if (isActive)
                  Positioned(
                    top: 0,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Активен',
                        style: TextStyle(
                          color: Colors.white,
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
    });
  }

  /// Строит раздел для категорий с превышением бюджета
  Widget _buildOverspentCategoriesSection(BuildContext context) {
    final overspentCategories = controller.getOverspentCategories();
    
    if (overspentCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Категории с превышением бюджета',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: overspentCategories.length,
          itemBuilder: (context, index) {
            final categoryId = overspentCategories[index];
            final category = controller.categories.firstWhere(
              (c) => c.id == categoryId,
              orElse: () => throw Exception('Категория не найдена'),
            );
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.red[100],
                child: Icon(category.icon, color: Colors.red),
              ),
              title: Text(category.name),
              subtitle: Text(
                'Превышение: ${(controller.getBudgetCompletionPercentage(categoryId) - 100).toStringAsFixed(1)}%',
              ),
              trailing: const Icon(Icons.warning, color: Colors.red),
              dense: true,
            );
          },
        ),
      ],
    );
  }

  /// Строит раздел для категорий с низким использованием бюджета
  Widget _buildUnderspentCategoriesSection(BuildContext context) {
    final underspentCategories = controller.getUnderspentCategories();
    
    if (underspentCategories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Категории с низким использованием бюджета',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 8.0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: underspentCategories.length,
          itemBuilder: (context, index) {
            final categoryId = underspentCategories[index];
            final category = controller.categories.firstWhere(
              (c) => c.id == categoryId,
              orElse: () => throw Exception('Категория не найдена'),
            );
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Icon(category.icon, color: Colors.green),
              ),
              title: Text(category.name),
              subtitle: Text(
                'Использовано: ${controller.getBudgetCompletionPercentage(categoryId).toStringAsFixed(1)}%',
              ),
              dense: true,
            );
          },
        ),
      ],
    );
  }

  /// Форматирует период бюджета для отображения
  String _formatPeriod(dynamic period) {
    if (period == null) return 'Не указан';
    
    switch (period.toString()) {
      case 'BudgetPeriod.month':
        return 'Месяц';
      case 'BudgetPeriod.quarter':
        return 'Квартал';
      case 'BudgetPeriod.year':
        return 'Год';
      default:
        return 'Не указан';
    }
  }

  /// Возвращает цвет для прогресса в зависимости от процента выполнения
  Color _getProgressColor(double percent) {
    if (percent >= 100) {
      return Colors.red;
    } else if (percent >= 90) {
      return Colors.orange;
    } else if (percent >= 75) {
      return Colors.amber;
    } else {
      return Colors.green;
    }
  }
}