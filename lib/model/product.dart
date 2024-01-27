// lib/model/product.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductStatus { inStock, onSale, inactive }

class Product {
  String? id;
  String? name;
  double? sellPrice;
  double? buyPrice;
  String? imei;
  Map<String, dynamic>? details;
  ProductStatus? status;

  Product({
    this.id,
    this.name,
    this.sellPrice,
    this.buyPrice,
    this.status = ProductStatus.inStock,
    this.imei,
    this.details,
  });

  // Method to convert a Product instance into a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'sellPrice': sellPrice,
      'buyPrice': buyPrice,
      'imei': imei,
      'details': details,
    };
  }

  // Factory constructor to create a Product instance from a Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'],
      sellPrice: data['sellPrice'],
      buyPrice: data['buyPrice'],
      imei: data['imei'],
      details: data['details'],
    );
  }
}
// lib/model/product.dart