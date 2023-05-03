
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:untitled/CommutingDetails.dart';
import 'package:untitled/TimeFunctions.dart';
import 'package:untitled/LocationFunctionality.dart';
import 'package:localstorage/localstorage.dart';
import "package:untitled/AuthFunctionality.dart";
import 'package:geocoding/geocoding.dart';


///GLOBAL VARIABLES
final LocalStorage storage = new LocalStorage('localstorage.json');
final String GOOGLE_API_KEY = "AIzaSyBce6Z3cfRfUxq-Vi0cuVDeTv3NxcPIBn0";
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
    generateLocalUUID(); //make sure user authentication is valid : then we can start pulling commute data
    resetLocalStorage();
    // storage.clear();
    List<dynamic> json_obj_list = (storage.getItem("saved_commute_ids") == null ? [] : storage.getItem("saved_commute_ids")); //return empty or something
    //populate runtime array of commute IDs by pulling from local storage
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
      title: 'OnTime MobileAPP',
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
        scaffoldBackgroundColor: Colors.white54,
        textTheme: TextTheme(
            titleLarge: TextStyle(color: Color.fromARGB(255, 3, 80, 0)),
            headlineMedium: TextStyle(color: Colors.black))
      ),
      home: const MyHomePage(title: 'My Commutes'),
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
  static bool user_consent = false;
  final location_service = new LocationServicer();

  static bool get userConsent {
    return user_consent;
  }


  //make an async call to database to retrieve commutes (ALL of them at once)
  Future<List> retrieve_commutes() async {
    var user_commute_list = [];
    for (var doc_id_map in saved_commute_ids)
    {
      var data = {
        "id" : doc_id_map["id"]
      };
      //for now the entries are unordered, because we are calling them one at a time instead of all together
      //we can order them by calling as a group
      //But all the documents need to be grouped inside a *unique* collection specific to this device/user
      //unsure if we want users still though. Maybe just have a collection key that users can copy and share across devices
      var document = await FirebaseFirestore.instance.collection("commutes").doc(doc_id_map["id"]).get();
      data!["data"] = json.encode(document.data()); //Turn object into String (easier to add as a field to other objects this way)
      //Use decode to turn string value field back into JSON object structure
      user_commute_list.add(data);
    }
    return user_commute_list;
  }

  @override
  void didChangeDependencies() async //unwraps the future return from retrieve_commutes for us
  {
    super.didChangeDependencies();
    bool? consent = await storage.getItem("user_consent");
    if(consent == null) {
        user_consent = false;
      }
    else{
      user_consent = consent;
    }

    retrieve_commutes().then((commutes) {
      setState(() {
        commute_entries.clear(); //we have to clear this for when didchangedependencies gets called from keyboard opening and causes a bunch of rebuilds
        commute_entries = commutes; //set commute_entries now that we know it is clear
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double Device_Height = MediaQuery.of(context).size.height;
    final double Device_Width = MediaQuery.of(context).size.width;

    // resetLocalStorage();
    // print(local_UUID);
    // storage.clear();

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: (() {
        if(user_consent)
          {
            //If user has consented to initial "prominent disclosure"
            location_service.initialize();
            return Center(

              // Center is a layout widget. It takes a single child and positions it
              // in the middle of the parent.
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: Device_Height*0.03),
                  child: ListView.separated(

                    padding: EdgeInsets.symmetric(horizontal: Device_Width*0.05),
                    itemCount: commute_entries.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Color(getCommuteData(index, "entry_color") as int),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        // color: Color(getCommuteData(index, "entry_color") as int), //as "Object_type" op tech
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
                                      "Begin Departure @: "
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
                                          Text(
                                            "${getCommuteData(index, "destination")}",
                                            textAlign: TextAlign.center,
                                          ),
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
            );
          }
        else if (!user_consent)
          {
            //display "Prominent disclosure" of application functionality upon first time app open.
            return AlertDialog(
              title: const Text('Disclosure'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: const <Widget>[
                    Text('This application utilizes and collects precise location data to help you better understand and plan your commuting routes.'),
                    Text('Your location is only tracked while the app is open and in the foreground.'),
                    Text('\nAre you okay with allowing OnTime access to your location in this way?'),
                  ],
                ),
              ),
              actions: <Widget>[
                Row(
                  children: [
                  TextButton(
                  child: const Text('Approve'),
                    onPressed: () {
                      user_consent = true;
                      storage.setItem("user_consent", true);
                      setState(() {
                      });
                    },
                  ),
                  Expanded(
                      child: Container()),
                  ],
                ),
              ],
            );
          }
        else{
          return Center();
        }
      }())

      //
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     getUserConsent();
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

void resetLocalStorage()
{
  var test_data = [
    {
      "id" : "0DRpxhntwQca4IWLYQTo"
    },
    {
      "id" : "0pubLLJ7y6Ek1oco2ylO"
    },
    {
      "id" : "AACVFVOcPc3JbhSkOEM0"
    },
    {
      "id" : "RNtDKzgPepLaV5PolNBG"
    },
    {
      "id" : "vXrUbN3WPGTX3C5EDQRv"
    },
    {
      "id" : "3ZByANfWALxauHX7ICwW"
    },
    {
      "id" : "GajBY5uhuKefMBWhkOUH"
    },
  ];
  storage.deleteItem("saved_commute_ids");
  storage.setItem("saved_commute_ids", test_data);
}

