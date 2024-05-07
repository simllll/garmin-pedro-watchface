import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;
import Toybox.Graphics;

var lowMemoryDevice as Boolean = false;

class WatchSettings {
    enum WatchMode {
        ANALOG,
        DIGITAL
    }
    
    enum DataFieldOptionEnum {
        DataFieldElevation = "Elevation",
        DataFieldHeartRate = "Heartrate",
        DataFieldTemperature = "Temperature",
        DataFieldDate = "Date",
        DataFieldBattery = "Battery",
        DataFieldCalories = "Calories",
        DataFieldSteps = "Steps",
        DataFieldTimeToRecovery = "Time To Recovery",
        DataFieldNone = "None"
    }

    public static var mode as WatchMode = ANALOG;
    public static var color as ColorValue = Graphics.COLOR_WHITE;
    public static var overlay as Boolean = true;;
    public static var showlogo as Boolean = true;
    public static var autoplay as Boolean = true;
    public static var datafield as [DataFieldOptionEnum, DataFieldOptionEnum, DataFieldOptionEnum, DataFieldOptionEnum] = [
            DataFieldElevation,
            DataFieldHeartRate,
            DataFieldTemperature, 
            DataFieldDate
        ];

    public static function getColor(value as String) {
        if (value == null) {
            return Graphics.COLOR_WHITE;
        }
        switch (value) {
            default:
            case "white":
                return Graphics.COLOR_WHITE;
            case "green":
                return Graphics.COLOR_GREEN;
            case "red":
                return Graphics.COLOR_RED;
            case "blue":
                return Graphics.COLOR_BLUE;
            case "yellow":
                return Graphics.COLOR_YELLOW;
            case "black":
                return Graphics.COLOR_BLACK;
            case "pink":
                return Graphics.COLOR_PINK;
            case "purple":
                return Graphics.COLOR_PURPLE;
        }
    }
}

class pedroappApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
        System.println("onStart: " + Storage.getValue("mode"));

        var mode = Storage.getValue("mode");
        WatchSettings.mode = mode != null && mode.equals("digital") ? WatchSettings.DIGITAL : WatchSettings.ANALOG;
        WatchSettings.color = WatchSettings.getColor(Storage.getValue("color"));
        WatchSettings.overlay = Storage.getValue("overlay") == false ? false : true;
        WatchSettings.showlogo = Storage.getValue("showlogo") == false ? false : true;
        WatchSettings.autoplay = Storage.getValue("autoplay") == false ? false : true;
        WatchSettings.datafield = [Storage.getValue("datafield0") != null ? Storage.getValue("datafield0") : WatchSettings.DataFieldElevation, 
                            Storage.getValue("datafield1") != null ? Storage.getValue("datafield1") : WatchSettings.DataFieldHeartRate, 
                            Storage.getValue("datafield2") != null ? Storage.getValue("datafield2") : WatchSettings.DataFieldTemperature,
                            Storage.getValue("datafield3") != null ? Storage.getValue("datafield3") : WatchSettings.DataFieldDate];

        var partNumber = System.getDeviceSettings().partNumber;
        lowMemoryDevice =  partNumber.equals("006-B3652-00") || // forerunner 945 lte
                         partNumber.equals("006-B3113-00") || // forerunner 945
                         partNumber.equals("006-B3589-00") || // forerunner 745
                         partNumber.equals("006-B4432-00") || // forerunner 165
                         partNumber.equals("006-B3076-00") || // forerunner 245
                         partNumber.equals("006-B2697-00") || // Fenix 5
                         partNumber.equals("006-B3289-00") || // Fenix 6	
                         partNumber.equals("006-B3287-00") || // Fenix 6S	
                         partNumber.equals("006-B3288-00") || // Fenix 6S pro
                         partNumber.equals("006-B3291-00") || // Fenix 6x pro
                         partNumber.equals("006-B3290-00") || // fenix 6 pro
                         partNumber.equals("006-B3226-00"); // Venu
 
        System.println("Device Model: " + partNumber + ", Low Memory Device = " + lowMemoryDevice);
    }

    function onSettingsChanged() {
        System.println("settings updated! :-)");
        WatchUi.requestUpdate();
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
        System.println("onStop");
    }

    // Return the initial view of your application here
    function getInitialView() as [Views] or [Views, InputDelegates] {
        if (WatchUi has :WatchFaceDelegate) {
            var view = new BaseWatchFace();
            var delegate = new BaseWatchFaceDelegate(view);
            return [view, delegate];
        } else {
            return [new BaseWatchFace()];
        }
    }

    //! Return the settings view and delegate
    //! @return Array Pair [View, Delegate]
    public function getSettingsView() as [Views] or [Views, InputDelegates] or Null {
        return [new SettingsMenu(), new SettingsMenuDelegate()];
    }
}

function getApp() as pedroappApp {
    return Application.getApp() as pedroappApp;
}