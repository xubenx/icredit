import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:icredit/views/customer_pages.dart';
import 'package:icredit/views/login_pages.dart';
import 'package:icredit/views/map_page.dart';
import 'package:icredit/views/menu_pages.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:icredit/controller/customer_service.dart';




class SalesPage extends StatefulWidget {
  String id;
  String role;
  SalesPage({super.key, required this.id, required this.role}) ;



  @override
  State<SalesPage> createState() => _SalesPageState(role: role, id: id);
}

class _SalesPageState extends State<SalesPage> {
  final String role;
  final String id;
  _SalesPageState({Key? key, required this.role, required this.id});

  int _index = 0;
  CustomerService customerService = CustomerService();
  final TextEditingController imeiController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController curpController = TextEditingController();
  final TextEditingController abonosSemanasController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final addCustomerForm _form = addCustomerForm();
  Map<String, dynamic>? productData;
  Map<String, dynamic>? productDataMap;
  String? productId;
  double precioFinal = 0;
  double preciodespuesEnganche = 0;
  double preciodelProducto = 0;
  double precioAbonos = 0;
  String buffAddress = '';
  DateTime buyDate = DateTime.now();
  DateTime firstPaymentDate = DateTime.now();



  @override


  Widget build(BuildContext context) {

    return Scaffold(

      body: Stepper(
        currentStep: _index,
        onStepCancel: () {
          if (_index > 0) {
            setState(() {
              _index -= 1;
            });
          }
        },
        onStepContinue: () async {
          if (_index == 0) {
            final productSnapshot = await checkIfImeiExists(imeiController.text);
            if (productSnapshot != null) {

              final productData = productSnapshot.data();
              final productId = productSnapshot.id;
              Map<String, dynamic> productDataMap = productData as Map<String, dynamic>;

              print('Product ID: $productId');
              print(productData);


              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Información respecto al producto'),
                    content: Column(
                      children: [
                        Text('IMEI: ${productDataMap['imei']}'),
                        Text('Nombre: ${productDataMap['name']}'),
                        Text('Modelo: ${productDataMap['details']['model']}'),
                        Text('Color: ${productDataMap['details']['color']}'),
                        Text('Almacenamiento: ${productDataMap['details']['storage']}'),
                        Text('Batería: ${productDataMap['details']['battery']}'),
                        Text('Porcentaje: ${productDataMap['details']['percentage']}'),
                        Text('Precio: ${productDataMap['sellPrice']}'),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Aceptar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
              setState(() {
                _index += 1;
              });
            } else {



              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('IMEI no existe en la base de datos'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          }else if(_index == 1){





            if(abonosSemanasController.text == null || abonosSemanasController.text.isEmpty){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('Por favor ingresa el número de semanas'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
            else
             setState(() {

              _index += 1;
            });

          }
          else if(_index == 2){

            setState(() {
              _index += 1;
            });

          }
          else if (_index == 3) {
            if (_formKey.currentState?.validate() ?? false) {
              setState(() {
                _index += 1;
              });
            } else if (nameController.text == null || nameController.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('Por favor ingresa el nombre del cliente'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
            else if (phoneController.text == null || phoneController.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('Por favor ingresa el teléfono del cliente'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
            else if (emailController.text == null || emailController.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('Por favor ingresa el correo del cliente'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
            else if (curpController.text == null || curpController.text.isEmpty) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('Por favor ingresa la CURP del cliente'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
            else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('Por favor completa el formulario'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }
          }else if (_index == 3) { setState(() {
            _index += 1;
          });}
        },
        onStepTapped: (int index) {
          setState(() {
            _index = index;
          });
        },
        steps: <Step>[
          Step(
            title: const Text('Seleccionar producto'),
            content: Container(
              alignment: Alignment.centerLeft,
              child: TextFormField(
                controller: imeiController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  icon: Icon(Icons.numbers),
                  hintText: 'Ingresa el IMEI del telefono a vender',
                  labelText: 'IMEI',
                ),
              ),
            ),
          ),
          Step(
            title: const Text('Enganche y abonos'),
            content: Column(
              children: [
                TextFormField(
                  controller: abonosSemanasController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.calendar_today),
                    hintText: 'Ingrese el número de semanas deseadas para pagar el producto',
                    labelText: 'Número de semanas',
                  ),
                ),
              ],
            ),
          ),
          Step(
            title: Text('Establecer fechas'),
            content: Column(
              children: [
                Text('Fecha de venta del producto ${buyDate.toString()}'),
                ElevatedButton(
                  child: Text('Seleccionar el primer dia de pago:'),
                  onPressed: () async {
                    DateTime initialDate = DateTime.now();
                    while (initialDate.weekday != 5) {
                      initialDate = initialDate.add(Duration(days: 1));
                    }
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: initialDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      selectableDayPredicate: (DateTime date) {
                        // Only allow Fridays to be selected.
                        return date.weekday == 5;
                      },
                    );
                    if (pickedDate != null) {
                      // Do something with the picked date
                      firstPaymentDate = pickedDate;

                      print(pickedDate);
                    }
                  },
                ),
                Text('Fecha de primer pago: ${firstPaymentDate.toString()}'),
              ],
            ),
          ),
          Step(
            title: Text('Información básica del cliente'),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    children: [
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        controller: nameController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.person),
                          hintText: 'Ingresa el nombre del cliente',
                          labelText: 'Nombre',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el nombre del cliente';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        controller: phoneController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.phone),
                          hintText: 'Ingresa el teléfono del cliente',
                          labelText: 'Teléfono',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el teléfono del cliente';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        controller: emailController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.email),
                          hintText: 'Ingresa el correo del cliente',
                          labelText: 'Correo',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa el correo del cliente';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        textInputAction: TextInputAction.next,
                        controller: curpController,
                        decoration: const InputDecoration(
                          icon: Icon(Icons.badge),
                          hintText: 'Ingresa la CURP del cliente',
                          labelText: 'CURP',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa la CURP del cliente';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Step(
            title: Text('Agregar ubicación'),
            content: MyAppMap(), // Asumiendo que MyAppMap es tu widget combinado de mapa y autocompletado
          ),

          Step(
            title: Text("Agregar fotos y documentos"),
            content: Center(
              child: ElevatedButton(
                child: Text('Seleccionar fotos'),
                onPressed: () async {
                  String userId = 'yourUserId'; // Reemplaza esto con el ID de usuario correcto
                  await customerService.seleccionarImagenesYConvertirAPdf(userId);
                },
              ),
            ),
          ),
          Step(
            title: Text('Desglose de información'),
            content: Column(
              children: [
                Text('Nombre: ${nameController.text}'),
                Text('Teléfono: ${phoneController.text}'),
                Text('Correo: ${emailController.text}'),
                Text('CURP: ${curpController.text}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
Future<DocumentSnapshot?> checkIfImeiExists(String imei) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('products')
      .where('imei', isEqualTo: imei)
      .get();

  return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
}

class AutocompleteService {
  final String apiKey;

  AutocompleteService(this.apiKey);

  Future<List<String>> getAutocomplete(String input) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$apiKey&language=es';
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final predictions = jsonResponse['predictions'] as List;

      List<String> placesList = predictions.map((p) => p['description'].toString()).toList();
      return placesList;
    } else {
      throw Exception('Failed to load places');
    }
  }
}

