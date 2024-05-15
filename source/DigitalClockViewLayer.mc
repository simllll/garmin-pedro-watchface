// based on digital clock view layer example of garmin sdk

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time.Gregorian;

class DigitalClockViewLayer extends WatchUi.Layer {
    private const MAJOR_FONT = Graphics.FONT_NUMBER_MEDIUM;
    private const MINOR_FONT = Graphics.FONT_NUMBER_MILD;
    
    private var _drawBackground as Boolean?;

    private var _minorFontHeight;
    private var _minorFontWidth;

    private var _width;
    private var _height;

    private var _wingsImage  as BitmapResource?;

    private var _datafields as Datafields;

    //! Constructor
    public function initialize(dc as Dc) {

        _width = dc.getWidth();
        _height = dc.getHeight();

        _minorFontHeight = Graphics.getFontHeight(MINOR_FONT);
        _minorFontWidth = _minorFontHeight * 2 / 3;
        
        Layer.initialize({
            :locX=>0,
            :locY=>0});

        _wingsImage = lowMemoryDevice == false && WatchSettings.showlogo == true ? WatchUi.loadResource($.Rez.Drawables.earlybirds) as BitmapResource : null;

        _datafields = new Datafields();
    }

    //! Update the view
    //! @param dc Device Context
    public function fullUpdate(layer as WatchUi.Layer) as Void {
        var dc = layer.getDc();

        System.println("DigitalClockViewLayer onUpdate(drawBackground: "+_drawBackground+")");
        var color = WatchSettings.color;

        // Update the entire draw layer
        if (_drawBackground) {
            if (color == Graphics.COLOR_BLACK) {
                dc.setColor(color, Graphics.COLOR_WHITE);
            } else {
                dc.setColor(color, Graphics.COLOR_BLACK);
            } 
            
            dc.clear();

            if (_wingsImage != null) {
                dc.drawBitmap(_width / 2 - (_wingsImage.getWidth() / 2), _height / 2 - (_wingsImage.getHeight() / 2), _wingsImage);
            }
        } else {
            dc.setColor(color, Graphics.COLOR_TRANSPARENT);
            dc.clear();
        }

        var clockTime = System.getClockTime();
        var hourMinString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);

        _datafields.drawDataFields(dc, _width, _height);

        dc.drawText(_width / 2, _height / 3, MAJOR_FONT, hourMinString, Graphics.TEXT_JUSTIFY_CENTER);
    }

    public function getSecondsView() {
        return new WatchUi.Layer({
            :locX=>_width / 2 - _minorFontWidth,
            :locY=>_height / 3 + Graphics.getFontHeight(MAJOR_FONT) - 15,
            :width=>_minorFontWidth * 2,
            :height=>_minorFontHeight,
            :colorDepth=>8,
        });
    }

    //! Handle the partial update event
    //! @param dc Device Context
    public function secondsUpdate(layer as WatchUi.Layer) as Void {
        var dc = layer.getDc();
        // System.println("DigitalClockViewLayer onPartialUpdate()");

        dc.setColor(WatchSettings.color, Graphics.COLOR_TRANSPARENT);
        dc.clear();

        // Only update the second digit
        var clockTime = System.getClockTime();
        var secString = Lang.format("$1$", [clockTime.sec.format("%02d")]);

        dc.setClip(0, 0, _minorFontWidth * 2, _minorFontHeight);
        dc.drawText(_minorFontWidth, 0, MINOR_FONT, secString, Graphics.TEXT_JUSTIFY_CENTER);
    }

    public function setDrawBackground(drawBackground as Boolean) as Void {
        _drawBackground = drawBackground;
    }
}