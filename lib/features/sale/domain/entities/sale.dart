import 'package:equatable/equatable.dart';

class Sale extends Equatable {
  final String id;
  final String? customerId; // Nullable for guest customers
  final DateTime date;
  final String status; // e.g., "pending", "paid", "shipped", "cancelled"
  final double totalAmount;
  final double totalTax;
  final double discountAmount;
  final String paymentMethod; // e.g., "cash", "credit card", "mobile"
  final String currency; // For multi-country apps
  final String? notes; // Optional comment
  final DateTime createdAt;
  final DateTime updatedAt;
  final String adminId;

  const Sale({
    required this.id,
    this.customerId,
    required this.date,
    required this.status,
    required this.totalAmount,
    required this.totalTax,
    required this.discountAmount,
    required this.paymentMethod,
    required this.currency,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.adminId,
  });

  @override
  List<Object?> get props => [
    id,
    customerId,
    date,
    status,
    totalAmount,
    totalTax,
    discountAmount,
    paymentMethod,
    currency,
    notes,
    createdAt,
    updatedAt,
  ];
}
