import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/budget_model.dart';
import '../constants/theme_constants.dart';

/// Виджет для отображения карточки бюджета
class BudgetCard extends StatelessWidget {
  /// Модель бюджета для отображения
  final BudgetModel budget;
  
  /// Текущая потраченная сумма
  final double spentAmount;
  
  /// Обратный вызов при нажатии на карточку
  final VoidCallback? onTap;

  /// Конструктор
  const BudgetCard({
    Key? key,
    required this.budget,
    required this.spentAmount,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Процент выполнения бюджета
    final double progressPercent = spentAmount / budget.totalAmount;
    
    // Оставшаяся сумма
    final double remainingAmount = budget.totalAmount - spentAmount;
    
    // Форматирование чисел для отображения суммы
    final currencyFormat = NumberFormat.currency(
      locale: 'ru_RU',
      symbol: '₽',
      decimalDigits: 0,
    );
    
    // Определение цвета прогресса в зависимости от процента использования
    Color progressColor = Colors.green;
    if (progressPercent > 0.9) {
      progressColor = Colors.red;
    } else if (progressPercent > 0.75) {
      progressColor = Colors.orange;
    }
    
    // Форматирование дат для периода
    final dateFormat = DateFormat('dd.MM.yyyy');
    final periodText = '${dateFormat.format(budget.startDate)} - ${dateFormat.format(budget.endDate)}';
    
    // Текст периода бюджета
    String periodTypeText;
    switch (budget.period) {
      case BudgetPeriod.month:
        periodTypeText = 'Месячный';
        break;
      case BudgetPeriod.quarter:
        periodTypeText = 'Квартальный';
        break;
      case BudgetPeriod.year:
        periodTypeText = 'Годовой';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок и период бюджета
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      budget.name,
                      style: Theme.of(context).textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ThemeConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      periodTypeText,
                      style: TextStyle(
                        color: ThemeConstants.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Период действия бюджета
              Text(
                periodText,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Прогресс-бар
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressPercent.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[200],
                  color: progressColor,
                  minHeight: 8,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Информация о потраченной и оставшейся сумме
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Потрачено',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        currencyFormat.format(spentAmount),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: progressColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Осталось',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        currencyFormat.format(remainingAmount),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}