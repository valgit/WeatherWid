using Toybox.WatchUi;
using Toybox.System;
using Toybox.Graphics as Gfx; 

class WeatherAppView extends WatchUi.View {
    private var mWidth;
    private var mHeight;

    function initialize() {
        System.println("view app initialize");
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        //setLayout(Rez.Layouts.MainLayout(dc));
        System.println("view app onLayout");
        mWidth=dc.getWidth();
        mHeight=dc.getHeight();
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
        System.println("view app onShow");
    }

    // Update the view
    function onUpdate(dc) {
        System.println("view app onUpdate");
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
          
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
		dc.clear();
		dc.setColor(Gfx.COLOR_WHITE,/*Gfx.COLOR_RED*/ Gfx.COLOR_TRANSPARENT);

        var _todo = "this is hourly view";
        dc.drawText(mWidth * 0.1, mHeight * 0.5,Gfx.FONT_XTINY,_todo,Gfx.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
        System.println("view app onHide");
    }

}
