import 'package:cloud_firestore/cloud_firestore.dart';

class Seller {
  String? id;
  String? name;
  String? email;
  int? phone;
  String? curp;
  String? user;
  String? password;
  bool? isActive;

  Seller({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.curp,
    this.user,
    this.password,
    this.isActive = true,
  });
}

class sellersService {
  final CollectionReference sellers =
  FirebaseFirestore.instance.collection('sellers');

  Future<void> addSeller(
      String name, String email, int phone, String CURP, String user, String password) {
    return sellers.add({
      'name': name,
      'email': email,
      'phone': phone,
      'curp': CURP,
      'user': user,
      'password': password,
      'isActive': true,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateSeller(Seller seller) {
    return sellers.doc(seller.id).update({
      'name': seller.name,
      'email': seller.email,
      'phone': seller.phone,
      'curp': seller.curp,
      'user': seller.user,
      'password': seller.password,
      'isActive': seller.isActive,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deactivateSeller(String sellerId) {
    return sellers.doc(sellerId).update({
      'isActive': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Seller>> getSellers() {
    return sellers.where('isActive', isEqualTo: true).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Seller(
          id: doc.id,
          name: doc['name'],
          email: doc['email'],
          phone: doc['phone'],
          curp: doc['curp'],
          user: doc['user'],
          password: doc['password'],
          isActive: doc['isActive'],
        );
      }).toList();
    });
  }
}
