import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/income_controller.dart';
import 'package:fin_flow_pro/app/controllers/expense_controller.dart';
import 'package:fin_flow_pro/app/routes/app_routes.dart';

class HomeController extends GetxController {
  final IncomeController _incomeController = Get.find<IncomeController>();
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  
  final RxInt currentNavIndex = 0.obs;
  
  @override
  void onInit() {
    super.onInit();
  }
  
  // Получение общей суммы доходов за текущий месяц
  double getTotalIncome() {
    return _incomeController.getTotalIncomeForCurrentMonth();
  }
  
  // Получение общей суммы расходов за текущий месяц
  double getTotalExpense() {
    return _expenseController.getTotalExpenseForCurrentMonth();
  }
  
  // Получение остатка средств
  double getRemainingAmount() {
    return getTotalIncome() - getTotalExpense();
  }
  
  // Получение процента расходов от доходов
  double getExpensePercentage() {
    final income = getTotalIncome();
    if (income <= 0) return 0;
    
    final expense = getTotalExpense();
    return (expense / income) * 100;
  }
  
  // Получение списка расходов по категориям
  Map<String, double> getCategoryExpenses() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    return _expenseController.getCategoryExpensesForChart(startOfMonth, endOfMonth);
  }
  
  // Получение среднего дневного расхода
  double getAverageDailyExpense() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final totalExpense = getTotalExpense();
    
    return totalExpense / daysInMonth;
  }
  
  // Получение основной категории расходов
  String getLargestExpenseCategory() {
    final categoryExpenses = getCategoryExpenses();
    if (categoryExpenses.isEmpty) return "Нет данных";
    
    String largestCategory = "";
    double maxAmount = 0;
    
    categoryExpenses.forEach((category, amount) {
      if (amount > maxAmount) {
        maxAmount = amount;
        largestCategory = category;
      }
    });
    
    return largestCategory;
  }
  
  // Получение прогноза расходов на месяц
  double getMonthlyExpenseForecast() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day;
    final totalExpense = getTotalExpense();
    
    // Простой линейный прогноз
    if (currentDay < daysInMonth) {
      return (totalExpense / currentDay) * daysInMonth;
    }
    
    return totalExpense;
  }
  
  // Переход к разделу доходов
  void navigateToIncome() {
    Get.toNamed(AppRoutes.INCOME_LIST);
  }
  
  // Переход к разделу категорий расходов
  void navigateToExpense() {
    Get.toNamed(AppRoutes.EXPENSE_CATEGORIES);
  }
  
  // Переход к разделу финансов
  void navigateToFinance() {
    Get.toNamed(AppRoutes.FINANCE);
  }
  
  // Переход к разделу календаря (был статистикой)
  void navigateToCalendar() {
    Get.toNamed(AppRoutes.CALENDAR);
  }
  
  // Переход к разделу настроек
  void navigateToSettings() {
    Get.toNamed(AppRoutes.SETTINGS);
  }
  
  // Изменение индекса навигации
  void changeNavIndex(int index) {
    currentNavIndex.value = index;
    
    switch (index) {
      case 0:
        // Домашний экран (текущий)
        break;
      case 1:
        navigateToExpense(); // Переход к категориям расходов
        break;
      case 2:
        navigateToFinance();
        break;
      case 3:
        navigateToSettings();
        break;
    }
  }
}