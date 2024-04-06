import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class DebtSaleDetailPage extends StatelessWidget {
  final Map<String, dynamic> sale;

  DebtSaleDetailPage({Key? key, required this.sale}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    print(sale);
    final imei = sale['productId']?? '';
    final customer = sale['customer'] ?? {};
    final payments = List.from(sale['payments'] ?? []);
    final String urlFiles = sale['urlFiles'] ?? '';
    final double latitude = customer['latitude'];
    final double longitude = customer['longitude'];
    final String address = customer['address'] ?? '';
    final String pdfUrl = urlFiles;
    final DateTime date = sale['date'].toDate();
    final String fileName = '$urlFiles.pdf';
    final String status = sale['status'];


    print(payments);
    if(status == 'cashSold'){
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalle de la Venta'),
        ),
        body: Center(
          child: ListView(
            padding: const EdgeInsets.all(8.0),
            children: <Widget>[
              Center(child: Text('Fecha', style: Theme.of(context).textTheme.headline6)),
              _customerInfoTile('Fecha', DateFormat('yyyy-MM-dd').format(date)),
              Divider(),
              Center(child: Text('IMEI', style: Theme.of(context).textTheme.headline6)),
              _customerInfoTile('IMEI', imei),
              Divider(),
              Center(child: Text('Pagos', style: Theme.of(context).textTheme.headline6)),
              Column(
                children: payments.map((payment) {
                  return ListTile(
                    title: Text('Monto: ${DateFormat('yyyy-MM-dd').format(payment['date'].toDate())}'),
                    subtitle: Text('Descripción: ${payment['description']}'),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }else{
      return Scaffold(
        appBar: AppBar(
          title: Text('Detalle de la Venta'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(8.0),
          children: <Widget>[
            Center(child: Text('Fecha', style: Theme.of(context).textTheme.headline6)),
            _customerInfoTile('Fecha', DateFormat('yyyy-MM-dd').format(date)),
            Divider(),
            Center(child: Text('Cliente', style: Theme.of(context).textTheme.headline6)),
            _customerInfoTile('Nombre', customer['name'] ?? 'No disponible'),
            _customerInfoTile('Teléfono', customer['phone'] ?? 'No disponible'),
            _customerInfoTile('Correo Electrónico', customer['email'] ?? 'No disponible'),
            _customerInfoTile('CURP', customer['curp'] ?? 'No disponible'),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Dirección'),
              subtitle: Text(address),
              onTap: () => _openMap(latitude, longitude),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.file_download),
                label: Text('Descargar PDF'),
                onPressed: () => _openPdf(context, pdfUrl),
              ),
            ),
            Divider(),
            Center(child: Text('Pagos', style: Theme.of(context).textTheme.headline6)),
            Column(
              children: payments.map((payment) {
                return ListTile(
                  title: Text('Fecha: ${DateFormat('yyyy-MM-dd').format(payment['date'].toDate())}'),
                  subtitle: Text('Monto: \$${payment['amount']}'),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }



  }

  ListTile _customerInfoTile(String title, String subtitle) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
  void _openPdf(context,String pdfUrl) async {
// Descarga el PDF y muéstralo
    final url = pdfUrl;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo descargar el pdf: $url';
    }
  }

  void _openMap(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir el mapa para la dirección: $url';
    }
  }

  Future<File?> downloadPdfFile(String url, String fileName) async {
    try {
      final File file = File('./$fileName');

      // Crea una referencia de Firebase Storage desde la URL
      final ref = FirebaseStorage.instance.refFromURL(url);

      // Descarga el archivo
      final bytes = await ref.getData();
      if (bytes != null) {
        await file.writeAsBytes(bytes);
        print('PDF descargado: ${file.path}');
        return file;
      }
    } catch (e) {
      print('Error al descargar el PDF: $e');
      return null;
    }
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
      case 'cashSold':
        return 'Vendido en efectivo';
      default:
        return 'Desconocido';
    }
  }
  void _showLoadingDialog(context)  {
    showDialog(
      context: context,
      barrierDismissible: false, // El usuario no puede cerrar el diálogo tocando fuera de él
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Procesando..."),
              ],
            ),
          ),
        );
      },
    );
  }
}
class PdfViewerPage extends StatelessWidget {
  final File pdfFile;

  PdfViewerPage({required this.pdfFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
      ),
      body: PDFView(
        filePath: pdfFile.path,
      ),
    );
  }
}
