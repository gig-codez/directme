import '/exports/exports.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:http/http.dart' as http;
class CommandController extends Cubit<Predections>{
  CommandController() : super(placePredictions);
   static Predections placePredictions = Predections.empty();

  executeComand(String input,Map<String, dynamic> w){
 
      if (input.isNotEmpty) {
      String url =
          "https://api.mapbox.com/geocoding/v5/mapbox.places/$input.json?access_token=${w['apiKey']}&cachebuster=1566806258853&autocomplete=true&language=${w['language']}&limit=${w['limit']}";
      // if (widget.location != null) {
      //   url += "&proximity=${widget.location!.lng}%2C${w['location'].location!.lat}";
      // }
      if (w['country'] != null) {
        url += "&country=${w['country']}";
      }
       http.get(Uri.parse(url)).then((value) {
          var predictions = Predections.fromRawJson(value.body);
          placePredictions = predictions;
       });
      // print(response.body);
    } else {
    placePredictions = Predections.empty();
    }
    emit(placePredictions);
  }
}