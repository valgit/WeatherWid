/*
 * comm tools to API
 */
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Communications;
using Toybox.Application as App;

using Toybox.Math; 

using Toybox.Time;
using Toybox.Time.Gregorian;

class weatherDelegate {
    
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
                    var lastData = data;
                    var lastFetchTime = Time.now().value();
                    //setLastData(lastData);
                    setLastRefresh(lastFetchTime);
                    _status = 0;
                    parseCurrentWeather(data);
                }   
            }
        } else {
            System.println("Current weather response code " + responseCode);
            //maybe null !  + " message " + data.get("message"));   
            //App.Storage.deleteValue(  
            var lastFetchTime = null;                  
            setLastRefresh(lastFetchTime);
        }
        WatchUi.requestUpdate();
    }

    function receiveHourlyWeather(responseCode, data) {
   		System.println("receiveHourlyWeather");
        if (responseCode == 200) {
             if (data instanceof Lang.String && data.equals("Forbidden")) {
                //var dict = { "msg" => "WRONG KEY" };
                System.println("wrong API key");
                //Background.exit(dict);
            } else {
                if (data instanceof Dictionary) {                                    
                    // TODO: persist receive data
                    var lastData = data;
                    var lastFetchTime = Time.now().value();
                    //setLastData(lastData);
                    setLastRefresh(lastFetchTime);
                    _status = 0;
                    parseHourlyWeather(data);
                }   
            }
        } else {
            System.println("Current weather response code " + responseCode);
            //maybe null !  + " message " + data.get("message"));   
            //App.Storage.deleteValue(      
            var lastFetchTime = null;                  
            setLastRefresh(lastFetchTime);
        }
        WatchUi.requestUpdate();
    }

}
