import 'package:care_taker/exports/exports.dart';

class AddNewLocationController extends Cubit<Marker>{
  AddNewLocationController():super(marker);

 static MarkerId markerId = MarkerId(const LatLng(6.1470738, 1.2170085).toString());

    static Marker marker = Marker(
      markerId: markerId,
      position: const LatLng(6.1470738, 1.2170085),
      infoWindow: InfoWindow(
        title: "Your Location",
        snippet:const LatLng(6.1470738, 1.2170085).toString(),
      ),
     
    );

      // markers[markerId] = marker;
  addNewAddress(LatLng point){
        String placeName = "";
    getPlaceName(point.latitude, point.longitude).then((value) {
      placeName = value;
    });
    final MarkerId markerId = MarkerId(point.toString());

    final Marker marker = Marker(
      markerId: markerId,
      position: LatLng(point.latitude, point.longitude),
      infoWindow: InfoWindow(
        title: placeName,
        snippet: point.toString(),
      ),
   
    );
    emit(marker);
  }

}