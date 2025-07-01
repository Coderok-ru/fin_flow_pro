import 'package:get/get.dart';

class ExpenseModel {
  final String id;
  final String name;
  final String category; // Категория: Кредиты, Транспорт, Семья и т.д.
  final double amount;
  final DateTime date;
  final String frequency; // Частота: еженедельно, ежемесячно, разово и т.д.
  final DateTime? endDate; // Дата окончания (для кредитов - дата последнего платежа)
  final String? bankName; // Имя банка (для кредитов и кредитных карт)
  final String? description; // Дополнительное описание

  ExpenseModel({
    required this.id,
    required this.name,
    required this.category,
    required this.amount,
    required this.date,
    required this.frequency,
    this.endDate,
    this.bankName,
    this.description,
  });

  // Преобразование модели в JSON для хранения
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'amount': amount,
      'date': date.toIso8601String(),
      'frequency': frequency,
      'endDate': endDate?.toIso8601String(),
      'bankName': bankName,
      'description': description,
    };
  }

  // Создание модели из JSON
  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'],
      name: json['name'],
      category: json['category'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      frequency: json['frequency'],
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      bankName: json['bankName'],
      description: json['description'],
    );
  }

  // Создание копии с обновленными полями
  ExpenseModel copyWith({
    String? id,
    String? name,
    String? category,
    double? amount,
    DateTime? date,
    String? frequency,
    DateTime? endDate,
    String? bankName,
    String? description,
    bool clearEndDate = false,
    bool clearBankName = false,
    bool clearDescription = false,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      frequency: frequency ?? this.frequency,
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      bankName: clearBankName ? null : (bankName ?? this.bankName),
      description: clearDescription ? null : (description ?? this.description),
    );
  }
}