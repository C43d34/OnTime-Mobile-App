import 'package:flutter/material.dart';

class TEMPLATENAME extends StatefulWidget {
  const TEMPLATENAME({super.key, required this.title});
  final String title;

  @override
  State<TEMPLATENAME> createState() => _TEMPLATENAMEState();
}

//Assuming this is environment variables within this page?
//ie. _counter is a global environment variable
class _TEMPLATENAMEState extends State<TEMPLATENAME> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    //get actual width and height of device
    final double Device_Height = MediaQuery.of(context).size.height;
    final double Device_Width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[ //all the widgets going inside here, including layout widgets
            Row( //Row layout packed inside column layout
              children: [
                Expanded(
                  child: FloatingActionButton(
                    onPressed: _incrementCounter, //call a function
                    tooltip: 'Increment',
                    child: const Icon(Icons.add),
                  ),
                ),
                Expanded(
                  child: Text(
                    '$_counter',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: Device_Width*0.2, vertical: Device_Height*0.05),
              child: const Text(
                'You have pushed the button this many times:',
              ),
            ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter, //call a function
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}