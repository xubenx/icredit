    // lib/model/product.dart
    import 'package:cloud_firestore/cloud_firestore.dart';

    enum ProductStatus { inStock, inCredit, inactive, sold }

    class Product {
      String? id;
      String? name;
      double? buyPrice;
      double? sellingPrice;
      String? imei;
      double? sellingPriceCredit;
      Map<String, dynamic>? details;
      ProductStatus? status;
      double? hookPrice;
      double? miniumMount;

      Product({
        this.id,
        this.name,
        this.buyPrice,
        this.sellingPrice,
        this.status = ProductStatus.inStock,
        this.imei,
        this.details,
        this.sellingPriceCredit,
        this.hookPrice,
        this.miniumMount,

      });

      // Method to convert a Product instance into a Firestore documenta
      Map<String, dynamic> toFirestore() {
        return {
          'name': name,
          'buyPrice': buyPrice,
          'sellingPrice': sellingPrice,
          'imei': imei,
          'sellingPriceCredit': sellingPriceCredit,
          'details': details,
          'hookPrice': hookPrice,
          'status': status.toString().split('.').last,
          'miniumMount': miniumMount,
        };
      }
      Product copyWith({
        String? id,
        String? name,
        double? buyPrice,
        double? sellingPrice,
        String? imei,
        Map<String, dynamic>? details,
        double? sellingPriceCredit,
        double? hookPrice,
        ProductStatus? status,
        double? miniumMount,
      }) {
        return Product(
          id: id ?? this.id,
          name: name ?? this.name,
          buyPrice:buyPrice ?? this.buyPrice,
          sellingPrice: sellingPrice ?? this.sellingPrice,
          imei: imei ?? this.imei,
          details: details ?? this.details,
          sellingPriceCredit: sellingPriceCredit ?? this.sellingPriceCredit,
          hookPrice: hookPrice ?? this.hookPrice,
          status: status ?? this.status,
          miniumMount: miniumMount ?? this.miniumMount,
        );
      }

      // Factory constructor to create a Product instance from a Firestore document

      factory Product.fromFirestore(DocumentSnapshot doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Product(
          id: doc.id,
          name: data['name'],
          buyPrice: data['buyPrice']?.toDouble(),
          sellingPrice: data['sellingPrice']?.toDouble(),
          sellingPriceCredit: data['sellingPriceCredit']?.toDouble(),
          imei: data['imei'],
          hookPrice: data['hookPrice']?.toDouble(),
          details: data['details'],
          status: _stringToProductStatus(data['status']),
          miniumMount: data['miniumMount']?.toDouble(),
        );
      }

      static ProductStatus _stringToProductStatus(String? statusAsString) {
        if (statusAsString == null) {
          return ProductStatus.inactive; // O un valor por defecto que prefieras
        }
        return ProductStatus.values.firstWhere(
              (status) => status.toString().split('.').last == statusAsString,
          orElse: () => ProductStatus.inactive, // Valor por defecto en caso de no encontrar coincidencia
        );
      }
    }
    // lib/model/product.dart