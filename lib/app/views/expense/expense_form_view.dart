import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/expense_controller.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';
import 'package:fin_flow_pro/app/constants/app_constants.dart';
import 'package:fin_flow_pro/app/models/expense_model.dart';
import 'package:intl/intl.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ExpenseFormView extends GetView<ExpenseController> {
  const ExpenseFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Получаем расход для редактирования, если передан
    final ExpenseModel? expense = Get.arguments as ExpenseModel?;
    final bool isEditing = expense != null;

    // Форматтер для дат
    final dateFormat = DateFormat(AppConstants.dateFormat);

    // Контроллеры для полей формы
    final nameController = TextEditingController(text: expense?.name ?? '');
    final amountController = TextEditingController(
        text: expense?.amount.toString() ?? '');
    final descriptionController = TextEditingController(text: expense?.description ?? '');
    
    // Значения для полей формы
    final selectedCategory = (expense?.category ?? AppConstants.expenseCategories[0]).obs;
    final selectedDate = (expense?.date ?? DateTime.now()).obs;
    final selectedFrequency = (expense?.frequency ?? AppConstants.frequencyOptions[2]).obs;
    final selectedEndDate = (expense?.endDate).obs;
    final showEndDate = (expense?.endDate != null).obs;
    final selectedBank = (expense?.bankName ?? '').obs;
    final showBankField = (expense?.category == 'Кредиты' || expense?.category == 'Кредитные карты' || selectedCategory.value == 'Кредиты' || selectedCategory.value == 'Кредитные карты').obs;

    // Функция сохранения
    void saveExpense() {
      if (nameController.text.isEmpty) {
        Get.snackbar(
          'Ошибка',
          'Введите название расхода',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final amount = double.tryParse(amountController.text.replaceAll(',', '.'));
      if (amount == null || amount <= 0) {
        Get.snackbar(
          'Ошибка',
          'Введите корректную сумму',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (isEditing) {
        // Обновление существующего расхода
        final updatedExpense = expense!.copyWith(
          name: nameController.text,
          category: selectedCategory.value,
          amount: amount,
          date: selectedDate.value,
          frequency: selectedFrequency.value,
          endDate: showEndDate.value ? selectedEndDate.value : null,
          bankName: showBankField.value ? selectedBank.value : null,
          description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
          clearEndDate: !showEndDate.value,
          clearBankName: !showBankField.value,
          clearDescription: descriptionController.text.isEmpty,
        );
        controller.updateExpense(updatedExpense);
        Get.back();
        Get.snackbar(
          'Успешно',
          'Расход обновлен',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Создание нового расхода
        controller.addExpense(
          nameController.text,
          selectedCategory.value,
          amount,
          selectedDate.value,
          selectedFrequency.value,
          showEndDate.value ? selectedEndDate.value : null,
          bankName: showBankField.value ? selectedBank.value : null,
          description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
        );
        Get.back();
        Get.snackbar(
          'Успешно',
          'Расход добавлен',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактирование расхода' : 'Новый расход'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Категория расхода
            const Text(
              'Категория',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Obx(() => Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: AppConstants.expenseCategories.map((category) {
                    final isSelected = selectedCategory.value == category;
                    final categoryColor = ThemeConstants.categoryColors[category] ?? 
                        ThemeConstants.primaryColor;
                    
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      selectedColor: categoryColor.withOpacity(0.7),
                      backgroundColor: categoryColor.withOpacity(0.1),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : categoryColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          selectedCategory.value = category;
                          
                          // Показать поле выбора банка для категорий "Кредиты" и "Кредитные карты"
                          showBankField.value = category == 'Кредиты' || category == 'Кредитные карты';
                          
                          // Для кредитов автоматически устанавливаем периодичность "Ежемесячно"
                          if (category == 'Кредиты') {
                            selectedFrequency.value = 'Ежемесячно';
                            showEndDate.value = true;
                            if (selectedEndDate.value == null) {
                              selectedEndDate.value = DateTime.now().add(const Duration(days: 365 * 3));  // 3 года
                            }
                          }
                        }
                      },
                    );
                  }).toList(),
                )),
            const SizedBox(height: 16),

            // Название расхода
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Название',
                hintText: 'Например: ${selectedCategory.value == 'Кредиты' ? 'Ипотека' : 'Продукты'}',
                prefixIcon: const Icon(Icons.description),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Сумма расхода
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Сумма',
                hintText: 'Введите сумму',
                prefixIcon: Icon(Icons.monetization_on),
                prefixText: '₽ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Выбор банка (для кредитов и кредитных карт)
            Obx(() => showBankField.value
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Банк',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedBank.value.isEmpty
                                ? null
                                : selectedBank.value,
                            hint: const Text('Выберите банк'),
                            icon: const Icon(Icons.arrow_drop_down),
                            items: AppConstants.russianBanks
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                selectedBank.value = newValue;
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  )
                : const SizedBox()),

            // Дата платежа
            Obx(() => ListTile(
                  title: const Text('Дата платежа'),
                  subtitle: Text(dateFormat.format(selectedDate.value)),
                  leading: const Icon(Icons.calendar_today),
                  tileColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.value,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      selectedDate.value = picked;
                    }
                  },
                )),
            const SizedBox(height: 16),

            // Периодичность
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedFrequency.value,
                      hint: const Text('Выберите периодичность'),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: AppConstants.frequencyOptions
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          selectedFrequency.value = newValue;

                          // Если выбрана опция "Разово", скрываем поле с датой окончания
                          if (newValue == 'Разово') {
                            showEndDate.value = false;
                          }
                        }
                      },
                    ),
                  ),
                )),
            const SizedBox(height: 16),

            // Включение/выключение даты окончания
            Obx(() => CheckboxListTile(
                  title: const Text('Указать дату окончания'),
                  value: showEndDate.value,
                  activeColor: ThemeConstants.primaryColor,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (bool? value) {
                    if (selectedFrequency.value != 'Разово') {
                      showEndDate.value = value ?? false;
                      if (showEndDate.value && selectedEndDate.value == null) {
                        selectedEndDate.value = DateTime.now().add(const Duration(days: 365));
                      }
                    } else {
                      Get.snackbar(
                        'Внимание',
                        'Для разового расхода нельзя указать дату окончания',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                )),

            // Дата окончания (если выбрана)
            Obx(() => showEndDate.value
                ? ListTile(
                    title: const Text('Дата окончания'),
                    subtitle: Text(selectedEndDate.value != null
                        ? dateFormat.format(selectedEndDate.value!)
                        : 'Не указана'),
                    leading: const Icon(Icons.event_available),
                    tileColor: Colors.grey[200],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedEndDate.value ?? DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        selectedEndDate.value = picked;
                      }
                    },
                  )
                : const SizedBox()),
            
            const SizedBox(height: 16),
            
            // Описание (необязательно)
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Описание (необязательно)',
                hintText: 'Дополнительная информация',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            onPressed: saveExpense,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: Text(
              isEditing ? 'Сохранить изменения' : 'Добавить расход',
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }
}