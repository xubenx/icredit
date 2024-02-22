import 'package:flutter/material.dart';
import '../model/product.dart';
import '../controller/product_service.dart';

class ProductPage extends StatelessWidget {
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
  ProductFormState createState() => ProductFormState();
}

class ProductFormState extends State<ProductForm> {
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
  final TextEditingController _miniumMountController = TextEditingController(); // Nuevo controlador para monto mínimo

  final List<String> _colors = [
    'Gris y negro', 'Blanco', 'Azul', 'Verde', 'Amarillo',
    'Gris espacial', 'Plata', 'Oro', 'Rosa', 'Negro mate',
    'Negro brillante', 'Oro rosado', 'Rojo', 'Dorado',
    'Verde noche', 'Blanco estrella', 'Medianoche',
    'Azul pacífico', 'Grafito', 'Malva', 'Azul alpino',
    'Morado oscuro', 'Negro espacial', 'Púrpura'
  ];

  final List<int> _capacities = [32, 64, 128, 256, 512, 1024, 2048];

  String? _selectedColor;
  int? _selectedCapacity;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _preLoadProductData();
    }
  }

  void _preLoadProductData() {
    final product = widget.product!;
    _nameController.text = product.name ?? '';
    _sellPriceController.text = product.sellPrice?.toString() ?? '';
    _buyPriceController.text = product.buyPrice?.toString() ?? '';
    _imeiController.text = product.imei ?? '';
    _colorController.text = product.details?['color'] ?? '';
    _storageController.text = product.details?['storage']?.toString() ?? '';
    _batteryController.text = product.details?['battery']?.toString() ?? '';
    _modelController.text = product.details?['model'] ?? '';
    _percentageController.text = product.details?['percentage']?.toString() ?? '';
    _buyPriceCreditController.text = product.buyPriceCredit?.toString() ?? '';
    _hookPriceController.text = product.hookPrice?.toString() ?? '';
    _selectedColor = product.details?['color'];
    _miniumMountController.text = product.details?['miniumMount']?.toString() ?? ''; // Asignar valor a controlador de monto mínimo
    _selectedCapacity = int.tryParse(product.details?['storage']?.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Nombre',
            hint: 'Ingresa el nombre del producto',
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _modelController,
            label: 'Modelo',
            hint: 'Ingresa el modelo',
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _sellPriceController,
            label: 'Precio de venta',
            hint: 'Ingresa el precio de venta',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _buyPriceController,
            label: 'Precio de compra',
            hint: 'Ingresa el precio de compra',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          _buildDropdownField(
            currentValue: _selectedColor,
            items: _colors,
            label: 'Color',
            onChanged: (newValue) {
              setState(() => _selectedColor = newValue);
            },
          ),
          const SizedBox(height: 10),
          _buildDropdownField(
            currentValue: _selectedCapacity?.toString(),
            items: _capacities.map((c) => c.toString()).toList(),
            label: 'Capacidad',
            onChanged: (newValue) {
              setState(() => _selectedCapacity = int.tryParse(newValue ?? ''));
            },
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _imeiController,
            label: 'IMEI',
            hint: 'Ingresa el IMEI',
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _batteryController,
            label: 'Batería',
            hint: 'Ingresa la capacidad de la batería',
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _percentageController,
            label: 'Porcentaje de ganancia',
            hint: 'Ingresa el porcentaje de ganancia',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _buyPriceCreditController,
            label: 'Precio de compra a crédito',
            hint: 'Ingresa el precio de compra a crédito',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _hookPriceController,
            label: 'Precio de enganche',
            hint: 'Ingresa el precio de gancho',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          _buildTextField(
            controller: _miniumMountController,
            label: 'Monto mínimo al mes', // Etiqueta para monto mínimo
            hint: 'Ingresa el monto mínimo', // Indicación para monto mínimo
            keyboardType: TextInputType.number, // Teclado numérico para monto mínimo
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveProduct,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  TextFormField _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      keyboardType: keyboardType,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor ingresa $label';
        }
        return null;
      },
    );
  }

  DropdownButtonFormField<String> _buildDropdownField({
    String? currentValue,
    required List<String> items,
    required String label,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: currentValue,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Por favor selecciona $label';
        }
        return null;
      },
    );
  }

  void _saveProduct() {
    // Implementación de guardado de producto
    // Esta función debe implementarse según la lógica específica de tu aplicación.
  }
}
