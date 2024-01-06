
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:firebase_storage/firebase_storage.dart';
import '../model/customer.dart';

class CustomerService {
  final CollectionReference customers =
  FirebaseFirestore.instance.collection('customers');

  Future<void> addCustomer(


      String name, String email, int phone, String address) {
    return customers.add({
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'isActive': true,
      'timestamp': FieldValue.serverTimestamp(),
    });


  }

  Future<void> updateCustomer(Customer customer) {
    return customers.doc(customer.id).update({
      'name': customer.name,
      'email': customer.email,
      'phone': customer.phone,
      'address': customer.address,
      'isActive': customer.isActive,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deactivateCustomer(String customerId) {
    return customers.doc(customerId).update({
      'isActive': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<Customer>> getCustomers() {
    return customers
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Customer(
          id: doc.id,
          name: doc['name'],
          email: doc['email'],
          phone: doc['phone'],
          address: doc['address'],
          isActive: doc['isActive'],
        );
      }).toList();
    });
  }
  Future<void> seleccionarImagenesYConvertirAPdf(String userId) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      final pdf = pw.Document();

      for (final file in result.files) {
        final Uint8List? imageData = file.bytes;
        if (imageData != null) {
          final image = pw.MemoryImage(imageData);

          pdf.addPage(pw.Page(
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image),
              );
            },
          ));
        }
      }

      Uint8List pdfBytes = await pdf.save();

      String fileName = '${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Subir el archivo PDF a Firebase Storage

      Reference storageReference = FirebaseStorage.instance.ref().child('pdfs/$userId/$fileName');

      UploadTask uploadTask = storageReference.putData(pdfBytes);

      await uploadTask.whenComplete(() => print('PDF uploaded successfully'));

      // Obtener la URL del archivo PDF en Firebase Storage
      String pdfUrl = await storageReference.getDownloadURL();

      // Ahora puedes utilizar pdfUrl según tus necesidades (por ejemplo, guardarlo en Firestore).
      return customers.doc(userId).update({
        'documents': pdfUrl,
      });

    } else {
      print("No se seleccionaron imágenes.");
    }
  }
}
