# garmin-pedro-watchface

Garmin Watchface that plays a pedro animation.
Includes a digital and analog watch face.

Download in Garmin Connect IQ Store fore free:
https://apps.garmin.com/apps/f148c8ff-8c37-4237-b0ae-4ad5e1bf98b5

If you like it, feel free to buy me a coffee: https://buymeacoffee.com/siml

Credits and Kodus to:
* https://github.com/sunpazed/garmin-hedgetime
* Garmin Analog Watch Face Example (https://github.com/markw65/garmin-ciq-samples/tree/main/Analog)
* Garmin Animation Example (https://github.com/markw65/garmin-ciq-samples/tree/main/AnimationWatchFace)

# Learnings
## Handle Low Memory Devices
* seconds update / partial updates only on 1/4 of the screen (or indivudal size), do not ues a full second layer (see Version 3)
* list of low memory devices to only have animation or the watch face, not both.
* use layer with reduced colors
* why use layers and not buffered bitmaps? easier and cleaner ;) and actually faster
* Enums and other things.. well, you are right, it could be done more memory friendly, but I would say it's a trade off between readable/maintable code and just few bits more ;-)
* Memory Errors are uncatchable :( Even though I have a workaround in place to handle low memory devices, I had to test each device seperately..I couldn't find a list that tells me the available memory, there is also nothing in the SDK to retrieve this information, and testing it by runtime is also not an option, as the app crashes without a way to handle it gracefully.

## Supporting more devices
To support more devices, I reduced the animation's file size by making it grayscale. And played around with monkey motion,
in the end I ended up with using Color Depht: 3 and Quality: Medium.
I also found out about the SDK versions, API Levels and Supported Devices. Even if you build "against" and older API level,
you can use the new features by checking it with "has" (https://developer.garmin.com/connect-iq/reference-guides/monkey-c-reference/). 
API levels on the other hand are the min version that are required to be supported, but then there is also supported devices. It can be that a watch has this minimum api level, but it still doesn't support the functionality. Therefore you always also have to check for the list
of supported devices.

## Images
Somehow images are handled differntly on some devices,
using drawBitmap2 fails on older Sdks, this can be checked if supported, but even falling back to drawBitmap
fails on some devices (e.g. Venu). Also I had to add a weird "format png" hack in the drawables.xml to get it running on some devices.

## Settings
Create a Menu was easier than expected, saving it and restoring the values on the other hand wasn't ;-). I wanted to find a way
to update values on the fly, but also have a permanent store to retrieve the settings again. I ended up with a "WatchSettings" instance with static properties to have some type safety in comparison to a Dictionary or other approaches. Check out SettingsMenu.mc and pedroappApp.mc how I did implement it.

# The story

I wanted to learn how an app or watch face can be created for a Garmin watch, so what would be better than 
actually creating a garmin watch face with the pedro animation to do this? :)

## Version 1: Pedro!
Playing a Pedro Animation, after the animation finishes, let's show the analog clock from the garmin example.
I looked into the AnimationLayer and found a great example on https://github.com/sunpazed/garmin-hedgetime that gave me the first ideas how I want to accomplish it. For quicker success, I used the analog clock from the garmin sdk as my watch face.

## Version 2: Playing with layers and learning about memory limitations the hard way.
We need a watch face during the animation ;-) Using the watch face was fun, but I actually wanted to see the time when looking at my watch, so I started looking into possible solutions. Unfortuntaly it's not possible to draw on the AnimationLayer, but it's possible to add 
another layer. I still used the approach of the analog watch face example here, that only adds one layer and does some clippings for the partial updates (for the seconds pointer). I also learned about bitmaps, colors and other things that are quite confusing at the beginning.

## Version 3: Digital Clock and more layers ;-)
Well, if we have a analog watch face, we need a digital one too. I still was playing around with the memory limiations and layers,
and finally came up with a new idea:
* I got three layers now: AnimationLayer, Full Screen Layer, Layer for seconds.
3 fullscreen layers would mean a lot of memory consumption though, therefore I took it a step further:
* On low memory devices I only show either the animation layer or the others.
* For the "seconds layer", I reduced the amount of colors and also the size of the layer (not fullscreen) and reposition it every 15 seconds (for the ananlog clock). So between second 0 and 15, it's on the top right corner, then it moves to the right bottom corner, and so on... so I need less memory and just move the layer to the position where it is required to draw something. For the digital clock
it's even easier, because it stays at the same place all the time. But also only uses that much space to show the seconds and not more.
I also started to clean up the code, I didn't want to have any special logic for the analog or digital clock outside of it's implementation classes. Therefore I let the implementation now create the seconds view layer (so we can configure the size and color depht etc inside of it), and also added another method called "secondsUpdate" that is basically the "onPartialUpdate" from the main.

## Version 4
If I want to use this watch face longer than just for fun, I need some sensor values. I hardcoded some values already in version 3,
but now it's time for customization and settings. I introduced a settings menu, allows customization of colors and data fields.
Besides that I added some more error handlings and refactored the settings menus to not have as many constants as possible for a cleaner code :). I also introduced "Datafields"-class, which also is now able to draw the choosen sensor values, this class can be used within the digital and analog clock and therefore I didn't need to implement it twice in each watch face.

