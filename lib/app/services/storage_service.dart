import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fin_flow_pro/app/constants/app_constants.dart';
import 'package:fin_flow_pro/app/models/income_model.dart';
import 'package:fin_flow_pro/app/models/expense_model.dart';

class StorageService extends GetxService {
  final box = GetStorage();
  
  // Инициализация хранилища
  Future<StorageService> init() async {
    await GetStorage.init();
    return this;
  }
  
  // Методы для работы с доходами
  List<IncomeModel> getIncomes() {
    final jsonList = box.read<List<dynamic>>(AppConstants.incomeStorageKey) ?? [];
    return jsonList.map((json) => IncomeModel.fromJson(json)).toList();
  }
  
  Future<void> saveIncome(IncomeModel income) async {
    final incomes = getIncomes();
    final index = incomes.indexWhere((item) => item.id == income.id);
    
    if (index != -1) {
      incomes[index] = income;
    } else {
      incomes.add(income);
    }
    
    await box.write(AppConstants.incomeStorageKey, incomes.map((e) => e.toJson()).toList());
  }
  
  Future<void> deleteIncome(String id) async {
    final incomes = getIncomes();
    incomes.removeWhere((item) => item.id == id);
    await box.write(AppConstants.incomeStorageKey, incomes.map((e) => e.toJson()).toList());
  }
  
  // Методы для работы с расходами
  List<ExpenseModel> getExpenses() {
    final jsonList = box.read<List<dynamic>>(AppConstants.expenseStorageKey) ?? [];
    return jsonList.map((json) => ExpenseModel.fromJson(json)).toList();
  }
  
  Future<void> saveExpense(ExpenseModel expense) async {
    final expenses = getExpenses();
    final index = expenses.indexWhere((item) => item.id == expense.id);
    
    if (index != -1) {
      expenses[index] = expense;
    } else {
      expenses.add(expense);
    }
    
    await box.write(AppConstants.expenseStorageKey, expenses.map((e) => e.toJson()).toList());
  }
  
  Future<void> deleteExpense(String id) async {
    final expenses = getExpenses();
    expenses.removeWhere((item) => item.id == id);
    await box.write(AppConstants.expenseStorageKey, expenses.map((e) => e.toJson()).toList());
  }
  
  // Методы для работы с настройками
  Future<void> saveThemeMode(String mode) async {
    await box.write(AppConstants.themeKey, mode);
  }
  
  String getThemeMode() {
    return box.read<String>(AppConstants.themeKey) ?? 'system';
  }
  
  // Очистка всех данных (для тестирования)
  Future<void> clearAll() async {
    await box.erase();
  }
}