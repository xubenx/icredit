import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SaleDetailPage extends StatelessWidget {
  final Map<String, dynamic> sale;

  SaleDetailPage({Key? key, required this.sale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Asume que estos campos existen en el objeto sale
    final customer = sale['customer'] ?? {};
    final payments = List.from(sale['payments'] ?? []);
    final String urlFiles = sale['urlFiles'] ?? '';
    final double latitude = customer['latitude'];
    final double longitude = customer['longitude'];
    final String address = customer['address'] ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de la Venta'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text('Cliente'),
            subtitle: Text(customer['name'] ?? 'No disponible'),
          ),
          ListTile(
            title: Text('Teléfono'),
            subtitle: Text(customer['phone'] ?? 'No disponible'),
          ),
          ListTile(
            title: Text('Correo Electrónico'),
            subtitle: Text(customer['email'] ?? 'No disponible'),
          ),
          ListTile(
            title: Text('CURP'),
            subtitle: Text(customer['curp'] ?? 'No disponible'),
          ),
          ListTile(
            title: Text('Dirección'),
            subtitle: Text(address),
            onTap: () {
              _openMap(latitude, longitude);
            },
          ),
          ElevatedButton(
            onPressed: () {
              _openPdf(urlFiles);
            },
            child: Text('Ver Documento PDF'),
          ),
          Text('Pagos', style: Theme.of(context).textTheme.headline6),
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

  void _openPdf(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'No se pudo abrir $url';
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
}
