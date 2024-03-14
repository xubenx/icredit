import 'dart:async';
import 'dart:html';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icredit/controller/product_service.dart';
import 'package:icredit/controller/sales_service.dart';
import 'package:icredit/model/product.dart';
import 'package:icredit/views/customer_pages.dart';
import 'package:icredit/views/login_pages.dart';
import 'package:icredit/views/map_page.dart';
import 'package:icredit/views/menu_pages.dart';
import 'package:google_geocoding_api/google_geocoding_api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:icredit/controller/customer_service.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class SalesPage extends StatefulWidget {
  String id;
  String role;
  SalesPage({Key? key, required this.id, required this.role}) : super(key: key);

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  // Índice para controlar el paso actual en el Stepper
  int _index = 0;

  // Controladores para los campos de texto
  final TextEditingController firstPaymentDateController = TextEditingController();

  final TextEditingController imeiController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController curpController = TextEditingController();

  // Key para el formulario (usado para la validación)
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Uint8List> selectedImages = [];

  // Variables para manejar datos del producto
  Map<Object, dynamic>? productData;
  Map<Object, dynamic>? productDataMap;
  String productId = '';

  // Variables para la ubicación y documentos
  double lat = 21.0200542; // Ejemplo de latitud inicial
  double lng = -101.8909784; // Ejemplo de longitud inicial
  String buffAddress = ''; // Dirección seleccionada
  String pdfUrl = ''; // URL del PDF con documentos/fotos

  // Variables para manejar las fechas
  DateTime buyDate = DateTime.now(); // Fecha de compra
  DateTime firstPaymentDate = DateTime.now(); // Fecha del primer pago

  double buyPrice = 0 ;
  double sellingPriceCredit = 0;
  double hookPrice = 0;
  double minimumPayment = 0;

  double totalAmount = 0;
  double balanceAfterDownPayment = 0;

  double finalDebtAmount = 0;
  List<Map<String, dynamic>> salesList = []; // Lista para almacenar las ventas

  @override
  void initState() {
    super.initState();
    _loadSales();
  }

  void _loadSales() async {
    QuerySnapshot salesSnapshot;
    if (widget.role == 'admin') {
      salesSnapshot = await FirebaseFirestore.instance.collection('sales').get();
    } else {
      salesSnapshot = await FirebaseFirestore.instance
          .collection('sales')
          .where('sellerId', isEqualTo: widget.id)
          .get();
    }

    final sales = salesSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    setState(() {
      salesList = sales;
    });
  }





  late bool available;
  // Servicios
  final CustomerService customerService = CustomerService();
  final SalesService salesService = SalesService();




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Proceso de Venta"),
      ),
      body: Stepper(
        currentStep: _index,
        onStepContinue: _goToNextStep,
        onStepCancel: _goToPreviousStep,
        steps: _getSteps(),
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          if(_index < 6) {
            return Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: const Text('Continuar'),
                ),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Atrás'),
                ),
              ],
            );
          } else {
            return AlertDialog(
              title: Text('Confirmación'),
              content: Text('¿Estás seguro de que deseas finalizar el proceso de venta?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cierra el diálogo
                  },
                  child: Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    _showLoadingDialog();

                    await _finalizarVenta(); // Lógica para finalizar la venta
                  },
                  child: Text('Finalizar'),
                ),
              ],
            );
          }
        },
      ),
    );
  }

  List<Step> _getSteps() {


    return [
      Step(
        title: const Text('Seleccionar Producto'),
        content: Column(
          children: [
            SizedBox(height: 20),
            TextFormField(
              controller: imeiController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                icon: Icon(Icons.phone_android),
                labelText: 'IMEI del teléfono',
                hintText: 'Ingresa el IMEI del teléfono a vender',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(onPressed: () {
              _buscarProducto();
            },
                icon: Icon(Icons.search),
                label: Text('Buscar Producto')
            ),
            SizedBox(height: 20),

          ],
        ),
        isActive: _index >= 0,
      ),
      Step(
        title: Text('Establecer Fechas'),
        content: Column(
          children: [
            SizedBox(height: 20),
            TextFormField(
              controller: firstPaymentDateController,
              decoration: InputDecoration(
                icon: Icon(Icons.calendar_today), // Icono de calendario
                labelText: 'Fecha de Primer Pago',
                border: OutlineInputBorder(),
              ),
              readOnly: true, // Hace el campo de texto de solo lectura
              onTap: () async {
                // Abre el DatePicker cuando el usuario toca el campo
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: firstPaymentDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                // Actualiza el valor del campo si el usuario selecciona una fecha
                if (pickedDate != null && pickedDate != firstPaymentDate) {
                  setState(() {
                    firstPaymentDate = pickedDate;
                    // Actualiza el texto del controlador para mostrar la fecha seleccionada
                    firstPaymentDateController.text = DateFormat('yyyy-MM-dd').format(firstPaymentDate);
                  });
                }
              },
            ),
            SizedBox(height: 20),

            // Más widgets según sea necesario...
          ],
        ),
        isActive: _index >= 1,
      ),
      Step(
        title: Text('Información Básica del Cliente'),
        content: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  icon: Icon(Icons.person), // Icono de persona
                  labelText: 'Nombre del Cliente',
                  hintText: 'Ingresa el nombre completo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre del cliente';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10), // Espacio entre inputs
              TextFormField(
                controller: phoneController,
                decoration: InputDecoration(
                  icon: Icon(Icons.phone), // Icono de teléfono
                  labelText: 'Teléfono del Cliente',
                  hintText: 'Ingresa el número de teléfono',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el teléfono del cliente';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10), // Espacio entre inputs
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  icon: Icon(Icons.email), // Icono de correo electrónico
                  labelText: 'Correo Electrónico del Cliente',
                  hintText: 'Ingresa el correo electrónico',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el correo electrónico del cliente';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10), // Espacio entre inputs
              TextFormField(
                controller: curpController,
                decoration: InputDecoration(
                  icon: Icon(Icons.fingerprint), // Icono que podría representar la CURP
                  labelText: 'CURP del Cliente',
                  hintText: 'Ingresa la CURP',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la CURP del cliente';
                  }
                  if (value.length != 18) {
                    return 'La CURP debe tener 18 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

            ],
          ),
        ),
        isActive: _index >= 2,
      ),

      Step(
        title: Text('Agregar Ubicación'),
        content: MyAppMap(
          onLocationSelected: (lat, lng, address) {

            setState(() {
              this.lat = lat;
              this.lng = lng;
              buffAddress = address;
            });
            // Lógica para manejar la ubicación seleccionada
          },
        ),
        isActive: _index >= 3,
      ),
      Step(
        title: Text("Agregar Fotos y Documentos"),
        content: Column(
          children: [
            SizedBox(height: 20),
            //crea el boton de seleccionar fotosp ero con un icono de picker
            ElevatedButton.icon(
              onPressed: () {
                _selectImages();
              },
              icon: Icon(Icons.photo),
              label: Text('Seleccionar fotos'),
            ),
            SizedBox(height: 20),
            selectedImages.isNotEmpty
                ? Wrap(
              spacing: 8.0, // Espacio horizontal entre imágenes
              runSpacing: 4.0, // Espacio vertical entre imágenes
              children: selectedImages
                  .map((imgData) => GestureDetector(
                onTap: () => _showImageDialog(imgData),
                child: Image.memory(
                  imgData,
                  width: 100, // Ancho de la imagen
                  height: 100, // Alto de la imagen
                  fit: BoxFit.cover,
                ),
              ))
                  .toList(),
            )
                : Text("No se han seleccionado imágenes."),
            SizedBox(height: 20),
          ],
        ),
        isActive: _index >= 4,
      ),
      Step(
        title: Text('Desglose de Información'),
        content: SingleChildScrollView( // Asegúrate de que todo sea scrollable si el contenido es mucho
          child: Column(
            children: [
              Text("Detalles del Producto", style: Theme.of(context).textTheme.headline6),
              Divider(),
              ListTile(
                title: Text('IMEI'),
                subtitle: Text('${imeiController.text}'),
              ),
              ListTile(
                title: Text('Nombre del Producto'),
                subtitle: Text('${productDataMap?['name'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Modelo'),
                subtitle: Text('${productDataMap?['details']['model'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Color'),
                subtitle: Text('${productDataMap?['details']['color'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Capacidad'),
                subtitle: Text('${productDataMap?['details']['storage'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Porcentaje de batería'),
                subtitle: Text('${productDataMap?['details']['battery'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Precio de venta de contado'),
                subtitle: Text('\$${productDataMap?['sellingPrice'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Precio de venta a crédito'),
                subtitle: Text('\$${productDataMap?['sellingPriceCredit'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Enganche'),
                subtitle: Text('\$${productDataMap?['hookPrice'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Monto minimo de pago'),
                subtitle: Text('\$${productDataMap?['miniumMount'] ?? 'N/A'}'),
              ),
              ListTile(
                title: Text('Estado'),
                subtitle: Text(_formatStatus(productDataMap?['status'])),
              ),

              SizedBox(height: 20),
              Text("Información del Cliente", style: Theme.of(context).textTheme.headline6),
              Divider(),
              ListTile(
                title: Text('Nombre'),
                subtitle: Text('${nameController.text}'),
              ),
              ListTile(
                title: Text('Teléfono'),
                subtitle: Text('${phoneController.text}'),
              ),
              ListTile(
                title: Text('Correo Electrónico'),
                subtitle: Text('${emailController.text}'),
              ),
              ListTile(
                title: Text('CURP'),
                subtitle: Text('${curpController.text}'),
              ),

              SizedBox(height: 20),
              Text("Detalles de domicilio", style: Theme.of(context).textTheme.headline6),
              Divider(),
              //ingresar un Mapa estatico de Google Maps en con las coordinadas iniciales lat y lng con zoom
              Container(
                height: 200,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(lat, lng),
                    zoom: 1.0,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('selectedLocation'),
                      position: LatLng(lat, lng),
                      infoWindow: InfoWindow(title: 'Ubicación Seleccionada', snippet: buffAddress),
                    ),
                  },
                ),
              ),
              ListTile(
                title: Text('Dirección'),
                subtitle: Text('$buffAddress'),
              ),
              SizedBox(height: 20),
              Text("Fotos Seleccionadas", style: Theme.of(context).textTheme.headline6),
              Divider(),
              selectedImages.isNotEmpty
                  ? Wrap(
                spacing: 8.0, // Espacio horizontal entre imágenes
                runSpacing: 4.0, // Espacio vertical entre imágenes
                children: selectedImages.map((imgData) => GestureDetector(
                  onTap: () => _showImageDialog(imgData),
                  child: Image.memory(
                    imgData,
                    width: 100, // Ancho de la imagen
                    height: 100, // Alto de la imagen
                    fit: BoxFit.cover,
                  ),
                )).toList(),
              )
                  : Text("No se han seleccionado imágenes."),
              SizedBox(height: 20),
              Text("Detalles de pagos", style: Theme.of(context).textTheme.headline6),
              Divider(),

              ListTile(
                title: Text('Fecha del Primer Pago'),
                subtitle: Text('${DateFormat('yyyy-MM-dd').format(firstPaymentDate)}'),
              ),
              ListTile(
                title: Text('Monto a pagar en total:'),
                subtitle: Text('\$$totalAmount '),
              ),
              ListTile(
                title: Text('Enganche'),
                subtitle: Text('\$$hookPrice'),
              ),
              ListTile(
                title: Text('Saldo adeudo del producto:'),
                subtitle: Text('\$$balanceAfterDownPayment'),
              ),
              ListTile(
                title: Text('Saldo adeudo del crédito:'),
                subtitle: Text('\$$sellingPriceCredit'),
              ),
              ListTile(
                title: Text('Saldo adeudo actual:'),
                subtitle: Text('\$$finalDebtAmount'),
              ),
              ListTile(
                title: Text('Monto mínimo de pago'),
                subtitle: Text('\$$minimumPayment'),
              ),


            ],
          ),
        ),
        isActive: _index >= 5,
      ),

      Step(
        title: Text('Confirmación Final'),
        content: Column(
          children: [
            SizedBox(height: 20),
            Text('Por favor revisa la información antes de finalizar el proceso de venta.'),
            SizedBox(height: 20),

          ],
        ),

        isActive: _index >= 6,
      ),
    ];
  }


  void _goToNextStep() {
    print(_index);
    if (_index < _getSteps().length - 1) { // Asegúrate de no sobrepasar el número de pasos
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmación'),
            content: Text('¿Estás seguro de que deseas continuar?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo
                },
                child: Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el diálogo

                  if (available == true) {
                    setState(() {
                      _index++; // Avanza al siguiente paso
                    });
                  }
                },
                child: Text('Continuar'),
              ),
            ],
          );
        },
      );
    }
  }


  void _goToPreviousStep() {
    if (_index > 0) {
      setState(() {
        _index--;
      });
    }
  }

