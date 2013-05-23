//
//  ESVEyeScroller.m
//  EyeScrollView
//
//  Created by Benjamin Loulier on 5/14/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import "ESVEyeScroller.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

@interface ESVEyeScroller() <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) CIDetector *faceDetector;

@property (nonatomic, assign) BOOL shouldCalibrate;
/** Vertical ratio for which the speed is zero */
@property (nonatomic, assign) float neutralRelativeVerticalEyePosition;

/**The scrollView scrolled by the EyeScroller*/
@property (nonatomic, weak) UIScrollView *scrollView;
/** Display link to scroll the scrollview */
@property (nonatomic, strong) CADisplayLink *scrollDisplayLink;

/** Speed in pt/sec */
@property (nonatomic, assign, readwrite) float currentSpeed;
@property (nonatomic, assign) float verticalOffset;
@property (nonatomic, assign) CFTimeInterval lastUpdateTimestamp;

- (void)setupFaceDetector;
- (CIFaceFeature *)detectFirstFaceFeatureInImage:(CIImage *)image;
- (void)teardownCapture;
- (void)setupCapture;
- (float)computeRelativeVerticalEyePositionForFaceFeature:(CIFaceFeature *)feature inImage:(CIImage *)image;
- (float)computeSpeedForRelativeVerticalEyePosition:(float)position;

@end

@implementation ESVEyeScroller

#pragma mark - Initialization/Teardown

- (id)init {
    self = [super init];
    if (self) {
        self.maxSpeed = 100.0;
        self.neutralRelativeVerticalEyePosition = 0.7;
    }
    return self;
}

- (void)dealloc {
    [self stopEyeDetection];
}

#pragma mark - Start/Stop detection
- (void)startEyeDetection {
    [self setupCapture];
    [self setupFaceDetector];
}

- (void)stopEyeDetection {
    [self teardownCapture];
}
#pragma mark - Video capture

- (void)setupCapture {
    AVCaptureDevice *device;
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == AVCaptureDevicePositionFront) {
			device = d;
			break;
		}
	}

	AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput
										  deviceInputWithDevice:device
										  error:nil];
    
	AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
	captureOutput.alwaysDiscardsLateVideoFrames = YES;
	dispatch_queue_t queue;
	queue = dispatch_queue_create("cameraQueue", NULL);
	[captureOutput setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
    
	NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
	NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
	NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
	[captureOutput setVideoSettings:videoSettings];
    
	self.captureSession = [[AVCaptureSession alloc] init];
	[self.captureSession addInput:captureInput];
	[self.captureSession addOutput:captureOutput];
    [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
	[self.captureSession startRunning];
	
}

- (void)teardownCapture {
    [self.captureSession stopRunning];
    self.captureSession = nil;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    // make a CIImage from the pixel buffer
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *image = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer
                                                    options:(__bridge NSDictionary *)attachments];
    if (attachments) {
		CFRelease(attachments);
    }
    
    [self eyeScrollFromImage:image];
}

#pragma mark - Face detection

- (void)setupFaceDetector {
	self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
}

- (CIFaceFeature *)detectFirstFaceFeatureInImage:(CIImage *)image {
    
    NSArray *features = [self.faceDetector featuresInImage:image options:@{CIDetectorImageOrientation: @6}];
    
    return features.count ? features[0] : nil;
}

#pragma mark - Eye Scroll
- (void)attachScrollView:(UIScrollView *)scrollView {
    self.scrollView = scrollView;
    self.scrollDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateScrollPosition:)];
    [self.scrollDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self resetScrollParameters];
}

- (void)detachScrollView {
    self.scrollView = nil;
    [self.scrollDisplayLink invalidate];
    self.scrollDisplayLink = nil;
}

- (void)resetScrollParameters {
    self.verticalOffset = self.scrollView.contentOffset.y;
    self.currentSpeed = 0;
}

