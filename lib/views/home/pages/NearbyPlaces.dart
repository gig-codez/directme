// ignore_for_file: depend_on_referenced_packages

import 'package:directme/utils/config/api_keys.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'dart:async';

import 'package:google_maps_webservice/places.dart';
class NearbyPlacesScreen extends StatefulWidget {
  final LatLng destination;

  NearbyPlacesScreen({required this.destination});

  @override
  _NearbyPlacesScreenState createState() => _NearbyPlacesScreenState();
}

class _NearbyPlacesScreenState extends State<NearbyPlacesScreen> {
  GoogleMapController? _mapController;
  List<Marker> _markers = [];

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> _searchNearbyPlaces(String type) async {
    final response = await PlacesAutocomplete.show(
      context: context,
      apiKey: Config.androidApiKey,
      mode: Mode.overlay,
      language: 'en',
      types: [type],
      components: [
        Component(Component.country, 'ug'),
      ],
      location: Location(lat:widget.destination.latitude, lng:widget.destination.longitude),
      radius: 1000,
    );

    if (response != null) {
      // setState(() {
      //   _markers = response.matchedSubstrings.map((prediction) {
      //     return Marker(
      //       markerId: MarkerId(prediction.placeId),
      //       position: prediction.latLng!,
      //       infoWindow: InfoWindow(
      //         title: prediction.description,
      //       ),
      //     );
      //   }).toList();
      // });

      // _mapController?.animateCamera(
      //   CameraUpdate.newLatLng(response.predictions.first.latLng!),
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nearby Places'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.destination,
              zoom: 14.0,
            ),
            markers: Set<Marker>.from(_markers),
          ),
          Positioned(
            top: 16.0,
            left: 16.0,
            right: 16.0,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _searchNearbyPlaces('restaurant'),
                    child: Text('Restaurants'),
                  ),
                ),
                SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _searchNearbyPlaces('hospital'),
                    child: Text('Hospitals'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
