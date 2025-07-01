import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/income_controller.dart';
import 'package:fin_flow_pro/app/controllers/expense_controller.dart';
import 'package:intl/intl.dart';

class StatisticsController extends GetxController {
  final IncomeController _incomeController = Get.find<IncomeController>();
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  
  Rx<DateTime> selectedDate = DateTime.now().obs;
  Rx<String> selectedPeriod = 'Месяц'.obs;
  
  final List<String> periods = ['День', 'Неделя', 'Месяц', 'Год'];
  
  // Получение дат начала и конца для выбранного периода
  DateTime getStartDate() {
    final date = selectedDate.value;
    
    switch (selectedPeriod.value) {
      case 'День':
        return DateTime(date.year, date.month, date.day, 0, 0, 0);
      case 'Неделя':
        // Начало недели (понедельник)
        final weekDay = date.weekday;
        return DateTime(date.year, date.month, date.day - weekDay + 1, 0, 0, 0);
      case 'Месяц':
        return DateTime(date.year, date.month, 1, 0, 0, 0);
      case 'Год':
        return DateTime(date.year, 1, 1, 0, 0, 0);
      default:
        return DateTime(date.year, date.month, 1, 0, 0, 0);
    }
  }
  
  DateTime getEndDate() {
    final date = selectedDate.value;
    
    switch (selectedPeriod.value) {
      case 'День':
        return DateTime(date.year, date.month, date.day, 23, 59, 59);
      case 'Неделя':
        // Конец недели (воскресенье)
        final weekDay = date.weekday;
        return DateTime(date.year, date.month, date.day + (7 - weekDay), 23, 59, 59);
      case 'Месяц':
        // Последний день месяца
        return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
      case 'Год':
        return DateTime(date.year, 12, 31, 23, 59, 59);
      default:
        return DateTime(date.year, date.month + 1, 0, 23, 59, 59);
    }
  }
  
  // Получение форматированного заголовка для периода
  String getPeriodTitle() {
    final DateFormat formatter;
    
    switch (selectedPeriod.value) {
      case 'День':
        formatter = DateFormat('dd MMMM yyyy', 'ru_RU');
        return formatter.format(selectedDate.value);
      case 'Неделя':
        final start = getStartDate();
        final end = getEndDate();
        final startFormatter = DateFormat('dd', 'ru_RU');
        final endFormatter = DateFormat('dd MMMM', 'ru_RU');
        return '${startFormatter.format(start)} - ${endFormatter.format(end)}';
      case 'Месяц':
        formatter = DateFormat('MMMM yyyy', 'ru_RU');
        return formatter.format(selectedDate.value);
      case 'Год':
        formatter = DateFormat('yyyy', 'ru_RU');
        return formatter.format(selectedDate.value);
      default:
        formatter = DateFormat('MMMM yyyy', 'ru_RU');
        return formatter.format(selectedDate.value);
    }
  }
  
  // Переключение на предыдущий период
  void previousPeriod() {
    final current = selectedDate.value;
    
    switch (selectedPeriod.value) {
      case 'День':
        selectedDate.value = current.subtract(const Duration(days: 1));
        break;
      case 'Неделя':
        selectedDate.value = current.subtract(const Duration(days: 7));
        break;
      case 'Месяц':
        selectedDate.value = DateTime(current.year, current.month - 1, current.day);
        break;
      case 'Год':
        selectedDate.value = DateTime(current.year - 1, current.month, current.day);
        break;
    }
  }
  
  // Переключение на следующий период
  void nextPeriod() {
    final current = selectedDate.value;
    
    switch (selectedPeriod.value) {
      case 'День':
        selectedDate.value = current.add(const Duration(days: 1));
        break;
      case 'Неделя':
        selectedDate.value = current.add(const Duration(days: 7));
        break;
      case 'Месяц':
        selectedDate.value = DateTime(current.year, current.month + 1, current.day);
        break;
      case 'Год':
        selectedDate.value = DateTime(current.year + 1, current.month, current.day);
        break;
    }
  }
  
  // Изменение типа периода
  void changePeriod(String period) {
    selectedPeriod.value = period;
    update();
  }
  
  // Получение данных о расходах по категориям для текущего периода
  Map<String, double> getExpensesByCategory() {
    try {
      final start = getStartDate();
      final end = getEndDate();
      
      return _expenseController.getCategoryExpensesForChart(start, end);
    } catch (e) {
      print('Ошибка при получении расходов по категориям: $e');
      return {};
    }
  }
  
  // Получение общей суммы доходов за выбранный период
  double getTotalIncome() {
    try {
      final start = getStartDate();
      final end = getEndDate();
      
      // Используем тот же подход, что и в IncomeController для учета периодичности
      return _calculateTotalIncomeForPeriod(start, end);
    } catch (e) {
      print('Ошибка при расчете общего дохода: $e');
      return 0.0;
    }
  }
  
  // Вспомогательный метод для расчета доходов с учетом периодичности
  double _calculateTotalIncomeForPeriod(DateTime start, DateTime end) {
    double total = 0.0;
    
    for (var income in _incomeController.incomes) {
      // Для разового дохода
      if (income.frequency == 'Разово') {
        if (_isDateInRange(income.date, start, end)) {
          total += income.amount;
        }
        continue;
      }
      
      // Для периодических доходов с учетом даты начала и окончания
      if (income.endDate != null && income.endDate!.isBefore(start)) {
        continue; // Доход уже закончился до начала периода
      }
      
      if (income.date.isAfter(end)) {
        continue; // Доход начинается после окончания периода
      }
      
      // Иначе доход действует в данном периоде
      total += income.amount;
    }
    
    return total;
  }
  
  // Получение общей суммы расходов за выбранный период
  double getTotalExpense() {
    try {
      final start = getStartDate();
      final end = getEndDate();
      
      double total = 0.0;
      final categoryExpenses = _expenseController.getCategoryExpensesForChart(start, end);
      
      categoryExpenses.forEach((category, amount) {
        total += amount;
      });
      
      return total;
    } catch (e) {
      print('Ошибка при расчете общих расходов: $e');
      return 0.0;
    }
  }
  
  // Проверка, попадает ли дата в указанный диапазон
  bool _isDateInRange(DateTime date, DateTime start, DateTime end) {
    final startDate = DateTime(start.year, start.month, start.day);
    final endDate = DateTime(end.year, end.month, end.day, 23, 59, 59);
    final checkDate = DateTime(date.year, date.month, date.day);
    
    return (checkDate.isAtSameMomentAs(startDate) || checkDate.isAfter(startDate)) &&
           (checkDate.isAtSameMomentAs(endDate) || checkDate.isBefore(endDate));
  }
  
  @override
  void onInit() {
    super.onInit();
    // Устанавливаем обработчики для обновления данных при изменении периода
    ever(selectedDate, (_) => update());
    ever(selectedPeriod, (_) => update());
  }
}