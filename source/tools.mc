/*
 *
 */

function getLestRefresh() {
    var myapp = App.getApp();
    var lastFetchTime = null;
        // TODO : check if (Toybox.Application has :Storage && Toybox.Application.Storage has :setValue)
        //
    lastFetchTime = myapp.Storage.getValue("lastfetchtime");
    return lastFetchTime;
}

