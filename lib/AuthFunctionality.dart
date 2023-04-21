import "main.dart";
import 'package:uuid/uuid.dart';
///Assign user a unique UUID and keep it stored on the device so they can access only their own commute information
late final String local_UUID;

///Generate first time user identifier to serve as authentication
///If this device already has a UUID then it will return that instead of generating a new one
void generateLocalUUID() {
  String? uuid = storage.getItem("UUID");
  //Check for UUID already generated
  if (uuid != null) {
    local_UUID = uuid;
  }
  else //generate a new UUID to this device and store it
  {
    var uuid_generator = Uuid();
    local_UUID = uuid_generator.v1();
    storage.setItem("UUID", local_UUID);
  }
}

void clearLocalUUID() {
  storage.deleteItem("UUID");
}
