import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/budget_category_model.dart';
import '../constants/theme_constants.dart';

/// Виджет для ввода суммы бюджета по категории
class BudgetCategoryTile extends StatefulWidget {
  /// Модель категории бюджета
  final BudgetCategoryModel category;
  
  /// Текущая сумма бюджета для этой категории
  final double amount;
  
  /// Обратный вызов при изменении суммы
  final Function(double) onAmountChanged;
  
  /// Максимальная доступная сумма для распределения
  final double maxAvailableAmount;
  
  /// Флаг, указывающий, является ли категория активной
  final bool isActive;

  /// Конструктор
  const BudgetCategoryTile({
    Key? key,
    required this.category,
    required this.amount,
    required this.onAmountChanged,
    this.maxAvailableAmount = double.infinity,
    this.isActive = true,
  }) : super(key: key);

  @override
  State<BudgetCategoryTile> createState() => _BudgetCategoryTileState();
}

class _BudgetCategoryTileState extends State<BudgetCategoryTile> {
  /// Контроллер для текстового поля ввода
  late TextEditingController _controller;
  
  /// Фокус-нода для текстового поля
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Инициализация контроллера с текущей суммой
    _controller = TextEditingController(
      text: widget.amount > 0 ? widget.amount.toStringAsFixed(0) : '',
    );
    
    // Добавление слушателя для отслеживания изменений текста
    _controller.addListener(_updateAmount);
  }

  @override
  void didUpdateWidget(BudgetCategoryTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновление текста в контроллере при изменении суммы извне
    if (oldWidget.amount != widget.amount) {
      final String newText = widget.amount > 0 
          ? widget.amount.toStringAsFixed(0) 
          : '';
      
      // Проверка, чтобы избежать циклического обновления
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  /// Обновление суммы при изменении текста
  void _updateAmount() {
    if (_controller.text.isEmpty) {
      widget.onAmountChanged(0);
      return;
    }
    
    try {
      final double value = double.parse(_controller.text);
      
      // Проверка, не превышает ли введенная сумма максимально доступную
      if (value <= widget.maxAvailableAmount) {
        widget.onAmountChanged(value);
      } else {
        // Если превышает, устанавливаем максимально доступную сумму
        _controller.text = widget.maxAvailableAmount.toStringAsFixed(0);
        _controller.selection = TextSelection.fromPosition(
          TextPosition(offset: _controller.text.length),
        );
        widget.onAmountChanged(widget.maxAvailableAmount);
      }
    } catch (e) {
      // При ошибке разбора числа ничего не делаем, 
      // так как дальнейшая валидация происходит при потере фокуса
    }
  }

  /// Действие при потере фокуса
  void _onFocusLost() {
    if (_controller.text.isEmpty) {
      widget.onAmountChanged(0);
      return;
    }
    
    try {
      double value = double.parse(_controller.text);
      
      // Приведение значения к допустимому диапазону
      if (value < 0) value = 0;
      if (value > widget.maxAvailableAmount) value = widget.maxAvailableAmount;
      
      // Обновление текста в контроллере
      _controller.text = value > 0 ? value.toStringAsFixed(0) : '';
      widget.onAmountChanged(value);
    } catch (e) {
      // При ошибке разбора числа устанавливаем предыдущее значение
      _controller.text = widget.amount > 0 
          ? widget.amount.toStringAsFixed(0) 
          : '';
    }
  }

  @override
  void dispose() {
    // Освобождение ресурсов
    _controller.removeListener(_updateAmount);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      elevation: 1,
      color: widget.isActive 
          ? Theme.of(context).cardTheme.color 
          : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Иконка категории
            CircleAvatar(
              backgroundColor: widget.isActive
                  ? widget.category.color.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              radius: 20,
              child: Icon(
                widget.category.icon,
                color: widget.isActive 
                    ? widget.category.color 
                    : Colors.grey,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Название категории
            Expanded(
              flex: 3,
              child: Text(
                widget.category.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: widget.isActive 
                      ? null 
                      : isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Поле ввода суммы
            Expanded(
              flex: 2,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.isActive,
                onEditingComplete: _onFocusLost,
                onTapOutside: (_) => _focusNode.unfocus(),
                keyboardType: const TextInputType.numberWithOptions(decimal: false),
                textAlign: TextAlign.end,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, 
                    vertical: 8,
                  ),
                  hintText: '0',
                  suffix: const Text('₽'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: widget.isActive 
                          ? Colors.grey[400]! 
                          : Colors.grey[300]!,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: widget.isActive 
                          ? Colors.grey[400]! 
                          : Colors.grey[300]!,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: ThemeConstants.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: widget.isActive
                      ? isDarkMode ? Colors.white : Colors.black87
                      : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}