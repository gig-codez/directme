import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../controllers/CommandController.dart';
import '/routes/Routes.dart';
import 'package:care_taker/tools/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';

class SearchHelper extends StatefulWidget {
  /// Mapbox API_TOKEN
  final String apiKey;
  final TextEditingController? searchKey;

  /// Hint text to show to users
  final String? hint;

  /// Callback on Select of autocomplete result
  final void Function(MapBoxPlace place)? onSelect;

  /// if true will dismiss autocomplete widget once a result has been selected
  final bool closeOnSelect;

  /// The callback that is called when the user taps on the search icon.
  // final void Function(MapBoxPlaces place) onSearch;

  /// Language used for the autocompletion.
  ///
  /// Check the full list of [supported languages](https://docs.mapbox.com/api/search/#language-coverage) for the MapBox API
  final String language;

  /// The point around which you wish to retrieve place information.
  final Location? location;

  /// Limits the no of predections it shows
  final int? limit;

  ///Limits the search to the given country
  ///
  /// Check the full list of [supported countries](https://docs.mapbox.com/api/search/) for the MapBox API
  final String? country;

  SearchHelper({
    Key? key,
    required this.apiKey,
    this.searchKey,
    this.hint,
    this.onSelect,
    this.closeOnSelect = true,
    this.language = "en",
    this.location,
    this.limit,
    this.country,
  }) : super(key: key);

  @override
  _SearchHelperState createState() => _SearchHelperState();
}

class _SearchHelperState extends State<SearchHelper> {
  final _searchFieldTextFocus = FocusNode();

  void _selectPlace(MapBoxPlace prediction) async {
    // Calls the `onSelected` callback
    widget.onSelect!(prediction);
    widget.searchKey!.clear();
    if (widget.closeOnSelect) Routes.pop(context);
  }

  String currentValue = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CustomTextField(
          hintText: widget.hint,

          textController: widget.searchKey,
          onChanged: (input) {
            BlocProvider.of<CommandController>(context).executeComand(input, {
              "apiKey": widget.apiKey,
              "language": widget.language,
              "limit": widget.limit,
              "country": widget.country,
            });
          },
          focusNode: _searchFieldTextFocus,
          onFieldSubmitted: (value) => _searchFieldTextFocus.unfocus(),
          // onChanged: (input) => print(input),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => widget.searchKey!.clear(),
          )
        ],
      ),
      body: BlocBuilder<CommandController, Predections>(
        builder: (context, predictions) {
          return ListView.separated(
            separatorBuilder: (cx, _) => const Divider(),
            padding: const EdgeInsets.symmetric(horizontal: 15),
            itemCount: predictions.features!.length,
            itemBuilder: (ctx, i) {
              // int count = 0;
              if (i == 0) {
                speakNow("Here's what i have found");
              }
              // print(predictions.features!.length.toString());
              MapBoxPlace singlePlace = predictions.features![i];
              return ListTile(
                title: Text(singlePlace.text!),
                subtitle: Text(singlePlace.placeName!),
                onTap: () => _selectPlace(singlePlace),
              );
            },
          );
        },
      ),
    );
  }
}
