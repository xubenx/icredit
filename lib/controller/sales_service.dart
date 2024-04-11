import 'dart:html' as html;
import 'dart:typed_data';
import 'package:icredit/model/Payment.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:icredit/controller/product_service.dart';
import 'package:icredit/model/product.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';

class SalesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //obtener producto por id
  Future<Map<String, dynamic>?> getDetailsById(
      String collectionPath, String documentId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection(collectionPath).doc(documentId).get();
      if (!documentSnapshot.exists) {
        print('Error de la base de datos');
        return null;
      }
      // Use the `.data()` method and cast the result as Map<String, dynamic>.
      return documentSnapshot.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error al buscar: $e');
      return null;
    }
  }

  Future<void> generateAndDownloadTicket({
    required String saleId,
    required Map<String, dynamic> saleData,
  }) async {
    final sellerSnapshot =
        await _firestore.collection('sellers').doc(saleData['sellerId']).get();
    final productSnapshot = await _firestore
        .collection('products')
        .doc(saleData['productId'])
        .get();

    if (!sellerSnapshot.exists || !productSnapshot.exists) {
      // Handle the case when either document does not exist.
      print('One of the documents does not exist');
      return;
    }

    final sellerData = sellerSnapshot.data();
    final productData = productSnapshot.data();

    if (sellerData == null || productData == null) {
      // Handle the case when data is null.
      print('One of the document snapshots returned null data');
      return;
    }
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          58 * PdfPageFormat.mm, // Ancho del ticket
          300, // Altura estimada, ajustable según el contenido
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('iCredit',
                  style: pw.TextStyle(
                      font: pw.Font.helvetica(),
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 24)),

              pw.Text('Ticket de Venta',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('ID Venta: $saleId'),
              pw.Text('IMEI: ${productData?['imei']}'),
              pw.Text('Vendedor: ${sellerData?['name']}'),
              pw.Text('Cliente: ${saleData['customer']['name']}'),
              pw.Text('Teléfono: ${saleData['customer']['phone']}'),
              pw.Text('Dirección: ${saleData['customer']['address']}'),
              pw.Text('Fecha: ${saleData['date']}'),
              pw.Text('Pagos:'),
              for (var payment in saleData['payments'])
                pw.Text('${payment['method']}: \$${payment['amount']}'),
              // Incluye todos los datos adicionales que necesites
              // Agrega aquí más detalles del ticket
              pw.Text(
                  'Producto: ${productData?['name']} + ${productData?['details']['model']}+ ${productData?['details']['color']} + ${productData?['details']['storage']} GB'),
              pw.Text('Total: \$${saleData['totalAmount']}'),
              // Incluye todos los datos adicionales que necesites
            ],
          );
        },
      ),
    );
  }

  Future<void> generateAndDownloadCashTicket({
    required String saleId,
    required Map<String, dynamic> saleData,
  }) async {
    final sellerSnapshot =
        await _firestore.collection('sellers').doc(saleData['sellerId']).get();
    final productSnapshot = await _firestore
        .collection('products')
        .doc(saleData['productId'])
        .get();

    if (!sellerSnapshot.exists || !productSnapshot.exists) {
      // Handle the case when either document does not exist.
      print('One of the documents does not exist');
      return;
    }

    final sellerData = sellerSnapshot.data();
    final productData = productSnapshot.data();

    if (sellerData == null || productData == null) {
      // Handle the case when data is null.
      print('One of the document snapshots returned null data');
      return;
    }

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          58 * PdfPageFormat.mm, // Ancho del ticket
          300, // Altura estimada, ajustable según el contenido
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('iCredit',
                  style: pw.TextStyle(
                      font: pw.Font.helvetica(),
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 24)),

              pw.Text('Ticket de Venta',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('ID Venta: $saleId'),
              pw.Text('Vendedor: ${sellerData?['name']}'),
              pw.Text('Teléfono: ${saleData['customer']['phone']}'),

              // Agrega aquí más detalles del ticket
              pw.Text(
                  'Producto: ${productData?['name']} + ${productData?['details']['model']}+ ${productData?['details']['color']} + ${productData?['details']['storage']} GB'),
              pw.Text('Fecha: ${saleData['date']}'),
              pw.Text('Total: \$${saleData['totalAmount']}'),
              // Incluye todos los datos adicionales que necesites
            ],
          );
        },
      ),
    );

    // Guardar el PDF en un Uint8List
    final bytes = await pdf.save();

    // Crear un enlace de descarga y activarlo
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "ticket-$saleId.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Future<DocumentSnapshot?> getProductById(String documentId) async {
    try {
      DocumentSnapshot documentSnapshot =
          await _firestore.collection('products').doc(documentId).get();

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

  Future<String> saveCashSale({
    required String sellerId,
    required String productImei,
    String? phoneNumber,
    required List<Map<Object, dynamic>> payments,
    required DateTime date,
    required Map<Object, dynamic> customerData,

    // Puedes agregar más parámetros si son necesarios
  }) async {
    // Contar los documentos existentes en la colección 'sales'.
    final querySnapshot = await _firestore.collection('sales').get();
    int nextSaleId = querySnapshot.docs.length + 1;

    // Crear el documento de venta con el ID basado en el conteo.
    final sale = {
      'id': nextSaleId,
      'sellerId': sellerId,
      'productId': productImei,
      'customer': {
        'phone': phoneNumber ?? 'N/A', // Si no se provee un número, usar 'N/A'
      },
      'date': date,
      'status': 'cashSold',
      'payments': payments,
    };

    // Guardar la nueva venta en Firestore.
    DocumentReference documentReference =
        await _firestore.collection('sales').add(sale);
    if (documentReference.id != null) {
      ProductService productService = ProductService();
      await productService.updateStatusProduct(productImei, ProductStatus.sold);

      return documentReference
          .id; // Return the ID of the newly created sale document.
    } else {
      return 'Hubo un error al guardar la venta. Inténtalo de nuevo.';
    }
  }

  final FirebaseFirestore _firestores = FirebaseFirestore.instance;

  Stream<List<Payment>> getPaymentsForSeller(String sellerId) {
    return _firestores
        .collection('sales')
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      List<Payment> payments = [];
      for (var doc in snapshot.docs) {
        var saleData = doc.data();
        // Here we're expecting 'id' to be an integer.
        var id = saleData['id']?.toString() ?? 'N/A';
        List<dynamic> paymentsList = saleData['payments'] ?? [];
        for (var paymentMap in paymentsList) {
          payments.add(Payment.fromMap({
            ...paymentMap, // This contains 'amount', 'amountCommission', etc.
            'saleId': id,
            // Add 'saleId' from the sale document.
          }));
        }
      }
      return payments;
    });
  }
  Future<void> updatePaymentStatus(String saleId, int paymentIndex, String newStatus) async {
    try {
      // Get the document reference for the sale
      DocumentReference saleRef = _firestore.collection('sales').doc(saleId);

      // Fetch the current sale data
      DocumentSnapshot saleSnapshot = await saleRef.get();
      if (!saleSnapshot.exists) {
        throw Exception('Sale not found.');
      }
      var saleData = saleSnapshot.data() as Map<String, dynamic>;

      // Update the payment status within the payments list
      List<dynamic> paymentsList = saleData['payments'] as List<dynamic>;
      if (paymentsList.length > paymentIndex) {
        paymentsList[paymentIndex]['commissionStatus'] = newStatus;
      } else {
        throw Exception('Payment not found.');
      }

      // Update the sale document with the new payments list
      await saleRef.update({'payments': paymentsList});

      print('Payment status updated to $newStatus for payment index $paymentIndex in sale $saleId');
    } catch (e) {
      print('Failed to update payment status: $e');
  }
  }

  // ... your existing methods ...
  Future<void> updateCommissionStatus(String saleId, int paymentIndex, String newStatus) async {
    DocumentReference saleRef = _firestore.collection('sales').doc(saleId);
    print(saleId);
    print(paymentIndex);
    print(newStatus);
    try {
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot saleSnapshot = await transaction.get(saleRef);
        if (saleSnapshot.exists && saleSnapshot.data() != null) {
          var saleData = saleSnapshot.data() as Map<String, dynamic>;
          List<dynamic> payments = saleData['payments'];
          if (payments.length > paymentIndex && payments[paymentIndex] != null) {
            payments[paymentIndex]['commissionStatus'] = newStatus;
            transaction.update(saleRef, {'payments': payments});
          } else {
            throw Exception("Índice de pago no válido!");
          }
        } else {
          throw Exception("Documento no existe!");
        }
      });
    } catch (e, stack) {
      print('Error al actualizar el estado de la comisión: $e');
      print('Stack trace: $stack');
      rethrow; // Relanzamos para poder capturar fuera del método si es necesario.
    }
  }


  Future<String> saveSale({
    required String sellerId,
    required String productImei,
    required Map<Object, dynamic> customerData,
    required List<Map<Object, dynamic>> payments,
    required double tax,
    required double debtCreditAmount,
    required double debtAmount,
    required DateTime date,
    required String urlFiles,
    required String status,
    required double minPayment,
    required bool firstPayment,
    required DateTime firstPaymentDate,
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
      'tax': tax,
      'minPayment': minPayment,
      'debtAmount': debtAmount,
      'debtCreditAmount': debtCreditAmount,
      'date': DateTime.now(),
      'payments': payments,
      'urlFiles': urlFiles,
      'status': status,
      'firstPayment': firstPayment,
      'firstPaymentDate': firstPaymentDate,
    };

    // Guardar la nueva venta en Firestore.
    DocumentReference documentReference =
        await _firestore.collection('sales').add(sale);
    if (documentReference.id != null) {
      ProductService productService = ProductService();
      await productService.updateStatusProduct(
          productImei, ProductStatus.inCredit);

      return documentReference
          .id; // Return the ID of the newly created sale document.
    } else {
      return 'Hubo un error al guardar la venta. Inténtalo de nuevo.';
    }
  }

  Future<int> countSales() async {
    final querySnapshot = await _firestore.collection('sales').get();
    return querySnapshot.docs.length;
  }
// Add more methods as needed for your sales process
}
