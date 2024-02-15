import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../model/product.dart'; // Asegúrate de importar tu modelo Product
import '../controller/product_service.dart'; // Importa ProductService

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProductPage(id: '', role: '',));


}


class ProductPage extends StatelessWidget {
  final String id;
  final String role;

  const ProductPage({Key? key, required this.id, required this.role}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agregar Producto'),
      ),
      body: ProductForm(),
    );
  }
}

class ProductForm extends StatefulWidget {
  final Product? product;

  const ProductForm({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormState createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _imeiController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _storageController = TextEditingController();
  final TextEditingController _batteryController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  final TextEditingController _buyPriceCreditController = TextEditingController();
  final TextEditingController _hookPriceController = TextEditingController();
  // Agrega aquí más controladores si necesitas más campos.

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // Precarga los datos si estás editando un producto existente
      _nameController.text = widget.product!.name ?? '';
      _sellPriceController.text = widget.product!.sellPrice?.toString() ?? '';
      _buyPriceController.text = widget.product!.buyPrice?.toString() ?? '';
      _imeiController.text = widget.product!.imei ?? '';
      _colorController.text = widget.product!.details?['color'] ?? '';
      _storageController.text = widget.product!.details?['storage']?.toString() ?? '';
      _batteryController.text = widget.product!.details?['battery']?.toString() ?? '';
      _modelController.text = widget.product!.details?['model'] ?? '';
      _percentageController.text = widget.product!.details?['percentage']?.toString() ?? '';
      _buyPriceCreditController.text = widget.product!.buyPriceCredit?.toString() ?? '';
      _hookPriceController.text = widget.product!.hookPrice?.toString() ?? '';
      // Agrega más campos según sea necesario
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Nombre del Producto'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el nombre del producto';
              }
              return null;
            },
          ),
          // Agrega más TextFormField para otros campos como precio de venta, IMEI, etc.
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Llama a tu método para añadir o actualizar el producto aquí
                _saveOrUpdateProduct();
              }
            },
            child: Text('Guardar Producto'),
          ),
        ],
      ),
    );
  }

  void _saveOrUpdateProduct() async {
    // Aquí añadirías la lógica para guardar o actualizar el producto
    // Utilizando el ProductService y los controladores de texto para obtener los valores de los campos
    ProductService productService = ProductService();
    if (widget.product == null) {
      // Lógica para añadir un nuevo producto
      await productService.addProduct(
        _nameController.text,
        double.parse(_sellPriceController.text),
        double.parse(_buyPriceController.text),
        _imeiController.text,
        {}, // Aquí deberías pasar los detalles adicionales como un Map
        0.0, // Precio de compra a crédito, ajusta según corresponda
        0.0, // Precio de gancho, ajusta según corresponda
      );
    } else {
      // Lógica para actualizar un producto existente
      // Asegúrate de implementar un método en ProductService para actualizar basado en el IMEI o un ID específico
    }

    // Después de guardar o actualizar, puedes volver a la pantalla anterior o mostrar un mensaje
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sellPriceController.dispose();
    _buyPriceController.dispose();
    _imeiController.dispose();
    // Asegúrate de deshacerte de todos los controladores
    super.dispose();
       }
}
