import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String saleId;
  final double amount;
  final double amountCommission;
  final String commissionStatus;
  final DateTime date;  // Add a DateTime field to hold the payment date

  Payment({
    required this.saleId,
    required this.amount,
    required this.amountCommission,
    required this.commissionStatus,
    required this.date,  // Ensure to require the date in the constructor
  });

  factory Payment.fromMap(Map<String, dynamic> map) {
    // You need to parse the date from the map
    final paymentDate = map['date'] is Timestamp ? (map['date'] as Timestamp).toDate() : DateTime.now();
    return Payment(
      saleId: map['saleId'] ?? 'n/a',
      amount: map['amount']?.toDouble() ?? 0.0,
      amountCommission: map['amountCommission']?.toDouble() ?? 0.0,
      commissionStatus: map['commissionStatus'] ?? '',
      date: paymentDate,  // Parse and set the date
    );
  }
}