import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Asegúrate de que la ruta del import coincida con la ubicación de tu archivo PlacesService
import 'package:icredit/controller/places_service.dart';

class MySearchWidget extends StatefulWidget {
  @override
  _MySearchWidgetState createState() => _MySearchWidgetState();
}

class _MySearchWidgetState extends State<MySearchWidget> {
  final PlacesService _placesService = PlacesService();
  List<dynamic> _places = [];
  GoogleMapController? _mapController;
  LatLng _currentLatLng = LatLng(-34.603684, -58.381559); // Un valor por defecto

  void _onSearchChanged(String value) async {
    final places = await _placesService.fetchPlaces(value);
    setState(() {
      _places = places;
    });
    // Opcional: Ajusta la ubicación del mapa basado en los resultados de la búsqueda
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buscador de Lugares'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar ubicación...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _currentLatLng,
                zoom: 14.0,
              ),
            ),
          ),
          // Agrega aquí la visualización de los resultados de búsqueda si es necesario.
        ],
      ),
    );
  }
}
