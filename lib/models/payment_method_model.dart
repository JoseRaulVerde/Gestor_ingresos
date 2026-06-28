class PaymentMethodModel {
  int? id;
  String name;
  String? icon;

  PaymentMethodModel({
    this.id,
    required this.name,
    this.icon,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
    };
  }

  factory PaymentMethodModel.fromMap(Map<String, dynamic> map) {
    return PaymentMethodModel(
      id: map['id'],
      name: map['name'],
      icon: map['icon'],
    );
  }
}