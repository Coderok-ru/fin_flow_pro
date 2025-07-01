import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/budget_model.dart';
import '../models/budget_category_model.dart';

/// Контроллер для работы с бюджетами
class BudgetController extends GetxController {
  /// Список всех бюджетов
  final _budgets = <BudgetModel>[].obs;
  
  /// Текущий активный бюджет
  final Rx<BudgetModel?> _activeBudget = Rx<BudgetModel?>(null);
  
  /// Список всех категорий бюджета
  final _categories = <BudgetCategoryModel>[].obs;

  /// Геттер для списка бюджетов
  List<BudgetModel> get budgets => _budgets;
  
  /// Геттер для активного бюджета
  BudgetModel? get activeBudget => _activeBudget.value;
  
  /// Геттер для списка категорий
  List<BudgetCategoryModel> get categories => _categories;

  @override
  void onInit() {
    super.onInit();
    _loadCategories();
    _loadBudgets();
    _setActiveBudget();
  }

  /// Загружает список категорий
  void _loadCategories() {
    // TODO: Реализовать загрузку категорий из базы данных или API
    // Пока используем тестовые данные
    _categories.clear();
    
    // Добавляем тестовые категории
    _categories.addAll([
      BudgetCategoryModel(
        id: '1',
        name: 'Продукты',
        color: Colors.green,
        icon: Icons.shopping_cart,
        description: 'Расходы на продукты питания',
      ),
      BudgetCategoryModel(
        id: '2',
        name: 'Транспорт',
        color: Colors.blue,
        icon: Icons.directions_car,
        description: 'Расходы на транспорт и топливо',
      ),
      BudgetCategoryModel(
        id: '3',
        name: 'Развлечения',
        color: Colors.purple,
        icon: Icons.movie,
        description: 'Расходы на развлечения и отдых',
      ),
      BudgetCategoryModel(
        id: '4',
        name: 'Коммунальные платежи',
        color: Colors.orange,
        icon: Icons.home,
        description: 'Расходы на коммунальные услуги',
      ),
      BudgetCategoryModel(
        id: '5',
        name: 'Здоровье',
        color: Colors.red,
        icon: Icons.healing,
        description: 'Расходы на медицину и здоровье',
      ),
    ]);
  }

  /// Загружает список бюджетов
  void _loadBudgets() {
    // TODO: Реализовать загрузку бюджетов из базы данных или API
    // Пока используем тестовые данные
    _budgets.clear();
    
    // Текущая дата для создания периодов бюджета
    final now = DateTime.now();
    
    // Создаем тестовый месячный бюджет
    final monthlyBudget = BudgetModel(
      id: '1',
      name: 'Основной бюджет',
      totalAmount: 50000.0,
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(now.year, now.month + 1, 0),
      period: BudgetPeriod.month,
      categoryBudgets: {
        '1': 15000.0, // Продукты
        '2': 5000.0,  // Транспорт
        '3': 8000.0,  // Развлечения
        '4': 12000.0, // Коммунальные платежи
        '5': 10000.0, // Здоровье
      },
    );
    
    // Добавляем бюджет в список
    _budgets.add(monthlyBudget);
  }

  /// Устанавливает активный бюджет
  void _setActiveBudget() {
    if (_budgets.isNotEmpty) {
      // Находим текущий бюджет (на текущую дату)
      final now = DateTime.now();
      _activeBudget.value = _budgets.firstWhereOrNull(
        (budget) => budget.startDate.isBefore(now) && budget.endDate.isAfter(now),
      );
      
      // Если не нашли активный бюджет, используем последний созданный
      if (_activeBudget.value == null && _budgets.isNotEmpty) {
        _activeBudget.value = _budgets.last;
      }
    }
  }

  /// Создает новый бюджет
  Future<void> createBudget(BudgetModel budget) async {
    // TODO: Реализовать сохранение бюджета в базу данных или API
    _budgets.add(budget);
    _setActiveBudget();
    update();
  }

  /// Обновляет существующий бюджет
  Future<void> updateBudget(BudgetModel budget) async {
    // TODO: Реализовать обновление бюджета в базе данных или API
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget;
      
      // Если обновляемый бюджет является активным, обновляем и его
      if (_activeBudget.value?.id == budget.id) {
        _activeBudget.value = budget;
      }
      
      update();
    }
  }

  /// Удаляет бюджет
  Future<void> deleteBudget(String budgetId) async {
    // TODO: Реализовать удаление бюджета из базы данных или API
    _budgets.removeWhere((budget) => budget.id == budgetId);
    
    // Если удаляемый бюджет является активным, переустанавливаем активный бюджет
    if (_activeBudget.value?.id == budgetId) {
      _setActiveBudget();
    }
    
    update();
  }

  /// Устанавливает активный бюджет вручную
  void setActiveBudget(String budgetId) {
    final budget = _budgets.firstWhereOrNull((b) => b.id == budgetId);
    if (budget != null) {
      _activeBudget.value = budget;
      update();
    }
  }

  /// Фильтрует бюджеты по периоду
  List<BudgetModel> filterBudgetsByPeriod(BudgetPeriod period) {
    return _budgets.where((budget) => budget.period == period).toList();
  }

  /// Рассчитывает доступную сумму для планирования
  double getAvailableAmount() {
    if (_activeBudget.value == null) return 0.0;
    return _activeBudget.value!.unallocatedAmount;
  }

  /// Предлагает распределение бюджета на основе статистики расходов
  Map<String, double> suggestBudgetDistribution(double totalAmount) {
    // TODO: Реализовать алгоритм распределения бюджета на основе статистики
    
    // Пока возвращаем простое равномерное распределение по всем категориям
    final result = <String, double>{};
    if (_categories.isEmpty) return result;
    
    final amountPerCategory = totalAmount / _categories.length;
    for (final category in _categories) {
      result[category.id] = amountPerCategory;
    }
    
    return result;
  }

  /// Получает бюджет по ID
  BudgetModel? getBudgetById(String budgetId) {
    return _budgets.firstWhereOrNull((budget) => budget.id == budgetId);
  }

  /// Создает новую категорию бюджета
  Future<void> createCategory(BudgetCategoryModel category) async {
    // TODO: Реализовать сохранение категории в базу данных или API
    _categories.add(category);
    update();
  }

  /// Обновляет существующую категорию бюджета
  Future<void> updateCategory(BudgetCategoryModel category) async {
    // TODO: Реализовать обновление категории в базе данных или API
    final index = _categories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _categories[index] = category;
      update();
    }
  }

  /// Удаляет категорию бюджета
  Future<void> deleteCategory(String categoryId) async {
    // TODO: Реализовать удаление категории из базы данных или API
    // Также нужно обновить все бюджеты, удалив данную категорию из них
    _categories.removeWhere((category) => category.id == categoryId);
    
    // Обновляем все бюджеты, удаляя удаленную категорию
    for (var i = 0; i < _budgets.length; i++) {
      final budget = _budgets[i];
      if (budget.categoryBudgets.containsKey(categoryId)) {
        final updatedCategoryBudgets = Map<String, double>.from(budget.categoryBudgets);
        updatedCategoryBudgets.remove(categoryId);
        
        _budgets[i] = budget.copyWith(categoryBudgets: updatedCategoryBudgets);
        
        // Если это активный бюджет, обновляем и его
        if (_activeBudget.value?.id == budget.id) {
          _activeBudget.value = _budgets[i];
        }
      }
    }
    
    update();
  }
}