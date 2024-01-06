// lib/views/customer_pages.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:icredit/model/customer.dart';
import 'package:icredit/controller/customer_service.dart';

class ClientePage extends StatefulWidget {
  const ClientePage({Key? key, required this.title});

  final String title;

  @override
  State<ClientePage> createState() => _ClientePageState();
}

class AddCustomer extends StatelessWidget {
  const AddCustomer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Cliente'),
      ),
      body: _CustomerForm(),
    );
  }
}

class _ClientePageState extends State<ClientePage> {
  @override
  final CustomerService customerService = CustomerService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Clientes'),
      ),
      body: ListCustomer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddCustomer(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditCustomer extends StatelessWidget {
  final Customer customer;

  const EditCustomer({Key? key, required this.customer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cliente'),
      ),
      body: _CustomerForm(customer: customer),
    );
  }
}

class ListCustomer extends StatelessWidget {
  @override
  final CustomerService customerService = CustomerService();

  Widget build(BuildContext context) {
    return StreamBuilder<List<Customer>>(
      stream: customerService.getCustomers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error al cargar los Clientes');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No hay Clientes disponibles');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final customer = snapshot.data![index];
              return ListTile(
                title: Text(customer.name ?? ''),
                subtitle: Text(customer.phone.toString() ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCustomer(customer: customer),
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

class _CustomerForm extends StatefulWidget {
  final Customer? customer;

  const _CustomerForm({Key? key, this.customer}) : super(key: key);

  @override
  __CustomerFormState createState() => __CustomerFormState();
}

class __CustomerFormState extends State<_CustomerForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameController.text = widget.customer!.name ?? '';
      _emailController.text = widget.customer!.email ?? '';
      _phoneController.text = widget.customer!.phone?.toString() ?? '';
      _addressController.text = widget.customer!.address ?? '';
      _isActive = widget.customer!.isActive ?? true;
    } else {
      _isActive = true;
    }
  }

  final CustomerService customerService = CustomerService();
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Estado'),
            value: _isActive,
            onChanged: (value) {
              setState(() {
                _isActive = value;
              });
            },
          ),
          TextFormField(
            controller: _nameController,
            autofocus: true,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Nombre del cliente',
              labelText: 'Nombre',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese el nombre del cliente';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Correo electrónico',
              labelText: 'Email',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese el correo electrónico';
              }
              // Add email format validation if needed
              return null;
            },
          ),
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Número de teléfono',
              labelText: 'Teléfono',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese el número de teléfono';
              }
              // Add additional phone number format validation if needed
              return null;
            },
          ),
          TextFormField(
            controller: _addressController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Dirección',
              labelText: 'Dirección',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese la dirección';
              }
              return null;
            },
          ),
          Row(
            children: <Widget>[
              Text('Cargar documentos'),
              IconButton(
                onPressed: null,
                icon: const Icon(Icons.upload_file),
                iconSize: 45,
                tooltip: 'Ingresé las fotos del contrario, domicilio, INE y del celular entregado.',
              ),
            ],
          ),


          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final String name = _nameController.text;
                final String email = _emailController.text;
                final int? phone = int.tryParse(_phoneController.text);
                final String address = _addressController.text;

                if (widget.customer != null) {
                  // If there's an existing customer, update the data
                  final updatedCustomer = Customer(
                    id: widget.customer?.id,
                    name: name,
                    email: email,
                    phone: phone,
                    address: address,
                    isActive: _isActive,
                  );
                  // Call your customer service update method here
                  await customerService.updateCustomer(updatedCustomer);
                } else {
                  await customerService.addCustomer(
                      name, email, phone ?? 0, address);
                }

                // Go back to the previous screen
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
