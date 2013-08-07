//
//  ESVEyePositionIndicatorView.h
//  EyeScrollView
//
//  Created by Benjamin Loulier on 5/28/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EyePositionIndicatorView : UIView

@property (nonatomic, assign) CGFloat relativeEyePosition;
@property (nonatomic, assign) CGFloat neutralVerticalEyePosition;
@property (nonatomic, assign) CGFloat deadZoneRelativeExtent;
@property (nonatomic, assign) CGFloat accelerationZoneRelativeExtent;

- (void)reset;

@end
