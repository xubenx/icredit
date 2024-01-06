// lib/model/customer.dart
class Customer {
  String? id;
  String? name;
  String? email;
  int? phone;
  String? address;
  bool? isActive;

  Customer({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.isActive = true,
  });
}
