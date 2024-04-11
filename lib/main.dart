import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:icredit/controller/login_service.dart';
import 'package:icredit/firebase_options.dart';
import 'package:icredit/views/login_pages.dart';
import 'package:icredit/views/menu_pages.dart';
import 'package:cron/cron.dart';

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
      theme: ThemeData(
        useMaterial3: true,
        // Define el color primario de la aplicación
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Colors.black,
          secondary: Colors.grey,
          background: Colors.white,
        ),
      ),
      /*MenuApp(id: 'JD0sColOYII0I8UjhqiY', role: 'admin',),*/
      /*MenuApp(id: 'Q28datXmO3ySoUvFViXi', role: 'seller',),*/
      /*WelcomeScreen()*/

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
            Divider(),
            SizedBox(height: 50),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: TextField(
                controller: _phoneNumberController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: 'Ingresa tu número',
                  labelText: 'Número de teléfono',
                  border: OutlineInputBorder(
                  ),


                ),
              ),
            ),
            Divider(color: Colors.grey, thickness: 1, height: 10, indent: 50, endIndent: 50),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {


                var buff = await fetchSaleByPhoneNumber(_phoneNumberController.text);

                print(buff);

                if(_phoneNumberController.text.trim() == 'login'){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));

                }else if(buff != null && _phoneNumberController.text.trim() == buff['customer']['phone']){

                  navigateToSaleDetailPage(context, _phoneNumberController.text);

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
