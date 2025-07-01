import 'package:get/get.dart';
import '../models/budget_model.dart';
import '../models/budget_category_model.dart';
import 'budget_controller.dart';

/// Типы финансовых разделов для навигации
enum FinanceSection {
  /// Обзор бюджета
  overview,
  
  /// Детальная информация о бюджете
  budget,
  
  /// Расходы
  expenses,
  
  /// Доходы
  income,
  
  /// Планирование
  planning,
}

/// Контроллер для экрана финансов
class FinanceController extends GetxController {
  /// Ссылка на контроллер бюджета
  late final BudgetController _budgetController;
  
  /// Текущий активный раздел
  final _currentSection = FinanceSection.overview.obs;
  
  /// Фактические расходы по категориям
  final _actualExpenses = <String, double>{}.obs;
  
  /// Тестовые данные о расходах
  final _transactionList = [].obs;

  /// Геттер для текущего раздела
  FinanceSection get currentSection => _currentSection.value;
  
  /// Геттер для списка категорий
  List<BudgetCategoryModel> get categories => _budgetController.categories;
  
  /// Геттер для активного бюджета
  BudgetModel? get activeBudget => _budgetController.activeBudget;
  
  /// Геттер для фактических расходов
  Map<String, double> get actualExpenses => _actualExpenses;

  @override
  void onInit() {
    super.onInit();
    
    // Инициализируем контроллер бюджета
    _budgetController = Get.find<BudgetController>();
    
    _loadTransactions();
    _calculateActualExpenses();
    
    // Правильно подписываемся на изменения в BudgetController
    ever(_budgetController.budgets, (_) => _calculateActualExpenses());
  }

  /// Загружает список транзакций (расходов и доходов)
  void _loadTransactions() {
    // TODO: Реализовать загрузку транзакций из базы данных или API
    // Пока используем тестовые данные
    _transactionList.clear();
    // Здесь будет код для получения транзакций
  }

  /// Рассчитывает фактические расходы по категориям
  void _calculateActualExpenses() {
    // Очищаем текущие данные
    _actualExpenses.clear();
    
    // Если нет активного бюджета, нечего считать
    final currentBudget = activeBudget;
    if (currentBudget == null) return;
    
    // TODO: Рассчитать фактические расходы на основе транзакций
    // Для тестирования используем различные проценты выполнения бюджета
    final percentages = {
      '1': 0.75, // Продукты - 75% бюджета
      '2': 0.90, // Транспорт - 90% бюджета
      '3': 1.20, // Развлечения - 120% (превышение бюджета)
      '4': 0.50, // Коммунальные платежи - 50% бюджета
      '5': 0.30, // Здоровье - 30% бюджета
    };
    
    for (final entry in currentBudget.categoryBudgets.entries) {
      final categoryId = entry.key;
      final budgetAmount = entry.value;
      
      // Используем заданный процент или 80% по умолчанию
      final percentage = percentages[categoryId] ?? 0.8;
      final actualAmount = budgetAmount * percentage;
      
      _actualExpenses[categoryId] = actualAmount;
    }
    
    update();
  }

  /// Вычисляет процент выполнения бюджета для категории
  double getBudgetCompletionPercentage(String categoryId) {
    final currentBudget = activeBudget;
    if (currentBudget == null) return 0.0;
    
    final budgetAmount = currentBudget.getBudgetForCategory(categoryId);
    if (budgetAmount <= 0) return 0.0;
    
    final actualAmount = _actualExpenses[categoryId] ?? 0.0;
    return (actualAmount / budgetAmount) * 100;
  }

  /// Вычисляет общий процент выполнения бюджета
  double getTotalBudgetCompletionPercentage() {
    final currentBudget = activeBudget;
    if (currentBudget == null) return 0.0;
    
    final totalBudget = currentBudget.allocatedAmount;
    if (totalBudget <= 0) return 0.0;
    
    final totalExpenses = _actualExpenses.values.fold(0.0, (sum, amount) => sum + amount);
    return (totalExpenses / totalBudget) * 100;
  }

  /// Получает остаток бюджета для категории
  double getRemainingBudget(String categoryId) {
    final currentBudget = activeBudget;
    if (currentBudget == null) return 0.0;
    
    final budgetAmount = currentBudget.getBudgetForCategory(categoryId);
    final actualAmount = _actualExpenses[categoryId] ?? 0.0;
    
    return budgetAmount - actualAmount;
  }

  /// Получает общий остаток бюджета
  double getTotalRemainingBudget() {
    final currentBudget = activeBudget;
    if (currentBudget == null) return 0.0;
    
    final totalBudget = currentBudget.allocatedAmount;
    final totalExpenses = _actualExpenses.values.fold(0.0, (sum, amount) => sum + amount);
    
    return totalBudget - totalExpenses;
  }

  /// Определяет, превышен ли бюджет для категории
  bool isBudgetExceeded(String categoryId) {
    return getBudgetCompletionPercentage(categoryId) > 100;
  }

  /// Определяет, превышен ли общий бюджет
  bool isTotalBudgetExceeded() {
    return getTotalBudgetCompletionPercentage() > 100;
  }

  /// Изменяет текущий раздел
  void changeSection(FinanceSection section) {
    _currentSection.value = section;
    update();
  }

  /// Создает новый бюджет с распределением на основе статистики
  Future<void> createBudgetWithSuggestions(String name, double totalAmount, BudgetPeriod period, DateTime startDate, DateTime endDate) async {
    // Получаем предлагаемое распределение бюджета
    final suggestedDistribution = _budgetController.suggestBudgetDistribution(totalAmount);
    
    // Создаем новый бюджет
    final newBudget = BudgetModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Генерируем ID
      name: name,
      totalAmount: totalAmount,
      startDate: startDate,
      endDate: endDate,
      categoryBudgets: suggestedDistribution,
      period: period,
    );
    
    // Создаем бюджет через контроллер бюджетов
    await _budgetController.createBudget(newBudget);
    
    // Пересчитываем фактические расходы
    _calculateActualExpenses();
  }

  /// Анализирует расходы и предлагает оптимизацию бюджета
  Map<String, double> analyzeBudgetOptimization() {
    final currentBudget = activeBudget;
    if (currentBudget == null) return {};
    
    final optimizedBudget = <String, double>{};
    
    // TODO: Реализовать алгоритм оптимизации бюджета на основе
    // статистики расходов и приоритетов категорий
    
    // Пока возвращаем текущее распределение
    return Map.from(currentBudget.categoryBudgets);
  }
  
  /// Получает список категорий, превышающих бюджет
  List<String> getOverspentCategories() {
    final result = <String>[];
    
    final currentBudget = activeBudget;
    if (currentBudget != null) {
      for (final categoryId in currentBudget.categoryBudgets.keys) {
        if (isBudgetExceeded(categoryId)) {
          result.add(categoryId);
        }
      }
    }
    
    return result;
  }
  
  /// Получает список категорий с низким уровнем использования бюджета
  List<String> getUnderspentCategories({double threshold = 50.0}) {
    final result = <String>[];
    
    final currentBudget = activeBudget;
    if (currentBudget != null) {
      for (final categoryId in currentBudget.categoryBudgets.keys) {
        final percentage = getBudgetCompletionPercentage(categoryId);
        if (percentage < threshold) {
          result.add(categoryId);
        }
      }
    }
    
    return result;
  }
}