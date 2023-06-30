// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api

// import 'package:location/location.dart' as l;
import 'package:geolocator/geolocator.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../controllers/AddNewLocationController.dart';
import '../../../controllers/ToggleVoiceController.dart';
import '../../../exports/exports.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'Places.dart';

final Set<Map<String, dynamic>> geofenceZones = {
  {
    'zone': 'Green Zone',
    'pos': const LatLng(0.2575137, 32.5451041),
    'color': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    'c': Colors.greenAccent,
  },
  {
    'zone': 'Red Zone',
    'pos': const LatLng(0.2675137, 32.5451041),
    'color': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    'c': Colors.redAccent,
  },
  {
    'zone': 'Yellow Zone',
    'pos': const LatLng(0.2875137, 32.5451041),
    'color': BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
    'c': Colors.yellowAccent,
  },
};

class DistanceBetweenTwoPoints extends StatefulWidget {
  const DistanceBetweenTwoPoints({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => DistanceBetweenTwoPointsState();
}

class DistanceBetweenTwoPointsState extends State<DistanceBetweenTwoPoints> {
  DistanceBetweenTwoPointsState();
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
  PolylinePoints polylinePoints = PolylinePoints();

  GoogleMapController? controller;
  LatLng? markerPosition;
  MarkerId? selectedMarker;

  final GlobalKey<ScaffoldState> _key = GlobalKey();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    BlocProvider.of<LocationController>(context).updateLocation();
    super.initState();
  }

  String placeName = "";
  void _add(LatLng point) {
    getPlaceName(point.latitude, point.longitude).then((value) {
      setState(() {
        placeName = value;
      });
    });
    final MarkerId markerId = MarkerId(point.toString());

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(point.latitude, point.longitude),
      infoWindow: InfoWindow(
        title: placeName,
        snippet: point.toString(),
      ),
      onTap: () => _onMarkerTapped(markerId),
    );
    setState(() {
      markers[markerId] = marker;
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    this.controller = controller;
  }

  void _onMarkerTapped(MarkerId markerId) {
    final Marker? tappedMarker = markers[markerId];
    if (tappedMarker != null) {
      setState(() {
        final MarkerId? previousMarkerId = selectedMarker;
        if (previousMarkerId != null && markers.containsKey(previousMarkerId)) {
          final Marker resetOld = markers[previousMarkerId]!
              .copyWith(iconParam: BitmapDescriptor.defaultMarker);
          markers[previousMarkerId] = resetOld;
        }
        selectedMarker = markerId;
        final Marker newMarker = tappedMarker.copyWith(
          iconParam: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        );
        markers[markerId] = newMarker;

        markerPosition = null;
      });
    }
  }

  bool isPaused = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      body: Stack(
        children: [
          SlidingUpPanel(
            parallaxEnabled: true,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            body: StreamBuilder<Position>(
                stream:
                    GeolocatorPlatform.instance.getCurrentPosition().asStream(),
                builder: (context, snapshot) {
                  var location = snapshot.data;

                  return snapshot.hasData
                      ? BlocBuilder<AddNewLocationController, Marker>(
                          builder: (context, newAddress) {
                            getPlaceName(location!.latitude, location.longitude)
                                .then((value) {
                              setState(() {
                                placeName = value;
                              });
                            });
                            markers[newAddress.mapsId] = newAddress;
                            return GoogleMap(
                              mapType: MapType.normal,
                              trafficEnabled: true,
                              myLocationEnabled: true,
                              markers: {
                                Marker(
                                    markerId: MarkerId(
                                      LatLng(location.latitude,
                                              location.longitude)
                                          .toString(),
                                    ),
                                    position: LatLng(
                                        location.latitude, location.longitude)),
                                ...markers.values.toSet(),
                              },
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                    location!.latitude, location.longitude),
                                zoom: 17.0,
                              ),
                              zoomControlsEnabled: true,
                              // onTap: _add,
                            );
                          },
                        )
                      : const Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator.adaptive(),
                              SizedBox(height: 20),
                              Text("Loading your current location, please wait...",style: TextStyle(fontSize: 15),),
                            ],
                          ),
                        );
                }),
            panel: Places(
              currentPlace: placeName,
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: InkWell(
              onTap: () =>
                  BlocProvider.of<ToggleVoiceController>(context).toggleVoice(),
              child: BlocBuilder<ToggleVoiceController, bool>(
                builder: (context, toggleSpeak) {
                  return CircleAvatar(
                    radius: 25,
                    child: Icon(
                      toggleSpeak
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      size: 25,
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          GeolocatorPlatform.instance
              .getCurrentPosition()
              .asStream()
              .listen((event) {
            final LatLng position = LatLng(event.latitude, event.longitude);
            // move camera to new position
            controller!.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                target: position,
                zoom: 17.0,
              ),
            ));
            // add marker
            _add(position);
          });
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }
}
