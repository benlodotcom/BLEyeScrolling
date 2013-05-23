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

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) ESVEyeScroller *eyeScroller;
@end

@implementation ESVViewController

#pragma mark - Initialization/Teardown
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self setupEyeScroller];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, 1.5*self.scrollView.bounds.size.height);
    [self.eyeScroller attachScrollView:self.scrollView];
}
                        
#pragma mark - EyeScroller management
- (void)setupEyeScroller {
    self.eyeScroller = [[ESVEyeScroller alloc] init];
    [self.eyeScroller startEyeDetection];
}

- (void)viewDidUnload {
    [self setScrollView:nil];
    [super viewDidUnload];
}
@end
