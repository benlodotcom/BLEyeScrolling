//
//  ESVEyePositionIndicatorView.h
//  EyeScrollView
//
//  Created by Benjamin Loulier on 5/28/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESVEyePositionIndicatorView : UIView

@property (nonatomic, assign) float relativeEyePosition;
@property (nonatomic, assign) float neutralVerticalEyePosition;

- (void)reset;

@end
