import 'package:get/get.dart';
import 'package:fin_flow_pro/app/models/income_model.dart';
import 'package:fin_flow_pro/app/services/storage_service.dart';
import 'dart:math';

class IncomeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  
  final RxList<IncomeModel> incomes = <IncomeModel>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadIncomes();
  }
  
  // Загрузка доходов из хранилища
  void loadIncomes() {
    incomes.value = _storageService.getIncomes();
  }
  
  // Добавление нового дохода
  Future<void> addIncome(String name, double amount, DateTime date, 
      String frequency, DateTime? endDate) async {
    final income = IncomeModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      amount: amount,
      date: date,
      frequency: frequency,
      endDate: endDate,
    );
    
    await _storageService.saveIncome(income);
    incomes.add(income);
  }
  
  // Обновление существующего дохода
  Future<void> updateIncome(IncomeModel income) async {
    await _storageService.saveIncome(income);
    
    final index = incomes.indexWhere((item) => item.id == income.id);
    if (index != -1) {
      incomes[index] = income;
      incomes.refresh();
    }
  }
  
  // Удаление дохода
  Future<void> deleteIncome(String id) async {
    await _storageService.deleteIncome(id);
    incomes.removeWhere((income) => income.id == id);
  }
  
  // Получение общей суммы доходов за текущий месяц
  double getTotalIncomeForCurrentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0); // Последний день текущего месяца
    
    return _calculateTotalIncomeForPeriod(startOfMonth, endOfMonth);
  }
  
  // Расчет общей суммы доходов за период
  double _calculateTotalIncomeForPeriod(DateTime start, DateTime end) {
    double total = 0.0;
    
    for (var income in incomes) {
      if (_isIncomeRelevantForPeriod(income, start, end)) {
        total += _calculateIncomeAmountForPeriod(income, start, end);
      }
    }
    
    return total;
  }
  
  // Проверка, попадает ли доход в указанный период
  bool _isIncomeRelevantForPeriod(IncomeModel income, DateTime start, DateTime end) {
    // Если доход имеет дату окончания и она раньше начала периода
    if (income.endDate != null && income.endDate!.isBefore(start)) {
      return false;
    }
    
    // Если дата дохода позже конца периода
    if (income.date.isAfter(end)) {
      return false;
    }
    
    return true;
  }
  
  // Расчет суммы дохода за период с учетом периодичности
  double _calculateIncomeAmountForPeriod(IncomeModel income, DateTime start, DateTime end) {
    // Для разового дохода
    if (income.frequency == 'Разово') {
      if (income.date.isAfter(start.subtract(const Duration(days: 1))) && 
          income.date.isBefore(end.add(const Duration(days: 1)))) {
        return income.amount;
      }
      return 0.0;
    }
    
    // Для периодических доходов
    double amount = 0.0;
    
    switch (income.frequency) {
      case 'Еженедельно':
        amount = _calculateWeeklyIncome(income, start, end);
        break;
      case 'Раз в две недели':
        amount = _calculateBiWeeklyIncome(income, start, end);
        break;
      case 'Ежемесячно':
        amount = _calculateMonthlyIncome(income, start, end);
        break;
      case 'Раз в два месяца':
        amount = _calculateBiMonthlyIncome(income, start, end);
        break;
      case 'Раз в три месяца':
        amount = _calculateQuarterlyIncome(income, start, end);
        break;
      case 'Раз в полгода':
        amount = _calculateSemiAnnualIncome(income, start, end);
        break;
      case 'Ежегодно':
        amount = _calculateAnnualIncome(income, start, end);
        break;
      default:
        amount = 0.0;
    }
    
    return amount;
  }
  
  // Расчеты для разных периодичностей
  double _calculateWeeklyIncome(IncomeModel income, DateTime start, DateTime end) {
    final effectiveStart = income.date.isBefore(start) ? start : income.date;
    final effectiveEnd = income.endDate != null && income.endDate!.isBefore(end) 
        ? income.endDate! 
        : end;
    
    final weeks = (effectiveEnd.difference(effectiveStart).inDays / 7).ceil();
    return income.amount * max(0, weeks);
  }
  
  double _calculateBiWeeklyIncome(IncomeModel income, DateTime start, DateTime end) {
    final effectiveStart = income.date.isBefore(start) ? start : income.date;
    final effectiveEnd = income.endDate != null && income.endDate!.isBefore(end) 
        ? income.endDate! 
        : end;
    
    final biWeeks = (effectiveEnd.difference(effectiveStart).inDays / 14).ceil();
    return income.amount * max(0, biWeeks);
  }
  
  double _calculateMonthlyIncome(IncomeModel income, DateTime start, DateTime end) {
    final effectiveStart = income.date.isBefore(start) ? start : income.date;
    final effectiveEnd = income.endDate != null && income.endDate!.isBefore(end) 
        ? income.endDate! 
        : end;
    
    final months = (effectiveEnd.year - effectiveStart.year) * 12 + 
                   effectiveEnd.month - effectiveStart.month;
    return income.amount * max(0, months + 1);
  }
  
  double _calculateBiMonthlyIncome(IncomeModel income, DateTime start, DateTime end) {
    final effectiveStart = income.date.isBefore(start) ? start : income.date;
    final effectiveEnd = income.endDate != null && income.endDate!.isBefore(end) 
        ? income.endDate! 
        : end;
    
    final months = (effectiveEnd.year - effectiveStart.year) * 12 + 
                   effectiveEnd.month - effectiveStart.month;
    return income.amount * max(0, (months / 2).ceil());
  }
  
  double _calculateQuarterlyIncome(IncomeModel income, DateTime start, DateTime end) {
    final effectiveStart = income.date.isBefore(start) ? start : income.date;
    final effectiveEnd = income.endDate != null && income.endDate!.isBefore(end) 
        ? income.endDate! 
        : end;
    
    final months = (effectiveEnd.year - effectiveStart.year) * 12 + 
                   effectiveEnd.month - effectiveStart.month;
    return income.amount * max(0, (months / 3).ceil());
  }
  
  double _calculateSemiAnnualIncome(IncomeModel income, DateTime start, DateTime end) {
    final effectiveStart = income.date.isBefore(start) ? start : income.date;
    final effectiveEnd = income.endDate != null && income.endDate!.isBefore(end) 
        ? income.endDate! 
        : end;
    
    final months = (effectiveEnd.year - effectiveStart.year) * 12 + 
                   effectiveEnd.month - effectiveStart.month;
    return income.amount * max(0, (months / 6).ceil());
  }
  
  double _calculateAnnualIncome(IncomeModel income, DateTime start, DateTime end) {
    final effectiveStart = income.date.isBefore(start) ? start : income.date;
    final effectiveEnd = income.endDate != null && income.endDate!.isBefore(end) 
        ? income.endDate! 
        : end;
    
    final years = (effectiveEnd.year - effectiveStart.year);
    return income.amount * max(0, years + 1);
  }
}