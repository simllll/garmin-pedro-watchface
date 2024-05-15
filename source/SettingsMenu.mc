import Toybox.Application.Storage;
import Toybox.Lang;
import Toybox.WatchUi;

var colorMenuItem as WatchUi.MenuItem?;
var datafield0MenuItem as WatchUi.MenuItem?;
var datafield1MenuItem as WatchUi.MenuItem?;
var datafield2MenuItem as WatchUi.MenuItem?;
var datafield3MenuItem as WatchUi.MenuItem?;

class SettingsMenu extends WatchUi.Menu2 {

    public function initialize() {
        Menu2.initialize({:title=>"Settings"});

        colorMenuItem = new WatchUi.MenuItem("Color", null, "color", {});

        Menu2.addItem(colorMenuItem);

        var boolean = WatchSettings.mode == WatchSettings.DIGITAL ? true : false;
        Menu2.addItem(new WatchUi.ToggleMenuItem("Digital Clock", null, "mode", boolean, null));

        Menu2.addItem(new WatchUi.MenuItem("Data Fields", null, "datafields", {}));

        if (lowMemoryDevice == false) {
            Menu2.addItem(new WatchUi.ToggleMenuItem("Show Logo", null, "logo", WatchSettings.showlogo, null));
        }

        if (lowMemoryDevice == false) {
            Menu2.addItem(new WatchUi.ToggleMenuItem("Show Watch during pedro", null, "overlay", WatchSettings.overlay, null));
        }

        Menu2.addItem(new WatchUi.ToggleMenuItem("Auto Play (Play On Motion)", null, "autoplay", WatchSettings.autoplay, null));
    }
}

