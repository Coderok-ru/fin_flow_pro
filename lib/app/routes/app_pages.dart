import 'package:get/get.dart';
import 'package:fin_flow_pro/app/routes/app_routes.dart';
import 'package:fin_flow_pro/app/bindings/home_binding.dart';
import 'package:fin_flow_pro/app/bindings/income_binding.dart';
import 'package:fin_flow_pro/app/bindings/expense_binding.dart';
import 'package:fin_flow_pro/app/bindings/calendar_binding.dart';
import 'package:fin_flow_pro/app/bindings/statistics_binding.dart';
import 'package:fin_flow_pro/app/bindings/finance_binding.dart';
import 'package:fin_flow_pro/app/views/home/home_view.dart';
import 'package:fin_flow_pro/app/views/income/income_list_view.dart';
import 'package:fin_flow_pro/app/views/income/income_form_view.dart';
import 'package:fin_flow_pro/app/views/expense/expense_list_view.dart';
import 'package:fin_flow_pro/app/views/expense/expense_form_view.dart';
import 'package:fin_flow_pro/app/views/expense/expense_categories_view.dart';
import 'package:fin_flow_pro/app/views/calendar/calendar_view.dart';
import 'package:fin_flow_pro/app/views/statistics/statistics_view.dart';
import 'package:fin_flow_pro/app/views/settings_view.dart';
import 'package:fin_flow_pro/app/views/finance/finance_view.dart';
import 'package:fin_flow_pro/app/views/finance/budget_planning_view.dart';
import 'package:fin_flow_pro/app/views/finance/budget_tracking_view.dart';
import 'package:fin_flow_pro/app/views/finance/budget_category_view.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.INCOME_LIST,
      page: () => const IncomeListView(),
      binding: IncomeBinding(),
    ),
    GetPage(
      name: AppRoutes.INCOME_FORM,
      page: () => const IncomeFormView(),
      binding: IncomeBinding(),
    ),
    GetPage(
      name: AppRoutes.EXPENSE_LIST,
      page: () => const ExpenseListView(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.EXPENSE_FORM,
      page: () => const ExpenseFormView(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.EXPENSE_CATEGORIES,
      page: () => const ExpenseCategoriesView(),
      binding: ExpenseBinding(),
    ),
    GetPage(
      name: AppRoutes.CALENDAR,
      page: () => const CalendarView(),
      binding: CalendarBinding(),
    ),
    GetPage(
      name: AppRoutes.STATISTICS,
      page: () => const StatisticsView(),
      binding: StatisticsBinding(),
    ),
    GetPage(
      name: AppRoutes.SETTINGS,
      page: () => const SettingsView(),
    ),
    
    // Маршруты для экранов финансов
    GetPage(
      name: AppRoutes.FINANCE,
      page: () => const FinanceView(),
      binding: FinanceBinding(),
      children: [
        GetPage(
          name: '/budget/planning',
          page: () => const BudgetPlanningView(),
        ),
        GetPage(
          name: '/budget/:id',
          page: () => const BudgetTrackingView(), // Используем BudgetTrackingView для просмотра деталей
        ),
        GetPage(
          name: '/categories',
          page: () => const BudgetCategoryView(),
        ),
      ],
    ),
    
    // Дополнительные маршруты для финансов (доступ без вложенности)
    GetPage(
      name: AppRoutes.FINANCE_BUDGET_PLANNING,
      page: () => const BudgetPlanningView(),
      binding: FinanceBinding(),
    ),
    GetPage(
      name: AppRoutes.FINANCE_CATEGORIES,
      page: () => const BudgetCategoryView(),
      binding: FinanceBinding(),
    ),
    // Добавляем прямой маршрут для просмотра деталей бюджета
    GetPage(
      name: AppRoutes.FINANCE_BUDGET_DETAIL,
      page: () => const BudgetTrackingView(),
      binding: FinanceBinding(),
    ),
  ];
}