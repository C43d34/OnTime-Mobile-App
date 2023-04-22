# OnTime Mobile APP

A new Flutter project.

## Getting Started

To get started running the app on an android emulation

    - Create a .properties file under the directory ./android/gradle
    - specify following properties
            sdk.dir=<directory of android SDK on local machine>
            flutter.sdk=<directory path where Flutter is installed on local machine> 
            flutter.buildMode=debug
            flutter.minSdkVersion= (20 or higher is recommended)

Testing the APP: (Use Android studios to run the app on an emulated Android device)

        - Utilize "Extended Controls" panel to simulate device changing location and demonstrate commute
        capture functionality. 
        - Creating a new commute will occur after the device location has consecutively moved a sufficient
        distance from an arbitrary starting point and remains at the end location for 2 minutes without 
        new movement. 
            - The terminal should notify when this occurs
            - Reloading the app or rebuilding the main page will display the new commute

        - An existing commute can be interacted with by tapping it
        A following page will be displayed showcasing the commute details and offering a few functions
        to customize the commute qualitites such as - Modifying commute name and ideal commute arrival/departure time. 
