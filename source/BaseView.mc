import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;
import Toybox.Application.Storage;

var _animationCompleted = true;

class BaseWatchFace extends WatchUi.WatchFace {
    private var animationLayer as WatchUi.AnimationLayer or Null = null; // pedro animation
    private var clockLayer as AnalogClockViewLayer or DigitalClockViewLayer or Null = null; // watch face
    private var clockLayerTop as WatchUi.Layer?; // watch face (seconds)

    private var _isAwake as Boolean?;
    private var _partialUpdatesAllowed as Boolean;

    private var _initializedWatchMode;

    public function initialize() {
        WatchFace.initialize();

        _partialUpdatesAllowed = (WatchUi.WatchFace has :onPartialUpdate);

    }

    private function initWatchFace(dc as Dc) {
        System.println("initWatchFace(): " + WatchSettings.mode);
        clockLayer = WatchSettings.mode == WatchSettings.DIGITAL ?
                        new DigitalClockViewLayer(dc) :
                        new AnalogClockViewLayer(dc);
        _initializedWatchMode = WatchSettings.mode;

        insertLayer(clockLayer, 1);
        if (_partialUpdatesAllowed) {
            clockLayerTop = clockLayer.getSecondsView();
            if (clockLayerTop != null) {
                insertLayer(clockLayerTop, 2);
            }
        }
    }

    public function onLayout(dc as Dc) as Void {
        if (lowMemoryDevice == false && WatchSettings.overlay == true) {
            initWatchFace(dc);
        }
    }

    public function onUpdate(dc as Dc) as Void {
        if (clockLayer != null && _initializedWatchMode != WatchSettings.mode) {
            // if watch face mode changed, re init
            _animationCompleted = true; // changing the view, stops any animations
            initWatchFace(dc);
        }
        if (_animationCompleted) {
            // remove animation layer if it still exists
            if (animationLayer != null) {
                System.println("killAnimations()");
                removeLayer(animationLayer);
                animationLayer = null;
            }
            // (re)create clock layer
            if (clockLayer == null) {
                initWatchFace(dc);
            }
            clockLayer.setDrawBackground(true);
            if (clockLayerTop != null) {
                clockLayerTop.setVisible(true);
            }
            _animationCompleted = false;
        }
        
        if (clockLayer != null) {
            // handle onUpdate
            clockLayer.fullUpdate(clockLayer);
            // only draw seconds when background is also visible (so not during animation)
            if (animationLayer == null && (_partialUpdatesAllowed || _isAwake)) {
                // If this device supports partial updates and they are currently
                // allowed run the onPartialUpdate method to draw the second hand.
                onPartialUpdate(dc);
            }
        }
    }

    public function onPartialUpdate(dc as Dc) as Void {
        // handle onPartialUpdate
        if (clockLayer != null && clockLayerTop != null) {
            clockLayer.secondsUpdate(clockLayerTop);
        }
    }

    //! Turn off partial updates
    public function turnPartialUpdatesOff() as Void {
        _partialUpdatesAllowed = false;
    }

    // The user has just looked at their watch.
    // Time to trigger the start of the animation.
    function onExitSleep() {
      // System.println("onExitSleep()");
      
      _isAwake = true;
      
      /* if (clockLayerTop != null) {
        clockLayerTop.setVisible(true);
      }*/

      if (WatchSettings.autoplay) {
        doAnimation();
      }
    }

    // Terminate any active timers and prepare for slow updates.
    // Let's trigger an onUpdate() to show the time
    function onEnterSleep() {
      _animationCompleted = true;
      
      _isAwake = false;
      
      /* if (clockLayerTop != null) {
        clockLayerTop.setVisible(false);
      }*/

      // System.println("onEnterSleep()");
      WatchUi.requestUpdate();
    }

    // let's load the animation, and initialise the
    // delegate to manage any play events
    function loadAnimation() {
      // System.println("loadAnimation()");
        animationLayer = new WatchUi.AnimationLayer(
            Rez.Drawables.pedro,
            {
                :locX=>0,
                :locY=>0,
            }
            );

        insertLayer(animationLayer, 0);
    }

    // wrapper to play the animation,
    // but let's first check if the animation exists, if not load it.
    public function doAnimation() {
       System.println("doAnimation(): " + WatchSettings.overlay);
        if (lowMemoryDevice == true || WatchSettings.overlay == false) {
            if (clockLayer != null) {
                removeLayer(clockLayer);
                clockLayer = null;
            }
            if (clockLayerTop != null) {
                removeLayer(clockLayerTop);
                clockLayerTop = null;
            }
        }

        if( animationLayer == null ) {
            loadAnimation();
        }

        if (clockLayer != null) {
            clockLayer.setDrawBackground(false);
        }

        if (clockLayerTop != null) {
            clockLayerTop.setVisible(false);
        }

        _animationCompleted = false;
        // System.println("play()");
        animationLayer.play({:delegate=>new AnimationDelegate()});
    }


    // load, and play the animation when the show event triggers
    function onShow() {
      /// System.println("onShow()");
      doAnimation();
    }
}

//! Receives watch face events
class BaseWatchFaceDelegate extends WatchUi.WatchFaceDelegate {
    private var _view as BaseWatchFace;

    //! Constructor
    //! @param view The analog view
    public function initialize(view as BaseWatchFace) {
        System.println("BaseWatchFaceDelegate initialize(): " + (WatchUi.WatchFaceDelegate has :onPress ? "onPress suppported": "no onpress"));
        WatchFaceDelegate.initialize();
        _view = view;
    }

    //! The onPowerBudgetExceeded callback is called by the system if the
    //! onPartialUpdate method exceeds the allowed power budget. If this occurs,
    //! the system will stop invoking onPartialUpdate each second, so we notify the
    //! view here to let the rendering methods know they should not be rendering a
    //! second hand.
    //! @param powerInfo Information about the power budget
    public function onPowerBudgetExceeded(powerInfo as WatchFacePowerInfo) as Void {
        System.println("Average execution time: " + powerInfo.executionTimeAverage);
        System.println("Allowed execution time: " + powerInfo.executionTimeLimit);
        _view.turnPartialUpdatesOff();
    }
    
    public function onPress(clickEvent) {
        System.println("Touch screen clicked");
        _view.doAnimation();
        return false;
    }
}

class AnimationDelegate extends WatchUi.AnimationDelegate {

    function initialize() {
        WatchUi.AnimationDelegate.initialize();
    }

    function onAnimationEvent(event, options) {

        switch(event) {

            // when the animation is done, trigger an
            // onUpdate() to show the time
            case ANIMATION_EVENT_COMPLETE:
              _animationCompleted = true;
              System.println("animation completed");
              WatchUi.requestUpdate();
              break;

            default:

        }

    }

}