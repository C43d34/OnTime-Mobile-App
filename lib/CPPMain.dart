
import 'package:flutter/material.dart';


class CPPMain extends StatefulWidget {
  const CPPMain({super.key});

  @override
  State<CPPMain> createState() => _CPPMainState();
}

class _CPPMainState extends State<CPPMain> {
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bookmark),
            icon: Icon(Icons.bookmark_border),
            label: 'Classes',
          ),
        ],
      ),
      body: <Widget>[
        Container(
          color: Colors.red,
          alignment: Alignment.center,
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField( //place at top of view
                onFieldSubmitted: (String input) {
                  setState(() {
                    currentPageIndex = 1;
                  });
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Search for Building #',
                ),
              ),
              ExpansionTile(
                title: Text("Foods"),
                children: [
                  TextButton(
                      onPressed: () {setState(() {
                        currentPageIndex = 1; //go back to main map
                      });},
                      child: Text("Carls JR."),
                  ),
                  TextButton(
                    onPressed: () {setState(() {
                      currentPageIndex = 1; //go back to main map
                    });},
                    child: Text("Panda Express"),
                  ),
                  TextButton(
                    onPressed: () {setState(() {
                      currentPageIndex = 1; //go back to main map
                    });},
                    child: Text("Subway"),
                  ),

                ],
              ),
              ExpansionTile(
                  title: Text("Student Services"),

              ),
              ExpansionTile(
                  title: Text("Other Stuff"),

              ),
              ExpansionTile(
                  title: Text("Useful"),

              ),
            ],
          ),
        ),
        Container(
          color: Colors.green,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  flex: 80,
                  child: Image.network("https://www.cpp.edu/career/img/building-97.jpg")),
            ],
          ),
        ),
        Container(
          color: Colors.blue,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  Expanded(
                    flex: 80,
                    child: Image.network("https://www.cpp.edu/career/img/building-97.jpg")),
                  Expanded(
                    flex: 10,
                    child: Container(
                    margin: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(border: Border.all()),
                      child: Row(
                        children: [
                          Expanded(
                            child: FloatingActionButton(
                              onPressed: () {},
                              tooltip: "Daboing",
                              child: const Icon(Icons.arrow_back),
                            ),
                          ),
                          Expanded(
                            child: Text("Class ####",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ),Expanded(
                            child: FloatingActionButton(
                              onPressed: () {},
                              tooltip: "Daboing",
                              child: const Icon(Icons.arrow_forward),
                            ),
                          ),
                        ],
                      ),
                    ),
                )
             ],
          ),
        ),
      ][currentPageIndex],
    );
  }
}
