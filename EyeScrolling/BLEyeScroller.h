//
//  ESVEyeScroller.h
//  EyeScrollView
//
//  Created by Benjamin Loulier on 5/14/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#define ESDispatchQueueRelease(q) (dispatch_release(q))

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
#define ESDispatchQueueRelease(q)
#endif

#import <Foundation/Foundation.h>

@class BLEyeScroller;

@protocol BLEyeScrollerDelegate <NSObject>

//All the delegate calls will be performed in the main thread
@optional
- (void)eyeScroller:(BLEyeScroller *)eyeScroller didCalibrateForNeutralRelativeVerticalEyePosition:(float)neutralPosition;
- (void)eyeScroller:(BLEyeScroller *)eyeScroller didGetNewRelativeVerticalEyePosition:(float)eyePosition;


@end

@interface BLEyeScroller : NSObject

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign, readonly) BOOL isRunning;
/**The maximum speed in pt/s the scrollview can attain, the speed values are interpolated between
 0 and max speed depending on the position of the eye.*/
@property (nonatomic, assign) CGFloat maxSpeed;
@property (nonatomic, assign) CGFloat deadZoneRelativeExtent;
@property (nonatomic, assign) CGFloat accelerationZoneRelativeExtent;
/**Speed in pt/sec*/
@property (nonatomic, assign, readonly) float currentSpeed;

- (void)startRunning;
- (void)stopRunning;
- (void)attachScrollView:(UIScrollView *)scrollView;
- (void)detachScrollView;
- (void)calibrateNeutralRelativeVerticalEyePosition;

@end
