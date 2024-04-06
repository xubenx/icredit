import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyAppMap(onLocationSelected: (lat , lng , adress) {  },));
}

class MyAppMap extends StatefulWidget {
  final Function(double, double, String) onLocationSelected;

  MyAppMap({Key? key, required this.onLocationSelected}) : super(key: key);

  @override
  _MyAppMapState createState() => _MyAppMapState();
}


class _MyAppMapState extends State<MyAppMap> {
  String _selectedAddress = '';

  final String apiKey = 'AIzaSyA2eeEBJqcBHM4MBQ2sD8zc8oufNZcbzY4';
  GoogleMapController? mapController; // Controlador del GoogleMap
  final LatLng _center = const LatLng(21.0200542,-101.8909784);
  Set<Marker> _markers = {}; // Conjunto de marcadores para el mapa

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Esta función actualiza el mapa y añade un marcador en la ubicación seleccionada
  Future<void> _moveToSelectedLocation(double lat, double lng) async {
    mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: 14.0,
    )));

    final String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      String address = data['results'][0]['formatted_address'];

      setState(() {
        _markers.clear(); // Limpia marcadores existentes
        _markers.add(
          Marker(
            markerId: MarkerId('selectedLocation'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: 'Ubicación Seleccionada', snippet: address),
          ),
        );
        _selectedAddress = address; // Guarda la dirección obtenida en una variable de estado
        widget.onLocationSelected(lat, lng, _selectedAddress); // Llama a la función onLocationSelected con las coordenadas

      });
    } else {
      throw Exception('Failed to load address');
    }
  }


  Future<void> _onSelected(String placeId) async {
    final String url = 'https://us-central1-icredit-mx.cloudfunctions.net/api/placeDetails?place_id=${placeId}';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      double lat = data['lat'];
      double lng = data['lng'];
      _moveToSelectedLocation(lat, lng);
    } else {
      throw Exception('Failed to load place details');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
            children: [
              Autocomplete<Map<String, dynamic>>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text == '') {
                    return const Iterable<Map<String, dynamic>>.empty();
                  }
                  return fetchSuggestions(textEditingValue.text);
                },
                displayStringForOption: (Map<String, dynamic> option) => option['description'],
                onSelected: (Map<String, dynamic> selection) {
                  _onSelected(selection['place_id']);
                },
                fieldViewBuilder: (
                    BuildContext context,
                    TextEditingController fieldTextEditingController,
                    FocusNode fieldFocusNode,
                    VoidCallback onFieldSubmitted,
                    ) {
                  return TextField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: InputDecoration(
                      hintText: "Escribe para buscar...", // Aquí va tu texto de placeholder
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                    onSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                  );
                },
              ),
              SizedBox(height: 10),



              Container(
                height: 300, // Ajusta según necesites
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(target: _center, zoom: 12.0),
                  markers: _markers,
                ),
              ),
              Text(_selectedAddress), // Muestra la dirección seleccionada
            ],
          );
  }

  Future<List<Map<String, dynamic>>> fetchSuggestions(String input) async {
    final String url = 'https://us-central1-icredit-mx.cloudfunctions.net/api/placeAutocomplete?input=${input}&components=country:MX';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final List<dynamic> predictions = json.decode(response.body)['predictions'];
      return predictions.map((prediction) => {
        'description': prediction['description'],
        'place_id': prediction['place_id'], // Incluye el place_id
      }).toList();
    } else {
      throw Exception('Failed to load suggestions');
    }
  }


}
