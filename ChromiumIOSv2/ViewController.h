//
//  ViewController.h
//  ChromiumIOSv2
//
//  Main view controller for iOS 14+ compatible WebKit-based browser
//

#import <UIKit/UIKit.h>
#import "BrowserViewController.h"

@interface ViewController : UIViewController

@property (nonatomic, strong) BrowserViewController *browserViewController;

@end