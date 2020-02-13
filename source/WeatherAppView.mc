using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Application as App;
using Toybox.Graphics as Gfx; 
using Toybox.Math; 

using Toybox.Time;
using Toybox.Time.Gregorian;

class WeatherAppView extends WatchUi.View {
    var units = null;
    private var latitude = null;
	private var longitude = null;

	private var width = null;
	private var height = null;	

	//private var mTimer = null;
    private var _status = null;

	//private var lastData;
    private var lastFetchTime = null;

	private var summary = null;
	private var pressure = null;
    private var temperature = null;
    private var windspeed = null;
    private var windbearing = null;
    private var weathericon = null;
	private var apparentTemperature = null;
    private var proba = null;
    private var writer = null;

    function initialize() {
    	System.println("initialize");
        View.initialize();

        units =(System.getDeviceSettings().temperatureUnits==System.UNIT_STATUTE) ? "us" : "si";
        //System.println("units in " + units);
        //System.println("lang : " + System.getDeviceSettings().systemLanguage);
           
        /* last known position */
        var positionInfo = Position.getInfo();
        var myLocation = positionInfo.position.toDegrees();
        latitude = myLocation[0];
        longitude = myLocation[1];
    	System.println(latitude + "," +longitude  );
    	//System.println(); // longitude (e.g -94.800953)
        
        if (positionInfo.accuracy == Position.QUALITY_NOT_AVAILABLE) {
        	System.println("no position : "+positionInfo.accuracy);
            latitude = 50.4747;
            longitude = 3.061;
        }
        // debug
        latitude = 50.4747;
        longitude = 3.061;
        
        var myapp = App.getApp();
        var freshen = null;
        
        lastFetchTime = getLastRefresh();
        if (lastFetchTime != null) {
            var _now = Time.now().value();
        	//freshen = _now - lastFetchTime;
            //System.println("now h : "+getHour(_now)+" / last : "+getHour(lastFetchTime));
            freshen = getHour(_now) - getHour(lastFetchTime);            
        } else {
        	freshen = 24;
        }
        // more than 1 hour ?
        _status = 0;
        if (freshen >= 1) { // TODO: check value
                System.println("(too old) Fetching weather data on startup " + freshen);                
                makeCurrentWeatherRequest();                
        } else {                
                System.println("using current weather data");
                var data = myapp.Storage.getValue("lastdata");
                parseCurrentWeather(data);
                //makeCurrentWeatherRequest();
        }              

        // debug
        /*
        summary = "Ciel Couvert";
        pressure = 1021.3;
        temperature = 5.12;
        windspeed = 7.7;
        windbearing = 294;
        weathericon = "cloudy";
        apparentTemperature = 8;
        */
        /*
        summary = "Ciel Dégagé";
        pressure = 1036.3;
        temperature = 3.22;
        windspeed = 0.83;
        windbearing = 331;
        weathericon = "clear-day";
        apparentTemperature = 3.22;
    */
    /*
     	summary = "Vent moyen commençant dans la matinée, se prolongeant jusqu’à ce soir.";
        pressure = 1008.9;
        temperature = 5.02;
        windspeed = 8.85;
        windbearing = 261;
        weathericon = "clear-day";
        apparentTemperature = -0.06;
        proba = 0.06;
		_status = 0;
	
     */
    }

    // Load your resources here
    function onLayout(dc) {
        //setLayout(Rez.Layouts.MainLayout(dc));
        width=dc.getWidth();
        height=dc.getHeight();

        writer = new WrapText();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	// Allocate a 1Hz timer               
        //mTimer = new Timer.Timer();     
        //mTimer.start(method(:onTimer), 1000, true);
    }

	// Handler for the timer callback
    function onTimer() {
    	//System.println("onTimer");
    	// for testing
    	//mModel.generateTest();
    	
    	//mModel.updateTimer();
        //WatchUi.requestUpdate();
    }
    
    // Update the view
    function onUpdate(dc) {
    	System.println("onUpdate");

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_WHITE,/*Gfx.COLOR_RED*/ Gfx.COLOR_TRANSPARENT);

