// lib/controller/product_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/product.dart';

class ProductService {
  final CollectionReference _productsRef =
  FirebaseFirestore.instance.collection('products');

  Future<void> addProduct(String name, double sellPrice, double buyPrice,
      String imei, Map<String, dynamic> details) async {
    try {
      await _productsRef.add({
        'status': ProductStatus.inStock.toString().split('.').last,
        'name': name,
        'sellPrice': sellPrice,
        'buyPrice': buyPrice,
        'imei': imei,
        'details': details,
      });
    } catch (e) {
      print('Failed to add product: $e');
      // You can also show a user-friendly error message using a dialog or a snackbar
    }
  }
  Future<void> updateProduct(Product product) async {
    await _productsRef.doc(product.id).update(product.toFirestore());
  }

  Stream<List<Product>> getProducts() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();
    });
  }
}
// lib/controller/product_service.dart