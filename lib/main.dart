import 'dart:math';

import 'package:flutter/material.dart';
import 'package:untitled/CPPMain.dart';
import 'package:untitled/CommutingDetails.dart';

void main() {
  runApp(const MyApp());
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

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }


  @override
  Widget build(BuildContext context) {
    final double Device_Height = MediaQuery.of(context).size.height;
    final double Device_Width = MediaQuery.of(context).size.width;

    var commute_entries = [
      {
        "ID" : 1,
        "title" : "CS4700 Commute",
        "arrival_time" : "10:30AM",
        "departure_time" : "10:00AM",
        "destination" : "CS4700 B8 RM302",
        "avg_drive_time" : 20,
        "avg_walk_time" : 15,
        "entry_color" : Colors.amber[600]
      },
      {
        "ID" : 2,
        "title" : "CS4200 Commute",
        "arrival_time" : "10:30AM",
        "departure_time" : "10:00AM",
        "destination" : "CS4200 B6 RM1005",
        "avg_drive_time" : 20,
        "avg_walk_time" : 15,
        "entry_color" : Colors.amber[500]
      },
      {
        "ID" : 3,
        "title" : "CS3650 Commute",
        "arrival_time" : "10:30AM",
        "departure_time" : "10:00AM",
        "destination" : "CS3650 B8 RM104",
        "avg_drive_time" : 0,
        "avg_walk_time" : 15,
        "entry_color" : Colors.amber[300]
      },
      {
        "ID" : 4,
        "title" : "EC4100 Commute",
        "arrival_time" : "10:30AM",
        "departure_time" : "10:00AM",
        "destination" : "CS4700",
        "avg_drive_time" : 20,
        "avg_walk_time" : 15,
        "entry_color" : Colors.amber[100]
      },
      {
        "ID" : 5,
        "title" : "MAT1220 Commute",
        "arrival_time" : "10:30AM",
        "departure_time" : "10:00AM",
        "destination" : "CS4700",
        "avg_drive_time" : 20,
        "avg_walk_time" : 15,
        "entry_color" : Colors.amber[100]
      }
    ];
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
                  height: Device_Height * 0.15,
                  color: commute_entries[index]["entry_color"] as Color, //as "Object_type" op tech
                  child: InkWell(
                    onTap: () {Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        CommutingDetails(entry_data : commute_entries[index])));
                    },
                    child: Column(
                        children: [
                          Text(
                              "${commute_entries[index]["title"]}",
                              style: Theme.of(context).textTheme.headlineMedium
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                                "Arriving @ " + "${commute_entries[index]["arrival_time"]}",
                              style: Theme.of(context).textTheme.titleLarge
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                                "Latest Departure @: " + "${commute_entries[index]["departure_time"]}",
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
                                    Text("${commute_entries[index]["destination"]}"),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 20,
                                  child: Row(
                                    children: [
                                      if (commute_entries[index]["avg_walk_time"] != 0)
                                        Icon(
                                          Icons.directions_walk,
                                          color: Colors.green,
                                          size: 30.0,
                                        ),
                                      if (commute_entries[index]["avg_drive_time"] != 0)
                                        Icon(
                                          Icons.directions_bike,
                                          color: Colors.black,
                                          size: 30.0,
                                        ),
                                      if (commute_entries[index]["avg_drive_time"] != 0)
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CPPMain()),
          );
        },
        tooltip: 'Increment',
        child: const Icon(Icons.map),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
