class TransactionModel {
  final int? id;
  final String title;
  final String? description; // <-- NUEVO CAMPO (Opcional)
  final double amount;
  final DateTime date;
  final bool isIncome;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    this.id,
    required this.title,
    this.description, // <-- Añadido al constructor
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      description: map['description'], // <-- Leer de la BD
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'] == 1,
      categoryId: map['categoryId'],
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description, // <-- Guardar en la BD
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
      'categoryId': categoryId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}