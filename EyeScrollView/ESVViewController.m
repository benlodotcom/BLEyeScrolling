//
//  ESVViewController.m
//  EyeScrollView
//
//  Created by Benjamin Loulier on 5/14/13.
//  Copyright (c) 2013 Benjamin Loulier. All rights reserved.
//

#import "ESVViewController.h"
#import "ESVEyeScroller.h"

@interface ESVViewController ()

@property (nonatomic, strong) ESVEyeScroller *eyeScroller;
@end

@implementation ESVViewController

#pragma mark - Initialization/Teardown
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupEyeScroller];
}

                        
#pragma mark - EyeScroller management
- (void)setupEyeScroller {
    self.eyeScroller = [[ESVEyeScroller alloc] init];
    [self.eyeScroller startEyeDetection];
}

@end
