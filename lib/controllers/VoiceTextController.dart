
import '../exports/exports.dart';

class VoiceTextController extends Cubit<String>{
  VoiceTextController():super("");
  captureTextVoices(){

  initializeSpeech().then((available) {
    if (available) {
      speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            String spokenText = result.recognizedWords;
            debugPrint('Spoken Text: $spokenText');
              emit(spokenText);
            // Use Google Maps Geocoding API to convert spoken text to coordinates
            // convertToCoordinates(spokenText).then((location) {
            //   debugPrint('Location: $location');
            //   // Use the location coordinates for further processing or display
            // }).catchError((error) {
            //   debugPrint('Error: $error');
            // });
          }
        },
      );
    } else {
      debugPrint('Speech recognition not available');
    }
  });
  }
}