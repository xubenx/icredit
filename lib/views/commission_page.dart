  import 'package:flutter/cupertino.dart';
  import 'package:flutter/material.dart';
  import 'package:icredit/controller/sales_service.dart';
  import 'package:icredit/controller/sellers_service.dart';
  import 'package:icredit/model/Payment.dart';
  import 'package:icredit/model/sellers.dart';

  class CommissionsPage extends StatelessWidget {
    final String? sellerId; // Make sellerId optional
    final String? role;
    const CommissionsPage({Key? key,required  this.sellerId,required this.role}) : super(key: key); // Accept sellerId as a parameter

    @override
    Widget build(BuildContext context) {
      if (sellerId != null && role != 'admin') {
        // If a sellerId is provided, go directly to that seller's commissions
        return SellerCommissionsPage(sellerId: sellerId!, role: role!,);
      } else {
        // Otherwise, show the list of all sellers with commissions
        return ListSellersWithCommissions(role: role!, id: sellerId!,);
      }
    }
  }

  class ListSellersWithCommissions extends StatelessWidget {
    final SellersService sellerService = SellersService();
    final String role;
    final String id;

    ListSellersWithCommissions({Key? key, required this.role,required this.id});
    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vendedores'),
          // Include other AppBar properties if needed
        ),
        body: StreamBuilder<List<Seller>>(
          stream: sellerService.getSellers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error al cargar los vendedores');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No hay vendedores disponibles');
            } else {
              return Material( // Still wrapped with Material for visual effects on ListTile
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final seller = snapshot.data![index];
                    return ListTile(
                      title: Text(seller.name ?? ''),
                      subtitle: Text(seller.phone.toString() ?? ''),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SellerCommissionsPage(sellerId: seller.id!, role: '',),
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            }
          },
        ),
      );
    }
  }


  class SellerCommissionsPage extends StatelessWidget {
    final String sellerId;
    final String role;
    const SellerCommissionsPage({Key? key, required this.sellerId, required this.role,}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Detalle de Comisiones'),
        ),
        body: CommissionsList(sellerId: sellerId, role: role), // We will create this next.
      );
    }
  }
  class CommissionsList extends StatefulWidget {
    final String sellerId;
    final String role; // Role added to determine the UI and functionality

    const CommissionsList({
      Key? key,
      required this.sellerId,
      required this.role, // Accept the role here
    }) : super(key: key);

    @override
    _CommissionsListState createState() => _CommissionsListState();
  }

  class _CommissionsListState extends State<CommissionsList> {
    double totalPending = 0.0;
    double totalPaid = 0.0;

    @override
    Widget build(BuildContext context) {
      final salesService = SalesService();

      return StreamBuilder<List<Payment>>(
        stream: salesService.getPaymentsForSeller(widget.sellerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Text('No hay comisiones disponibles');
          } else {
            // Calculate totals
            totalPending = 0.0;
            totalPaid = 0.0;

            List<Payment> payments = snapshot.data!;
            payments.sort((a, b) => a.date.compareTo(b.date));

            // Sum up the total pending and paid amounts
            for (var payment in payments) {
              if (payment.commissionStatus == 'Pendiente') {
                totalPending += payment.amountCommission;
              } else if (payment.commissionStatus == 'Pagado') {
                totalPaid += payment.amountCommission;
              }
            }

            return Column(
              children: [
                // Display total pending and total paid in a more prominent way
                _buildTotalDisplay('Total Pendiente', totalPending, Colors.orange),
                _buildTotalDisplay('Total Pagado', totalPaid, Colors.green),
                Expanded(
                  child: ListView.builder(
                    itemCount: payments.length,
                    itemBuilder: (context, index) {
                      var payment = payments[index];
                      Color color;
                      switch (payment.commissionStatus) {
                        case 'Pendiente':
                          color = Colors.orange;
                          break;
                        case 'Pagado':
                          color = Colors.green;
                          break;
                        case 'Retraso':
                          color = Colors.red;
                          break;
                        default:
                          color = Colors.grey;
                      }
                      return ListTile(
                        title: Text('Venta ID: ${payment.saleId}'),
                        subtitle: Text('Comisión: ${payment.amountCommission}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              payment.commissionStatus,
                              style: TextStyle(color: color),
                            ),
                            // Conditionally display an icon button for users with specific roles
                            if (widget.role != 'seller') // This check is added
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.grey),
                                onPressed: () async {
                                  int paymentIndex = index; // El índice del elemento que se va a editar.
                                  String newStatus = 'Pagado'; // El nuevo estado que queremos establecer.

                                  try {
                                    await salesService.updateCommissionStatus(payment.saleId, paymentIndex, newStatus);
                                    // Actualiza la UI después del éxito
                                    setState(() {
                                      // Actualiza tu lista de pagos o el estado de tu interfaz de usuario según sea necesario.
                                    });
                                  } catch (error) {
                                    // Manejo de errores en la interfaz de usuario
                                    final snackBar = SnackBar(content: Text('Error al actualizar: $error'));
                                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                  }
                                },
                              ),


                          ],
                        ),
                        tileColor: color.withOpacity(0.2),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      );
    }

    Widget _buildTotalDisplay(String title, double total, Color color) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        color: color,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    void _changePaymentStatus(Payment payment, int paymentIndex) {
      final salesService = SalesService();
      String newStatus = 'Pagado'; // O el nuevo estado que desees establecer

      salesService.updateCommissionStatus(payment.saleId, paymentIndex, newStatus)
          .then((_) {
        // Actualización exitosa, puedes actualizar la UI si es necesario
        setState(() {
          // Actualiza el estado de tu UI aquí si es necesario
        });
      }).catchError((error) {
        // Maneja el error aquí
        print("Ocurrió un error al actualizar el estado: $error");
      });
    }

  }
