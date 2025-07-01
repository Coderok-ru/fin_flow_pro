import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/expense_controller.dart';
import 'package:fin_flow_pro/app/controllers/income_controller.dart';
import 'package:fin_flow_pro/app/models/expense_model.dart';
import 'package:fin_flow_pro/app/models/income_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class CalendarController extends GetxController {
  final ExpenseController _expenseController = Get.find<ExpenseController>();
  final IncomeController _incomeController = Get.find<IncomeController>();
  
  // Текущий выбранный месяц и год
  Rx<DateTime> selectedMonth = DateTime.now().obs;
  
  // Получение списка дней в выбранном месяце
  List<DateTime> getDaysInMonth() {
    final year = selectedMonth.value.year;
    final month = selectedMonth.value.month;
    
    // Первый день месяца
    final firstDay = DateTime(year, month, 1);
    
    // Количество дней в месяце
    final daysInMonth = DateTime(year, month + 1, 0).day;
    
    // Список всех дней месяца
    return List.generate(daysInMonth, (index) => DateTime(year, month, index + 1));
  }
  
  // Получение платежей (доходы и расходы) для конкретного дня
  List<dynamic> getPaymentsForDay(DateTime day) {
    final List<dynamic> payments = [];
    final targetDate = DateTime(day.year, day.month, day.day);
    
    // Добавляем расходы на этот день
    for (var expense in _expenseController.expenses) {
      if (_shouldShowExpenseOnDate(expense, targetDate)) {
        payments.add(expense);
      }
    }
    
    // Добавляем доходы на этот день
    for (var income in _incomeController.incomes) {
      if (_shouldShowIncomeOnDate(income, targetDate)) {
        payments.add(income);
      }
    }
    
    return payments;
  }
  
  // Проверка, должен ли отображаться расход на указанную дату
  bool _shouldShowExpenseOnDate(ExpenseModel expense, DateTime date) {
    // Базовая проверка на соответствие дня
    if (_isSameDay(expense.date, date)) {
      return true;
    }
    
    // Проверка для периодических платежей
    if (expense.frequency == 'Разово') {
      return false; // Разовый платеж проверен выше
    }
    
    // Если платеж имеет дату окончания и эта дата раньше проверяемой даты
    if (expense.endDate != null && expense.endDate!.isBefore(date)) {
      return false;
    }
    
    // Если дата платежа позже проверяемой даты
    if (expense.date.isAfter(date)) {
      return false;
    }
    
    // Расчет для разных периодичностей
    switch (expense.frequency) {
      case 'Еженедельно':
        // Проверяем, совпадает ли день недели
        return expense.date.weekday == date.weekday;
      case 'Раз в две недели':
        // Проверяем, прошло ли четное количество недель с даты платежа
        final weeks = date.difference(expense.date).inDays ~/ 7;
        return expense.date.weekday == date.weekday && weeks % 2 == 0;
      case 'Ежемесячно':
        // Проверяем, совпадает ли день месяца
        return expense.date.day == date.day;
      case 'Раз в два месяца':
        // Проверяем, совпадает ли день месяца и прошло ли четное количество месяцев
        final months = (date.year - expense.date.year) * 12 + date.month - expense.date.month;
        return expense.date.day == date.day && months % 2 == 0;
      case 'Раз в три месяца':
        // Проверяем, совпадает ли день месяца и прошло ли кратное трем количество месяцев
        final months = (date.year - expense.date.year) * 12 + date.month - expense.date.month;
        return expense.date.day == date.day && months % 3 == 0;
      case 'Раз в полгода':
        // Проверяем, совпадает ли день месяца и прошло ли кратное шести количество месяцев
        final months = (date.year - expense.date.year) * 12 + date.month - expense.date.month;
        return expense.date.day == date.day && months % 6 == 0;
      case 'Ежегодно':
        // Проверяем, совпадает ли день и месяц
        return expense.date.day == date.day && expense.date.month == date.month;
      default:
        return false;
    }
  }
  
  // Проверка, должен ли отображаться доход на указанную дату
  bool _shouldShowIncomeOnDate(IncomeModel income, DateTime date) {
    // Базовая проверка на соответствие дня
    if (_isSameDay(income.date, date)) {
      return true;
    }
    
    // Проверка для периодических платежей
    if (income.frequency == 'Разово') {
      return false; // Разовый платеж проверен выше
    }
    
    // Если платеж имеет дату окончания и эта дата раньше проверяемой даты
    if (income.endDate != null && income.endDate!.isBefore(date)) {
      return false;
    }
    
    // Если дата платежа позже проверяемой даты
    if (income.date.isAfter(date)) {
      return false;
    }
    
    // Расчет для разных периодичностей
    switch (income.frequency) {
      case 'Еженедельно':
        // Проверяем, совпадает ли день недели
        return income.date.weekday == date.weekday;
      case 'Раз в две недели':
        // Проверяем, прошло ли четное количество недель с даты платежа
        final weeks = date.difference(income.date).inDays ~/ 7;
        return income.date.weekday == date.weekday && weeks % 2 == 0;
      case 'Ежемесячно':
        // Проверяем, совпадает ли день месяца
        return income.date.day == date.day;
      case 'Раз в два месяца':
        // Проверяем, совпадает ли день месяца и прошло ли четное количество месяцев
        final months = (date.year - income.date.year) * 12 + date.month - income.date.month;
        return income.date.day == date.day && months % 2 == 0;
      case 'Раз в три месяца':
        // Проверяем, совпадает ли день месяца и прошло ли кратное трем количество месяцев
        final months = (date.year - income.date.year) * 12 + date.month - income.date.month;
        return income.date.day == date.day && months % 3 == 0;
      case 'Раз в полгода':
        // Проверяем, совпадает ли день месяца и прошло ли кратное шести количество месяцев
        final months = (date.year - income.date.year) * 12 + date.month - income.date.month;
        return income.date.day == date.day && months % 6 == 0;
      case 'Ежегодно':
        // Проверяем, совпадает ли день и месяц
        return income.date.day == date.day && income.date.month == date.month;
      default:
        return false;
    }
  }
  
  // Проверка на совпадение дат без учета времени
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && date1.month == date2.month && date1.day == date2.day;
  }
  
  // Переключение на предыдущий месяц
  void previousMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month - 1,
      1,
    );
    update();
  }
  
  // Переключение на следующий месяц
  void nextMonth() {
    selectedMonth.value = DateTime(
      selectedMonth.value.year,
      selectedMonth.value.month + 1,
      1,
    );
    update();
  }
  
  // Получение суммы всех платежей для дня
  double getTotalForDay(DateTime day) {
    double total = 0;
    
    final payments = getPaymentsForDay(day);
    for (var payment in payments) {
      if (payment is ExpenseModel) {
        total -= payment.amount;
      } else if (payment is IncomeModel) {
        total += payment.amount;
      }
    }
    
    return total;
  }
  
  // Форматирование заголовка месяца
  String getMonthTitle() {
    final formatter = DateFormat('MMMM yyyy', 'ru_RU');
    return formatter.format(selectedMonth.value);
  }
}