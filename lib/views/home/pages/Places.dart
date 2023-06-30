// ignore_for_file: library_private_types_in_public_api, deprecated_member_use

import '/controllers/ToggleVoiceController.dart';
import '/widgets/space.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../controllers/CommandController.dart';
import '/controllers/AddNewLocationController.dart';
import '/exports/exports.dart';
import 'widgets/SearchHelper.dart';

class Places extends StatefulWidget {
  const Places({super.key, required this.currentPlace});
  final String currentPlace;
  @override
  _PlacesState createState() => _PlacesState();
}

class _PlacesState extends State<Places> {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  TextEditingController searchController = TextEditingController();
  bool _isListening = false;
  String _searchText = "";
  //  function to handle listening
  void listen() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() {
          _isListening = true;
        });
        _speechToText.listen(onResult: (result) {
          setState(() {
            _searchText = result.recognizedWords;
          });
          int count = 0;
          // navigate to results page after voice command
          if (_searchText.isNotEmpty) {
            if (count == 0) {
              context.read<CommandController>().executeComand(_searchText, {
                  "apiKey": Config.mapboxApiKey,
                  "language": "en",
                  "limit":30,
                  "country": "UG",
                });
              Routes.push(
                context,
                SearchHelper(
                  country: "UG",
                  searchKey: TextEditingController(text: _searchText),
                  apiKey: Config.mapboxApiKey,
                  hint: "Select starting point",
                  onSelect: (place) {
                    _startPointController.text = place.placeName ?? "";
                    setState(() {
                      coordinates = place.geometry!.coordinates!.join(",");
                    });
                  },
                  limit: 20,
                ),
              );
              setState(() {
              count++;
                _isListening = true;
              });
            }
          }
        });
      }
    } else {
      setState(() {
        _isListening = false;
        _speechToText.stop();
      });
    }
  }

  @override
  void initState() {
    super.initState();
  }

  final _startPointController = TextEditingController();
  String coordinates = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text("Find routes",
                  style: Theme.of(context).textTheme.headline6),
            ),
            ListTile(
                leading: const Icon(Icons.my_location),
                title: Text("Your location: ${widget.currentPlace}")),
            const Space(
              space: 0.03,
            ),
            CustomTextField(
              hintText: "Select your destination point",
              prefixIcon: const Icon(Icons.location_on_rounded),
              textController: _startPointController,
              onTap: () {
                // navigate to results page after voice command
                Routes.push(
                  context,
                  SearchHelper(
                    country: "UG",
                    searchKey: TextEditingController(text: _searchText),
                    apiKey: Config.mapboxApiKey,
                    hint: "Select starting point",
                    onSelect: (place) {
                      _startPointController.text = place.placeName ?? "";
                      setState(() {
                        coordinates = place.geometry!.coordinates!.join(",");
                      });
                    },
                    limit: 20,
                  ),
                );
                // update the points on the map
              },
              enabled: true,
            ),
            const Space(space: 0.03),
            if (coordinates.isNotEmpty)
              StreamBuilder<Position>(
                  stream: GeolocatorPlatform.instance.getPositionStream(),
                  builder: (context, snapshot) {
                    var position = snapshot.data;

                    if (coordinates.isNotEmpty) {
                      BlocProvider.of<AddNewLocationController>(context)
                          .addNewAddress(
                        LatLng(
                          double.parse(coordinates.split(",")[1]),
                          double.parse(coordinates.split(",")[0]),
                        ),
                      );
                      if (snapshot.hasData) {
                        String distance = calculateDistance(
                                position!.latitude,
                                position.longitude,
                                double.parse(coordinates.split(",")[1]),
                                double.parse(coordinates.split(",")[0]))
                            .toStringAsFixed(2);
                        Future.delayed(const Duration(seconds: 45), () async {
                          BlocProvider.of<ToggleVoiceController>(context).state
                              ? await speakNow(
                                  "You're currently left with $distance kilometers to ${_startPointController.text.split(",")[0]}.")
                              : await pause();
                        });
                      }
                    }
                    return snapshot.hasData
                        ? ListTile(
                            leading: const Icon(Icons.directions),
                            title: Text(
                              "Distance to be covered",
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall!
                                  .copyWith(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16),
                            ),
                            trailing: Text(
                              "${calculateDistance(position!.latitude, position.longitude, double.parse(coordinates.split(",")[1]), double.parse(coordinates.split(",")[0])).toStringAsFixed(2)} KM",
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              "Speed ${((position.speed * 0.001) / (1 / 3600)).toStringAsFixed(2)} (kM/h)",
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          )
                        : const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                  }),
            Center(
              child: Text(_isListening ? "Listening" : "Not Listening"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _searchText,
                style: const TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: listen,
        heroTag: null,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
