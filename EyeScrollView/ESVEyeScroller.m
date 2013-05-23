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

- (void)setupFaceDetector;
- (CIFaceFeature *)detectFirstFaceFeatureInImage:(CIImage *)image;
- (void)teardownCapture;
- (void)setupCapture;

@end

@implementation ESVEyeScroller

#pragma mark - Initialization/Teardwon

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
    
    [self detectFirstFaceFeatureInImage:image];
}

#pragma mark - Face detection

- (CIFaceFeature *)detectFirstFaceFeatureInImage:(CIImage *)image {
    
    NSArray *features = [self.faceDetector featuresInImage:image options:@{CIDetectorImageOrientation: @6}];
    
    NSLog(@"%d", features.count);
    
    return features.count ? features[0] : nil;
}

- (void)setupFaceDetector {
	self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];
}

@end
