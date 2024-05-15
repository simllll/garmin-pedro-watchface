import Toybox.Math;
import Toybox.System;
using Toybox.ActivityMonitor;
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.Lang;

class Datafields {
    var _datafield_loaded_icon  as [WatchSettings.DataFieldOptionEnum, WatchSettings.DataFieldOptionEnum, WatchSettings.DataFieldOptionEnum, WatchSettings.DataFieldOptionEnum] = [
         WatchSettings.DataFieldNone,
         WatchSettings.DataFieldNone,
         WatchSettings.DataFieldNone,
         WatchSettings.DataFieldNone
     ];

    var _datafield_icon as [BitmapResource or Null, BitmapResource or Null, BitmapResource or Null, BitmapResource or Null] = [
        null, null, null, null
    ];

    private function getElevation() {
        var altitude = Toybox.Activity.getActivityInfo().altitude;
        if (altitude == null) {
            return null;
        }
         return Math.round(altitude).toNumber().toString();
    }

    private  function getSteps() {
        var steps = ActivityMonitor.getInfo().steps;
        if (steps == null) {
            return null;
        }
         return steps.toNumber().toString();
    }

    private  function getCalories() {
        var steps = ActivityMonitor.getInfo().calories;
        if (steps == null) {
            return null;
        }
         return steps.toNumber().toString();
    }

    private function getTimeToRecovery() {
        var timeToRecovery = ActivityMonitor.getInfo().timeToRecovery;
        if (timeToRecovery == null) {
            return null;
        }
        return timeToRecovery.toNumber().toString();
    }

    private function getBattery() {
        return (System.getSystemStats().battery + 0.5).toNumber().toString() + "%";
    }

    private function getWeatherTemperature() {
        var weather = Toybox.Weather.getCurrentConditions();
        if (weather == null) {
            return null;
        }
        return weather.temperature.toNumber().toString()+"°";
    }
    
    private function getHeartrate() {
    	var heartrateIterator = ActivityMonitor.getHeartRateHistory(1, true);
        var currentHeartrate = heartrateIterator.next().heartRate;

        if(currentHeartrate == Toybox.ActivityMonitor.INVALID_HR_SAMPLE) {
            return null;
        }		

        return currentHeartrate.format("%d");
    }
    
    private function enoughMemory(datafield as Number) {
        if (lowMemoryDevice) {
            // only allow 2 icons on low memory devices
            var cnt = (datafield != 0 && _datafield_icon[0] != null ? 1 : 0) +
                (datafield != 1 && _datafield_icon[1] != null ? 1 : 0) + 
                (datafield != 2 && _datafield_icon[2] != null ? 1 : 0) +
                (datafield != 3 && _datafield_icon[3] != null ? 1 : 0);

            // System.println("enoughMemory: " + cnt);

            if (cnt >= 2) {
                return false;
            }
        }
        return true;
    }

