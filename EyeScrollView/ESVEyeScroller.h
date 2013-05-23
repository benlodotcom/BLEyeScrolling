//
//  ESVEyeScroller.h
//  EyeScrollView
//
//  Created by Benjamin Loulier on 5/14/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESVEyeScroller : NSObject

- (void)startEyeDetection;
- (void)stopEyeDetection;

/**The maximum speed in pt/s the scrollview can attain, the speed values are interpolated between
 0 and max speed depending on the position of the eye.*/
@property (nonatomic, assign) float maxSpeed;
/**Speed in pt/sec*/
@property (nonatomic, assign, readonly) float currentSpeed;
/**The scrollView scrolled by the EyeScroller*/
@property (nonatomic, weak) UIScrollView *scrollView;

@end
