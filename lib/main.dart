
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:untitled/CPPMain.dart';
import 'package:untitled/CommutingDetails.dart';
import 'package:untitled/TimeFunctions.dart';
import 'package:untitled/LocationFunctionality.dart';
import 'package:localstorage/localstorage.dart';
import 'StorageFunctionality.dart';


///GLOBAL VARIABLES
final LocalStorage storage = new LocalStorage('localstorage.json');
var commute_entries = [];
  //contains an "id" field mapped to a String
  //and a "data" field mapped to a json string encoded Commute object (must be decoded)
List<Map<String, String>> saved_commute_ids = [
  // {
  //   "id" : "0DRpxhntwQca4IWLYQTo"
  // },
  // {
  //   "id" : "0pubLLJ7y6Ek1oco2ylO"
  // },
  // {
  //   "id" : "AACVFVOcPc3JbhSkOEM0"
  // },
  // {
  //   "id" : "RNtDKzgPepLaV5PolNBG"
  // },
  // {
  //   "id" : "vXrUbN3WPGTX3C5EDQRv"
  // }
];


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await storage.ready.then((ready) { //wait for local storage to ready and then grab items before launching app
    var json_obj_list = storage.getItem("saved_commute_ids");
    for (var json in json_obj_list){
      saved_commute_ids.add({"id" : json["id"]}); //structure each entry individually so we can assure correct typing
    }
    runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Colors.white54
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final location_service = new LocationServicer();

  //make an async call to database to retrieve commutes (ALL of them at once)
  Future retrieve_commutes(Map<String, String> doc_id_map) async {
    var data = {
      "id" : doc_id_map["id"]
    };
    //for now the entries are unordered, because we are calling them one at a time instead of all together
    //we can order them by calling as a group
    //But all the documents need to be grouped inside a *unique* collection specific to this device/user
      //unsure if we want users still though. Maybe just have a collection key that users can copy and share across devices
    var document = await FirebaseFirestore.instance.collection("commutes").doc(doc_id_map["id"]).get();
    setState(() {
      data!["data"] = json.encode(document.data()); //Turn object into String (easier to add as a field to other objects this way)
                                                      //Use decode to turn string value field back into JSON object structure
      commute_entries.add(data);
    });
  }

  @override
  void didChangeDependencies() //unwraps the future return from retrieve_commutes for us
  {
    super.didChangeDependencies();
    for (var doc_ID in saved_commute_ids){
      retrieve_commutes(doc_ID!);
    }
    // print("List of stored saved items: ${storage.getItem("saved_commute_ids")}");
  }

  @override
  Widget build(BuildContext context) {
    final double Device_Height = MediaQuery.of(context).size.height;
    final double Device_Width = MediaQuery.of(context).size.width;


    // for (int i=0; i < commute_entries.length; i++)
    //   {
    //     FirebaseFirestore.instance.collection("commutes").add(
    //       commute_entries[i]
    //     ).then((value) {
    //       print("Successfully added new entry ${i}");
    //     }).catchError((error)
    //     {
    //       print("Unsucessful in adding entry ${i}");
    //       print(error);
    //     });
    //   }

//         FirebaseFirestore.instance.collection("commutes").get(
//               ).then((data) {
//                 for (var value in data.docs) {
//                   print(value.id); //these are the document ids that are randomly generated
// //SAVE THESE IDS LOCALLY TO DEVICE SO WE KNOW WHICH COMMUTES BELONG TO WHO (we don't care about user authentication tbh)
//                 }
//               }).catchError((error)
//               {
//                 print(error);
//               });
//     var commute_entries = [];
//     for (var docID in saved_commute_ids)
//     {
//       FirebaseFirestore.instance.collection("commutes").doc(docID["id"]).get(
//       ).then((doc_snapshot){
//         commute_entries.add(doc_snapshot.data() as Map<String, dynamic>); //add each entry of the document such that string : any
//
//       }).catchError((error){
//         print("Error retrieving list of commutes on this device");
//         print(error);
//       });
//     }

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(

        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Container(
          padding: EdgeInsets.symmetric(vertical: Device_Height*0.03),
          child: ListView.separated(

              padding: EdgeInsets.symmetric(horizontal: Device_Width*0.05),
              itemCount: commute_entries.length,
              itemBuilder: (BuildContext context, int index) {
                  return Container(
                    color: Color(getCommuteData(index, "entry_color") as int), //as "Object_type" op tech
                    child: InkWell(
                      onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) =>
                          CommutingDetails(entry_data : json.decode(commute_entries[index]["data"]), entry_id : commute_entries[index]["id"])))
                          .then((amended_values) {
                            //when we return from this page, update the local commute data (assuming something changed)
                              //better to do this than to make another call to database
                            commute_entries[index]["data"] = json.encode(amended_values);
                            setState(() {
                            });
                          });
                      },
                      child: Column(
                          children: [
                            FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                  "${getCommuteData(index, "title")}",
                                  style: Theme.of(context).textTheme.headlineMedium
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                  "Arriving @ "
                                      + "${calcHour(getCommuteData(index, "arrival_time"))}:"
                                      + "${calcMin(getCommuteData(index, "arrival_time"))}"
                                      + "${resolveAMPM(getCommuteData(index, "AM_true"))}",
                                  style: Theme.of(context).textTheme.titleLarge
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                  "Latest Departure @: "
                                      + "${calcHour(getCommuteData(index, "departure_time"))}:"
                                      + "${calcMin(getCommuteData(index, "departure_time"))}"
                                      + "${resolveAMPM(getCommuteData(index, "departure_AM_true"))}",
                                  style: Theme.of(context).textTheme.titleLarge
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 20,
                                  child: Column(
                                    children: [
                                      Text("Going to: "),
                                      Text("${getCommuteData(index, "destination")}"),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 20,
                                  child: Row(
                                    children: [
                                      if (getCommuteData(index, "avg_walk_time") != 0)
                                        Icon(
                                          Icons.directions_walk,
                                          color: Colors.green,
                                          size: 30.0,
                                        ),
                                      if (getCommuteData(index, "avg_drive_time") != 0)
                                        Icon(
                                          Icons.directions_bike,
                                          color: Colors.black,
                                          size: 30.0,
                                        ),
                                      if (getCommuteData(index, "avg_drive_time") != 0)
                                        Icon(
                                          Icons.drive_eta,
                                          color: Colors.blue,
                                          size: 30.0,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ]
                      ),
                    ),
                  );
              },
              separatorBuilder: (BuildContext context, int index) => const Divider(),
          ),
        )
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(builder: (context) => const MapSample()),
      //     );
      //   },
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.map),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  dynamic getCommuteData(int list_indx, String data_key) {
    return json.decode(commute_entries[list_indx]["data"])[data_key];
  }


}
