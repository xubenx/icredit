import 'package:flutter/material.dart';
import 'package:icredit/views/sellers_pages.dart';
/// Flutter code sample for [Menu].
import 'package:firebase_core/firebase_core.dart';
import 'package:icredit/views/customer_pages.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MenuApp());
}

class MenuApp extends StatelessWidget {
  const MenuApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const MenuExample(),
    );
  }
}

class MenuExample extends StatefulWidget {
  const MenuExample({super.key});

  @override
  State<MenuExample> createState() => _MenuExampleState();
}

class _MenuExampleState extends State<MenuExample> {
  String selectedPage = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),

      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.white54,
                ),
                child:  Image(
                  image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/icreditmx69.appspot.com/o/icredit.png?alt=media'),
                )
            ),
            ListTile(
              leading: const Icon(Icons.sell_rounded),
              title: const Text('Vendedores'),
              onTap: () {
                setState(() {
                  PageSellers;
                  selectedPage = 'Vendedores';
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PageSellers()),
                  );
                });

              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Clientes'),
              onTap: () {
                setState(() {
                  selectedPage = 'Clientes';
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ClientePage( title: 'Clientes',)),
                  );
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale_rounded),
              title: const Text('Ventas'),
              onTap: () {
                setState(() {
                  selectedPage = 'Ventas';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_off),
              title: const Text('Comisiones'),
              onTap: () {
                setState(() {
                  selectedPage = 'Comisiones';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.collections_bookmark_rounded),
              title: const Text('Diario'),
              onTap: () {
                setState(() {
                  selectedPage = 'Diario';
                });
              },
            ),ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text('Dashboard'),
              onTap: () {
                setState(() {
                  selectedPage = 'Dashboard';
                });
              },
            ),ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Dashboard'),
              onTap: () {
                setState(() {
                  selectedPage = 'Dashboard';
                });
              },
            ),
          ],
        ),
      ),
      body: const Center(
          child: Image(
            image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/icreditmx69.appspot.com/o/icredit.png?alt=media'),
          )
      ),
    );
  }
}
