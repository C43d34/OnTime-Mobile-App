import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:untitled/TimeFunctions.dart';

class CommutingDetails extends StatefulWidget {
  final entry_data;
  final entry_id;

  const CommutingDetails({super.key, required this.entry_data, required this.entry_id});



  @override
  State<CommutingDetails> createState() => _CommutingDetailsState();
}

class _CommutingDetailsState extends State<CommutingDetails> {
  var entry_data;
  final List<String> hr = List.generate(12, (index) => calcHour((index + 1) * 60));
  final List<String> min = List.generate(60, (index) => calcMin(index));
  final db = FirebaseFirestore.instance;
  final ampm = ["AM", "PM"];
  String arrival_hr = "1";
  String arrival_min = "1";
  String arrival_ampm = "AM";

  @override
  void initState(){
    super.initState();
    arrival_hr = calcHour(widget.entry_data["arrival_time"]);
    arrival_min = calcMin(widget.entry_data["arrival_time"]);
    arrival_ampm = resolveAMPM(widget.entry_data["AM_true"]);
  }

  @override
  Widget build(BuildContext context) {
    //get actual width and height of device
    final double Device_Height = MediaQuery.of(context).size.height;
    final double Device_Width = MediaQuery.of(context).size.width;

    print("desired arrival time ${arrival_hr}:${arrival_min}${arrival_ampm}");


    return WillPopScope(
      onWillPop: () async {  //When screen is exited, will send updates to firebase of any changed data
        /*
          Expected changes to handle:
            Commute name
            ~~Desired arrival:: actually we should do this in real time incase user chooses to not exit this window
            *Also maybe commute path itself, but this should be handled on demand*
         */
        print("BingoBOngo");
        Navigator.pop(context, widget.entry_data);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextFormField(
            initialValue: "${widget.entry_data["title"]}",
            style: TextStyle(color: Colors.white, fontSize: 25),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 40,
                child: Image.network("https://www.cpp.edu/career/img/building-97.jpg")),
              Expanded(
                flex: 60,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: Device_Width*0.05),
                  child: Column(
                    children: [
                      Expanded(
                        flex: 45,
                        child: Column(
                          children: [
                            Text("Desired Arrival",
                              style: TextStyle(fontSize: 30, color: Colors.white70),
                            ),
          //Desired arrival timer display widget
                            Container(
                              width: 0.5 * Device_Width,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)
                                  )
                              ),
                              child: Row(
                                children: [
                                  //Hours
                                  Expanded(
                                    flex: 45,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: DropdownButton<String>(
                                        value: arrival_hr,
                                        icon: const Icon(null),
                                        iconSize: 0.0,
                                        style: const TextStyle(color: Colors.deepPurple), //doesnt do anything right now
                                        menuMaxHeight: 0.3 * Device_Height,
                                        selectedItemBuilder: (BuildContext context) {
                                          return hr.map<Widget>((String hour) {
                                            return Container(
                                                alignment: Alignment.centerRight,
                                                width: 0.07 * Device_Width,
                                                child: Text(hour.toString(),
                                                    textAlign: TextAlign.end,
                                                    style: Theme.of(context).textTheme.headlineSmall)
                                            );
                                          }).toList();
                                        },
                                        items: hr.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(value: value,
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  value,
                                                  style: Theme.of(context).textTheme.headlineSmall,
                                                ),
                                              )
                                          );
                                        }).toList(),
                                        onChanged: (String? value) {
                                          setState(() {
                                            arrival_hr = value!;
                                            timeUpdate();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  Expanded(flex: 10, child: Text(":", style: Theme.of(context).textTheme.headlineSmall)),
                                  //Minutes
                                  Expanded(
                                    flex: 45,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: DropdownButton<String>(
                                        value: arrival_min,
                                        icon: const Icon(null),
                                        iconSize: 0.0,
                                        style: const TextStyle(color: Colors.deepPurple), //doesnt do anything right now
                                        menuMaxHeight: 0.3 * Device_Height,
                                        items: min.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(value: value,
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  value,
                                                  style: Theme.of(context).textTheme.headlineSmall,
                                                ),
                                              )
                                          );
                                        }).toList(),
                                        onChanged: (String? value) {
                                          setState(() {
                                            arrival_min = value!;
                                            timeUpdate();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  //AM or PM
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: DropdownButton<String>(
                                      value: arrival_ampm,
                                      icon: const Icon(null),
                                      iconSize: 0.0,
                                      style: const TextStyle(color: Colors.deepPurple),  //doesnt do anything right now
                                      menuMaxHeight: 0.3 * Device_Height,
                                      items: ampm.map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(value: value,
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                value,
                                                style: Theme.of(context).textTheme.headlineSmall,
                                              ),
                                            )
                                        );
                                      }).toList(),
                                      onChanged: (String? value) {
                                        setState(() {
                                          arrival_ampm = value!;
                                          timeUpdate();
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
          //Projected Departure Text
                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text("Projected Departured",
                                style: TextStyle(fontSize: 30, color: Colors.amber[200]),
                              ),
                            ),
          //Projected departure display widget
                            Container(
                              width: 0.5 * Device_Width,
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.white),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10)
                                  )
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                child: Row(
                                  children: [
                                    //Hours
                                    Expanded(
                                      flex: 45,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            calcHour(widget.entry_data["departure_time"]),
                                            style: Theme.of(context).textTheme.headlineSmall,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(flex: 10, child: Text(":", style: Theme.of(context).textTheme.headlineSmall)),
                                    //Minutes
                                    Expanded(
                                      flex: 45,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                        child: Text(
                                          calcMin(widget.entry_data["departure_time"]),
                                          style: Theme.of(context).textTheme.headlineSmall,
                                        ),
                                      ),
                                    ),
                                    //AM or PM
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Text(
                                        resolveAMPM(widget.entry_data["departure_AM_true"]),
                                        style: Theme.of(context).textTheme.headlineSmall,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Container(
                          width: Device_Width,
                          height: 2,
                          color: Colors.black,),
                      ),
          //Commute Statistics box
                      Expanded(
                        flex: 45,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(10)
                              )
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Commute Statistics:",
                                    style: TextStyle(fontSize: 30, color: Colors.white),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "ID:",
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "${widget.entry_data["ID"]}",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Total Traversal Time: ",
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "${(widget.entry_data["avg_walk_time"] + widget.entry_data["avg_drive_time"])}",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Average Walking Time:",
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "${widget.entry_data["avg_walk_time"]}",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            "Average Driving Time:",
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            "${widget.entry_data["avg_drive_time"]}",
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ],
          ),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }

  //Reevaluate the projected departure time (assuming desired arrival time was changed)
  void timeUpdate(){
    int arrival_time = getTotalMin(arrival_hr, arrival_min, arrival_ampm.startsWith("A"));
    int departure_time =  withinTimeBounds(arrival_time + (widget.entry_data["avg_drive_time"] + widget.entry_data["avg_walk_time"]) as int);

    print("Arrival time ${arrival_time}");
    print("Departure time ${departure_time}");

    var departure_ampm = "AM";
    if(!isAM(departure_time)){
      departure_ampm = "PM";
    }

    //Refactor database entry
    var updates = {
      "AM_true": arrival_ampm.startsWith("A"), //if starts with P them it's PM and AM => false
      "arrival_time" : arrival_time,
      "departure_time" : departure_time,
      "departure_AM_true": departure_ampm.startsWith("A"),
    };
    db.collection("commutes").doc(widget.entry_id)
        .update(updates)
        .then(
          (value) => print("DocumentSnapshot successfully updated!"),
          onError: (e) => print("Error updating document $e"));

    //Update information locally (for this page)
    local_entryUpdate(updates);
  }

  void local_entryUpdate(Map<String, dynamic> data_to_update)
  {
    data_to_update.forEach((key, value)
    {
      widget.entry_data[key] = value;
    });
  }
}