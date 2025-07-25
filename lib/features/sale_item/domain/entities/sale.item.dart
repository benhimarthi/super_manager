import 'package:equatable/equatable.dart';

class SaleItem extends Equatable {
  final String id;
  final String saleId;
  final String productId;
  final int quantity;
  final double unitPrice; // Price at the time of sale
  final double totalPrice; // quantity * unitPrice
  final double taxAmount;
  final double discountApplied; // Optional per item

  const SaleItem({
    required this.id,
    required this.saleId,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.taxAmount,
    required this.discountApplied,
  });

  @override
  List<Object?> get props => [
        id,
        saleId,
        productId,
        quantity,
        unitPrice,
        totalPrice,
        taxAmount,
        discountApplied,
      ];
}
