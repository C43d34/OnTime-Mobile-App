
String calcHour(int total_minutes)
{
  int hour = (total_minutes / 60).toInt();

  //if the hour value or total minutes = 0 or 12, treat as a 12
  if(hour == 0){
    hour = 12;
  }
  else if(hour > 12){
    hour = hour - 12;
  }

  //12 1 2 3 4 5 6 7 8 9 10 11 12  1(13) 2 3 4 5 6 7 8 9 10 11
  //0 60 120 ....          660 720
  return hour.toString();
}

String calcMin(int total_minutes)
{
  int minute = (total_minutes % 60).toInt();
  if(minute < 10)
  {
      return "0${minute}";
  }
  else{
    return minute.toString();
  }
}

String resolveAMPM(bool isAM)
{
  if(isAM){
    return "AM";
  }
  else{
    return "PM";
  }
}

bool isAM(int total_minutes){
  if(total_minutes > 1440){
    return true;
  }
  else if (total_minutes > 720){
    return false;
  }
  else{
    return true;
  }
}

//get total minute count of a given time
int getTotalMin(String hour, String min, bool isAM)
{
  int total = 0;
  if(!isAM){
    total = 720;
  }

  //weird because we treat 12 as a 0 ... remember that
  if (int.parse(hour) == 12)
  {
       total = total + int.parse(min);
  }
  else{
    total = total + (int.parse(hour)*60) + int.parse(min);
  }

  return withinTimeBounds(total);
}

//use when we are computing a minute value, make sure it is within bounds.
int withinTimeBounds(int total_minutes) //simply checks the minute representation of a time and binds it to be between 0 < x < 1440 minutes
{
  return (total_minutes % 1440);
}

int getCurrMinutes()
{
  var dt = DateTime.now();
  int cur_hours = dt.hour;
  int cur_mins = dt.minute;
  int total_minutes = cur_hours*60 + cur_mins;

  return(total_minutes);
}