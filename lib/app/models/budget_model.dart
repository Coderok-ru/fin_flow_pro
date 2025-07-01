import 'package:flutter/foundation.dart';
import 'budget_category_model.dart';

/// Enum для периода бюджета
enum BudgetPeriod {
  /// Месячный бюджет
  month,

  /// Квартальный бюджет
  quarter,

  /// Годовой бюджет
  year,
}

/// Модель для хранения информации о бюджете
class BudgetModel {
  /// Уникальный идентификатор бюджета
  final String id;

  /// Название бюджета
  final String name;

  /// Общая сумма бюджета
  final double totalAmount;

  /// Дата начала действия бюджета
  final DateTime startDate;

  /// Дата окончания действия бюджета
  final DateTime endDate;

  /// Распределение бюджета по категориям
  /// Ключ - id категории, значение - сумма
  final Map<String, double> categoryBudgets;

  /// Период бюджета (месяц, квартал, год)
  final BudgetPeriod period;

  /// Конструктор
  BudgetModel({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.startDate,
    required this.endDate,
    required this.categoryBudgets,
    required this.period,
  });

  /// Создает копию объекта с указанными изменениями
  BudgetModel copyWith({
    String? id,
    String? name,
    double? totalAmount,
    DateTime? startDate,
    DateTime? endDate,
    Map<String, double>? categoryBudgets,
    BudgetPeriod? period,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      totalAmount: totalAmount ?? this.totalAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryBudgets: categoryBudgets ?? Map.from(this.categoryBudgets),
      period: period ?? this.period,
    );
  }

  /// Получает сумму, выделенную для указанной категории
  double getBudgetForCategory(String categoryId) {
    return categoryBudgets[categoryId] ?? 0.0;
  }

  /// Получает общую сумму по всем категориям
  double get allocatedAmount {
    return categoryBudgets.values.fold(0.0, (sum, amount) => sum + amount);
  }

  /// Получает нераспределенную сумму бюджета
  double get unallocatedAmount {
    return totalAmount - allocatedAmount;
  }

  /// Проверяет, все ли средства распределены
  bool get isFullyAllocated {
    return unallocatedAmount <= 0;
  }

  /// Создает объект из JSON
  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    // Преобразование Map<String, dynamic> в Map<String, double>
    final categoryBudgetsRaw = json['categoryBudgets'] as Map<String, dynamic>;
    final Map<String, double> categoryBudgets = categoryBudgetsRaw.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return BudgetModel(
      id: json['id'] as String,
      name: json['name'] as String,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      categoryBudgets: categoryBudgets,
      period: BudgetPeriod.values.firstWhere(
        (e) => e.toString() == 'BudgetPeriod.${json['period']}',
      ),
    );
  }

  /// Преобразует объект в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalAmount': totalAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'categoryBudgets': categoryBudgets,
      'period': period.toString().split('.').last,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BudgetModel{id: $id, name: $name, totalAmount: $totalAmount}';
  }
}