import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:localstorage/localstorage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:untitled/main.dart';
import 'StorageFunctionality.dart';
import 'TimeFunctions.dart';

class LocationServicer
{
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );
  // Stream tracks user location whenever it changes -> create a function to handle this case
  late StreamSubscription<Position> position_stream; //late keyword to initialize this attribute only once the constructor is called.

  Position? cur_pos;
  Position? cur_commute_initial_pos;
  Position? cur_commute_end_pos;
  bool is_commuting = false;

  Timer pos_change_timer = Timer(const Duration(seconds: 0), () {});
  final max_wait_time = const Duration(seconds: 20); //max time to wait until pos_change_timer should fire

  final stopwatch = Stopwatch(); //use to measure commute duration
  int last_stopwatch_timestamp_S = 0;
  int cur_walking_seconds = 0;
  int cur_biking_seconds = 0;
  int cur_driving_seconds = 0;


  LocationServicer() { //default constructor
    //Handle initializing location and perms
    determineInitialPosition().then((Position? inital_pos)
    {
      cur_pos = inital_pos;
      print(inital_pos == null ? 'Unknown' : 'Initial POS ${inital_pos.latitude.toString()}, ${inital_pos.longitude.toString()}');

      //Establish position_stream to watch user location changes
      position_stream = Geolocator.getPositionStream(locationSettings: locationSettings)
          .listen((Position? position) //will send a position update whenever user moves arbitrary amount (see locationSettings)
      {
        print(position == null ? 'Unknown' : 'New POS ${position.latitude.toString()}, ${position.longitude.toString()}');
        watchForCommute(position);
        //Position has changed so there must be some time that passed between last change
        if(this.is_commuting){
          addElapsedTimeToCommute();
        }
      }); //PositionStream

    }).catchError((e)
    {
      print(e);
    });
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<Position> determineInitialPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  //Determine if position change initiates a commute
  void watchForCommute(Position? position)
  {
    //If recently changed positions, user is commuting
    if(this.pos_change_timer.isActive) {
      this.is_commuting = true;
    }
    //If first position change in a while (not confirmed commuting yet)
      //set previous position as POSSIBLE commute starting coordinate
    if(!this.is_commuting) {
      this.cur_commute_initial_pos = this.cur_pos;
      this.stopwatch.start();
    }

    this.cur_pos = position; //current position update
    initiatePosChangeTimer(); //Waiting for next positional update (commuting)
  }

  //Set(or Reset) a global time limit for next positional update
  //If position update doesn't arrive in time, we reset user to idle state/finish commute
  void initiatePosChangeTimer()
  {
    this.pos_change_timer.cancel(); //Clear and reset timer if there is one
    this.pos_change_timer = Timer(this.max_wait_time, () { //wait max_wait_time and then...
      //Timer is up -> do...
      if (this.is_commuting)
      {
        print("Commute is finished. (DO COMMUTE FINISHING LOGIC)");
        finishCommute();
      }
      else{
        print("No Commute, only singular movement occured");
        resetStats();
      }
    });
  }

  /*
   Add elapsed time from last time we measured stopwatch to now to respective value
      driving
      biking
      walking...
   */
  void addElapsedTimeToCommute()
  {
    int cur_time = this.stopwatch.elapsed.inSeconds;
    int seconds_since_last_pos_change =  cur_time - this.last_stopwatch_timestamp_S;
    this.last_stopwatch_timestamp_S = cur_time;

    double speed = (100/seconds_since_last_pos_change) as double; //meters per second
    print("Average speed: ${speed}");

    //Determine momentary speed and thus transport method of commute based on distance/time
      //Longer time = slower travel rate => slower transport method
      //Distance is controlled by distanceFilter (see locationSettings)

    //Average running speed (high end for walking) = 2.5meters per second (about 6mph)
    if(speed < 2.5) {
        this.cur_walking_seconds += seconds_since_last_pos_change;
      }
    //Average high end biking speed = 7mps (about 15.5mph)
      //may overlap with driving speed though
      //interpret as driving in traffic?
    else if(speed < 7) {
        this.cur_biking_seconds += seconds_since_last_pos_change;
      }
    //Anything faster than 8.9mps we should assume is driving.
    else {
        this.cur_driving_seconds += seconds_since_last_pos_change;
      }
  }

  void finishCommute()
  {
    this.is_commuting = false;

    //save commute endpoint
    this.cur_commute_end_pos = this.cur_pos;

    //Check if the commute that just occured already exists
    String? existing_commute_id = commuteAlreadyExists();
    //This is a new commute
    if(existing_commute_id == null)
      {
        //submit new commute to database and such
        print("Storing new commute...");
        Commute new_commute = buildNewCommute();
        storeNewCommuteEntry(new_commute);
      }
    else { //Commute already exists, we can reevalute some of the statistics
        print("Updating existing commute");
        updateCurrentCommuteStats(existing_commute_id);
      }

    //reset all values
    resetStats();
  }

  //returns document id of a commute (if it exists) that matches location information of the current commute
    //else returns null == no matching commute exists
  String? commuteAlreadyExists()
  {
    //check every commute stored on this device to see if start and end points match
    for (var obj in commute_entries)
      {
        Commute existing_commute_entry = getCommuteData(obj);
        String existing_commute_id = obj['id'];

        GeoPoint other_initial = existing_commute_entry.initial_position;
        GeoPoint other_final = existing_commute_entry.final_position;

        print("Commute to match ${this.cur_commute_end_pos!.latitude}");
        print("OTher commute match? ${other_final.latitude}");

        //get start and end longitude and latitude from the doc and compare (GeoPoint class object)
          //Compare with some degree of leeway (lets say 100 meter range)
        double meters_between_initial_pos = Geolocator.distanceBetween(
            other_initial.latitude, other_initial.longitude, this.cur_commute_initial_pos!.latitude, this.cur_commute_initial_pos!.longitude);
        double meters_between_final_pos = Geolocator.distanceBetween(
            other_final.latitude, other_final.longitude, this.cur_commute_end_pos!.latitude, this.cur_commute_end_pos!.longitude);

        //if two distance between the two points is kinda close then...
        if(meters_between_final_pos < 150 && meters_between_initial_pos < 150){
          print("Commute exists already ! ${existing_commute_id}");
          return existing_commute_id;
        }
      }
    return null;
  }

  Commute buildNewCommute()
  {
    //round time values to minutes
    int walking_minutes = (this.cur_walking_seconds / 60).toInt();
    int drivingBiking_minutes = ((this.cur_driving_seconds+this.cur_biking_seconds) / 60).toInt();

    int arrival_time = getCurrMinutes();
    int departure_time = arrival_time - (walking_minutes + drivingBiking_minutes);

    return new Commute(
        times_commuted: 1,
        AM_true: isAM(arrival_time),
        arrival_time: arrival_time,
        avg_drive_time: drivingBiking_minutes,
        avg_walk_time: walking_minutes,
        departure_AM_true: isAM(departure_time),
        departure_time: departure_time,
        destination: "TBD", //use geocoding plugin to estimate address from endpoint coordinates
        entry_color: 4294956367,
        final_position: GeoPoint(this.cur_commute_end_pos!.latitude, this.cur_commute_end_pos!.longitude),
        initial_position: GeoPoint(this.cur_commute_initial_pos!.latitude, this.cur_commute_initial_pos!.longitude),
        title: "New Unnamed Commute");
  }

  //Update existing commute that just occurred
    //Items such as average travel time
    //We could also try to narrow in departure and destination endpoints in the future
  void updateCurrentCommuteStats(String doc_id_to_update)
  {
    Commute commute_data = getCommuteData(commute_entries.firstWhere((entry) => entry["id"] == doc_id_to_update));

    int times_commuted = commute_data.times_commuted;
    double old_drivingBiking_minutes = commute_data.avg_drive_time.toDouble();
    double old_walking_minutes = commute_data.avg_walk_time.toDouble();
    double drivingBiking_minutes = (this.cur_driving_seconds + this.cur_biking_seconds).toDouble() / 60;
    double walking_minutes = (this.cur_walking_seconds).toDouble() / 60;

    // Recompute average values using new information
      //convert to int as rounding method (will lose info this way for sure)
    int avg_drivingBiking_minutes = ((times_commuted/times_commuted + 1) * old_drivingBiking_minutes
        +(1 - (times_commuted/times_commuted + 1)) * drivingBiking_minutes).toInt();
    int avg_walking_minutes = ((times_commuted/times_commuted + 1) * old_walking_minutes
        +(1 - (times_commuted/times_commuted + 1)) * walking_minutes).toInt();

    //It's possible ideal destination changed so update that as well
    int ideal_departure = commute_data.arrival_time - (avg_drivingBiking_minutes + avg_walking_minutes);

    Commute updated_commute = new Commute(
        times_commuted: times_commuted + 1,
        AM_true: commute_data.AM_true,
        arrival_time: commute_data.arrival_time,
        avg_drive_time: avg_drivingBiking_minutes,
        avg_walk_time: avg_walking_minutes,
        departure_AM_true: isAM(ideal_departure),
        departure_time: ideal_departure,
        destination: commute_data.destination,
        entry_color: commute_data.entry_color,
        final_position: commute_data.final_position,
        initial_position: commute_data.initial_position,
        title: commute_data.title
    );

    //Submit changes to database and update local storage
    updateCommuteEntry(doc_id_to_update, updated_commute);
  }

  void resetStats()
  {
    this.stopwatch.stop();
    this.cur_driving_seconds = 0;
    this.cur_biking_seconds = 0;
    this.cur_walking_seconds = 0;
    this.last_stopwatch_timestamp_S = 0;
    this.stopwatch.reset();
    this.cur_commute_initial_pos = null;
    this.cur_commute_end_pos = null;
  }

}


