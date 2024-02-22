import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:icredit/controller/files_manager_service.dart';
import 'package:icredit/model/files_manager.dart';

void main() {
  runApp(MyAppFileManager());
}

class MyAppFileManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Asegúrate de inicializar Firebase aquí si aún no lo has hecho.

    // Crear el controlador con el modelo (repositorio).
    final storageController = StorageController(StorageRepository());

    return MaterialApp(
      title: 'Flutter Firebase Storage Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: StoragePage(controller: storageController),
    );
  }
}


class StoragePage extends StatefulWidget {
  final StorageController controller;

  StoragePage({required this.controller});

  @override
  _StoragePageState createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  late List<Map<String, dynamic>> files;
  String currentPath = '';

  @override
  void initState() {
    super.initState();
    _listFiles();
  }

  Future<void> _listFiles() async {
    files = await widget.controller.getFiles(currentPath);
    setState(() {});
  }

  Future<void> _uploadFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.bytes != null) {
      final confirmation = await _showUploadDialog();
      if (confirmation) {
        final destination = currentPath + result.files.single.name;
        await widget.controller.uploadFile(destination);
        _listFiles(); // Refresh the file list
      }
    }
  }

  Future<bool> _showUploadDialog() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Upload'),
        content: Text('Are you sure you want to upload this file?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(false),
          ),
          TextButton(
            child: Text('Upload'),
            onPressed: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    ) ?? false; // The dialog returns null if dismissed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Storage Manager'),
      ),
      body: ListView.builder(
        itemCount: files.length,
        itemBuilder: (context, index) {
          final file = files[index];
          return ListTile(
            title: Text(file['name']),
            trailing: file['isFolder'] ? Icon(Icons.folder) : Icon(Icons.file_present),
            onTap: () {
              if (file['isFolder']) {
                setState(() {
                  currentPath = file['fullPath'];
                });
                _listFiles(); // Refresh the list for the new path
              } else {
                // Download or perform actions on the file
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        tooltip: 'Upload File',
        child: Icon(Icons.add),
      ),
    );
  }
}
