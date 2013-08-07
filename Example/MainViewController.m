//
//  ESVViewController.m
//  EyeScrollView
//
//  Created by Benjamin Loulier on 5/14/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import "MainViewController.h"
#import "BLEyeScroller.h"
#import "EyePositionIndicatorView.h"

@interface MainViewController () <BLEyeScrollerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webview;
@property (nonatomic, strong) BLEyeScroller *eyeScroller;
@property (weak, nonatomic) IBOutlet EyePositionIndicatorView *eyePositionIndicator;

- (IBAction)calibrate:(id)sender;
- (IBAction)startStopRunning:(id)sender;

@end

@implementation MainViewController

#pragma mark - Initialization/Teardown
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupEyeScroller];
    [self loadWebviewContent];
    self.webview.scrollView.delegate = self;
    //Attach a scrollview (the webview's scrollview in this case) to the EyeScroller
}

- (void)loadWebviewContent {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"iPhoneAppProgrammingGuide" ofType:@"pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.webview loadRequest:request];
}

- (void)viewDidUnload {
    [self setWebview:nil];
    [self setEyePositionIndicator:nil];
    [super viewDidUnload];
}

#pragma mark - EyeScroller management
- (void)setupEyeScroller {
    
    static CGFloat maxSpeed = 100.0;
    static CGFloat deadZoneRelativeExtent = 0.02;
    static CGFloat accelerationZoneRelativeExtent = 0.05;
    
    self.eyeScroller = [[BLEyeScroller alloc] init];
    self.eyeScroller.maxSpeed = maxSpeed;
    self.eyeScroller.deadZoneRelativeExtent = deadZoneRelativeExtent;
    self.eyeScroller.accelerationZoneRelativeExtent = accelerationZoneRelativeExtent;
    self.eyeScroller.delegate = self;
    
    self.eyePositionIndicator.deadZoneRelativeExtent = 0.02;
    self.eyePositionIndicator.accelerationZoneRelativeExtent = 0.05;
}

#pragma mark - ESVEyeScrollerDelegate
- (void)eyeScroller:(BLEyeScroller *)eyeScroller didGetNewRelativeVerticalEyePosition:(float)eyePosition {
    self.eyePositionIndicator.relativeEyePosition = eyePosition;
}

- (void)eyeScroller:(BLEyeScroller *)eyeScroller didCalibrateForNeutralRelativeVerticalEyePosition:(float)neutralPosition {
    self.eyePositionIndicator.neutralVerticalEyePosition = neutralPosition;
}

#pragma mark - Actions
- (IBAction)startStopRunning:(UIBarButtonItem *)sender {
    if (self.eyeScroller.isRunning) {
        [self.eyeScroller stopRunning];
        [self.eyePositionIndicator reset];
        sender.title = @"Start running";
    }
    else {
        [self.eyeScroller startRunning];
        [self.eyeScroller attachScrollView:self.webview.scrollView];
        sender.title = @"Stop running";
    }
}

- (IBAction)calibrate:(id)sender {
    [self.eyeScroller calibrateNeutralRelativeVerticalEyePosition];
}

#pragma mark - UIScrollView delegate

//Detactivate the eye scrolling when the user scrolls manually.
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.eyeScroller.isRunning) {
        [self.eyeScroller detachScrollView];
    }
}

//Reatach the scrollview when it finish decelerating
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.eyeScroller.isRunning) {
        [self.eyeScroller attachScrollView:self.webview.scrollView];
    }
}

#pragma mark - Autorotation
//Legacy code for iOS5
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return toInterfaceOrientation == UIInterfaceOrientationPortrait;
}

@end
