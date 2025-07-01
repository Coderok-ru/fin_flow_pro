import 'package:get/get.dart';
import 'package:fin_flow_pro/app/models/expense_model.dart';
import 'package:fin_flow_pro/app/services/storage_service.dart';
import 'dart:math';

class ExpenseController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadExpenses();
  }
  
  // Загрузка расходов из хранилища
  void loadExpenses() {
    expenses.value = _storageService.getExpenses();
  }
  
  // Добавление нового расхода
  Future<void> addExpense(String name, String category, double amount, 
      DateTime date, String frequency, DateTime? endDate, 
      {String? bankName, String? description}) async {
    final expense = ExpenseModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      category: category,
      amount: amount,
      date: date,
      frequency: frequency,
      endDate: endDate,
      bankName: bankName,
      description: description,
    );
    
    await _storageService.saveExpense(expense);
    expenses.add(expense);
  }
  
  // Обновление существующего расхода
  Future<void> updateExpense(ExpenseModel expense) async {
    await _storageService.saveExpense(expense);
    
    final index = expenses.indexWhere((item) => item.id == expense.id);
    if (index != -1) {
      expenses[index] = expense;
      expenses.refresh();
    }
  }
  
  // Удаление расхода
  Future<void> deleteExpense(String id) async {
    await _storageService.deleteExpense(id);
    expenses.removeWhere((expense) => expense.id == id);
  }
  
  // Получение общей суммы расходов за текущий месяц
  double getTotalExpenseForCurrentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0); // Последний день текущего месяца
    
    return _calculateTotalExpenseForPeriod(startOfMonth, endOfMonth);
  }
  
  // Получение суммы расходов по категории за текущий месяц
  double getTotalExpenseByCategory(String category) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _calculateTotalExpenseForPeriodByCategory(startOfMonth, endOfMonth, category);
  }
  
  // Расчет общей суммы расходов за период
  double _calculateTotalExpenseForPeriod(DateTime start, DateTime end) {
    double total = 0.0;
    
    for (var expense in expenses) {
      if (_isExpenseRelevantForPeriod(expense, start, end)) {
        total += _calculateExpenseAmountForPeriod(expense, start, end);
      }
    }
    
    return total;
  }
  
  // Расчет суммы расходов по категории за период
  double _calculateTotalExpenseForPeriodByCategory(
      DateTime start, DateTime end, String category) {
    double total = 0.0;
    
    for (var expense in expenses) {
      if (expense.category == category && 
          _isExpenseRelevantForPeriod(expense, start, end)) {
        total += _calculateExpenseAmountForPeriod(expense, start, end);
      }
    }
    
    return total;
  }
  
  // Проверка, попадает ли расход в указанный период
  bool _isExpenseRelevantForPeriod(ExpenseModel expense, DateTime start, DateTime end) {
    // Если расход имеет дату окончания и она раньше начала периода
    if (expense.endDate != null && expense.endDate!.isBefore(start)) {
      return false;
    }
    
    // Если дата расхода позже конца периода
    if (expense.date.isAfter(end)) {
      return false;
    }
    
    return true;
  }
  
  // Расчет суммы расхода за период с учетом периодичности
  double _calculateExpenseAmountForPeriod(ExpenseModel expense, DateTime start, DateTime end) {
    // Для разового расхода
    if (expense.frequency == 'Разово') {
      if (expense.date.isAfter(start.subtract(const Duration(days: 1))) && 
          expense.date.isBefore(end.add(const Duration(days: 1)))) {
        return expense.amount;
      }
      return 0.0;
    }
    
    // Для периодических расходов
    double amount = 0.0;
    
    switch (expense.frequency) {
      case 'Еженедельно':
        amount = _calculateWeeklyExpense(expense, start, end);
        break;
      case 'Раз в две недели':
        amount = _calculateBiWeeklyExpense(expense, start, end);
        break;
      case 'Ежемесячно':
        amount = _calculateMonthlyExpense(expense, start, end);
        break;
      case 'Раз в два месяца':
        amount = _calculateBiMonthlyExpense(expense, start, end);
        break;
      case 'Раз в три месяца':
        amount = _calculateQuarterlyExpense(expense, start, end);
        break;
      case 'Раз в полгода':
        amount = _calculateSemiAnnualExpense(expense, start, end);
        break;
      case 'Ежегодно':
        amount = _calculateAnnualExpense(expense, start, end);
        break;
      default:
        amount = 0.0;
    }
    
    return amount;
  }
  
  // Получение списка расходов по категории
  List<ExpenseModel> getExpensesByCategory(String category) {
    return expenses.where((expense) => expense.category == category).toList();
  }
  
  // Расчеты для разных периодичностей
  double _calculateWeeklyExpense(ExpenseModel expense, DateTime start, DateTime end) {
    final effectiveStart = expense.date.isBefore(start) ? start : expense.date;
    final effectiveEnd = expense.endDate != null && expense.endDate!.isBefore(end) 
        ? expense.endDate! 
        : end;
    
    final weeks = (effectiveEnd.difference(effectiveStart).inDays / 7).ceil();
    return expense.amount * max(0, weeks);
  }
  
  double _calculateBiWeeklyExpense(ExpenseModel expense, DateTime start, DateTime end) {
    final effectiveStart = expense.date.isBefore(start) ? start : expense.date;
    final effectiveEnd = expense.endDate != null && expense.endDate!.isBefore(end) 
        ? expense.endDate! 
        : end;
    
    final biWeeks = (effectiveEnd.difference(effectiveStart).inDays / 14).ceil();
    return expense.amount * max(0, biWeeks);
  }
  
  double _calculateMonthlyExpense(ExpenseModel expense, DateTime start, DateTime end) {
    final effectiveStart = expense.date.isBefore(start) ? start : expense.date;
    final effectiveEnd = expense.endDate != null && expense.endDate!.isBefore(end) 
        ? expense.endDate! 
        : end;
    
    final months = (effectiveEnd.year - effectiveStart.year) * 12 + 
                   effectiveEnd.month - effectiveStart.month;
    return expense.amount * max(0, months + 1);
  }
  
  double _calculateBiMonthlyExpense(ExpenseModel expense, DateTime start, DateTime end) {
    final effectiveStart = expense.date.isBefore(start) ? start : expense.date;
    final effectiveEnd = expense.endDate != null && expense.endDate!.isBefore(end) 
        ? expense.endDate! 
        : end;
    
    final months = (effectiveEnd.year - effectiveStart.year) * 12 + 
                   effectiveEnd.month - effectiveStart.month;
    return expense.amount * max(0, (months / 2).ceil());
  }
  
  double _calculateQuarterlyExpense(ExpenseModel expense, DateTime start, DateTime end) {
    final effectiveStart = expense.date.isBefore(start) ? start : expense.date;
    final effectiveEnd = expense.endDate != null && expense.endDate!.isBefore(end) 
        ? expense.endDate! 
        : end;
    
    final months = (effectiveEnd.year - effectiveStart.year) * 12 + 
                   effectiveEnd.month - effectiveStart.month;
    return expense.amount * max(0, (months / 3).ceil());
  }
  
  double _calculateSemiAnnualExpense(ExpenseModel expense, DateTime start, DateTime end) {
    final effectiveStart = expense.date.isBefore(start) ? start : expense.date;
    final effectiveEnd = expense.endDate != null && expense.endDate!.isBefore(end) 
        ? expense.endDate! 
        : end;
    
    final months = (effectiveEnd.year - effectiveStart.year) * 12 + 
                   effectiveEnd.month - effectiveStart.month;
    return expense.amount * max(0, (months / 6).ceil());
  }
  
  double _calculateAnnualExpense(ExpenseModel expense, DateTime start, DateTime end) {
    final effectiveStart = expense.date.isBefore(start) ? start : expense.date;
    final effectiveEnd = expense.endDate != null && expense.endDate!.isBefore(end) 
        ? expense.endDate! 
        : end;
    
    final years = (effectiveEnd.year - effectiveStart.year);
    return expense.amount * max(0, years + 1);
  }
  
  // Получение данных для графиков
  Map<String, double> getCategoryExpensesForChart(
      DateTime start, DateTime end) {
    Map<String, double> result = {};
    
    for (var category in _getUniqueCategories()) {
      double amount = _calculateTotalExpenseForPeriodByCategory(start, end, category);
      if (amount > 0) {
        result[category] = amount;
      }
    }
    
    return result;
  }
  
  // Получение уникальных категорий из имеющихся расходов
  List<String> _getUniqueCategories() {
    return expenses.map((e) => e.category).toSet().toList();
  }
  
  // Получение остатка средств (доходы - расходы)
  double getRemainingAmount(double totalIncome) {
    return totalIncome - getTotalExpenseForCurrentMonth();
  }
}