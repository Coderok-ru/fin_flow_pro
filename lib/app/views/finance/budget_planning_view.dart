import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/budget_controller.dart';
import '../../controllers/finance_controller.dart';
import '../../models/budget_model.dart';
import '../../widgets/budget_category_tile.dart';
import '../../constants/theme_constants.dart';

/// Экран для создания и редактирования бюджета
class BudgetPlanningView extends GetView<FinanceController> {
  const BudgetPlanningView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final budgetController = Get.find<BudgetController>();
    
    // Формы для данных бюджета
    final TextEditingController nameController = TextEditingController();
    final TextEditingController amountController = TextEditingController();
    
    // Период бюджета по умолчанию
    final Rx<BudgetPeriod> selectedPeriod = BudgetPeriod.month.obs;
    
    // Даты начала и окончания бюджета
    final Rx<DateTime> startDate = DateTime.now().obs;
    final Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 30)).obs;
    
    // Распределение бюджета по категориям
    final RxMap<String, double> categoryBudgets = <String, double>{}.obs;
    
    // Общая сумма бюджета
    final RxDouble totalAmount = 0.0.obs;
    
    // Форматтер для дат
    final dateFormat = DateFormat('dd.MM.yyyy');
    
    // Инициализация распределения категорий
    void initCategoryBudgets() {
      categoryBudgets.clear();
      for (final category in budgetController.categories) {
        categoryBudgets[category.id] = 0;
      }
    }
    
    // Обновление дат в зависимости от выбранного периода
    void updateDates() {
      final now = DateTime.now();
      startDate.value = DateTime(now.year, now.month, 1);
      
      switch (selectedPeriod.value) {
        case BudgetPeriod.month:
          endDate.value = DateTime(now.year, now.month + 1, 0);
          break;
        case BudgetPeriod.quarter:
          final currentQuarter = (now.month - 1) ~/ 3;
          final startMonth = currentQuarter * 3 + 1;
          startDate.value = DateTime(now.year, startMonth, 1);
          endDate.value = DateTime(now.year, startMonth + 3, 0);
          break;
        case BudgetPeriod.year:
          startDate.value = DateTime(now.year, 1, 1);
          endDate.value = DateTime(now.year, 12, 31);
          break;
      }
    }
    
    // Расчет оставшейся нераспределенной суммы
    double getRemainingAmount() {
      final allocated = categoryBudgets.values.fold(0.0, (sum, amount) => sum + amount);
      return totalAmount.value - allocated;
    }
    
    // Обработчик изменения суммы для категории
    void handleCategoryAmountChanged(String categoryId, double amount) {
      categoryBudgets[categoryId] = amount;
    }
    
    // Создание нового бюджета
    void createBudget() {
      // Проверка на заполнение всех полей
      if (nameController.text.isEmpty) {
        Get.snackbar(
          'Ошибка',
          'Пожалуйста, введите название бюджета',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      if (totalAmount.value <= 0) {
        Get.snackbar(
          'Ошибка',
          'Пожалуйста, введите корректную сумму бюджета',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      // Создание модели бюджета
      final newBudget = BudgetModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text,
        totalAmount: totalAmount.value,
        startDate: startDate.value,
        endDate: endDate.value,
        categoryBudgets: Map<String, double>.from(categoryBudgets),
        period: selectedPeriod.value,
      );
      
      // Сохранение бюджета
      budgetController.createBudget(newBudget).then((_) {
        Get.back(); // Возврат на предыдущий экран
        Get.snackbar(
          'Успех',
          'Бюджет успешно создан',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      });
    }
    
    // Распределение бюджета поровну
    void distributeEquallyAcrossCategories() {
      if (totalAmount.value <= 0 || budgetController.categories.isEmpty) return;
      
      final amountPerCategory = totalAmount.value / budgetController.categories.length;
      
      for (final category in budgetController.categories) {
        categoryBudgets[category.id] = amountPerCategory;
      }
    }
    
    // Сброс распределения
    void resetDistribution() {
      for (final categoryId in categoryBudgets.keys) {
        categoryBudgets[categoryId] = 0;
      }
    }
    
    // Инициализация
    initCategoryBudgets();
    updateDates();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создание бюджета'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: createBudget,
            tooltip: 'Сохранить бюджет',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Основная информация о бюджете
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Основная информация',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Название бюджета
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Название бюджета',
                        hintText: 'Например: Бюджет на январь 2025',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Общая сумма бюджета
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(
                        labelText: 'Общая сумма',
                        hintText: 'Введите общую сумму бюджета',
                        border: OutlineInputBorder(),
                        suffixText: '₽',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          try {
                            totalAmount.value = double.parse(value);
                          } catch (e) {
                            // Игнорируем ошибку парсинга
                          }
                        } else {
                          totalAmount.value = 0;
                        }
                      },
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Выбор периода бюджета
                    Text(
                      'Период бюджета',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8.0),
                    
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: RadioListTile<BudgetPeriod>(
                            title: const Text('Месяц'),
                            value: BudgetPeriod.month,
                            groupValue: selectedPeriod.value,
                            onChanged: (value) {
                              if (value != null) {
                                selectedPeriod.value = value;
                                updateDates();
                              }
                            },
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<BudgetPeriod>(
                            title: const Text('Квартал'),
                            value: BudgetPeriod.quarter,
                            groupValue: selectedPeriod.value,
                            onChanged: (value) {
                              if (value != null) {
                                selectedPeriod.value = value;
                                updateDates();
                              }
                            },
                            dense: true,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<BudgetPeriod>(
                            title: const Text('Год'),
                            value: BudgetPeriod.year,
                            groupValue: selectedPeriod.value,
                            onChanged: (value) {
                              if (value != null) {
                                selectedPeriod.value = value;
                                updateDates();
                              }
                            },
                            dense: true,
                          ),
                        ),
                      ],
                    )),
                    
                    const SizedBox(height: 16.0),
                    
                    // Период действия бюджета
                    Obx(() => Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Дата начала'),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: startDate.value,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    startDate.value = picked;
                                  }
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: Text(dateFormat.format(startDate.value)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Дата окончания'),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: endDate.value,
                                    firstDate: startDate.value,
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    endDate.value = picked;
                                  }
                                },
                                icon: const Icon(Icons.calendar_today),
                                label: Text(dateFormat.format(endDate.value)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            ),
            
            // Распределение бюджета по категориям
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Распределение бюджета',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'distribute_equally') {
                              distributeEquallyAcrossCategories();
                            } else if (value == 'reset') {
                              resetDistribution();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem<String>(
                              value: 'distribute_equally',
                              child: Text('Распределить поровну'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'reset',
                              child: Text('Сбросить распределение'),
                            ),
                          ],
                          icon: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    
                    // Отображение оставшейся суммы
                    Obx(() {
                      final remaining = getRemainingAmount();
                      final isOverBudget = remaining < 0;
                      
                      return Container(
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color: isOverBudget
                              ? Colors.red.shade50
                              : remaining > 0
                                  ? Colors.green.shade50
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isOverBudget
                                  ? 'Превышение бюджета:'
                                  : remaining > 0
                                      ? 'Доступно для распределения:'
                                      : 'Бюджет распределен полностью',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isOverBudget
                                    ? Colors.red
                                    : remaining > 0
                                        ? Colors.green
                                        : Colors.grey[700],
                              ),
                            ),
                            if (remaining != 0)
                              Text(
                                '${remaining.abs().toStringAsFixed(0)} ₽',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isOverBudget
                                      ? Colors.red
                                      : remaining > 0
                                          ? Colors.green
                                          : Colors.grey[700],
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 16.0),
                    
                    // Список категорий для распределения бюджета
                    Obx(() => Column(
                      children: budgetController.categories.map((category) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: BudgetCategoryTile(
                            category: category,
                            amount: categoryBudgets[category.id] ?? 0,
                            onAmountChanged: (amount) => handleCategoryAmountChanged(category.id, amount),
                            maxAvailableAmount: double.infinity, // Можно ограничить максимальной суммой бюджета
                          ),
                        );
                      }).toList(),
                    )),
                    
                    if (budgetController.categories.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Нет доступных категорий.\nДобавьте категории в разделе управления категориями.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}