using Toybox.Application;

class WeatherWidApp extends Application.AppBase {
  
    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
        
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        //return [ new WeatherWidView() ];
        //return [ new WeatherAppView() ];
        return [ new WeatherWidView(), new WeatherAppDelegate() ];
    }

    function phoneConnected() {
        return System.getDeviceSettings().phoneConnected;
    }

    function canDoBackground() {
        return (Toybox.System has :ServiceDelegate);
    }

    /*
    function onPosition(info) {
        var myLocation = info.position.toDegrees();
        lattitude = myLocation[0];
        longitude = myLocation[1];        
        //locationString = lat + "," + long;
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function getLocation() {
        var _locationString = lattitude + "," + longitude;
        return _locationString;
    }
    */
}