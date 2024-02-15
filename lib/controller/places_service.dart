import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  final String _baseUrl = "https://icredit-mx.web.app/"; // URL de tu servidor

  // Función para buscar lugares con autocompletado
  Future<List<dynamic>> fetchPlaces(String input) async {
    final response = await http.get(Uri.parse('$_baseUrl/places-autocomplete?input=$input'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Asume que la respuesta es una lista de lugares
      return data['predictions'];
    } else {
      // Maneja el error
      throw Exception('Failed to load places');
    }
  }
}
