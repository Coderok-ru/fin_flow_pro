import 'package:flutter/material.dart';

/// Модель для категорий бюджета
class BudgetCategoryModel {
  /// Уникальный идентификатор категории
  final String id;

  /// Название категории
  final String name;

  /// Цвет для отображения категории
  final Color color;

  /// Иконка категории
  final IconData icon;

  /// Описание категории
  final String description;

  /// Конструктор
  BudgetCategoryModel({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
    this.description = '',
  });

  /// Создает копию объекта с указанными изменениями
  BudgetCategoryModel copyWith({
    String? id,
    String? name,
    Color? color,
    IconData? icon,
    String? description,
  }) {
    return BudgetCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      description: description ?? this.description,
    );
  }

  /// Создает объект из JSON
  factory BudgetCategoryModel.fromJson(Map<String, dynamic> json) {
    return BudgetCategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(json['color'] as int),
      icon: IconData(json['icon'] as int, fontFamily: 'MaterialIcons'),
      description: json['description'] as String? ?? '',
    );
  }

  /// Преобразует объект в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icon.codePoint,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetCategoryModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'BudgetCategoryModel{id: $id, name: $name}';
  }
}