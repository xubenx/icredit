import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icredit/views/menu_pages.dart';

class LoginApp extends StatelessWidget {
  const LoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        // Define el color primario de la aplicación
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.black,
          secondary: Colors.grey,
          background: Colors.white,
        ),
      ),
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
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 40), // Espacio adicional en la parte superior
            Image(
              image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/icreditmx69.appspot.com/o/icredit.png?alt=media'), height: 200,
            ),
            const SizedBox(height: 24), // Espacio entre la imagen y el formulario
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Usuario',
                hintText: 'Ingrese su usuario',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese un correo electrónico';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                filled: true,
                labelText: 'Contraseña',
                hintText: 'Ingrese su contraseña',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, ingrese una contraseña';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50), // Tamaño del botón
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Forma del botón
                ),
              ),
              child: const Text('Iniciar sesión'),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  // La lógica de inicio de sesión permanece igual
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
                    _showDialog('No hay vendedores existentes con este usuario.');
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
    );
  }

  void _showDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
