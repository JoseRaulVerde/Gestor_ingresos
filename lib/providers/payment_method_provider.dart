import 'package:flutter/material.dart';
import '../models/payment_method_model.dart';
import '../database/db_helper.dart';

class PaymentMethodProvider with ChangeNotifier {
  List<PaymentMethodModel> _paymentMethods = [];

  List<PaymentMethodModel> get paymentMethods => _paymentMethods;

  PaymentMethodProvider() {
    fetchPaymentMethods();
  }

  Future<void> fetchPaymentMethods() async {
    _paymentMethods = await DatabaseHelper.instance.getPaymentMethods();
    notifyListeners();
  }

  Future<void> addPaymentMethod(String name, String icon) async {
    final method = PaymentMethodModel(name: name, icon: icon);
    await DatabaseHelper.instance.insertPaymentMethod(method);
    await fetchPaymentMethods();
  }

  Future<void> updatePaymentMethod(PaymentMethodModel method) async {
    await DatabaseHelper.instance.updatePaymentMethod(method);
    await fetchPaymentMethods();
  }

  Future<void> deletePaymentMethod(int id) async {
    await DatabaseHelper.instance.deletePaymentMethod(id);
    await fetchPaymentMethods();
  }
}