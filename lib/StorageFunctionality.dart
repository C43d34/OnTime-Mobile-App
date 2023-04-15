import 'dart:convert';
import "main.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

///Handle Database queries and local storage queries

class Commute
{
  final bool AM_true;
  final int arrival_time;
  final int avg_drive_time;
  final int avg_walk_time;
  final bool departure_AM_true;
  final int departure_time;
  final String destination;
  final int entry_color;
  final GeoPoint final_position;
  final GeoPoint initial_position;
  final String title;
  final int times_commuted;

  Commute({required this.times_commuted,required this.AM_true, required this.arrival_time, required this.avg_drive_time, required this.avg_walk_time, required this.departure_AM_true, required this.departure_time, required this.destination, required this.entry_color, required this.final_position, required this.initial_position, required this.title});

  Commute.fromJson(Map<String, dynamic> json)
      : times_commuted = json["times_commuted"],
        AM_true = json["AM_true"],
        arrival_time = json["arrival_time"],
        avg_drive_time = json["avg_drive_time"],
        avg_walk_time = json["avg_walk_time"],
        departure_AM_true = json["departure_AM_true"],
        departure_time = json["departure_time"],
        destination = json["destination"],
        entry_color = json["entry_color"],
        final_position = GeoPoint.fromJson(json["final_position"]),
        initial_position = GeoPoint.fromJson(json["initial_position"]),
        title = json["title"];

  Map<String, dynamic> toJson() => {
    'times_commuted': times_commuted,
    'AM_true': AM_true,
    'arrival_time': arrival_time,
    'avg_drive_time' : avg_drive_time,
    'avg_walk_time' : avg_walk_time,
    'departure_AM_true' : departure_AM_true,
    'departure_time' : departure_time,
    'destination' : destination,
    'entry_color' : entry_color,
    'final_position' : final_position,
    'initial_position' : initial_position,
    'title' : title,
  };
}

void submitCommuteToDB(Commute new_commute)
{
  //Store commute information into database
  FirebaseFirestore.instance.collection("commutes").add(
      new_commute.toJson()
  ).then((doc_ref) {
    //Store item ID to local storage so device will remember this commute
    storage.setItem("id", doc_ref.id);
  }).catchError((error)
  {
    print("Unsucessful in adding entry");
    print(error);
  });
}

///Takes the object "id" = id and "data" = Commute
///and gets the Commute object specifically
Commute getCommuteData(Map<String, dynamic> entry_obj) {
  return Commute.fromJson(json.decode(entry_obj["data"]));
}

///Update an existing commute on database and locally
void updateCommuteEntry(String entry_doc_id, Commute commute_updated_data)
{
  print("updated data: ${commute_updated_data.toJson()}");
}

///Submit new commute to db and local storage
void storeNewCommuteEntry(Commute new_commute_data)
{

}
