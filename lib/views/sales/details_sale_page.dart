import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
class SaleDetailPage extends StatelessWidget {
  final Map<String, dynamic> sale;

  SaleDetailPage({Key? key, required this.sale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextStyle sectionTitleStyle = TextStyle(
      color: Colors.grey[300],
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );

    // Extracción de datos
    final imei = sale['productId'] ?? '';
    final customer = sale['customer'] ?? {};
    final payments = List.from(sale['payments'] ?? []);
    final String pdfUrl = sale['urlFiles'] ?? '';
    final double latitude = customer['latitude'] ?? 0.0;
    final double longitude = customer['longitude'] ?? 0.0;
    final DateTime date = DateTime.now(); // Placeholder, ajustar según datos.

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de la Venta', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      backgroundColor: Colors.grey[900],
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          _buildSectionCard(
            title: 'Fecha de Venta',
            contentWidget: Text(DateFormat('yyyy-MM-dd').format(date), style: TextStyle(color: Colors.grey[300])),
            icon: Icons.calendar_today,
            style: sectionTitleStyle,
          ),
          if (imei.isNotEmpty)
            _buildSectionCard(
              title: 'IMEI del Producto',
              contentWidget: Text(imei, style: TextStyle(color: Colors.grey[300])),
              icon: Icons.phonelink_setup,
              style: sectionTitleStyle,
            ),
          _buildCustomerInfoSection(customer,style: sectionTitleStyle),          _buildActionButton(
            context: context,
            buttonLabel: 'Descargar PDF',
            icon: Icons.picture_as_pdf,
            onPressed: () => _openPdf(context, pdfUrl),
          ),
          _buildPaymentsSection(payments, sectionTitleStyle),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget contentWidget,
    required IconData icon,
    required TextStyle style,
  }) {
    return Card(
      color: Colors.grey[800],
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: style),
            ListTile(
              leading: Icon(icon, color: Colors.white70),
              title: contentWidget,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerInfoSection(Map<String, dynamic> customer, {required TextStyle style}) {
    return Card(
      color: Colors.grey[800],
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Información del Cliente', style: style),
            _customerInfoTile('Nombre', customer['name'] ?? 'No disponible', Icons.person),
            _customerInfoTile('Teléfono', customer['phone'] ?? 'No disponible', Icons.phone),
            _customerInfoTile('Correo Electrónico', customer['email'] ?? 'No disponible', Icons.email),
            _customerInfoTile('CURP', customer['curp'] ?? 'No disponible', Icons.credit_card),
            _customerInfoTile('Dirección', customer['address'] ?? 'No disponible', Icons.location_on),
          ],
        ),
      ),
    );
  }

  ListTile _customerInfoTile(String title, String data, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(title, style: TextStyle(color: Colors.white70)),
      subtitle: Text(data, style: TextStyle(color: Colors.grey[300])),
      onTap: onTap, // Se añade la acción onTap aquí
    );
  }



  Widget _buildActionButton({
    required BuildContext context,
    required String buttonLabel,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(buttonLabel),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white, backgroundColor: Colors.blueGrey,
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPaymentsSection(List payments, TextStyle style) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Detalles de Pagos', style: TextStyle(color: Colors.black54, fontSize: 20, fontWeight: FontWeight.bold)), // Ajustar estilo ),
            ...payments.map((payment) {
              return ListTile(
                leading: Icon(Icons.payment, color: Colors.black54),
                title: Text('Fecha: ${DateFormat('yyyy-MM-dd').format(DateTime.now())}'), // Ajustar fecha
                subtitle: Text('Monto: \$${payment['amount']}\nDescripción: ${payment['description']}'),
                //agregar un divider

              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _openMap(BuildContext context, double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo abrir el mapa para la dirección')));
    }
  }

  void _openPdf(BuildContext context, String pdfUrl) async {
    // Aquí iría la lógica para abrir o descargar el PDF, similar a la proporcionada anteriormente
  }

// Considera reutilizar la función downloadPdfFile aquí si es necesario
}
