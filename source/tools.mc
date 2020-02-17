/*
 * toolbox of common functions
 */
using Toybox.Application as App;
using Toybox.Math; 

/* handle last refresh date with SDK version */
function getLastRefresh() {
    var myapp = App.getApp();
    var lastFetchTime = null;
    if (Toybox.Application has :Storage && Toybox.Application.Storage has :setValue) {
            lastFetchTime = myapp.Storage.getValue("lastfetchtime");
    } else {
            lastFetchTime = myapp.getProperty("lastfetchtime");
    }

    return lastFetchTime;
}

function setLastRefresh(lastFetchTime) {
    var myapp = App.getApp();

    if (Toybox.Application has :Storage && Toybox.Application.Storage has :setValue) {            
            myapp.Storage.setValue("lastfetchtime",lastFetchTime);
    } else {
            myapp.setProperty("lastfetchtime",lastFetchTime);
    }
}

/* handle last data date with SDK version */
function getLastData() {
    var myapp = App.getApp();
    var data = null;
    if (Toybox.Application has :Storage && Toybox.Application.Storage has :setValue) {
            data = myapp.Storage.getValue("lastdata");
    } else {
            data = myapp.getProperty("lastdata");
    }

    return data;
}

function setLastData(data) {
    var myapp = App.getApp();

    if (Toybox.Application has :Storage && Toybox.Application.Storage has :setValue) {            
            myapp.Storage.setValue("lastdata",data);
    } else {
            myapp.setProperty("lastdata",data);
    }
}

 // speed is in m/s
function formatWindSpeed(speed) {
        if (speed == null) {
            return "-";
        }
/* bug here ?
        switch (App.getApp().getProperty("WindSpeedUnits")) {
        case 1: //kmh
          return (value * 3.6).format("%0.f");
        case 2: //mph
          return (value * 2.237).format("%0.f");
        case 3: // nds
            return (value * 0.5144).format("%0.f");
        default: //ms
          return value.format("%.1f");
        }
*/
        // in nd
		return (speed * 1.943844).format("%0.f");
        return "-";
}

// calc Beaufort from speed in m/s
function formatBeaufort(speed) {
        // bf = sq3 (v^2 / 9) en kmh            
        //var _bfs = pow((windspeed*windspeed/9),(1/3)); e, kmh
        var _bfs = (speed * 1.943844 /5); //  si < 8, sinon +0
        if (_bfs < 8) {
        	_bfs = _bfs +1;
        }
        return Math.floor(_bfs).toNumber();
}

    // TODO: check value
function formatHeading(heading){
        //var sixteenthPI = Math.PI / 16.0;
        //var sixteenthPI = 11.25;
        var index = Math.floor(heading/22.5).toNumber();
        //System.println("test en deg : "+ index);
        var rose = ["N","NNE","NE","ENE","E",
                "ESE","SE","SSE","S","SSO","SO",
                "OSO","O","ONO","NO","NNO"];

        return rose[index];
}    

function getHour(date) {
      /*
    var _time=new Time.Moment(date);
    var _current = Gregorian.info(_time, Time.FORMAT_MEDIUM);
    var hour = _current.hour;
    */
    var hour = Math.floor(date/3600);
    return hour;
}
