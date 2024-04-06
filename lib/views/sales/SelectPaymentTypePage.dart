import 'package:flutter/material.dart';

import 'package:icredit/views/sales/add_cash_page.dart';
import 'package:icredit/views/sales/add_credit_sale_page.dart';

class SelectPaymentTypePage extends StatelessWidget {
  final String id;
  final String role;

  SelectPaymentTypePage({Key? key, required this.id, required this.role}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleccionar Tipo de Pago'),
      ),
      body: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          // Define el color primario de la aplicación
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.black,
            secondary: Colors.grey,
            background: Colors.white,
          ),
        ),
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCashPage(id: id, role: role),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: TextStyle(fontSize: 30),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.money, size: 200),
                      Text('Efectivo'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SalesPage(id: id, role: role),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    textStyle: TextStyle(fontSize: 30),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.credit_card, size: 200),
                      Text('Crédito'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}