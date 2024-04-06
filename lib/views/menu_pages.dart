import 'package:flutter/material.dart';
import 'package:icredit/views/commission_page.dart';
import 'package:icredit/views/product_pages.dart';
import 'package:icredit/views/sales/sale_pages.dart';
import 'package:icredit/views/sellers_pages.dart';
/// Flutter code sample for [Menu].
import 'package:firebase_core/firebase_core.dart';
import 'package:icredit/views/customer_pages.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

}

class MenuApp extends StatelessWidget {
  final String id;
  final String role;

  const MenuApp({Key? key, required this.id, required this.role}) : super(key: key);


  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: MenuExample(role: role, id: id,),
    );
  }
}

class MenuExample extends StatefulWidget {
  final String role;
  final String id;
  const MenuExample({Key? key, required this.role,required this.id}) : super(key: key);

  @override

  State<MenuExample> createState() => _MenuExampleState(role: role, id: id);
}



class _MenuExampleState extends State<MenuExample> {
  final String role;
  final String id;

  _MenuExampleState({Key? key, required this.role,required this.id});
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
            if (widget.role != 'seller') ListTile(
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
            /*
            if (widget.role != 'seller') ListTile(
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
            ),*/
            ListTile(
              leading: const Icon(Icons.monetization_on),
              title: const Text('Comisiones'),
              onTap: () {
                if (widget.role == 'seller') {
                  // If the role is seller, navigate directly to their commissions page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SellerCommissionsPage(sellerId: widget.id, role: widget.role,),
                    ),
                  );
                } else {
                  // Otherwise, navigate to the page showing all commissions
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CommissionsPage(sellerId: widget.id, role: widget.role),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale_rounded),
              title: const Text('Ventas'),
              onTap: () {
                setState(() {
                  selectedPage = 'Ventas';
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SalesPageView(role: role,id: id)),
                  );
                });
              },
            ),
            if (widget.role != 'seller') ListTile(
              leading: const Icon(Icons.inventory),
              title: const Text('Productos'),
              onTap: () {
                setState(() {
                  selectedPage = 'Productos';
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductPageView()),
                  );
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