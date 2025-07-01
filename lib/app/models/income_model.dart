import 'package:get/get.dart';

class IncomeModel {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final String frequency; // Частота: еженедельно, ежемесячно, разово и т.д.
  final DateTime? endDate; // Дата окончания (необязательно для разовых доходов)

  IncomeModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.frequency,
    this.endDate,
  });

  // Преобразование модели в JSON для хранения
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
      'frequency': frequency,
      'endDate': endDate?.toIso8601String(),
    };
  }

  // Создание модели из JSON
  factory IncomeModel.fromJson(Map<String, dynamic> json) {
    return IncomeModel(
      id: json['id'],
      name: json['name'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      frequency: json['frequency'],
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  // Создание копии с обновленными полями
  IncomeModel copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? date,
    String? frequency,
    DateTime? endDate,
    bool clearEndDate = false,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      frequency: frequency ?? this.frequency,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }
}