//
//  BrowserViewController.h
//  ChromiumIOSv2
//
//  Main browser view controller with Chromium integration and iOS 26 compatibility
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "AddressBarController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BrowserViewController : UIViewController <AddressBarControllerDelegate, WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) AddressBarController *addressBarController;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

- (void)loadURL:(NSURL *)url;
- (void)goBack;
- (void)goForward;
- (void)reload;

@end

NS_ASSUME_NONNULL_END