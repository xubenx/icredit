import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/product.dart';

class ProductService {
  final CollectionReference _productsRef = FirebaseFirestore.instance.collection('products');
  final DocumentReference _counterRef = FirebaseFirestore.instance.collection('counters').doc('productCounter');

  Future<void> addProduct(Product product) async {
    await _productsRef.doc(product.imei).set(product.toFirestore());

  }
  //update status product
  Future<void> updateStatusProduct(String imei, ProductStatus status) async {
    await _productsRef.doc(imei).update({'status': status.toString().split('.').last});
  }

  Future<void> updateProduct(Product product) async {
    await _productsRef.doc(product.imei).update(product.toFirestore());
  }

  Stream<List<Product>> getProducts() {
    return _productsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Product.fromFirestore(doc);
      }).toList();
    });
  }


}