class ColorMenuDelegate extends WatchUi.Menu2InputDelegate {
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(menuItem as MenuItem) as Void {
        System.println("menuItem: "+ menuItem.getId());
        Storage.setValue("color", menuItem.getId());
        WatchSettings.color = WatchSettings.getColor(menuItem.getId() as String);
        if (colorMenuItem != null) {
            colorMenuItem.setSubLabel(menuItem.getId());
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

class DatafieldMenuDelegate extends WatchUi.Menu2InputDelegate {
    var _datafield as Number;
    public function initialize(datafield as Number) {
        Menu2InputDelegate.initialize();
        _datafield = datafield;
    }

    public function onSelect(menuItem as MenuItem) as Void {
        Storage.setValue("datafield" + _datafield, menuItem.getId());
        WatchSettings.datafield[_datafield] = menuItem.getId();
        switch (_datafield) {
            case 0:
                if (datafield0MenuItem != null) {
                    datafield0MenuItem.setSubLabel(menuItem.getId());
                }
                break;
            case 1:
                if (datafield1MenuItem != null) {
                    datafield1MenuItem.setSubLabel(menuItem.getId());
                }    
                break;
            case 2:
                if (datafield2MenuItem != null) {
                    datafield2MenuItem.setSubLabel(menuItem.getId());
                }
                break;
            case 3:
                if (datafield3MenuItem != null) {
                    datafield3MenuItem.setSubLabel(menuItem.getId());
                }
                break;
            
        }
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    private function addDataFieldSubEntries(menu as WatchUi.Menu2) {
        menu.addItem(new WatchUi.MenuItem("Heart Rate", null, WatchSettings.DataFieldHeartRate, {}));
        menu.addItem(new WatchUi.MenuItem("Temperature", null, WatchSettings.DataFieldTemperature, {}));
        menu.addItem(new WatchUi.MenuItem("Battery", null, WatchSettings.DataFieldBattery, {}));
        menu.addItem(new WatchUi.MenuItem("Calories", null, WatchSettings.DataFieldCalories, {}));
        menu.addItem(new WatchUi.MenuItem("Steps", null, WatchSettings.DataFieldSteps, {}));
        menu.addItem(new WatchUi.MenuItem("Time to Recovery", null, WatchSettings.DataFieldTimeToRecovery, {}));
        menu.addItem(new WatchUi.MenuItem("Elevation", null, WatchSettings.DataFieldElevation, {}));
        menu.addItem(new WatchUi.MenuItem("Date", null, WatchSettings.DataFieldDate, {}));
        menu.addItem(new WatchUi.MenuItem("(none)", null, WatchSettings.DataFieldNone, {}));
    }

    public function onSelect(menuItem as MenuItem) as Void {
        switch (menuItem.getId() as String) {
            case "color": {
                var menu = new WatchUi.Menu2({:title=>"Color"});
                menu.addItem(new WatchUi.MenuItem("White (default)", null, "white", {}));
                menu.addItem(new WatchUi.MenuItem("Green", null, "green", {}));
                menu.addItem(new WatchUi.MenuItem("Red", null, "red", {}));
                menu.addItem(new WatchUi.MenuItem("Blue", null, "blue", {}));
                menu.addItem(new WatchUi.MenuItem("Yellow", null, "yellow", {}));
                menu.addItem(new WatchUi.MenuItem("Black", null, "black", {}));
                menu.addItem(new WatchUi.MenuItem("Pink", null, "pink", {}));
                menu.addItem(new WatchUi.MenuItem("Purple", null, "purple", {}));

                WatchUi.pushView(menu, new ColorMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
                break;
            }
            case "datafields": {
                var menu = new WatchUi.Menu2({:title=>"datafields"});
                datafield0MenuItem = new WatchUi.MenuItem("Data Field Left", WatchSettings.datafield[0], "datafield0", {});
                menu.addItem(datafield0MenuItem);
                datafield1MenuItem = new WatchUi.MenuItem("Data Field Right", WatchSettings.datafield[1], "datafield1", {});
                menu.addItem(datafield1MenuItem);
                datafield2MenuItem = new WatchUi.MenuItem("Data Field Top", WatchSettings.datafield[2], "datafield2", {});
                menu.addItem(datafield2MenuItem);
                datafield3MenuItem = new WatchUi.MenuItem("Data Field Bottom", WatchSettings.datafield[3], "datafield3", {});
                menu.addItem(datafield3MenuItem);

                WatchUi.pushView(menu, new SettingsMenuDelegate(), WatchUi.SLIDE_IMMEDIATE);
                break;
            }
            case "datafield0": {
                var menu = new WatchUi.Menu2({:title=>"Data Field Left"});
                addDataFieldSubEntries(menu);
                
                WatchUi.pushView(menu, new DatafieldMenuDelegate(0), WatchUi.SLIDE_IMMEDIATE);
                break;
            }
            case "datafield1": {
                var menu = new WatchUi.Menu2({:title=>"Data Field Right"});
               addDataFieldSubEntries(menu);
                
                WatchUi.pushView(menu, new DatafieldMenuDelegate(1), WatchUi.SLIDE_IMMEDIATE);
                break;
            }
            case "datafield2": {
                var menu = new WatchUi.Menu2({:title=>"Data Field Top"});
                addDataFieldSubEntries(menu);
                
                WatchUi.pushView(menu, new DatafieldMenuDelegate(2), WatchUi.SLIDE_IMMEDIATE);
                break;
            }
            case "datafield3": {
                var menu = new WatchUi.Menu2({:title=>"Data Field Bottom"});
                addDataFieldSubEntries(menu);
                
                WatchUi.pushView(menu, new DatafieldMenuDelegate(3), WatchUi.SLIDE_IMMEDIATE);
                break;
            }
            case "mode":
                if (menuItem instanceof ToggleMenuItem) {
                    Storage.setValue("mode", menuItem.isEnabled() ? "digital" : "analog");
                    WatchSettings.mode = menuItem.isEnabled() ? WatchSettings.DIGITAL : WatchSettings.ANALOG;
                }
                break;
            case "logo":
                if (menuItem instanceof ToggleMenuItem) {
                    Storage.setValue("showlogo", menuItem.isEnabled());
                    WatchSettings.showlogo = menuItem.isEnabled() ? true : false;                    
                }
                break;
            case "overlay":
                if (menuItem instanceof ToggleMenuItem) {
                    Storage.setValue("overlay", menuItem.isEnabled());
                    WatchSettings.overlay = menuItem.isEnabled() ? true : false;
                }
                break;
            case "autoplay":
                if (menuItem instanceof ToggleMenuItem) {
                    Storage.setValue("autoplay", menuItem.isEnabled());
                    WatchSettings.autoplay = menuItem.isEnabled() ? true : false;
                }
                break;
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
		// return false;
    }
}
