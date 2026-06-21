class GoalModel {
  final int? id;
  final int categoryId;
  final double amount; // El presupuesto máximo

  GoalModel({
    this.id,
    required this.categoryId,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'],
      categoryId: map['categoryId'],
      amount: map['amount'],
    );
  }
}