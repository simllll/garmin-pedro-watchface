// based on analog clock view layer example of garmin sdk

import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Application.Storage;

class AnalogClockViewLayer extends WatchUi.Layer {
    private var _font as FontResource?;
    
    private var _screenShape as ScreenShape;
    private var _dndIcon as BitmapResource?;
    private var _wingsImage  as BitmapResource?;
    
    private var _drawBackground as Boolean?;

    private var _width;
    private var _height;

    private var _datafields as Datafields;

    public function initialize(dc as Dc) {
        System.println("AnalogClockViewLayer initialize()");

        Layer.initialize({:x=>0, :y=>0});
        _screenShape = System.getDeviceSettings().screenShape;
        
        _width = dc.getWidth();
        _height = dc.getHeight();

        _font = WatchUi.loadResource($.Rez.Fonts.id_font_black_diamond) as FontResource;

        _datafields = new Datafields();

        _wingsImage = lowMemoryDevice == false && WatchSettings.showlogo == true ? WatchUi.loadResource($.Rez.Drawables.earlybirds) as BitmapResource : null;
    }

    private function validateDNDIcon() {
        if (_dndIcon == null) {
            _dndIcon = WatchUi.loadResource($.Rez.Drawables.DoNotDisturbIcon) as BitmapResource;
        }
    }

    // taken from garmin example, copyright to them.

