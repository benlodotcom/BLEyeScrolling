//
//  ESVEyeScroller.h
//  EyeScrollView
//
//  Created by Benjamin Loulier on 5/14/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ESEyeScroller;

@protocol ESEyeScrollerDelegate <NSObject>

//All the delegate calls will be performed in the main thread
@optional
- (void)eyeScroller:(ESEyeScroller *)eyeScroller didCalibrateForNeutralVerticalEyePosition:(float)neutralPosition;
- (void)eyeScroller:(ESEyeScroller *)eyeScroller didGetNewRelativeVerticalEyePosition:(float)eyePosition;


@end

@interface ESEyeScroller : NSObject

@property (nonatomic, weak) id delegate;

@property (nonatomic, assign, readonly) BOOL isRunning;
/**The maximum speed in pt/s the scrollview can attain, the speed values are interpolated between
 0 and max speed depending on the position of the eye.*/
@property (nonatomic, assign) float maxSpeed;
/**Speed in pt/sec*/
@property (nonatomic, assign, readonly) float currentSpeed;

- (void)startRunning;
- (void)stopRunning;
- (void)attachScrollView:(UIScrollView *)scrollView;
- (void)detachScrollView;
- (void)calibrateNeutralVerticalEyePosition;

@end
