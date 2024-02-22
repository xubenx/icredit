import 'package:file_picker/file_picker.dart';
import 'package:icredit/model/files_manager.dart';

class StorageController {
  final StorageRepository storageRepository;

  StorageController(this.storageRepository);

  Future<List<Map<String, dynamic>>> getFiles(String path) async {
    return await storageRepository.listFiles(path);
  }

  Future<void> uploadFile(String destination) async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.bytes != null) {
      await storageRepository.uploadFile(result.files.single, destination);
    }
  }

// Add more methods as needed for other file operations
}
