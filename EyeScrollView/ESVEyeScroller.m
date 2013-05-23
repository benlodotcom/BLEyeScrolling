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

/** Speed in pt/sec */
@property (nonatomic, assign, readwrite) float currentSpeed;
/** Vertical ratio for which the speed is zero */
@property (nonatomic, assign) float neutralRelativeVerticalEyePosition;

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
        self.maxSpeed = 50.0;
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
- (void)eyeScrollFromImage:(CIImage *)image {
    
    //Get the first face feature
    CIFaceFeature *feature = [self detectFirstFaceFeatureInImage:image];

    if  (feature && (feature.hasLeftEyePosition || feature.hasRightEyePosition)) {
        float relativeVerticalEyePosition = [self computeRelativeVerticalEyePositionForFaceFeature:feature inImage:image];
        self.currentSpeed = [self computeSpeedForRelativeVerticalEyePosition:relativeVerticalEyePosition];
        NSLog(@"%f %f", relativeVerticalEyePosition, self.currentSpeed);
    }

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

@end
