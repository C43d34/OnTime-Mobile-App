import 'dart:convert';
import "main.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

///Handle Database queries and local storage queries

class Commute
{
  bool AM_true;
  int arrival_time;
  int avg_drive_time;
  int avg_walk_time;
  bool departure_AM_true;
  int departure_time;
  String destination;
  int entry_color;
  GeoPoint final_position;
  GeoPoint initial_position;
  String title;
  int times_commuted;
  String owner;

  Commute({required this.owner, required this.times_commuted,required this.AM_true, required this.arrival_time, required this.avg_drive_time, required this.avg_walk_time, required this.departure_AM_true, required this.departure_time, required this.destination, required this.entry_color, required this.final_position, required this.initial_position, required this.title});

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
        title = json["title"],
        owner = json["owner"];

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
    'owner' : owner,
  };
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

  //Update commute under specific id
  FirebaseFirestore.instance.collection("commutes").doc(entry_doc_id).update(
      commute_updated_data.toJson()
  ).then((doc_ref) {
    print("Doc update successful ${entry_doc_id}");
    //find local commute entry matching ID and change its "data" value
    print("entrty length ${commute_entries.length}");
    for(var entry in commute_entries) {
      if(entry["id"] == entry_doc_id){
        entry["data"] = json.encode(commute_updated_data.toJson());
      }
    }
  }).catchError((error)
  {
    print("Unsucessful in adding entry");
    print(error);
  });

}

///Update existing commute ONLY on DB side
///Please ensure handle local runtime data updates if this function is used!
void updateCommuteEntryOnlyDB(String entry_doc_id, Commute commute_updated_data)
{
  //Update commute under specific id
  FirebaseFirestore.instance.collection("commutes").doc(entry_doc_id).update(
      commute_updated_data.toJson()
  ).then((doc_ref) {
    print("Doc update successful ${entry_doc_id}");
  }).catchError((error)
  {
    print("Unsucessful in adding entry");
    print(error);
  });
}

///Submit new commute to db and local storage
void storeNewCommuteEntry(Commute new_commute_data) async {

  ///Returns document ID of the stored commute
  Future<String> submitCommuteToDB(Commute new_commute) //returns as a future because we must wait for this query to finish before getting back out result
  {
    //Store commute information into database
    var return_id = FirebaseFirestore.instance.collection("commutes").add(
        new_commute.toJson()
    ).then((doc_ref) {
      //Store document ID of the stored commute
      print("new document added ${doc_ref.id}");
      return doc_ref.id; //return this back to the variable (doesn't return to function)
    }).catchError((error)
    {
      print("Unsucessful in adding entry");
      print(error);
      return ""; //return this back to the variable (doesn't return to function)
    });
    return return_id; //(this return statement actually goes to function like we would expect
  }

  //DATABASE STORAGE STEP
  //Store to DB and get the randomly generated ID of it
  String new_commute_ID = await submitCommuteToDB(new_commute_data);
  print("new ID ${new_commute_ID}");

  //LOCALSTORAGE STEP
  //Process ID and save to local storage in an object that is a list of ID:ID_VALUE pairs
  saved_commute_ids.add(
      {
        "id": new_commute_ID
      });

  storage.setItem("saved_commute_ids",
      saved_commute_ids); //replace last list with list containing the new entry

  //Lastly, store data locally to runtime
  commute_entries.add(
      {
        "id" : new_commute_ID,
        "data" : json.encode(new_commute_data.toJson())
      });


}