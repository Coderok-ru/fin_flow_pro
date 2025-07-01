abstract class AppRoutes {
  static const HOME = '/';
  static const INCOME_LIST = '/income';
  static const INCOME_FORM = '/income/form';
  static const EXPENSE_LIST = '/expense';
  static const EXPENSE_FORM = '/expense/form';
  static const EXPENSE_CATEGORIES = '/expense/categories';
  static const CALENDAR = '/calendar'; // Заменили Statistics на Calendar
  static const STATISTICS = '/statistics'; // Добавляем маршрут для статистики
  static const SETTINGS = '/settings';

  // Маршруты для модуля финансов
  static const FINANCE = '/finance';
  static const FINANCE_BUDGET_PLANNING = '/finance/budget/planning';
  static const FINANCE_BUDGET_DETAIL = '/finance/budget/:id';
  static const FINANCE_CATEGORIES = '/finance/categories';
}