    //! This function is used to generate the coordinates of the 4 corners of the polygon
    //! used to draw a watch hand. The coordinates are generated with specified length,
    //! tail length, and width and rotated around the center point at the provided angle.
    //! 0 degrees is at the 12 o'clock position, and increases in the clockwise direction.
    //! @param centerPoint The center of the clock
    //! @param angle Angle of the hand in radians
    //! @param handLength The length of the hand from the center to point
    //! @param tailLength The length of the tail of the hand
    //! @param width The width of the watch hand
    //! @return The coordinates of the watch hand
    private function generateHandCoordinates(centerPoint as Array<Number>, angle as Float, handLength as Number, tailLength as Number, width as Number) as Array<[Float, Float]> {
        // System.println("AnalogClockViewLayer generateHandCoordinates()");
        // Map out the coordinates of the watch hand
        var coords = [[-(width / 2), tailLength],
                      [-(width / 2), -handLength],
                      [width / 2, -handLength],
                      [width / 2, tailLength]];
        var result = new Array<[Float, Float]>[4];
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i++) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin) + 0.5;
            var y = (coords[i][0] * sin) + (coords[i][1] * cos) + 0.5;

            result[i] = [centerPoint[0] + x, centerPoint[1] + y];
        }

        return result;
    }

    //! Draws the clock tick marks around the outside edges of the screen.
    //! @param dc Device context
    private function drawHashMarks(dc as Dc) as Void {
        // System.println("AnalogClockViewLayer drawHashMarks()");
        
        // Draw hashmarks differently depending on screen geometry.
        if (System.SCREEN_SHAPE_ROUND == _screenShape) {
            var outerRad = _width / 2;
            var innerRad = outerRad - 10;
            // Loop through each 15 minute block and draw tick marks.
            for (var i = Math.PI / 6; i <= 11 * Math.PI / 6; i += (Math.PI / 3)) {
                // Partially unrolled loop to draw two tickmarks in 15 minute block.
                var sY = outerRad + innerRad * Math.sin(i);
                var eY = outerRad + outerRad * Math.sin(i);
                var sX = outerRad + innerRad * Math.cos(i);
                var eX = outerRad + outerRad * Math.cos(i);
                dc.drawLine(sX, sY, eX, eY);
                i += Math.PI / 6;
                sY = outerRad + innerRad * Math.sin(i);
                eY = outerRad + outerRad * Math.sin(i);
                sX = outerRad + innerRad * Math.cos(i);
                eX = outerRad + outerRad * Math.cos(i);
                dc.drawLine(sX, sY, eX, eY);
            }
        } else {
            var coords = [0, _width / 4, (3 * _width) / 4, _width];
            for (var i = 0; i < coords.size(); i++) {
                var dx = ((_width / 2.0) - coords[i]) / (_height / 2.0);
                var upperX = coords[i] + (dx * 10);
                // Draw the upper hash marks.
                dc.fillPolygon([[coords[i] - 1, 2],
                                [upperX - 1, 12],
                                [upperX + 1, 12],
                                [coords[i] + 1, 2]]);
                // Draw the lower hash marks.
                dc.fillPolygon([[coords[i] - 1, _height - 2],
                                [upperX - 1, _height - 12],
                                [upperX + 1, _height - 12],
                                [coords[i] + 1, _height - 2]]);
            }
        }
    }

    //! Handle the update event
    //! @param dc Device context
    public function fullUpdate(layer as WatchUi.Layer) as Void {
        var dc = layer.getDc();
        // System.println("AnalogClockViewLayer fullUpdate(drawBackground: "+_drawBackground+")");
        
        dc.clearClip();
        
        var color = WatchSettings.color;

        if (_drawBackground) {
            dc.setColor(Graphics.COLOR_BLACK, color);
            dc.fillRectangle(0, 0, _width, _height);

            // Draw a grey triangle over the upper right half of the screen.
            dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
            dc.fillPolygon([[0, 0],
                              [_width, 0],
                              [_width, _height],
                              [0, 0]]);

            if (_wingsImage != null) {
                dc.drawBitmap(_width / 2 - (_wingsImage.getWidth() / 2), _height / 2 - (_wingsImage.getHeight() / 2), _wingsImage);
            }
        } else {
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.clear();
        }

        // Draw the tick marks around the edges of the screen
        drawHashMarks(dc);

        // Draw the do-not-disturb icon if we support it and the setting is enabled
        if (System.getDeviceSettings().doNotDisturb && validateDNDIcon() && _dndIcon != null) {
            dc.drawBitmap(_width * 0.75, _height / 2 - 15, _dndIcon);
        }

        dc.setColor(color, Graphics.COLOR_TRANSPARENT);

        _datafields.drawDataFields(dc, _width, _height);
        
        var clockTime = System.getClockTime();
    
        // Draw the hour hand. Convert it to minutes and compute the angle.
        var hourHandAngle = (((clockTime.hour % 12) * 60) + clockTime.min);
        hourHandAngle = hourHandAngle / (12 * 60.0);
        hourHandAngle = hourHandAngle * Math.PI * 2;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateHandCoordinates([_width / 2, _height / 2], hourHandAngle, _height / 6 + 1, 0, _width / 40));
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateHandCoordinates([_width / 2, _height / 2], hourHandAngle, _height / 6, 0, _width / 80));

        // Draw the minute hand.
        var minuteHandAngle = (clockTime.min / 60.0) * Math.PI * 2;
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateHandCoordinates([_width / 2, _height / 2], minuteHandAngle, _height / 3 + 1, 0, _width / 60));
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(generateHandCoordinates([_width / 2, _height / 2], minuteHandAngle, _height / 3, 0, _width / 120));

        // Draw the 3, 6, 9, and 12 hour labels.
        var font = _font;
        if (font != null) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT); // COLOR_DK_GRAY);
            dc.drawText(_width / 2, 2, font, "12", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(_width - 2, (_height / 2) - 15, font, "3", Graphics.TEXT_JUSTIFY_RIGHT);
            dc.setColor(Graphics.COLOR_WHITE,  Graphics.COLOR_TRANSPARENT); //Graphics.COLOR_BLACK);
            dc.drawText(_width / 2, _height - 30, font, "6", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(2, (_height / 2) - 15, font, "9", Graphics.TEXT_JUSTIFY_LEFT);
        }


        // Draw the arbor in the center of the screen.
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_BLACK);
        dc.fillCircle(_width / 2, _height / 2, 7);
        dc.setColor(Graphics.COLOR_BLACK,Graphics.COLOR_BLACK);
        dc.drawCircle(_width / 2, _height / 2, 7);

        // Draw the battery percentage directly to the main screen.
        if (System.getSystemStats().battery < 15) {
            var dataString = (System.getSystemStats().battery + 0.5).toNumber().toString() + "%";
            dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
            dc.drawText(_width / 2, 3 * _height / 4 - 20, Graphics.FONT_XTINY, dataString, Graphics.TEXT_JUSTIFY_CENTER);
        }
    }

    public function getSecondsView() {
        return new WatchUi.Layer({
            :locX=>0,
            :locY=>0,
            :width=>_width / 4,
            :height=>_height / 4,
            :colorDepth=>8,
        });
    }

    //! Handle the partial update event
    //! @param dc Device context
    public function secondsUpdate(layer as WatchUi.Layer) as Void {
        var dc = layer.getDc();
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.clear();

        var clockTime = System.getClockTime();
        // System.println("AnalogClockViewLayer secondsUpdate(): " + clockTime.sec);
        
        var heightOffset = _height / 4;
        var widthOffset = _width / 4;

        if(clockTime.sec < 15) {
            widthOffset = _width / 2;
            heightOffset = _height / 4;
        } else if(clockTime.sec < 30) {
            widthOffset = _width / 2;
            heightOffset = _height / 2;
        } else if(clockTime.sec < 45) {
            widthOffset = _width / 4;
            heightOffset = _height / 2;
        } /* else if(clockTime.sec < 60) {
            widthOffset = 0;
            heightOffset = 0;
        }*/

        if (layer.getX() != widthOffset || layer.getY() != heightOffset) {
            layer.setLocation(widthOffset, heightOffset);
        }
        
        // System.println("secondsUpdate position(): " + layer.getX() + "," + layer.getY());

        var secondHand = (clockTime.sec / 60.0) * Math.PI * 2;
        var secondHandPoints = generateHandCoordinates([_width / 2 - widthOffset, _height / 2 - heightOffset], secondHand, _height / 4, 20, _width / 120);
        
        // Update the clipping rectangle to the new location of the second hand.
        var curClip = getBoundingBox(secondHandPoints);
        var bBoxWidth = curClip[1][0] - curClip[0][0] + 1;
        var bBoxHeight = curClip[1][1] - curClip[0][1] + 1;
        dc.setClip(curClip[0][0], curClip[0][1], bBoxWidth, bBoxHeight);

        // Draw the second hand to the screen.
        dc.setColor(Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(secondHandPoints);
    }

    //! Compute a bounding box from the passed in points
    //! @param points Points to include in bounding box
    //! @return The bounding box points
    private function getBoundingBox(points as Array< Array<Number or Float> >) as Array< Array<Number or Float> > {
        var min = [9999, 9999];
        var max = [0,0];

        for (var i = 0; i < points.size(); ++i) {
            if (points[i][0] < min[0]) {
                min[0] = points[i][0];
            }

            if (points[i][1] < min[1]) {
                min[1] = points[i][1];
            }

            if (points[i][0] > max[0]) {
                max[0] = points[i][0];
            }

            if (points[i][1] > max[1]) {
                max[1] = points[i][1];
            }
        }

        return [min, max];
    }

    public function setDrawBackground(drawBackground as Boolean) as Void {
        _drawBackground = drawBackground;
    }
}
