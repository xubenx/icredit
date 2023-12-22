
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

Future<void> seleccionarImagenesYConvertirAPdf() async {
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
            ); // Center
          },
        ));
      }
    }

    // Guarda el documento en un Blob
    Uint8List pdfBytes = await pdf.save();
    final blob = html.Blob([pdfBytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Crea un elemento de enlace para descargar el archivo
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', 'imagenes_convertidas.pdf')
      ..click();

    // Limpia la URL después de la descarga
    html.Url.revokeObjectUrl(url);
  } else {
    print("No se seleccionaron imágenes.");
  }
}
class ClientePage extends StatefulWidget {
  const ClientePage({super.key, required this.title});

  final String title;
  @override
  State<ClientePage> createState() => _ClientePageState();
}



class _ClientePageState extends State<ClientePage> {
  @override
  Widget build(BuildContext context) {
    return const CupertinoPageScaffold(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CupertinoTextField(
                placeholder: "CURP",
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CupertinoTextField(placeholder: "Ubicación"),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Text("Sube la foto de la casa:"),
                  IconButton(
                      iconSize: 72,
                      icon: Icon(Icons.file_open),
                      onPressed: seleccionarImagenesYConvertirAPdf)
                ],
              ),
            ),


          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
