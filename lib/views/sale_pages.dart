

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icredit/views/details_sale_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:icredit/views/add_credit_sale_page.dart';

class SalesPageView extends StatefulWidget {
  final String id;
  final String role;

  SalesPageView({Key? key, required this.id, required this.role}) : super(key: key);

  @override
  State<SalesPageView> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPageView> {
  List<Map<String, dynamic>> salesList = []; // Lista para almacenar las ventas

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  void _loadSales() async {
    QuerySnapshot salesSnapshot;
    if (widget.role == 'admin') {
      salesSnapshot = await FirebaseFirestore.instance.collection('sales').get();
    } else {
      salesSnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('sellerId', isEqualTo: widget.id)
          .get();
    }

    final sales = salesSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    setState(() {
      salesList = sales;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Ventas'),
      ),
      body: ListView.builder(
        itemCount: salesList.length,
        itemBuilder: (context, index) {
          final sale = salesList[index];
          // Supongamos que 'productId' es el imei y 'status' es un campo en tu objeto de venta
          String imei = sale['productId'] ?? 'IMEI no disponible';
          String status = _formatStatus(sale['status']);
          String urlFiles = sale['urlFiles'] ?? '';

          return ListTile(
            title: Text(imei),
            subtitle: Text(status),
            onTap: () => _navigateToSaleDetail(sale),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          MaterialPageRoute route = MaterialPageRoute(
            builder: (context) => SalesPage(id: widget.id, role: widget.role,),
          );
          // Lógica para navegar a la página de agregar venta
        },
        child: Icon(Icons.add),
      ),
    );
  }
  void _navigateToSaleDetail(Map<String, dynamic> sale) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SaleDetailPage(sale: sale),
      ),
    );
  }

  String _formatStatus(dynamic status) {
    switch (status) {
      case 'inStock':
        return 'En stock';
      case 'inCredit':
        return 'En crédito';
      case 'inactive':
        return 'Inactivo';
      case 'sold':
        return 'Vendido';
      default:
        return 'Desconocido';
    }
  }
}
