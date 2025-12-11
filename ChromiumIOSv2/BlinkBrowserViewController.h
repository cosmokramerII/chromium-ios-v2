//
//  BlinkBrowserViewController.h
//  ChromiumIOSv2
//
//  Main browser view controller using Blink rendering engine
//  NOTE: This is a conceptual implementation. iOS does not support alternative browser engines.
//

#import <UIKit/UIKit.h>
#import "AddressBarController.h"
#import "BlinkWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlinkBrowserViewController : UIViewController <AddressBarControllerDelegate, BlinkWebViewNavigationDelegate>

@property (nonatomic, strong) AddressBarController *addressBarController;
@property (nonatomic, strong) BlinkWebView *blinkWebView;
@property (nonatomic, strong) UIProgressView *progressView;

- (void)loadURL:(NSURL *)url;
- (void)goBack;
- (void)goForward;
- (void)reload;

@end

NS_ASSUME_NONNULL_END
