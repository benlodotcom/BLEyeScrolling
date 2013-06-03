//
//  ESVEyePositionIndicatorView.m
//  EyeScrollView
//
//  Created by Benjamin Loulier on 5/28/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import "ESVEyePositionIndicatorView.h"

@implementation ESVEyePositionIndicatorView

#pragma mark - Custom setters
- (void)setRelativeEyePosition:(float)relativeEyePosition {
    _relativeEyePosition = relativeEyePosition;
    [self setNeedsDisplay];
}

- (void)setNeutralVerticalEyePosition:(float)neutralVerticalEyePosition {
    _neutralVerticalEyePosition = neutralVerticalEyePosition;
    [self setNeedsDisplay];
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect {    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    [self drawEyePositionInContext:currentContext withDrawingRect:rect];
    [self drawNeutralVerticalEyePositionInContext:currentContext withDrawingRect:rect];
    
}

- (void)drawEyePositionInContext:(CGContextRef)context withDrawingRect:(CGRect)rect {
    
    if (self.relativeEyePosition == 0) {
        return;
    }
    
    static float eyeCircleRadius = 6.0f;
    
    CGContextSaveGState(context);
    
    [[UIColor greenColor] setFill];
    
    CGContextFillEllipseInRect(context, CGRectMake(rect.size.width/2.0 - eyeCircleRadius, self.relativeEyePosition * rect.size.height - eyeCircleRadius, eyeCircleRadius*2.0, eyeCircleRadius*2.0));
    
    CGContextRestoreGState(context);
}

- (void)drawNeutralVerticalEyePositionInContext:(CGContextRef)context withDrawingRect:(CGRect)rect {
    
    if (self.neutralVerticalEyePosition == 0) {
        return;
    }
    
    static float neutralPositionLineHeight = 2.0f;
    
    CGContextSaveGState(context);
    
    [[UIColor blueColor] setFill];
    
    CGContextFillRect(context, CGRectMake(0, self.neutralVerticalEyePosition * rect.size.height - neutralPositionLineHeight/2.0, rect.size.width, neutralPositionLineHeight));
    
    CGContextRestoreGState(context);
    
}

#pragma mark - Reset

- (void)reset {
    _relativeEyePosition = 0;
    [self setNeedsDisplay];
}

@end
