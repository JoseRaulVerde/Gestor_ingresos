class GoalModel {
  int? id;
  String title;
  int categoryId;
  double targetAmount;   // El monto meta (ej. límite de $3000 o ahorro de $5000)
  double currentAmount;  // Cuánto llevas gastado/ingresado hasta hoy
  DateTime startDate;    // Fecha inicio del rango
  DateTime endDate;      // Fecha fin del rango
  bool isExpenseMeta;    // true = Límite de Gasto, false = Meta de Ingreso

  GoalModel({
    this.id,
    required this.title,
    required this.categoryId,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.startDate,
    required this.endDate,
    required this.isExpenseMeta,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'categoryId': categoryId,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isExpenseMeta': isExpenseMeta ? 1 : 0,
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      title: map['title'],
      categoryId: map['categoryId'],
      targetAmount: map['targetAmount'],
      currentAmount: map['currentAmount'] ?? 0.0,
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      isExpenseMeta: map['isExpenseMeta'] == 1,
    );
  }
}