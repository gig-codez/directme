import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:intl/intl.dart';
// import 'package:location/location.dart' as l;
import '../utils/config/api_keys.dart';
import '../widgets/space.dart';

// libraries to handle voice command
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
// end of commands to handle voice commands

var flutterTts = FlutterTts();
void showMessage(
    {String type = 'info',
    String? msg,
    bool float = false,
    required BuildContext context,
    double opacity = 1,
    int duration = 5,
    Animation<double>? animation}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: float ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
      content: Text(msg ?? ''),
      backgroundColor: type == 'info'
          ? Colors.lightBlue
          : type == 'warning'
              ? Colors.orange[800]!.withOpacity(opacity)
              : type == 'danger'
                  ? Colors.red[800]!.withOpacity(opacity)
                  : type == 'success'
                      ? const Color.fromARGB(255, 2, 104, 7)
                          .withOpacity(opacity)
                      : Colors.grey[600]!.withOpacity(opacity),
      duration: Duration(seconds: duration),
    ),
  );
}

/// show progress widget
void showProgress(BuildContext context, {String? text = 'Task'}) {
  showCupertinoModalPopup(
    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    context: context,
    builder: (context) => BottomSheet(
      enableDrag: false,
      backgroundColor: Colors.black12,
      onClosing: () {},
      builder: (context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SpinKitDualRing(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Theme.of(context).primaryColor),
          const Space(
            space: 0.03,
          ),
          Text(
            "$text..",
            style: const TextStyle(color: Colors.black, fontSize: 20),
          )
        ],
      ),
    ),
  );
}

String formatNumberWithCommas(int number) {
  final formatter = NumberFormat('#,###');
  return formatter.format(number);
}

//  date format
String formatDate(DateTime date) {
  return DateFormat('dd-MM-yyyy').format(date);
}
//  get current location from geolocator

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
//  l.Location location = l.Location();

// Define the geofence zones
final Map<String, LatLng> geofenceZones = {
  'Green Zone': const LatLng(0.7749, 37.4194),
  'Yellow Zone': const LatLng(0.7833, 37.4167),
  'Blue Zone': const LatLng(0.7953, 37.3934),
};
StreamSubscription<Position>? positionStreamSubscription;
// computing distance between two points
double calculateDistance(double startLatitude,double startLongitude,
    double endLatitude, double endLongitude) {
  double distance = 0.0;

  distance = Geolocator.distanceBetween(
          startLatitude, startLongitude, endLatitude, endLongitude) /
      1000;
  return distance;
}

// logic to identify change of zones
StreamSubscription<Position>? positionStream;

void startGeofencing() {
  positionStream = Geolocator.getPositionStream().listen((Position position) {
    final LatLng currentPosition =
        LatLng(position.latitude, position.longitude);

    // Check if the current position is within any geofence zone
    for (final entry in geofenceZones.entries) {
      final String zoneName = entry.key;
      final LatLng zoneCoordinates = entry.value;
      final double distance = Geolocator.distanceBetween(
        currentPosition.latitude,
        currentPosition.longitude,
        zoneCoordinates.latitude,
        zoneCoordinates.longitude,
      );

      // Define the radius of the geofence zone (in meters)
      const double geofenceRadius = 100.0;

      if (distance <= geofenceRadius) {
        showNotification('Entered $zoneName');
      }
    }
  });
}

final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
//  initialize location permissions

Future<bool> initializeLocationPermissions() async {
  LocationPermission permission;
  permission = await geolocatorPlatform.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await geolocatorPlatform.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.

      permission = await geolocatorPlatform.requestPermission();
      return false;
    }
  }
  return true;
}

// initilaize app notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
// Define notification channels
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'geofence_channel',
  'Geofence Notifications',
  importance: Importance.high,
  playSound: true,
);
// ios notification channel

void initializeNotifications() {
//  initialize both android and ios notifications
  const InitializationSettings initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('android12splash'),
      iOS: DarwinInitializationSettings());
  //
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  //  request permission for android and ios notifications

  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()!
      .requestPermission();
  // ios permission
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

// function to handle notification for change of zones
void showNotification(String message) async {
  // android notification specifics
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      const AndroidNotificationDetails(
    'geofence_notification',
    'Geofence Notifications',
    importance: Importance.max,
    priority: Priority.high,
    playSound: true,
  );
  //  ios specifics
  const DarwinNotificationDetails iosPlatformChannelSpecifics =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0,
    'Patient\'s Location',
    message,
    platformChannelSpecifics,
  );
}

// logic for finding places using voice command
final speech = stt.SpeechToText();

// Check if speech recognition is available
Future<bool> initializeSpeech() async {
  bool available = await speech.initialize();
  return available;
}

// function to capture cordinates and return location details
Future<String> getPlaceName(double latitude, double longitude) async {
  String accessToken = Config.mapboxApiKey;
  String apiUrl =
      'https://api.mapbox.com/geocoding/v5/mapbox.places/$longitude,$latitude.json?access_token=$accessToken';
  http.Response response = http.Response("", 200);
  String placeName = "";
  try {
    response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      var result = json.decode(response.body);
      if (result['features'].isNotEmpty) {
        placeName = result['features'][0]['place_name'];
        return placeName;
      } else {
        placeName = 'Place name not found';
      }
    } else {
      placeName = 'Error occurred while contacting the Mapbox Geocoding API';
    }
  } on HandshakeException catch (e) {
    debugPrint("Handshake exception: ${e.message}");
  } on http.ClientException catch (e) {
    debugPrint("Client Exception:${e.message}");
  }
  return placeName;
}

Predections placePredictions = Predections.empty();
Predections getPlaces(String input, Map<String, dynamic> w) {
  if (input.isNotEmpty) {
    String url =
        "https://api.mapbox.com/geocoding/v5/mapbox.places/$input.json?access_token=${w['apiKey']}&cachebuster=1566806258853&autocomplete=true&language=${w['language']}&limit=${w['limit']}";
    // if (widget.location != null) {
    //   url += "&proximity=${widget.location!.lng}%2C${w['location'].location!.lat}";
    // }
    if (w['country'] != null) {
      url += "&country=${w['country']}";
    }
    try {
      http.get(Uri.parse(url)).then((value) {
        // placePredictions = Predections.fromRawJson(value.body);
        var predictions = Predections.fromRawJson(value.body);
        placePredictions = predictions;
      });
    } on HandshakeException catch (e) {
      debugPrint("Handshake exception: ${e.message}");
    } on http.ClientException catch (e) {
      debugPrint("Client Exception:${e.message}");
    }
  } else {
    placePredictions = Predections.empty();
  }
  return placePredictions;
}

// speak out the text
Future<void> speakNow(String? message) async {
  await flutterTts.setVolume(1);
  await flutterTts.setSpeechRate(0.5);
  await flutterTts.setPitch(0.9);
  await flutterTts.awaitSpeakCompletion(true);
  await flutterTts.awaitSynthCompletion(true);
  // await flutterTts.setSilence(0);
  if (message != null) {
    if (message.isNotEmpty) {
      await flutterTts.speak(message);
    }
  }
}

// pause speaker
Future<void> pause() async {
  await flutterTts.pause();
}
