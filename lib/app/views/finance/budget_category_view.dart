import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/budget_controller.dart';
import '../../models/budget_category_model.dart';
import '../../constants/theme_constants.dart';

/// Экран для управления категориями бюджета
class BudgetCategoryView extends GetView<BudgetController> {
  const BudgetCategoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Управление категориями'),
      ),
      body: Obx(() {
        if (controller.categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'У вас пока нет категорий бюджета',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => _showCategoryDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Добавить категорию'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.categories.length,
          itemBuilder: (context, index) {
            final category = controller.categories[index];
            return _buildCategoryItem(context, category);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add),
        tooltip: 'Добавить категорию',
      ),
    );
  }

  /// Создает элемент списка для категории
  Widget _buildCategoryItem(BuildContext context, BudgetCategoryModel category) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: category.color.withOpacity(0.2),
          child: Icon(
            category.icon,
            color: category.color,
          ),
        ),
        title: Text(category.name),
        subtitle: category.description.isNotEmpty
            ? Text(
                category.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Кнопка редактирования
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _showCategoryDialog(
                context,
                existingCategory: category,
              ),
              tooltip: 'Редактировать',
            ),
            // Кнопка удаления
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _showDeleteConfirmation(context, category),
              tooltip: 'Удалить',
            ),
          ],
        ),
      ),
    );
  }

  /// Показывает диалог подтверждения удаления категории
  void _showDeleteConfirmation(BuildContext context, BudgetCategoryModel category) {
    Get.dialog(
      AlertDialog(
        title: const Text('Удалить категорию?'),
        content: Text(
          'Вы уверены, что хотите удалить категорию "${category.name}"? '
          'Это действие нельзя отменить. Все бюджеты, использующие эту категорию, будут обновлены.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteCategory(category.id);
              Get.back();
              Get.snackbar(
                'Категория удалена',
                'Категория "${category.name}" была успешно удалена',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Удалить'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  /// Показывает диалог для создания или редактирования категории
  void _showCategoryDialog(BuildContext context, {BudgetCategoryModel? existingCategory}) {
    // Текстовые контроллеры
    final nameController = TextEditingController(text: existingCategory?.name ?? '');
    final descriptionController = TextEditingController(text: existingCategory?.description ?? '');
    
    // Выбранный цвет и иконка
    final Rx<Color> selectedColor = (existingCategory?.color ?? Colors.blue).obs;
    final Rx<IconData> selectedIcon = (existingCategory?.icon ?? Icons.shopping_cart).obs;
    
    // Доступные иконки для выбора
    final availableIcons = [
      Icons.shopping_cart,
      Icons.restaurant,
      Icons.home,
      Icons.directions_car,
      Icons.airplanemode_active,
      Icons.medical_services,
      Icons.school,
      Icons.sports_basketball,
      Icons.movie,
      Icons.book,
      Icons.devices,
      Icons.fitness_center,
      Icons.credit_card,
      Icons.pets,
      Icons.child_care,
      Icons.account_balance,
      Icons.local_gas_station,
      Icons.wifi,
      Icons.phone,
      Icons.cake,
    ];
    
    // Доступные цвета для выбора
    final availableColors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];

    Get.dialog(
      Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Заголовок диалога
              Text(
                existingCategory == null ? 'Новая категория' : 'Редактировать категорию',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              
              // Поле для ввода названия
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Название категории',
                  border: OutlineInputBorder(),
                ),
                maxLength: 30,
              ),
              const SizedBox(height: 16.0),
              
              // Поле для ввода описания
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание (необязательно)',
                  border: OutlineInputBorder(),
                ),
                maxLength: 100,
                maxLines: 2,
              ),
              const SizedBox(height: 16.0),
              
              // Выбор цвета
              Text(
                'Цвет категории',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8.0),
              
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: availableColors.map((color) {
                    return Obx(() => GestureDetector(
                      onTap: () => selectedColor.value = color,
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: selectedColor.value == color
                              ? Border.all(color: Colors.black, width: 2)
                              : null,
                        ),
                      ),
                    ));
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16.0),
              
              // Выбор иконки
              Text(
                'Иконка категории',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8.0),
              
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    childAspectRatio: 1,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: availableIcons.length,
                  itemBuilder: (context, index) {
                    final icon = availableIcons[index];
                    return Obx(() => GestureDetector(
                      onTap: () => selectedIcon.value = icon,
                      child: Container(
                        decoration: BoxDecoration(
                          color: selectedIcon.value == icon
                              ? selectedColor.value.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: selectedIcon.value == icon
                              ? Border.all(color: selectedColor.value)
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: selectedIcon.value == icon
                              ? selectedColor.value
                              : Colors.grey[700],
                        ),
                      ),
                    ));
                  },
                ),
              ),
              
              const SizedBox(height: 24.0),
              
              // Кнопки действий
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Отмена'),
                  ),
                  const SizedBox(width: 8.0),
                  Obx(() => ElevatedButton(
                    onPressed: () {
                      // Проверка валидности ввода
                      if (nameController.text.trim().isEmpty) {
                        Get.snackbar(
                          'Ошибка',
                          'Название категории не может быть пустым',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      
                      if (existingCategory == null) {
                        // Создание новой категории
                        final newCategory = BudgetCategoryModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: nameController.text.trim(),
                          color: selectedColor.value,
                          icon: selectedIcon.value,
                          description: descriptionController.text.trim(),
                        );
                        
                        controller.createCategory(newCategory);
                        Get.back();
                        Get.snackbar(
                          'Категория создана',
                          'Новая категория "${newCategory.name}" успешно создана',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      } else {
                        // Обновление существующей категории
                        final updatedCategory = existingCategory.copyWith(
                          name: nameController.text.trim(),
                          color: selectedColor.value,
                          icon: selectedIcon.value,
                          description: descriptionController.text.trim(),
                        );
                        
                        controller.updateCategory(updatedCategory);
                        Get.back();
                        Get.snackbar(
                          'Категория обновлена',
                          'Категория "${updatedCategory.name}" успешно обновлена',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedColor.value,
                    ),
                    child: Text(
                      existingCategory == null ? 'Создать' : 'Сохранить',
                      style: const TextStyle(color: Colors.white),
                    ),
                  )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}