        // Get and show the current time
        //var clockTime = System.getClockTime();
        //var timeString = Lang.format("$1$:$2$:$3$", [clockTime.hour, clockTime.min.format("%02d"), clockTime.sec.format("%02d")]);		
		
		//dc.drawText(width * 0.5, height * 0.12,Gfx.FONT_SMALL,timeString,Gfx.TEXT_JUSTIFY_CENTER);
        var myapp = App.getApp();
        var freshen = 0;
        var lastFetchTime = getLastRefresh();
        if (lastFetchTime != null) {
        	freshen = (Time.now().value() - lastFetchTime)/60; // minutes
        } else {
        	freshen = -1;
        }
        var _timeString = "last update "+freshen.format("%.0f") + " m";
        dc.drawText(width * 0.5, height * 0.12,Gfx.FONT_XTINY,_timeString,Gfx.TEXT_JUSTIFY_CENTER);

        if (_status != 0) {
            dc.drawText(width * 0.5, height * 0.5,Gfx.FONT_XTINY,"waiting data...",Gfx.TEXT_JUSTIFY_CENTER);
        }
		if (summary != null) {
            drawIcon(dc,width * 0.5 - 64,height * 0.5 - 64 ,weathericon);// 64 pix

            var y = height * 0.25;
            var _tempstr = temperature.format("%.0f") + "°";
            dc.drawText(width * 0.5, y,
                Gfx.FONT_NUMBER_MEDIUM,
                _tempstr,
                Gfx.TEXT_JUSTIFY_LEFT);
            _tempstr = "Feels " + apparentTemperature.format("%.0f") + "°";
            y = y + Graphics.getFontHeight(Gfx.FONT_NUMBER_MEDIUM);

            dc.drawText(width * 0.5,y,
                Gfx.FONT_XTINY,
                _tempstr,
                Gfx.TEXT_JUSTIFY_LEFT);

            //dc.drawText(width * 0.25,height * 0.75 ,Gfx.FONT_TINY,summary,Gfx.TEXT_JUSTIFY_LEFT);
            var posY = height * 0.75;
            posY = writer.writeLines(dc, summary, Gfx.FONT_XTINY, posY);

            //y = height * 0.5;
            y = y + Graphics.getFontHeight(Gfx.FONT_XTINY);
            _tempstr = "Wind:" + formatWindSpeed(windspeed) + " nd @ " + formatHeading(windbearing);
            // + " @ " +  / " + formatBeaufort(windspeed);
            dc.drawText(width * 0.25,y,
                Gfx.FONT_XTINY,
                _tempstr,
                Gfx.TEXT_JUSTIFY_LEFT);
                
            y = y + Graphics.getFontHeight(Gfx.FONT_XTINY);
            var _proba = proba * 100;
            _tempstr = pressure.format("%.0f") + " hPa Hum: " + _proba.format("%.0f")+ " %";
            dc.drawText(width * 0.25,y,
                Gfx.FONT_XTINY,
                _tempstr,
                Gfx.TEXT_JUSTIFY_LEFT);

            //writer.testFit(posY);  // start scrolling ?
            /*          
            //var _bfs = formatBeaufort(windspeed);
            //System.println("speed : "+ _bfs );
            */
        }
    
