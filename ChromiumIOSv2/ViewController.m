//
//  ViewController.m
//  ChromiumIOSv2
//
//  Main view controller for iOS 26 compatible Chromium browser
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize browser view controller
    self.browserViewController = [[BrowserViewController alloc] init];
    
    // Add as child view controller
    [self addChildViewController:self.browserViewController];
    [self.view addSubview:self.browserViewController.view];
    [self.browserViewController didMoveToParentViewController:self];
    
    // Setup constraints
    self.browserViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [self.browserViewController.view.topAnchor constraintEqualToAnchor:self.view.topAnchor],
        [self.browserViewController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.browserViewController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.browserViewController.view.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (void)dealloc {
    // Clean up to prevent crashes
    if (self.browserViewController) {
        [self.browserViewController willMoveToParentViewController:nil];
        [self.browserViewController.view removeFromSuperview];
        [self.browserViewController removeFromParentViewController];
    }
}

@end