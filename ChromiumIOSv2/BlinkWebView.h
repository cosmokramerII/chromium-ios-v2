//
//  BlinkWebView.h
//  ChromiumIOSv2
//
//  Native Blink rendering view wrapper for iOS
//  NOTE: This is a conceptual implementation. iOS does not support alternative browser engines.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BlinkWebView;

@protocol BlinkWebViewNavigationDelegate <NSObject>

@optional
- (void)blinkWebView:(BlinkWebView *)webView didStartLoadingURL:(NSURL *)url;
- (void)blinkWebView:(BlinkWebView *)webView didFinishLoadingURL:(NSURL *)url;
- (void)blinkWebView:(BlinkWebView *)webView didFailToLoadURL:(NSURL *)url withError:(NSError *)error;
- (void)blinkWebView:(BlinkWebView *)webView didUpdateProgress:(double)progress;

@end

@interface BlinkWebView : UIView

@property (nonatomic, weak, nullable) id<BlinkWebViewNavigationDelegate> navigationDelegate;
@property (nonatomic, readonly) NSURL *currentURL;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly) double estimatedProgress;

// Navigation
- (void)loadURL:(NSURL *)url;
- (void)loadHTMLString:(NSString *)htmlString baseURL:(nullable NSURL *)baseURL;
- (void)goBack;
- (void)goForward;
- (void)reload;
- (void)stopLoading;

// JavaScript execution
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(id _Nullable result, NSError * _Nullable error))completionHandler;

// Configuration
- (void)setAllowsBackForwardNavigationGestures:(BOOL)allows;
- (void)setUserAgent:(NSString *)userAgent;

@end

NS_ASSUME_NONNULL_END
