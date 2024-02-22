import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:icredit/firebase_options.dart';
import 'package:icredit/views/login_pages.dart';
import 'package:icredit/views/menu_pages.dart';

void main() async {
  runApp(MyApp());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {

  TextEditingController _phoneNumberController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Hola',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu número',
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {

                if(_phoneNumberController.text == 'login'){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginApp()));
                }
                else{
                  print('Número no válido');
                }
                // Acción al presionar
              },
              child: Text('Pagar'),
            ),
          ],
        ),
      ),
    );
  }
}
