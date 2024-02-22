import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class StorageRepository {
  final FirebaseStorage storage = FirebaseStorage.instance;

  Future<List<Map<String, dynamic>>> listFiles(String path) async {
    List<Map<String, dynamic>> files = [];
    ListResult result = await storage.ref(path).listAll();

    for (var item in result.items) {
      files.add({
        'name': item.name,
        'fullPath': item.fullPath,
      });
    }

    for (var prefix in result.prefixes) {
      files.add({
        'name': prefix.name,
        'fullPath': prefix.fullPath,
        'isFolder': true,
      });
    }

    return files;
  }

  Future<TaskSnapshot> uploadFile(PlatformFile file, String destination) async {
    final ref = storage.ref(destination);
    final result = await ref.putData(file.bytes!);

    return result;
  }

// You can add more methods to handle file deletion, downloading, etc.
}