    private function getdatafieldFieldValue(datafield as Number) {
        switch(WatchSettings.datafield[datafield]) {
            case WatchSettings.DataFieldHeartRate:
                if (_datafield_loaded_icon[datafield] != WatchSettings.DataFieldHeartRate) {
                    _datafield_icon[datafield] = enoughMemory(datafield) ? WatchUi.loadResource($.Rez.Drawables.HeartIcon) as BitmapResource : null;
                    _datafield_loaded_icon[datafield] = WatchSettings.DataFieldHeartRate;
                }
                return getHeartrate();
            case WatchSettings.DataFieldTemperature:
               if (_datafield_loaded_icon[datafield] != :temperature) {
                    _datafield_icon[datafield] = null;
                    _datafield_loaded_icon[datafield] = :temperature;
                }
                return getWeatherTemperature();
            case WatchSettings.DataFieldBattery:
                if (_datafield_loaded_icon[datafield] != :battery) {
                    _datafield_icon[datafield] = enoughMemory(datafield) ? WatchUi.loadResource($.Rez.Drawables.BatteryIcon) as BitmapResource : null;
                    _datafield_loaded_icon[datafield] = :battery;
                }
                return getBattery();
            case WatchSettings.DataFieldCalories:
                if (_datafield_loaded_icon[datafield] != :calories) {
                    _datafield_icon[datafield] = enoughMemory(datafield) ? WatchUi.loadResource($.Rez.Drawables.KCalIcon) as BitmapResource : null;
                    _datafield_loaded_icon[datafield] = :calories;
                }
                return getCalories();
            case WatchSettings.DataFieldSteps:
                if (_datafield_loaded_icon[datafield] != :steps) {
                    _datafield_icon[datafield] = enoughMemory(datafield) ? WatchUi.loadResource($.Rez.Drawables.StepsIcon) as BitmapResource : null;
                    _datafield_loaded_icon[datafield] = :steps;
                }
                return getSteps();
            case WatchSettings.DataFieldTimeToRecovery:
                if (_datafield_loaded_icon[datafield] != :timetorecovery) {
                    _datafield_icon[datafield] = null; // WatchUi.loadResource($.Rez.Drawables.StepsIcon) as BitmapResource;
                    _datafield_loaded_icon[datafield] = :timetorecovery;
                }
                return getTimeToRecovery();
            case WatchSettings.DataFieldElevation:
                if (_datafield_loaded_icon[datafield] != :elevation) {
                    _datafield_icon[datafield] = enoughMemory(datafield) ? WatchUi.loadResource($.Rez.Drawables.MountainIcon) as BitmapResource : null;
                    _datafield_loaded_icon[datafield] = :elevation;
                }
                return getElevation();
            case WatchSettings.DataFieldDate:
                if (_datafield_loaded_icon[datafield] != :date) {
                    _datafield_icon[datafield] = null;
                    _datafield_loaded_icon[datafield] = :date;
                }
                var info = Gregorian.info(Time.now(), Time.FORMAT_LONG);
                var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);
                return dateStr;
            case WatchSettings.DataFieldNone:
            default:
                if (_datafield_loaded_icon[datafield] != :none) {
                    _datafield_icon[datafield] = null;
                    _datafield_loaded_icon[datafield] = :none;
                }
                return null;
        }
    }

    private function drawBitmap(dc as Dc, x,y,icon) {
        try {
        if (dc has :drawBitmap2) {
            dc.drawBitmap2(x,y,icon, {
                 :tintColor=>WatchSettings.color,
                });
        } else {
            dc.drawBitmap(x,y,icon);
        }
        } catch (err) {
            System.println("cannot draw bitmap: " + err);
        }

    }

    public function drawDataFields(dc as Dc, width, height) {
        /*
        getdatafieldFieldValue(0) // left
        getdatafieldFieldValue(1) // right
        getdatafieldFieldValue(2) // top 
        getdatafieldFieldValue(3) // bottom
        */

        var datafield_left = getdatafieldFieldValue(0); // "elevation"
        if (datafield_left != null) {
            if (_datafield_icon[0] != null) {
                 drawBitmap(dc, width * 0.12, height / 2 - 20, _datafield_icon[0]);
            }
            dc.drawText(width * 0.15, height / 2, Graphics.FONT_XTINY, datafield_left, Graphics.TEXT_JUSTIFY_CENTER );
        }

        var datafield_right = getdatafieldFieldValue(1); // heartrate"
        if (datafield_right != null) {
            if (_datafield_icon[1] != null) {
                 drawBitmap(dc, width * 0.8, height / 2 - 20, _datafield_icon[1]);
            }
            dc.drawText(width * 0.85, height / 2, Graphics.FONT_XTINY, datafield_right,  Graphics.TEXT_JUSTIFY_CENTER );
        }

        var datafield_top = getdatafieldFieldValue(2); // "temperature"
        if (datafield_top != null) {
            if (_datafield_icon[2] != null) {
                 drawBitmap(dc, width / 2 - 20, height * 0.2 - 20, _datafield_icon[2]);
            }
            dc.drawText(width / 2, height * 0.2, Graphics.FONT_XTINY, datafield_top,  Graphics.TEXT_JUSTIFY_CENTER );
        }

        var datafield_bottom = getdatafieldFieldValue(3); //  "date"
        if (datafield_bottom != null) {
            if (_datafield_icon[3] != null) {
                 drawBitmap(dc, width / 2 - 20, 3 * height / 4 - 20, _datafield_icon[3]);
            }
            dc.drawText(width / 2, 3 * height / 4, Graphics.FONT_XTINY, datafield_bottom,  Graphics.TEXT_JUSTIFY_CENTER );
        }
    }
}