import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icredit/views/menu_pages.dart';


class UserData {
  String? userName = '';
  String password = '';
}
class FormData {
  String? email;
  String? password;

}

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Other widgets remain the same
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Usuario',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an email';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Contraseña',
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      return null;
                    },
                  ),
                  TextButton(
                    child: const Text('Login'),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final user = _emailController.text; // Assuming _emailController now holds the user value
                        final password = _passwordController.text;

                        print('Usuario: $user Contraseña: $password');

                        // Fetch the seller data from Firestore using 'user' field
                        final snapshot = await FirebaseFirestore.instance
                            .collection('sellers')
                            .where('user', isEqualTo: user)
                            .get();

// Imprime los datos de cada documento.
                        for (var doc in snapshot.docs) {
                          print(doc.data()); // Esto imprimirá los datos en forma de mapa.
                        }

                        if (snapshot.docs.isEmpty) {
                          _showDialog('No seller found with this username.');
                          return;
                        }



                        final sellerData = snapshot.docs.first.data();


                        if (sellerData['password'].trim() == password.trim()) {

                        }else{
                          _showDialog('Datos incorrectos. Intente de nuevo.');
                          return;


                        }


                        final sellerRole = sellerData['role'];
                        final sellerId = snapshot.docs.first.id;


                        print(sellerRole);
                        print(sellerId);

                        // If the username and password are correct, navigate to the next page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuApp(
                              role: sellerRole,
                              id: sellerId,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text(message),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
    );
  }
}