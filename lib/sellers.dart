import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'sellersService.dart';
class PageSellers extends StatefulWidget {
  const PageSellers({Key? key}) : super(key: key);

  @override
  _PageSellersState createState() => _PageSellersState();
}

class _PageSellersState extends State<PageSellers> {
  final sellersService sellerService = sellersService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Vendedores'),
      ),
      body: ListSellers(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddSellers(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddSellers extends StatelessWidget {
  const AddSellers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Vendedor'),
      ),
      body: _SellerForm(),
    );
  }
}

class EditSellers extends StatelessWidget {
  final Seller seller;

  const EditSellers({Key? key, required this.seller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Vendedor'),
      ),
      body: _SellerForm(seller: seller),
    );
  }
}

class _SellerForm extends StatefulWidget {
  final Seller? seller;

  const _SellerForm({Key? key, this.seller}) : super(key: key);

  @override
  __SellerFormState createState() => __SellerFormState();
}

class __SellerFormState extends State<_SellerForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _curpController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    if (widget.seller != null) {
      _nameController.text = widget.seller!.name ?? '';
      _emailController.text = widget.seller!.email ?? '';
      _phoneController.text = widget.seller!.phone?.toString() ?? '';
      _curpController.text = widget.seller!.curp ?? '';
      _userController.text = widget.seller!.user ?? '';
      _passwordController.text = widget.seller!.password ?? '';
      _isActive = widget.seller!.isActive ?? true;
    } else {
      _isActive = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sellersService sellerService = sellersService();

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
              hintText: 'Nombre del vendedor',
              labelText: 'Nombre',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese el nombre del vendedor';
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
              // Agrega validaciones de formato de correo electrónico si es necesario
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
              // Agrega validaciones adicionales para el formato del número de teléfono si es necesario
              return null;
            },
          ),
          TextFormField(
            controller: _curpController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              hintText: 'CURP',
              labelText: 'CURP',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese el CURP';
              }
              // Agrega validaciones adicionales para el formato del CURP si es necesario
              return null;
            },
          ),
          TextFormField(
            controller: _userController,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Usuario',
              labelText: 'Usuario',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese el usuario';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _passwordController,
            decoration: const InputDecoration(
              filled: true,
              hintText: 'Contraseña',
              labelText: 'Contraseña',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor, ingrese la contraseña';
              }
              // Agrega validaciones adicionales para la fortaleza de la contraseña si es necesario
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final String name = _nameController.text;
                final String email = _emailController.text;
                final int? phone = int.tryParse(_phoneController.text);
                final String CURP = _curpController.text;
                final String user = _userController.text;
                final String password = _passwordController.text;

                if (widget.seller != null) {
                  // Si hay un vendedor existente, actualiza los datos
                  final updatedSeller = Seller(
                    id: widget.seller?.id,
                    name: name,
                    email: email,
                    phone: phone,
                    curp: CURP,
                    user: user,
                    password: password,
                    isActive: _isActive,
                  );
                  await sellerService.updateSeller(updatedSeller);
                } else {
                  // Si no hay un vendedor existente, crea uno nuevo
                  await sellerService.addSeller(
                    name,
                    email,
                    phone ?? 0,
                    CURP,
                    user,
                    password,
                  );
                }

                // Vuelve a la pantalla anterior
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

class ListSellers extends StatelessWidget {
  @override
  final sellersService sellerService = sellersService();

  Widget build(BuildContext context) {
    return StreamBuilder<List<Seller>>(
      stream: sellerService.getSellers(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error al cargar los vendedores');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('No hay vendedores disponibles');
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final seller = snapshot.data![index];
              return ListTile(
                title: Text(seller.name ?? ''),
                subtitle: Text(seller.phone.toString() ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditSellers(seller: seller),
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
