//
//  ESVEyePositionIndicatorView.m
//  EyeScrollView
//
//  Created by Benjamin Loulier on 5/28/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import "EyePositionIndicatorView.h"

@interface EyePositionIndicatorView()

@property (nonatomic, strong) NSArray *propertiesToObserve;

@end

@implementation EyePositionIndicatorView

#pragma mark - Initialization/Teardown
- (void)awakeFromNib {
    [super awakeFromNib];
    self.propertiesToObserve = @[@"relativeEyePosition", @"neutralVerticalEyePosition", @"deadZoneRelativeExtent", @"accelerationZoneRelativeExtent"];
    [self.propertiesToObserve enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addObserver:self forKeyPath:(NSString *)obj options:NSKeyValueObservingOptionNew context:NULL];
    }];
}

- (void)dealloc {
    [self.propertiesToObserve enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self removeObserver:self forKeyPath:(NSString *)obj];
    }];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    [self setNeedsDisplay];
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect {    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    if (self.neutralVerticalEyePosition != 0) {
        [self drawAccelerationZoneInContext:currentContext withDrawingrect:rect];
        [self drawDeadZoneInContext:currentContext withDrawingRect:rect];
        [self drawNeutralVerticalEyePositionInContext:currentContext withDrawingRect:rect];
    }
    if (self.relativeEyePosition != 0) [self drawEyePositionInContext:currentContext withDrawingRect:rect];
    
}

- (void)drawEyePositionInContext:(CGContextRef)context withDrawingRect:(CGRect)rect {

    static float eyeCircleRadius = 6.0f;
    
    CGContextSaveGState(context);
    
    [[UIColor redColor] setFill];
    
    CGContextFillEllipseInRect(context, CGRectMake(rect.size.width/2.0 - eyeCircleRadius, self.relativeEyePosition * rect.size.height - eyeCircleRadius, eyeCircleRadius*2.0, eyeCircleRadius*2.0));
    
    CGContextRestoreGState(context);
}

- (void)drawNeutralVerticalEyePositionInContext:(CGContextRef)context withDrawingRect:(CGRect)rect {

    static float neutralPositionLineHeight = 2.0f;
    
    CGContextSaveGState(context);
    
    [[UIColor blueColor] setFill];
    
    CGContextFillRect(context, CGRectMake(0, self.neutralVerticalEyePosition * rect.size.height - neutralPositionLineHeight/2.0, rect.size.width, neutralPositionLineHeight));
    
    CGContextRestoreGState(context);
    
}

- (void)drawDeadZoneInContext:(CGContextRef)context withDrawingRect:(CGRect)rect {
    
    CGContextSaveGState(context);
    
    [[UIColor blackColor] setFill];
    CGContextFillRect(context, CGRectMake(0, - self.deadZoneRelativeExtent * rect.size.height + self.neutralVerticalEyePosition * rect.size.height, rect.size.width , 2.0 * self.deadZoneRelativeExtent * rect.size.height));
    
    CGContextRestoreGState(context);

}

- (void)drawAccelerationZoneInContext:(CGContextRef)context withDrawingrect:(CGRect)rect {
    
    CGContextSaveGState(context);
    
    [[UIColor darkGrayColor] setFill];
    CGContextFillRect(context, CGRectMake(0, - self.accelerationZoneRelativeExtent * rect.size.height + self.neutralVerticalEyePosition * rect.size.height, rect.size.width , 2.0 * self.accelerationZoneRelativeExtent * rect.size.height));
    
    CGContextRestoreGState(context);
}

#pragma mark - Reset

- (void)reset {
    _relativeEyePosition = 0;
    [self setNeedsDisplay];
}

@end