- (void)eyeScrollFromImage:(CIImage *)image {
    
    //Get the first face feature
    CIFaceFeature *feature = [self detectFirstFaceFeatureInImage:image];

    //If a face and one of the eye position is detected
    if  (feature && (feature.hasLeftEyePosition || feature.hasRightEyePosition)) {
        float relativeVerticalEyePosition = [self computeRelativeVerticalEyePositionForFaceFeature:feature inImage:image];
        
        if ([self.delegate respondsToSelector:@selector(esvEyeScroller:didGetNewRelativeVerticalEyePosition:)]) {
            [self.delegate esvEyeScroller:self didGetNewRelativeVerticalEyePosition:relativeVerticalEyePosition];
        }
        
        //Neutral vertical position calibration
        if (self.shouldCalibrate) {
            self.neutralRelativeVerticalEyePosition = relativeVerticalEyePosition;
            self.shouldCalibrate = NO;
            if ([self.delegate respondsToSelector:@selector(esvEyeScroller:didCalibrateForNeutralVerticalEyePosition:)]) {
                [self.delegate esvEyeScroller:self didCalibrateForNeutralVerticalEyePosition:self.neutralRelativeVerticalEyePosition];
            }
        }
        
        if (self.scrollView) {
            self.currentSpeed = [self computeSpeedForRelativeVerticalEyePosition:relativeVerticalEyePosition];
        }
    }
    else {
        [self resetScrollParameters];
    }

}

- (void)updateScrollPosition:(CADisplayLink *)sender {
    if (self.lastUpdateTimestamp == 0) {
        self.lastUpdateTimestamp = sender.timestamp;
        return;
    }
    
    double deltaTimeInterval = sender.timestamp - self.lastUpdateTimestamp;
    self.lastUpdateTimestamp = sender.timestamp;
    
    //Don't increment directly the offset of the scrollview as it is truncated, as most of the time we increment the offset by less than 0.5, the scrollview wouldn't move if we didn't track ou own "version" of the offset.
    self.verticalOffset = [self computeVerticalOffsetWithInitialOffset:self.verticalOffset speed:self.currentSpeed andTimeInterval:deltaTimeInterval];
    self.scrollView.contentOffset = CGPointMake(self.scrollView.contentOffset.x, self.verticalOffset);
}

- (void)calibrateNeutralVerticalEyePosition {
    self.shouldCalibrate = YES;
}

- (float)computeRelativeVerticalEyePositionForFaceFeature:(CIFaceFeature *)feature inImage:(CIImage *)image {
    CGPoint leftEyePosition = feature.hasLeftEyePosition ? feature.leftEyePosition : feature.rightEyePosition;
    CGPoint rightEyePosition = feature.hasRightEyePosition ? feature.rightEyePosition : feature.leftEyePosition;
        
    //Position of the middle point between the two eyes
    CGPoint averagePosition = CGPointMake(leftEyePosition.x+(rightEyePosition.x-leftEyePosition.x)/2.0, leftEyePosition.x+(rightEyePosition.y-leftEyePosition.y)/2.0);
        
    return (averagePosition.y / image.extent.size.height);
}

- (float)computeSpeedForRelativeVerticalEyePosition:(float)position {
    return (position - self.neutralRelativeVerticalEyePosition) * self.maxSpeed;
}

- (float)computeVerticalOffsetWithInitialOffset:(float)initialOffset speed:(float)speed andTimeInterval:(CFTimeInterval)timeInterval {
    float newOffset = initialOffset + speed*timeInterval;
    
    //Block the scroll when we reach the bounds of the scrollview
    CGFloat minBound = 0;
    CGFloat maxBound = self.scrollView.contentSize.height - self.scrollView.frame.size.height + self.scrollView.contentInset.top + self.scrollView.contentInset.bottom;
    if (newOffset < minBound) {
        newOffset = minBound;
    }
    else if (newOffset > maxBound) {
        newOffset = maxBound;
    }
    
    return newOffset;
}

@end
