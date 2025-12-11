//
//  ViewController.h
//  ChromiumIOSv2
//
//  Main view controller for iOS 14+ compatible Chromium browser with Blink rendering engine
//  NOTE: This is a conceptual implementation. iOS does not support alternative browser engines.
//

#import <UIKit/UIKit.h>
#import "BlinkBrowserViewController.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) BlinkBrowserViewController *browserViewController;

@end