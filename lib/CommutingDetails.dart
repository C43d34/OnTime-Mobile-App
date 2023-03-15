import 'package:flutter/material.dart';

class CommutingDetails extends StatelessWidget {
  const CommutingDetails({super.key, required this.entry_data});
  final entry_data;

  @override
  Widget build(BuildContext context) {
    //get actual width and height of device
    final double Device_Height = MediaQuery.of(context).size.height;
    final double Device_Width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: TextFormField(
          initialValue: entry_data["title"],
          style: Theme.of(context).textTheme.headlineSmall,
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
                padding: EdgeInsets.symmetric(vertical: Device_Height*0.05, horizontal: Device_Width*0.1),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "ID:${entry_data["ID"]}",
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Total Traversal Time: " + "${(entry_data["avg_walk_time"] + entry_data["avg_drive_time"])}",
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "AVG Walking Time: ${entry_data["avg_walk_time"]}",
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "AVG Driving Time: ${entry_data["avg_drive_time"]}",
                      ),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}