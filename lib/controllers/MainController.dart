import '/exports/exports.dart';

class MainController extends ChangeNotifier {
  MapType _type = MapType.normal;

  double _live_distance = 0;

  // get live distance
  double get live_distance => _live_distance;
  // get
  MapType get type => _type;
void setMapType(MapType value) {
    _type = value;
    notifyListeners();
  }


  // show live location updateds
  void showLiveDistance(double x){
    _live_distance = x;
    notifyListeners();
  }
}

