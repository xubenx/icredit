import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icredit/views/customer_pages.dart';
import 'package:icredit/views/login_pages.dart';
import 'package:icredit/views/menu_pages.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:google_maps_webservice/places.dart';

import 'package:icredit/controller/customer_service.dart';
class SalesApp extends StatelessWidget {
  const SalesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Vender')),
        body: const Center(
          child: SalesPage(),
        ),
      ),
    );
  }
}

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  int _index = 0;
  CustomerService customerService = CustomerService();
  final TextEditingController imeiController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController curpController = TextEditingController();
  final TextEditingController engancheController = TextEditingController();
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
  LatLng? _selectedLocation;


  @override
  Widget build(BuildContext context) {

    return Drawer(
      child: Stepper(
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





            if(engancheController.text == null || engancheController.text.isEmpty){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Error'),
                    content: Text('Por favor ingresa el enganche'),
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
            }else if(abonosSemanasController.text == null || abonosSemanasController.text.isEmpty){
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
            content: Container(
              alignment: Alignment.centerLeft,
              child: Column(
                children: [
                  TextFormField(
                    controller: engancheController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.price_change),
                      hintText: 'Ingresa el enganche del producto',
                      labelText: 'Cantidad del enganche',
                    ),
                  ),
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
          ),
          Step(title: Text('Desglose de precio final y abonos'), content: Column(
            children: [
              Text('Precio Final: $precioFinal'),
              Text('Precio Después de Enganche: $preciodespuesEnganche'),
              Text('Precio del Producto: $preciodelProducto'),
              Text('Precio Abonos: $precioAbonos'),
            ],
          ),
          ),
          Step(
            title: Text('Información básica del cliente'),
            content: Form(
              key: _formKey,
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
          Step(
            title: Text('Agregar ubicación'),
            content: GestureDetector(
              onTap: () {
                // Aquí puedes manejar el toque en el mapa y actualizar _selectedLocation
              },
              child: Container(
                height: 300, // Define la altura que necesites
                width: double.infinity, // Toma
                child: GoogleMap(
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(21.020058, -101.870421),
                    zoom: 11.0,
                  ),
                  markers: _selectedLocation != null
                      ? {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: _selectedLocation!,
                    ),
                  }
                      : {},
                  onTap: (LatLng location) {
                    setState(() {
                      _selectedLocation = location;
                    });
                    print(_selectedLocation);
                  },
                ),
              ),
            ),
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