import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:icredit/views/login_pages.dart';
/// Flutter code sample for [Drawer].
import 'package:firebase_core/firebase_core.dart';
import 'package:icredit/views/map_page.dart';
import 'package:icredit/views/menu_pages.dart';
import 'package:icredit/views/sale_pages.dart';
import 'firebase_options.dart';
import 'package:flutter/cupertino.dart';

/// Flutter code sample for [CupertinoPageInicio].
import 'package:flutter/cupertino.dart';

/// Flutter code sample for [CupertinoPageInicio].

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
      await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    } catch (e) {
      // ignore: avoid_print
      print(e);
    }
  }
  runApp(MaterialApp(home: SalesApp()));
}

class PageInicioApp extends StatelessWidget {
  const PageInicioApp({super.key});

  @override

  Widget build(BuildContext context) {
    return const CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: PageInicio(),
    );
  }
}

class PageInicio extends StatefulWidget {
  const PageInicio({super.key});

  @override
  State<PageInicio> createState() => _PageInicioState();
}

class _PageInicioState extends State<PageInicio> {
  TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Image(
          image: NetworkImage(
              'https://firebasestorage.googleapis.com/v0/b/icreditmx69.appspot.com/o/icredit_lowheight.png?alt=media'),
          height: 100,
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Column(
              children: [
                Image(
                  image: NetworkImage(
                      'https://firebasestorage.googleapis.com/v0/b/icreditmx69.appspot.com/o/background-fondo.jpg?alt=media'),
                ),
              ],
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 200,
                      child: CupertinoTextField(
                        controller: _textEditingController,
                        placeholder: 'Ingresa tu #.',
                      ),
                    ),
                    const SizedBox(width: 16),
                    CupertinoButton.filled(
                      onPressed: () {

                        //CONTRATO
                        int precioProducto = 7000;
                        double ComisionSemanal = 2.5;
                        int numSemanas = 40;
                        double comisionSemanalPesos = (precioProducto * (ComisionSemanal/100));

                        double precioFinal = precioProducto + (comisionSemanalPesos * numSemanas);

                        



                        print(precioFinal);





                        if (_textEditingController.text == "login") {
                          // Navigate to another screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginApp()),
                          );
                        } else {
                          // Handle other cases or show a message
                        }
                      },
                      child: const Text("Pagar"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}





class DrawerApp extends StatelessWidget {
  const DrawerApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const LoginPage(),
    );
  }
}
