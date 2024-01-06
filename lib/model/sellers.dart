// lib/model/sellers.dart
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