        //gridOverlay(dc);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    	//mTimer.stop();
        //mTimer = null;
    }


    function gridOverlay(dc) {
        dc.setPenWidth(1);		
        dc.setColor(0xFFFFFF, 0xFFFFFF);
        var grid = 32;		
        /*
        for (var i=1; i< grid; i+=1){ 
            dc.drawLine (0, width*i/grid, width, height*i/grid); 					
            dc.drawLine (width*i/grid, 0, width*i/grid, height); 
        } 
        */
        dc.drawLine (0, height*0.25, width, height*0.25); 
        dc.drawLine (0, height*0.5, width, height*0.5); 
        dc.drawLine (0, height*0.75, width, height*0.75); 

		dc.setColor(0xFFFF00, 0xFFFF00);
        dc.drawLine (width * 0.25, 0, width * 0.25, height); 
        dc.drawLine (width * 0.5, 0, width * 0.5, height); 
        dc.drawLine (width * 0.75, 0, width * 0.75, height); 
        //System.println("wh : "+ width * 0.25 + " px , hh : " + height*0.25 + " px");
    }

 function makeCurrentWeatherRequest() {
 		System.println("makeCurrentWeatherRequest");
        if (System.getDeviceSettings().phoneConnected) {

            var appid = getAPIkey();              
        
            // currently,  daily, hourly
            var params = {
                    "units" => units,
                    "lang" => "fr",
                    "exclude" => "[minutely,hourly,daily,alerts,flags]"
                    };

            var url = "https://api.darksky.net/forecast/"+appid+"/"+latitude+","+longitude;
    
            var options = {
                    :methods => Communications.HTTP_REQUEST_METHOD_GET,
                    :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };
        
            Communications.makeWebRequest(
                    url,
                    params,
                    options,
                    method(:receiveCurrentWeather));
            _status = 1;
        } else {
            System.println("no phone connection");
        }        
        WatchUi.requestUpdate();
    }

