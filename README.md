# BLEyeScrolling

A library to implement eye scrolling capabilities (Galaxy S4 like) on iOS (iPads and iPhones). Under the hood this library makes use of the CoreImage face features detection to track the position of one's eyes and scroll accordingly.

**Note**: Core image face features detection only works when the whole face is visible by the camera, therefore using eye scrolling is only practical in portrait up orientation.

## Installation

_**Important note if your project doesn't use ARC**: you must add the `-fobjc-arc` compiler flag to `BLEyeScroller.m` in Target Settings > Build Phases > Compile Sources._

- Copy the BLEyeScroller folder into your project.
- Add a bunch of frameworks, namely: **CoreMedia**, **CoreVideo**, **CoreImage**, **QuartzCore**, **AVFoundation** .
- Import `BLEyeScroller.h`

## Usage

See sample Xcode project for an example of eye scrolling implementation

### Initialize the eye scroller

``` objective-c
self.eyeScroller = [[BLEyeScroller alloc] init];
//Set the maximum speed in pt/s 
self.eyeScroller.maxSpeed = 800.0;
//The relative extent of the zone around the neutral position in which the speed is forced to zero
self.eyeScroller.deadZoneRelativeExtent = 0.02;
//The relative extent of the zone around the neutral position in which the scroll speed accelerate.
//Outside of this zone the scrolling happens at max speed.
self.eyeScroller.accelerationZoneRelativeExtent = 0.05;
```

### Start/Stop the eye scroller

``` objective-c
[self.eyeScroller startRunning];
self.eyeScroller.isRunning; //is YES
[self.eyeScroller stopRunning];
self.eyeScroller.isRunning; //is NO
```

### Calibrate the eye scroller

To determine if it has to scroll up or down the eye scroller has to know which eye position is neutral. By calling the calibrate method, the eye scroller will register the current eye position as neutral.

``` objective-c
[self.eyeScroller calibrateNeutralRelativeVerticalEyePosition];
```

### Attach/Detach a scroll view to/from the eye scroller

When you attach a scrollview to the eye scroller, it will start scrolling according to the position of your eyes.

``` objective-c
[self.eyeScroller attachScrollView:self.myScrollView];
[self.eyeScroller detachScrollView];
```

### Use the delegate methods

The eye scroller informs its delegate when it has finished calibrating and when it has computed a new relative eye position. In the sample project it is used to update the eye position indicator.

``` objective-c
self.eyeScroller.delegate = self;
```

`BLEyeScrollerDelegate` defines optional methods your delegate can implement, all the delegate calls are performed on the **main thread**.

``` objective-c
@protocol BLEyeScrollerDelegate <NSObject>

@optional
- (void)eyeScroller:(BLEyeScroller *)eyeScroller didCalibrateForNeutralRelativeVerticalEyePosition:(float)neutralPosition;
- (void)eyeScroller:(BLEyeScroller *)eyeScroller didGetNewRelativeVerticalEyePosition:(float)eyePosition;

@end
```

### Allow manual scrolling along with eye scrolling

Add the following code in your UIScrollView delegate methods.

``` objective-c
//Deactivate the eye scrolling when the user scrolls manually.
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.eyeScroller.isRunning) {
        [self.eyeScroller detachScrollView];
    }
}

//Reatach the scrollview when the scroll view finishes decelerating
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.eyeScroller.isRunning) {
        [self.eyeScroller attachScrollView:self.webview.scrollView];
    }
}
```

## Under the hood

The eye scroller starts an AVCaptureSession and for every frame :

- Detect the position of the eyes using a `CIDetector`
- Compute the relative position of the eyes in the frame (eg: if the eyes are centered in the frame, the relative position is 0.5).
-  Derives the speed from the relative distance between the neutral position and the eye position.
	
When a scrollview is attached to the eye scroller a `CADisplayLink` calls regularly (at the screen refresh rate) a method that modifies the offset of the scrollview according to the current speed.

**Note** As `UIKit` rounds up the offset value we pass to the scrollview (for drawing performance reason), we have to keep track of a "precise" offset.

## Contribute
When there is a change you'd like to make:

- Fork the repository
- [Send a pull request](https://github.com/benlodotcom/BLEyeScrolling/pulls)
- I'll happily merge it in the master !

## Contact

Benjamin Loulier

- http://twitter.com/benlodotcom
- http://github.com/benlodotcom

## License

BLEyeScrolling is available under the MIT license. See the LICENSE file for more info.


