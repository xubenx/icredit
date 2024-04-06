import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icredit/views/sales/details_sale_page.dart';

// Función para buscar la venta por número de teléfono
Future<Map<String, dynamic>?> fetchSaleByPhoneNumber(String phoneNumber) async {
  // Referencia a la colección de ventas
  final salesCollection = FirebaseFirestore.instance.collection('sales');

  try {
    // Busca el documento de la venta donde el campo 'phone' coincida con el phoneNumber
    final querySnapshot = await salesCollection
        .where('customer.phone', isEqualTo: phoneNumber)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Devuelve el primer documento de venta encontrado
      return querySnapshot.docs.first.data();
    }
    return null; // Si no se encontró ningún documento
  } catch (e) {
    print('Error al obtener la venta: $e');
    return null;
  }
}

// En algún lugar de tu código, llama a la función y navega a la página de detalles con los datos de la venta
void navigateToSaleDetailPage(BuildContext context, String phoneNumber) async {
  final saleData = await fetchSaleByPhoneNumber(phoneNumber);
  if (saleData != null) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaleDetailPage(sale: saleData),
      ),
    );
  } else {
    // Manejar el caso donde la venta no se encontró
    print('Venta no encontrada para el número de teléfono: $phoneNumber');
  }
}
