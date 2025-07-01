import 'package:flutter/material.dart';
import '../models/budget_category_model.dart';
import '../constants/theme_constants.dart';

/// Виджет для отображения прогресса выполнения бюджета по категории
class BudgetProgress extends StatelessWidget {
  /// Модель категории бюджета
  final BudgetCategoryModel category;

  /// Выделенная сумма бюджета для этой категории
  final double allocatedAmount;

  /// Фактически потраченная сумма по этой категории
  final double spentAmount;

  /// Обратный вызов при нажатии на элемент
  final VoidCallback? onTap;

  /// Конструктор
  const BudgetProgress({
    Key? key,
    required this.category,
    required this.allocatedAmount,
    required this.spentAmount,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Вычисление процента выполнения бюджета
    final double percent = allocatedAmount > 0 
        ? (spentAmount / allocatedAmount).clamp(0.0, 2.0) 
        : 0.0;
    
    // Определение цвета в зависимости от прогресса
    Color progressColor;
    if (percent >= 1.0) {
      // Превышен бюджет
      progressColor = Colors.red;
    } else if (percent >= 0.9) {
      // Близко к пределу
      progressColor = Colors.orange;
    } else if (percent >= 0.75) {
      // Приближается к пределу
      progressColor = Colors.amber;
    } else {
      // В пределах нормы
      progressColor = Colors.green;
    }

    // Процент для отображения
    final int displayPercent = (percent * 100).round();
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Иконка категории
              CircleAvatar(
                backgroundColor: category.color.withOpacity(0.2),
                radius: 20,
                child: Icon(
                  category.icon,
                  color: category.color,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Информация о категории и прогрессе
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Название категории
                        Expanded(
                          child: Text(
                            category.name,
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Процент выполнения
                        Text(
                          '$displayPercent%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: progressColor,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Прогресс-бар
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: percent.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[200],
                        color: progressColor,
                        minHeight: 6,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Суммы
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${spentAmount.toStringAsFixed(0)} ₽',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        Text(
                          'из ${allocatedAmount.toStringAsFixed(0)} ₽',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}