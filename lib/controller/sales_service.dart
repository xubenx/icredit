import 'dart:html';
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:icredit/controller/product_service.dart';
import 'package:icredit/model/product.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> getProductById(String documentId) async {
    try {
      DocumentSnapshot documentSnapshot = await _firestore
          .collection('products')
          .doc(documentId)
          .get();

      // Verificar si el documento existe
      if (!documentSnapshot.exists) {
        print('Error: el producto no existe en la base de datos');
        return null;
      }

      return documentSnapshot;
    } catch (e) {
      print('Error al buscar el producto: $e');
      return null;
    }
  }

  Future<String> saveSale({
    required String sellerId,
    required String productImei,
    required Map<Object, dynamic> customerData,
    required List<Map<Object, dynamic>> payments,
    required double finalDebtAmount,
    required double debtCreditAmount,
    required double debtAmount,
    required DateTime date,
    required String urlFiles,
    required String status,

  }) async {
    // Contar los documentos existentes en la colección 'sales'.
    final querySnapshot = await _firestore.collection('sales').get();
    int nextSaleId = querySnapshot.docs.length + 1;
    print("nextSaleId: $nextSaleId");

    // Crear el documento de venta con el ID basado en el conteo.
    final sale = {
      'id': nextSaleId,
      'sellerId': sellerId,
      'productId': productImei,
      'customer': customerData,
      'finalDebtAmount': finalDebtAmount,
      'debtAmount': debtAmount,
      'debtCreditAmount': debtCreditAmount,
      'date': DateTime.now(),
      'payments': payments,
      'urlFiles': urlFiles,
      'status': status,
    };

    // Guardar la nueva venta en Firestore.
    DocumentReference documentReference = await _firestore.collection('sales')
        .add(sale);
    if (documentReference.id != null) {




      ProductService productService = ProductService();
      await productService.updateStatusProduct(productImei, ProductStatus.inCredit);
      return documentReference.id; // Devuelve el ID del documento crea do.

    } else {
      return 'Hubo un error al guardar la venta. Inténtalo de nuevo.';
    }
  }
//metodo para contar los documentos existentes en la seccion sales y que me regrese un entero
  Future<int> countSales() async {
    final querySnapshot = await _firestore.collection('sales').get();
    return querySnapshot.docs.length;
  }


// Add more methods as needed for your sales process
}
