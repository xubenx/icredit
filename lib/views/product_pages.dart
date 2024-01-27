// lib/views/products_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import '../model/product.dart';
import '../controller/product_service.dart';

class PageProducts extends StatefulWidget {
  const PageProducts({Key? key}) : super(key: key);

  @override
  PageProductsState createState() => PageProductsState();
}

class PageProductsState extends State<PageProducts> {
  final ProductService productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar: AppBar(
        title: const Text('Lista de Productos'),
      ),

      body: ListProducts(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProduct(),
            ),
          );
        },
        child: const Icon(Icons.add),

      ),
    );
  }
}

class ListProducts extends StatelessWidget {
  final ProductService productService = ProductService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: productService.getProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error al cargar los productos');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No hay productos disponibles');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final product = snapshot.data![index];
              return ListTile(
                title: Text(product.name ?? ''),
                subtitle: Text('Precio de venta: ${product.sellPrice}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProduct(product: product),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
      },
    );
  }
}

class AddProduct extends StatelessWidget {
  const AddProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Producto'),
      ),
      body: ProductForm(),
    );
  }
}

class EditProduct extends StatelessWidget {
  final Product product;

  const EditProduct({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Producto'),
      ),
      body: ProductForm(product: product),
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
  final List<String> _colors = [
    'Gris y negro',
    'Blanco',
    'Azul',
    'Verde',
    'Rosa',
    'Amarillo',
    'Gris espacial',
    'Plata',
    'Oro',
    'Rosa',
    'Negro mate',
    'Negro brillante',
    'Oro rosado',
    'Rojo',
    'Dorado',
    'Verde noche',
    'Blanco estrella',
    'Medianoche',
    'Azul pacífico',
    'Grafito',
    'Malva',
    'Azul alpino',
    'Morado oscuro',
    'Negro espacial',
    'Púrpura'
  ];
  final List<int> _capacities = [32, 64, 128, 256, 512, 1024, 2048];
  String? _selectedColor;
  int? _selectedCapacity;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name ?? '';
      _sellPriceController.text = widget.product!.sellPrice?.toString() ?? '';
      _buyPriceController.text = widget.product!.buyPrice?.toString() ?? '';
      _imeiController.text = widget.product!.imei ?? '';
      _colorController.text = widget.product!.details?['color'] ?? '';
      _storageController.text = widget.product!.details?['storage']?.toString() ?? '';
      _batteryController.text = widget.product!.details?['battery']?.toString() ?? '';
      _modelController.text = widget.product!.details?['model'] ?? '';
      _percentageController.text = widget.product!.details?['percentage']?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final ProductService productService = ProductService();

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: [
          // Other fields remain the same
          TextFormField(
            controller: _imeiController,
            decoration: const InputDecoration(
              filled: true,
              labelText: 'IMEI',
              hintText: 'Enter IMEI',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an IMEI';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              filled: true,

              labelText: 'Name',
              hintText: 'Enter product name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _modelController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Model',
              labelText: 'Model',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el model';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _sellPriceController,
            decoration: const InputDecoration(
              filled: true,

              labelText: 'Sell Price',
              hintText: 'Enter selling price',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a selling price';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _buyPriceController,
            decoration: const InputDecoration(
              filled: true,

              labelText: 'Buy Price',
              hintText: 'Enter buying price',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a buying price';
              }
              return null;
            },
          ),

          DropdownButtonFormField<String>(
            value: _selectedColor,
            items: _colors.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            decoration: const InputDecoration(
              filled: true,
              labelText: 'Color',
            ),
            onChanged: (String? newValue) {
              setState(() {
                _selectedColor = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a color';
              }
              return null;
            },
          ),
          DropdownButtonFormField<int>(
            value: _selectedCapacity,
            items: _capacities.map((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text('$value GB'),
              );
            }).toList(),
            decoration: const InputDecoration(
              filled: true,
              labelText: 'Capacity',
            ),
            onChanged: (int? newValue) {
              setState(() {
                _selectedCapacity = newValue;
              });
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a capacity';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _batteryController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Battery',
              labelText: 'Battery',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa la battery';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _percentageController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Porcentaje',
              labelText: 'Porcentaje',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingresa el porcentaje';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                // Add or update product
                if (widget.product == null) {
                  await productService.addProduct(
                    _nameController.text,
                    double.parse(_sellPriceController.text),
                    double.parse(_buyPriceController.text),
                    _imeiController.text,
                    {
                      'color': _colorController.text,
                      'storage': _selectedCapacity,
                      'battery': int.parse(_batteryController.text),
                      'model': _modelController.text,
                      'percentage': int.parse(_percentageController.text),
                    },
                  );
                } else {
                  await productService.updateProduct(
                    Product(
                      id: widget.product!.id,
                      name: _nameController.text,
                      sellPrice: double.parse(_sellPriceController.text),
                      buyPrice: double.parse(_buyPriceController.text),
                      imei: _imeiController.text,
                      details: {
                        'color': _colorController.text,
                        'storage': int.parse(_storageController.text),
                        'battery': int.parse(_batteryController.text),
                        'model': _modelController.text,
                        'percentage': int.parse(_percentageController.text),
                      },
                    ),
                  );
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}