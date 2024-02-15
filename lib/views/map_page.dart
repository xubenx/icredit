import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

void main() {
  runApp(MyAppMap());
}


class MyAppMap extends StatelessWidget {
  final String apiKey = 'AIzaSyA2eeEBJqcBHM4MBQ2sD8zc8oufNZcbzY4';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Autocompletado de Google Places'),
        ),
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return fetchSuggestions(textEditingValue.text);
                },
                onSelected: (String selection) {
                  print('Has seleccionado "$selection"');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<String>> fetchSuggestions(String input) async {
  final String url = 'https://us-central1-icredit-mx.cloudfunctions.net/api/placeAutocomplete?input=${input}&components=country:MX';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final List<dynamic> predictions = json.decode(response.body)['predictions'];
    return predictions.map((prediction) => prediction['description'] as String).toList();
  } else {
    throw Exception('Failed to load suggestions');
  }
}

