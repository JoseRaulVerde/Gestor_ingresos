class TransactionModel {
  final int? id;
  final String title;
  final String? description; 
  final double amount;
  final DateTime date;
  final bool isIncome;
  final int categoryId;
  final int? paymentMethodId; // <--- NUEVO CAMPO PARA EL MÉTODO DE PAGO
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    this.id,
    required this.title,
    this.description, 
    required this.amount,
    required this.date,
    required this.isIncome,
    required this.categoryId,
    this.paymentMethodId, // <--- Añadido al constructor
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      description: map['description'], 
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      isIncome: map['isIncome'] == 1,
      categoryId: map['categoryId'],
      paymentMethodId: map['paymentMethodId'], // <--- Leer de la BD
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description, 
      'amount': amount,
      'date': date.toIso8601String(),
      'isIncome': isIncome ? 1 : 0,
      'categoryId': categoryId,
      'paymentMethodId': paymentMethodId, // <--- Guardar en la BD
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}