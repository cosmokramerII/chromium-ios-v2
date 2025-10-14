//
//  BrowserViewController_WebKit_Deprecated.h
//  ChromiumIOSv2
//
//  DEPRECATED: This file used WebKit and has been replaced by BlinkBrowserViewController
//  Kept for reference purposes only. Do not use in new code.
//
//  Main browser view controller with Chromium integration and iOS 14+ compatibility
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "AddressBarController.h"

NS_ASSUME_NONNULL_BEGIN

// DEPRECATED: Use BlinkBrowserViewController instead
__attribute__((deprecated("Use BlinkBrowserViewController instead")))
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