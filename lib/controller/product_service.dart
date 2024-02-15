import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/product.dart';

class ProductService {
  final CollectionReference _productsRef = FirebaseFirestore.instance.collection('products');
  final DocumentReference _counterRef = FirebaseFirestore.instance.collection('counters').doc('productCounter');

  Future<void> addProduct(String name, double sellPrice, double buyPrice, String imei, Map<String, dynamic> details, double buyPriceCredit, double hookPrice) async {
    try {
      // Incrementa el contador de productos y obtén el próximo ID disponible
      final nextId = await _incrementProductCounter();

      // Verifica el formato del IMEI usando regex (ejemplo ilustrativo)
      if (!_validateIMEI(imei)) {
        throw Exception("IMEI format is invalid");
      }

      // Usa el IMEI como ID del documento para el nuevo producto
      await _productsRef.doc(imei).set({
        'sequentialId': nextId, // ID secuencial como campo adicional
        'status': 'active',
        'name': name,
        'sellPrice': sellPrice,
        'buyPrice': buyPrice,
        'imei': imei, // Este ya es el ID del documento, pero lo mantenemos para facilidad de acceso
        'details': details,
        'buyPriceCredit': buyPriceCredit,
        'hookPrice': hookPrice,
      });
    } catch (e) {
      print('Failed to add product: $e');
    }
  }

  Future<int> _incrementProductCounter() async {
    // Transacción para incrementar el contador de manera segura
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(_counterRef);
      if (!snapshot.exists) {
        await _counterRef.set({'count': 1}); // Inicializa el contador si no existe
        return 1;
      }
      // Realiza un casting explícito de los datos a Map<String, dynamic>
      Map<String, dynamic> data = snapshot.data()! as Map<String, dynamic>;
      int currentCount = data['count'];
      transaction.update(_counterRef, {'count': currentCount + 1});
      return currentCount + 1;
    });
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

  bool _validateIMEI(String imei) {
    // Ejemplo de expresión regular para validar el IMEI
    // Ajusta según los requisitos específicos de formato de IMEI que necesites
    RegExp regex = RegExp(r'^[0-9]{15}$');
    return regex.hasMatch(imei);
  }
}
