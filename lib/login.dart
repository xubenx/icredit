import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';


class UserData {
  String? userName = '';
  String password = '';
}
class FormData {
  String? email;
  String? password;

}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  State<LoginPage> createState() => _LoginPageState();
}



class _LoginPageState extends State<LoginPage> {


  @override
  Widget build(BuildContext context) {
    FormData formData = FormData();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign in Form'),
      ),
      body: Form(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...[
                  TextFormField(

                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Your email address',
                      labelText: 'Email',
                    ),
                    onChanged: (value) {
                      formData.email = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      formData.password = value;
                    },
                  ),
                  TextButton(
                    child: const Text('Sign in'),
                    onPressed: () async {
                      if (formData.email != null && formData.password != null) {
                        addUser(formData.email!, formData.password!);
                      } else {
                        _showDialog('Please fill in all fields.');
                      }
                    },
                  ),
                ].expand(
                      (widget) => [
                    widget,
                    const SizedBox(
                      height: 48,
                    )
                  ],
                )
              ],
            ),
          ),
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
  void addUser(String emailAddress, String password) async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      // User successfully created. If needed, you can now access the user details via credential.user
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        _showDialog('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        _showDialog('The account already exists for that email.');
      }
    } catch (e) {
      _showDialog('An error occurred. Please try again.');
    }
  }
}