// Resto de tus métodos

  void _showProductDialog(String title, Map<Object, dynamic> productData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView( // Usar un SingleChildScrollView por si el contenido es muy largo
            child: ListBody( // Usar un ListBody para una lista de widgets
              children: <Widget>[
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyText2, // Estilo por defecto
                    children: <TextSpan>[
                      TextSpan(text: 'IMEI: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${productData['imei'] ?? 'N/A'}\n\n'),
                      TextSpan(text: 'Nombre: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${productData['name'] ?? 'N/A'}\n\n'),
                      TextSpan(text: 'Modelo: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${productData['details']['model'] ?? 'N/A'}\n\n'),
                      TextSpan(text: 'Color: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${productData['details']['color'] ?? 'N/A'}\n\n'),
                      TextSpan(text: 'Capacidad: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${productData['details']['storage'] ?? 'N/A'}\n\n'),
                      TextSpan(text: 'Porcentaje de batería: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${productData['details']['battery'] ?? 'N/A'}\n\n'),
                      TextSpan(text: 'Precio de venta contado: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${productData['sellingPrice'] ?? 'N/A'}\n\n'),
                      TextSpan(text: 'Precio de venta a crédito: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${productData['sellingPriceCredit'] ?? 'N/A'}\n\n'),
                      TextSpan(text: 'Cantidad de enganche: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${productData['hookPrice'] ?? 'N/A'}\n\n'),
                      TextSpan(text: 'Monto mínimo de pago: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${productData['miniumMount'] ?? 'N/A'}\n\n'),
                      TextSpan(text: 'Estado: ', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: '${_formatStatus(productData['status'])}\n\n'),
                    ],
                  ),
                ),
              ],
            ),
          ),
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

  String _formatStatus(dynamic status) {
    switch (status) {
      case 'inStock':
        return 'En stock';
      case 'inCredit':
        return 'En crédito';
      case 'inactive':
        return 'Inactivo';
      case 'sold':
        return 'Vendido';
      default:
        return 'Desconocido';
    }
  }

