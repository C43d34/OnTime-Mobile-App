import 'package:flutter/material.dart';

class CPPMapView{
  //define constant features of this view
  Image MapView = new Image.network(
      "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.cpp.edu%2Fcareer%2Fhours-and-location.shtml&psig=AOvVaw0Jfv7LVbWN1jTvPGjFcW-Z&ust=1677559454447000&source=images&cd=vfe&ved=0CA8QjRxqFwoTCPCcuYvytP0CFQAAAAAdAAAAABAD");

  //define adding and subtracting dynamic features of this view
  List<Widget> secondary_widgets = <Widget>[];

  void clearWidgets()
  {

  }

  Container returnView()
  {
    List<Widget> page_widgets = <Widget>[MapView];
    for (int i = 0; i < secondary_widgets.length; i++)
      {
        page_widgets.add(secondary_widgets[i]);
      }

    return Container(
      color: Colors.red,
      alignment: Alignment.center,
      child:
        Column(
          children: page_widgets
        )
    );
  }

}