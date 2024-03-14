import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icredit/controller/product_service.dart';
import 'package:icredit/views/add_product_page.dart';
import 'package:icredit/model/product.dart'; // Asegúrate de que este import es correcto

class ProductPageView extends StatefulWidget {
  ProductPageView({Key? key}) : super(key: key);

  @override
  State<ProductPageView> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPageView> {
  List<Product> productList = []; // Lista para almacenar los productos

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    ProductService().getProducts().listen((productData) {
      setState(() {
        productList = productData;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Productos'),
      ),
      body: ListView.builder(
        itemCount: productList.length,
        itemBuilder: (context, index) {
          final product = productList[index];

          String imei = product.imei ?? 'IMEI no disponible';
          String status = _formatStatus(product.status?? ProductStatus.inactive);

          return ListTile(
            title: Text(imei),
            subtitle: Text(status),
            // Puedes agregar onTap si necesitas hacer algo al tocar la lista
            onTap: () {
              // Por ejemplo, podrías querer navegar a la página de detalles del producto
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Navegar a la página de agregar producto
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String _formatStatus(ProductStatus status) {
    switch (status) {
      case ProductStatus.inStock:
        return 'En stock';
      case ProductStatus.inCredit:
        return 'En crédito';
      case ProductStatus.inactive:
        return 'Inactivo';
      case ProductStatus.sold:
        return 'Vendido';
      default:
        return 'Desconocido';
    }
  }
}
