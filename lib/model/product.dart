  // lib/model/product.dart
  import 'package:cloud_firestore/cloud_firestore.dart';

  enum ProductStatus { inStock, onSale, inactive }

  class Product {
    String? id;
    String? name;
    double? sellPrice;
    double? buyPrice;
    String? imei;
    double? buyPriceCredit;
    Map<String, dynamic>? details;
    ProductStatus? status;
    double? hookPrice;

    Product({
      this.id,
      this.name,
      this.sellPrice,
      this.buyPrice,
      this.status = ProductStatus.inStock,
      this.imei,
      this.details,
      this.buyPriceCredit,
      this.hookPrice,
    });

    // Method to convert a Product instance into a Firestore documenta
    Map<String, dynamic> toFirestore() {
      return {
        'name': name,
        'sellPrice': sellPrice,
        'buyPrice': buyPrice,
        'imei': imei,
        'buyPriceCredit': buyPriceCredit,
        'details': details,
        'hookPrice': hookPrice,
      };
    }
    Product copyWith({
      String? id,
      String? name,
      double? sellPrice,
      double? buyPrice,
      String? imei,
      Map<String, dynamic>? details,
      double? buyPriceCredit,
      double? hookPrice,
    }) {
      return Product(
        id: id ?? this.id,
        name: name ?? this.name,
        sellPrice: sellPrice ?? this.sellPrice,
        buyPrice: buyPrice ?? this.buyPrice,
        imei: imei ?? this.imei,
        details: details ?? this.details,
        buyPriceCredit: buyPriceCredit ?? this.buyPriceCredit,
        hookPrice: hookPrice ?? this.hookPrice,
      );
    }

    // Factory constructor to create a Product instance from a Firestore document
    factory Product.fromFirestore(DocumentSnapshot doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Product(
        id: doc.id,
        name: data['name'],
        sellPrice: data['sellPrice'],
        buyPrice: data['buyPrice'],
        buyPriceCredit: data['buyPriceCredit'],
        imei: data['imei'],
        hookPrice: data['hookPrice'],
        details: data['details'],
      );
    }
  }
  // lib/model/product.dart