import 'package:care_taker/exports/exports.dart';
import 'package:geolocator/geolocator.dart';

class LocationController extends Cubit<LatLng> {
  LocationController() : super(center);

  static const LatLng center = LatLng(6.1470738, 1.2170085);

  void updateLocation() {
    GeolocatorPlatform.instance.getCurrentPosition().then((event) {
      final LatLng position = LatLng(event.latitude, event.longitude);
      emit(position);
    });
  }
}
