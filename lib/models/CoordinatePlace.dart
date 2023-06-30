// To parse this JSON data, do
//
//     final coordinatePlace = coordinatePlaceFromJson(jsonString);

import 'dart:convert';

List<CoordinatePlace> coordinatePlaceFromJson(String str) => List<CoordinatePlace>.from(json.decode(str).map((x) => CoordinatePlace.fromJson(x)));

String coordinatePlaceToJson(List<CoordinatePlace> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CoordinatePlace {
    final String id;
    final String text;
    final String placeName;
    final List<Context> context;

    CoordinatePlace({
        required this.id,
        required this.text,
        required this.placeName,
        required this.context,
    });

    factory CoordinatePlace.fromJson(Map<String, dynamic> json) => CoordinatePlace(
        id: json["id"],
        text: json["text"],
        placeName: json["place_name"],
        context: List<Context>.from(json["context"].map((x) => Context.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "text": text,
        "place_name": placeName,
        "context": List<dynamic>.from(context.map((x) => x.toJson())),
    };
}

class Context {
    final String id;
    final String shortCode;
    final String wikidata;
    final String mapboxId;
    final String text;

    Context({
        required this.id,
        required this.shortCode,
        required this.wikidata,
        required this.mapboxId,
        required this.text,
    });

    factory Context.fromJson(Map<String, dynamic> json) => Context(
        id: json["id"],
        shortCode: json["short_code"],
        wikidata: json["wikidata"],
        mapboxId: json["mapbox_id"],
        text: json["text"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "short_code": shortCode,
        "wikidata": wikidata,
        "mapbox_id": mapboxId,
        "text": text,
    };
}