function makeHourlyWeatherRequest() {
 		System.println("makeCurrentWeatherRequest");
        if (System.getDeviceSettings().phoneConnected) {

            var appid = getAPIkey();              
        
            // currently,  daily, hourly
            var params = {
                    "units" => units,
                    "lang" => "fr",
                    "exclude" => "[minutely,daily,alerts,flags]"
                    };

            var url = "https://api.darksky.net/forecast/"+appid+"/"+latitude+","+longitude;
    
            var options = {
                    :methods => Communications.HTTP_REQUEST_METHOD_GET,
                    :headers => {"Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
                    :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };
        
            Communications.makeWebRequest(
                    url,
                    params,
                    options,
                    method(:receiveHourlyWeather));
            _status = 1;
        } else {
            System.println("no phone connection");
        }        
        WatchUi.requestUpdate();
    }


   
    // parse JSON weather data    
    function parseCurrentWeather(data) {
        // currently => {visibility=>16.093000, windBearing=>260, precipIntensity=>0, 
        // apparentTemperature=>6.060000, summary=>Ciel Nuageux, precipProbability=>0, humidity=>0.870000, 
        // uvIndex=>0, cloudCover=>0.700000, dewPoint=>7.630000, icon=>partly-cloudy-day,
        // ozone=>343.899994, pressure=>1007.800000, temperature=>9.730000, time=>1580569580, windGust=>17.040001, windSpeed=>9.030000}
        summary = data["currently"]["summary"];
        pressure = data["currently"]["pressure"];
        temperature = data["currently"]["temperature"];
        windspeed = data["currently"]["windSpeed"];
        windbearing = data["currently"]["windBearing"];
        weathericon = data["currently"]["icon"];
		proba = data["currently"]["precipProbability"];
		apparentTemperature = data["currently"]["apparentTemperature"];				   
    
    }

    // parse JSON weather data
    function parseHourlyWeather(data) {
        // currently => {visibility=>16.093000, windBearing=>260, precipIntensity=>0, 
        // apparentTemperature=>6.060000, summary=>Ciel Nuageux, precipProbability=>0, humidity=>0.870000, 
        // uvIndex=>0, cloudCover=>0.700000, dewPoint=>7.630000, icon=>partly-cloudy-day,
        // ozone=>343.899994, pressure=>1007.800000, temperature=>9.730000, time=>1580569580, windGust=>17.040001, windSpeed=>9.030000}
        summary = data["currently"]["summary"];
        pressure = data["currently"]["pressure"];
        temperature = data["currently"]["temperature"];
        windspeed = data["currently"]["windSpeed"];
        windbearing = data["currently"]["windBearing"];
        weathericon = data["currently"]["icon"];
		proba = data["currently"]["precipProbability"];
		apparentTemperature = data["currently"]["apparentTemperature"];
				 
        // check hourly data
        // first slot is actual time then next 24 hours
        System.println("next : "+data["hourly"]["summary"]);
        var _hdata = data["hourly"]["data"]; // table ?
        /*
        var _time=new Time.Moment(data["hourly"]["time"]);
        var _current = Gregorian.info(_time, Time.FORMAT_MEDIUM);
        System.println(_current.hour+":"+_current.min);
        */
        // Print the arguments duplicated and returned 
        /*
        var keys = _hdata.keys();
        for( var i = 0; i < keys.size(); i++ ) {
            //mMessage += Lang.format("$1$: $2$\n", [keys[i], args[keys[i]]]);
            System.println(keys[i] + " => " + data[keys[i]]);
        }
        */

        var _time;
        var _current;
        for(var i = 0; i<25;i++) {
            //System.println(i+" : "+_hdata[i]);
            _time=new Time.Moment(_hdata[i]["time"]);
            _current = Gregorian.info(_time, Time.FORMAT_MEDIUM);
            System.println(i + " => "+_current.day + " - "+_current.hour+":"+_current.min);
            System.println("icon: " + _hdata[i]["icon"] + " T: " +_hdata[i]["temperature"]+ " Pre : "+(_hdata[i]["precipProbability"] * 100)+
            	" summary: " + _hdata[i]["summary"]);
        }
    
    }

    function receiveCurrentWeather(responseCode, data) {
   		System.println("receiveCurrentWeather");
        if (responseCode == 200) {
             if (data instanceof Lang.String && data.equals("Forbidden")) {
                var dict = { "msg" => "WRONG KEY" };
                System.println("wrong API key");
                //Background.exit(dict);
            } else {
                if (data instanceof Dictionary) {                                    
                    // TODO: persist receive data
                    var myapp = App.getApp();
                    var lastData = data;
                    lastFetchTime = Time.now().value();
                    myapp.Storage.setValue("lastdata",lastData);
                    setLastRefresh(lastFetchTime);
                    _status = 0;
                    parseCurrentWeather(data);
                }   
            }
        } else {
            System.println("Current weather response code " + responseCode);
            //maybe null !  + " message " + data.get("message"));   
            //App.Storage.deleteValue(  
            var myapp = App.getApp();    
            lastFetchTime = null;                  
            setLastRefresh(lastFetchTime);
        }
        WatchUi.requestUpdate();
    }

    function receiveHourlyWeather(responseCode, data) {
   		System.println("receiveHourlyWeather");
        if (responseCode == 200) {
             if (data instanceof Lang.String && data.equals("Forbidden")) {
                var dict = { "msg" => "WRONG KEY" };
                System.println("wrong API key");
                //Background.exit(dict);
            } else {
                if (data instanceof Dictionary) {                                    
                    // TODO: persist receive data
                    var myapp = App.getApp();
                    var lastData = data;
                    lastFetchTime = Time.now().value();
                    myapp.Storage.setValue("lastdata",lastData);
                    setLastRefresh(lastFetchTime);
                    _status = 0;
                    parseHourlyWeather(data);
                }   
            }
        } else {
            System.println("Current weather response code " + responseCode);
            //maybe null !  + " message " + data.get("message"));   
            //App.Storage.deleteValue(  
            var myapp = App.getApp();    
            lastFetchTime = null;                  
            setLastRefresh(lastFetchTime);
        }
        WatchUi.requestUpdate();
    }

    // map icon name to png
    var iconIds = { 
        "clear-day" => :clear_day,
        "clear-night" => :clear_night,
        "cloudy" => :cloudy,
        "fog" => :fog,
        "partly-cloudy-day" => :partly_cloudy_day,
        "partly-cloudy-night" => :partly_cloudy_night,
        "rain" => :rain,
        "sleet" => :sleet,
        "snow" => :snow,
        "wind" => :wind
    };


  function getIcon(name) {
    return new WatchUi.Bitmap({:rezId=>Rez.Drawables[iconIds[name]]});
  }

  function drawIcon(dc, x, y, symbol) {
    var icon = getIcon(symbol);
    icon.setLocation(x, y);
    icon.draw(dc);
    //var dim = icon.getDimensions();
    //System.println("WxH : "+dim[0] + ","+dim[1]);
    //dc.drawText(x,y,Gfx.FONT_SMALL,iconIds[symbol],Gfx.TEXT_JUSTIFY_CENTER);    
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
}