// Ajustes en el método _buscarProducto para usar _showProductDialog
  void _buscarProducto() async {
    try {
      final productSnapshot = await salesService.getProductById(imeiController.text);
      if (productSnapshot != null) {
        final productData = productSnapshot.data() as Map<Object, dynamic>;
        setState(() {
          this.productData = productData;
          this.productId = productSnapshot.id;
          this.productDataMap = productData;

          buyPrice = productDataMap?['buyPrice']?.toDouble() ?? 0.0;
          sellingPriceCredit = productDataMap?['sellingPriceCredit']?.toDouble() ?? 0.0;
          hookPrice = productDataMap?['hookPrice']?.toDouble() ?? 0.0;
          minimumPayment = productDataMap?['miniumMount']?.toDouble() ?? 0.0;
          totalAmount = sellingPriceCredit + sellingPriceCredit;
          balanceAfterDownPayment = sellingPriceCredit - hookPrice;
          finalDebtAmount = sellingPriceCredit + balanceAfterDownPayment;
          ;

        });

        if (productDataMap?['status'] == 'inCredit') {
          _showDialog('Error', 'El producto con el IMEI proporcionado no está disponible, ya que se encuentra vendido.');
          setState(() {
            available = false;
          });
        } else {
          setState(() {
            available = true;
          });
          // Usar el método personalizado para mostrar el diálogo del producto
          _showProductDialog('Producto encontrado', productDataMap!);
        }
      } else {
        _showDialog('Error', 'El producto con el ID proporcionado no existe en la base de datos.');
      }
    } catch (e) {
      _showDialog('Error', 'Se produjo un error al buscar el producto: $e');
    }
  }



  // Método para mostrar un diálogo de alerta
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
  // Método para seleccionar la fecha del primer pago
  Future<void> _selectFirstPaymentDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstPaymentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != firstPaymentDate) {
      setState(() {
        firstPaymentDate = picked;
      });
    }
  }

  Future<void> _finalizarVenta() async {
    // Asegúrate de mostrar el diálogo de carga al principio


    try {
      // Intenta realizar las operaciones necesarias para finalizar la venta
      // Aquí se crea el PDF a partir de imágenes seleccionadas
      final pdfFilePath = await createPdfFromSelectedImages();
      if (pdfFilePath == null) {
        throw Exception('No se pudo crear el PDF.');
      }

      // Construir el nombre del archivo PDF con un identificador único
      String namePdf = widget.id + DateTime.now().microsecondsSinceEpoch.toString() + productId;

      // Subir el PDF a Firebase y obtener la URL
      String? pdfUrl = await uploadPdfBytesToFirebase(pdfFilePath, namePdf);
      if (pdfUrl == null) {
        throw Exception("Error al subir el PDF a Firebase.");
      }

      // Calcular los montos finales y deudas
      double finalDebtAmount = productDataMap?['buyPrice'] ?? 0.0;
      double hookPrice = productDataMap?['hookPrice'] ?? 0.0;
      double debtAmount = finalDebtAmount - hookPrice;

      // Guardar los detalles de la venta en la base de datos o donde corresponda
      String saleId = await salesService.saveSale(
        sellerId: widget.id,
        productImei: imeiController.text,
        customerData: {
          'name': nameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'curp': curpController.text,
          'address': buffAddress,
          'latitude': lat,
          'longitude': lng,
        },
        finalDebtAmount: finalDebtAmount,
        debtAmount: debtAmount,
        payments: [
          {
            'amount': hookPrice,
            'date': DateTime.now(),
            'status': 'payment',
            'description': 'Enganche abono inicial'
          },
        ],
        debtCreditAmount: finalDebtAmount,
        urlFiles: pdfUrl,
        date: DateTime.now(),
        status: 'inCredit',
      );

      // Si todo ha ido bien, cerrar el diálogo de carga y mostrar uno de éxito
      Navigator.of(context, rootNavigator: true).pop(); // Cierra el diálogo de carga
      _showSuccessDialog();

    } catch (e) {
      // Si algo falla, cierra el diálogo de carga y muestra uno de error
      Navigator.of(context, rootNavigator: true).pop(); // Cierra el diálogo de carga
      _showErrorDialog('$e');
    }
  }



  void _showLoadingDialog()  {
    showDialog(
      context: context,
      barrierDismissible: false, // El usuario no puede cerrar el diálogo tocando fuera de él
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Procesando..."),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showSuccessDialog() {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop(); // Cierra el diálogo de carga si está abierto
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green), // Icono de éxito
              SizedBox(width: 10),
              Text("Venta Realizada"),
            ],
          ),
          content: Text("La venta se ha realizado con éxito."),
          actions: <Widget>[
            TextButton(
              child: Text("Aceptar"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MenuApp(role: widget.role, id: widget.id))
                ); // Cierra el diálogo de éxito
                // Cierra el diálogo de éxito
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String errorMessage) {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop(); // Cierra el diálogo de carga si está abierto
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red), // Icono de error
              SizedBox(width: 10),
              Text("Error"),
            ],
          ),
          content: Text(errorMessage),
          actions: <Widget>[
            TextButton(
              child: Text("Cerrar"),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo de error
              },
            ),
          ],
        );
      },
    );
  }




  Future<Uint8List> createPdfFromSelectedImages() async {
    final pdf = pw.Document();

    for (final Uint8List imageData in selectedImages) {
      final image = pw.MemoryImage(imageData);
      pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(image))));
    }

    return pdf.save();
  }

  void _showImageDialog(Uint8List imgData) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          width: double.maxFinite,
          child: Image.memory(imgData, fit: BoxFit.cover),
        ),
      ),
    );
  }


  Future<String?> uploadPdfBytesToFirebase(Uint8List pdfBytes, String saleId) async {
    String fileName = 'sales/$saleId.pdf';
    try {
      Reference storageReference = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageReference.putData(pdfBytes);
      await uploadTask.whenComplete(() => null);
      return await storageReference.getDownloadURL();
    } catch (e) {
      print("Error al subir el PDF a Firebase Storage: $e");
      return null;
    }
  }




  Future<void> _selectImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      List<Uint8List> imageBytes = result.files.map((file) => file.bytes!).toList();
      setState(() {
        selectedImages = imageBytes;
      });
    }
  }

}


