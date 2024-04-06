import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:icredit/controller/sales_service.dart';
import 'package:icredit/views/menu_pages.dart';

class AddCashPage extends StatefulWidget {
  final String id;
  final String role;

  AddCashPage({Key? key, required this.id, required this.role}) : super(key: key);

  @override
  _AddCashPageState createState() => _AddCashPageState();
}

class _AddCashPageState extends State<AddCashPage> {
  int _index = 0;
  final TextEditingController imeiController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  final SalesService salesService = SalesService();
  Map<Object, dynamic>? productData;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool available = false; // Variable para indicar si el producto está disponible
  Map<Object, dynamic>? productDataMap;
  String productId = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Venta en efectivo'),
      ),

      body: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          // Define el color primario de la aplicación
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: Colors.black,
            secondary: Colors.grey,
            background: Colors.white,
          ),
        ),
        home: Scaffold(
          body: Center(
            child: Form(
              key: _formKey,
              child: Stepper(
                currentStep: _index,
                onStepContinue: _goToNextStep,

                steps: [
                  Step(
                    title: const Text('Seleccionar Producto'),
                    content: Column(
                      children: [
                        SizedBox(height: 20),
                        TextFormField(
                          controller: imeiController,
                          decoration: InputDecoration(
                            labelText: 'IMEI del teléfono',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el IMEI del teléfono';
                            }
                            return null;
                          },
                        ),
                        Divider(height: 1,indent: 1,endIndent: 50,thickness: 1,color: Colors.grey,),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _buscarProducto();
                            }
                          },
                          child: Text('Buscar Producto'),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                    isActive: _index >= 0,
                  ),
                  Step(
                    title: Text('Confirmar Venta y Añadir Teléfono (Opcional)'),
                    content: Column(
                      children: [
                        SizedBox(height: 20),
                        Text('¿Estás seguro de realizar la venta? Si lo deseas, añade un número de teléfono para enviar el ticket.'),
                        SizedBox(height: 20),
                        // Nuevo TextFormField para el número de teléfono opcional
                        TextFormField(
                          controller: phoneController,
                          decoration: InputDecoration(
                            labelText: 'Número de Teléfono (opcional)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                          // No es necesario un validador porque el campo es opcional
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _finalizarVenta, // Actualiza esta llamada al método
                          child: Text('Finalizar Venta'),
                        ),
                      ],
                    ),
                    isActive: _index >= 1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _goToNextStep() {
    if (_index < 1 && available) { // Solo permite avanzar si el producto está disponible
      setState(() {
        _index++;
      });
    } else if (_index < 1 && !available) {
      _showErrorDialog('El producto no está disponible para la venta.');
    } else {
      _finalizarVenta();
    }
  }

  void _buscarProducto() async {
    try {
      final productData = await salesService.getDetailsById('products', imeiController.text);

      print(productData);
      if (productData != null) {
        setState(() {
          this.productData = productData;
          this.productDataMap = productData;

          double buyPrice = productData['buyPrice']?.toDouble() ?? 0.0;
          double sellingPriceCredit = productData['sellingPriceCredit']?.toDouble() ?? 0.0;
          double hookPrice = productData['hookPrice']?.toDouble() ?? 0.0;
          double minimumPayment = productData['miniumMount']?.toDouble() ?? 0.0;
          double totalAmount = sellingPriceCredit + sellingPriceCredit;
          double balanceAfterDownPayment = sellingPriceCredit - hookPrice;
          double finalDebtAmount = sellingPriceCredit + balanceAfterDownPayment;
        });

        if (productData['status'] == 'inCredit') {
          _showDialog('Error', 'El producto con el IMEI proporcionado no está disponible, ya que se encuentra vendido.');
          setState(() {
            available = false;
          });
        } else {
          setState(() {
            available = true;
          });
          // Usar el método personalizado para mostrar el diálogo del producto
          _showProductDialog('Producto encontrado', productData);
        }
      } else {
        _showDialog('Error', 'El producto con el ID proporcionado no existe en la base de datos.');
      }
    } catch (e) {
      _showDialog('Error', 'Se produjo un error al buscar el producto: $e');
    }
  }

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
  Future<void> _finalizarVenta() async {
    // Asegúrate de mostrar el diálogo de carga al principio


    try {
      _showLoadingDialog();


      // Construir el nombre del archivo PDF con un identificador único
      // Calcular los montos finales y deudas
      double price = productDataMap?['sellingPrice'] ?? 0.0;

      double amountCommission = price*.10;

      // Guardar los detalles de la venta en la base de datos o donde corresponda
      String saleId = await salesService.saveCashSale(sellerId: widget.id,
        productImei: imeiController.text,
        payments: [
          {
          'amount': price,
          'date': DateTime.now(),
          'status': 'payment',
          'description': 'Pago total en efectivo',
          'amountCommission': amountCommission,
          'commissionStatus': 'Pendiente',
          },
          ],
          date: DateTime.now(), customerData: {
        'phone': phoneController.text,
        },
      );


      Map<String, dynamic> saleData = {
        'sellerId': widget.id,
        'productImei': imeiController.text,
        'payments': [
          {
            'amount': price,
            'date': DateTime.now(),
            'status': 'payment',
            'description': 'Enganche abono inicial',
            'amountCommission': amountCommission,
            'commissionStatus': 'Pendiente',
          },
        ],

        'date': DateTime.now(), 'customerData': {
          'phone': phoneController.text,
        },
      };

      await salesService.generateAndDownloadCashTicket(
        saleId: saleId,
        saleData: saleData,
      );
      // Si todo ha ido bien, cerrar el diálogo de carga y mostrar uno de éxito

      Navigator.of(context, rootNavigator: true).pop(); // Cierra el diálogo de carga
      _showSuccessDialog();
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop(); // Cierra el diálogo de carga
      _showErrorDialog('$e');
    }
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
      case 'cashSold':
        return 'Vendido en efectivo';
      default:
        return 'Desconocido';
    }
  }
}