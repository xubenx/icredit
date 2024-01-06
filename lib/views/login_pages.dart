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


  @override
  Widget build(BuildContext context) {
    FormData formData = FormData();

    return Scaffold(
      body: Form(
        child: ListView(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...[
                    const Image(
                      image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/icreditmx69.appspot.com/o/icredit_lowheight.png?alt=media'),
                      height: 100,
                    ),
                    const Text("Inicio de sesión" ,),
                    TextFormField(

                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Usuario',
                        labelText: 'Usuario',
                      ),
                      onChanged: (value) {
                        formData.email = value;
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        filled: true,
                        labelText: 'Contraseña',
                      ),
                      obscureText: true,
                      onChanged: (value) {
                        formData.password = value;
                      },
                    ),
                    TextButton(
                      child: const Text('Iniciar'),
                      onPressed: () async {
                        if (formData.email == "root" && formData.password == "root") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MenuApp()),
                          );
                        } else {
                          _showDialog('Rellena todos los datos!.');
                        }
                      },
                    ),
                  ].expand(
                        (widget) =>
                    [
                      widget,
                      const SizedBox(
                        height: 48,
                      )
                    ],
                  )
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




