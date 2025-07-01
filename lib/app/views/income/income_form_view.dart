import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fin_flow_pro/app/controllers/income_controller.dart';
import 'package:fin_flow_pro/app/constants/theme_constants.dart';
import 'package:fin_flow_pro/app/constants/app_constants.dart';
import 'package:fin_flow_pro/app/models/income_model.dart';
import 'package:intl/intl.dart';

class IncomeFormView extends GetView<IncomeController> {
  const IncomeFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Получаем доход для редактирования, если передан
    final IncomeModel? income = Get.arguments as IncomeModel?;
    final bool isEditing = income != null;

    // Форматтер для дат
    final dateFormat = DateFormat(AppConstants.dateFormat);

    // Контроллеры для полей формы
    final nameController = TextEditingController(text: income?.name ?? '');
    final amountController = TextEditingController(
        text: income?.amount.toString() ?? '');
    
    // Значения для полей формы
    final selectedDate = (income?.date ?? DateTime.now()).obs;
    final selectedFrequency = (income?.frequency ?? AppConstants.frequencyOptions[2]).obs;
    final selectedEndDate = (income?.endDate).obs;
    final showEndDate = (income?.endDate != null).obs;

    // Функция сохранения
    void saveIncome() {
      if (nameController.text.isEmpty) {
        Get.snackbar(
          'Ошибка',
          'Введите название дохода',
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
        // Обновление существующего дохода
        final updatedIncome = income!.copyWith(
          name: nameController.text,
          amount: amount,
          date: selectedDate.value,
          frequency: selectedFrequency.value,
          endDate: showEndDate.value ? selectedEndDate.value : null,
          clearEndDate: !showEndDate.value,
        );
        controller.updateIncome(updatedIncome);
        Get.back();
        Get.snackbar(
          'Успешно',
          'Доход обновлен',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        // Создание нового дохода
        controller.addIncome(
          nameController.text,
          amount,
          selectedDate.value,
          selectedFrequency.value,
          showEndDate.value ? selectedEndDate.value : null,
        );
        Get.back();
        Get.snackbar(
          'Успешно',
          'Доход добавлен',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Редактирование дохода' : 'Новый доход'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Название дохода
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название',
                hintText: 'Например: Зарплата',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Сумма дохода
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Сумма',
                hintText: 'Введите сумму',
                prefixIcon: Icon(Icons.monetization_on),
                prefixText: '₽ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Дата получения
            Obx(() => ListTile(
                  title: const Text('Дата получения'),
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
                        'Для разового дохода нельзя указать дату окончания',
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
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ElevatedButton(
            onPressed: saveIncome,
            style: ElevatedButton.styleFrom(
              backgroundColor: ThemeConstants.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: Text(
              isEditing ? 'Сохранить изменения' : 'Добавить доход',
              style: const TextStyle(fontSize: 16.0),
            ),
          ),
        ),
      ),
    );
  }
}