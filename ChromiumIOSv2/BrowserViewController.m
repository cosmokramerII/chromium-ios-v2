//
//  BrowserViewController.m
//  ChromiumIOSv2
//
//  Main browser view controller with WebKit integration and iOS 14+ compatibility
//

#import "BrowserViewController.h"

@interface BrowserViewController ()

@property (nonatomic, strong) WKWebViewConfiguration *webViewConfiguration;
@property (nonatomic, strong) NSURLRequest *currentRequest;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation BrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupWebViewConfiguration];
    [self setupUI];
    [self setupConstraints];
    [self loadDefaultPage];
}

- (void)dealloc {
    // Critical: Clean up to prevent crashes
    if (self.webView) {
        [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
        self.webView.navigationDelegate = nil;
        self.webView.UIDelegate = nil;
        [self.webView stopLoading];
    }
    
    self.addressBarController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupWebViewConfiguration {
    // Configure WebView for iOS 14+ compatibility
    // Note: iOS requires all browsers to use WebKit (WKWebView)
    self.webViewConfiguration = [[WKWebViewConfiguration alloc] init];
    
    // Enable JavaScript (required for modern web)
    self.webViewConfiguration.preferences.javaScriptEnabled = YES;
    
    // iOS 14+ compatible settings
    if (@available(iOS 14.0, *)) {
        self.webViewConfiguration.defaultWebpagePreferences.allowsContentJavaScript = YES;
    }
    
    // Configure user agent to identify as Chrome for site compatibility
    // Note: This is only a user agent string; the actual engine is WebKit (required by iOS)
    self.webViewConfiguration.applicationNameForUserAgent = @"ChromiumIOSv2/2.0 (iPhone; iOS 14.0) Chrome/91.0.4472.114 Mobile Safari/537.36";
    
    // Enable media playback
    self.webViewConfiguration.allowsInlineMediaPlayback = YES;
    self.webViewConfiguration.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    
    // Configure process pool for better performance
    self.webViewConfiguration.processPool = [[WKProcessPool alloc] init];
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor systemBackgroundColor];
    
    // Setup Address Bar Controller
    self.addressBarController = [[AddressBarController alloc] initWithFrame:CGRectZero];
    self.addressBarController.delegate = self;
    [self addChildViewController:self.addressBarController];
    [self.view addSubview:self.addressBarController.view];
    [self.addressBarController didMoveToParentViewController:self];
    
    // Setup Progress View
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.translatesAutoresizingMaskIntoConstraints = NO;
    self.progressView.progressTintColor = [UIColor systemBlueColor];
    self.progressView.alpha = 0.0;
    [self.view addSubview:self.progressView];
    
    // Setup WebView with crash prevention
    @try {
        self.webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:self.webViewConfiguration];
        self.webView.translatesAutoresizingMaskIntoConstraints = NO;
        self.webView.navigationDelegate = self;
        self.webView.UIDelegate = self;
        
        // Add KVO for progress tracking
        [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        
        [self.view addSubview:self.webView];
    } @catch (NSException *exception) {
        NSLog(@"Error creating WebView: %@", exception.reason);
        // Fallback handling
        [self showWebViewError];
    }
}

- (void)setupConstraints {
    self.addressBarController.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [NSLayoutConstraint activateConstraints:@[
        // Address Bar Controller
        [self.addressBarController.view.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.addressBarController.view.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.addressBarController.view.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.addressBarController.view.heightAnchor constraintEqualToConstant:60.0],
        
        // Progress View
        [self.progressView.topAnchor constraintEqualToAnchor:self.addressBarController.view.bottomAnchor],
        [self.progressView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.progressView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.progressView.heightAnchor constraintEqualToConstant:2.0]
    ]];
    
    if (self.webView) {
        [NSLayoutConstraint activateConstraints:@[
            // WebView
            [self.webView.topAnchor constraintEqualToAnchor:self.progressView.bottomAnchor],
            [self.webView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [self.webView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [self.webView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
        ]];
    }
}

- (void)loadDefaultPage {
    NSURL *defaultURL = [NSURL URLWithString:@"https://www.google.com"];
    [self loadURL:defaultURL];
}

- (void)showWebViewError {
    UILabel *errorLabel = [[UILabel alloc] init];
    errorLabel.text = @"Error initializing browser engine. Please restart the app.";
    errorLabel.textAlignment = NSTextAlignmentCenter;
    errorLabel.numberOfLines = 0;
    errorLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:errorLabel];
    
    [NSLayoutConstraint activateConstraints:@[
        [errorLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [errorLabel.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [errorLabel.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:20],
        [errorLabel.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-20]
    ]];
}

#pragma mark - Public Methods

- (void)loadURL:(NSURL *)url {
    if (!url || !self.webView) {
        return;
    }
    
    // Thread-safe URL loading
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:url 
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                             timeoutInterval:30.0];
        self.currentRequest = request;
        [self.webView loadRequest:request];
        
        // Update address bar
        [self.addressBarController updateURLDisplay:url.absoluteString];
    });
}

- (void)goBack {
    if (self.webView && [self.webView canGoBack]) {
        [self.webView goBack];
    }
}

- (void)goForward {
    if (self.webView && [self.webView canGoForward]) {
        [self.webView goForward];
    }
}

- (void)reload {
    if (self.webView) {
        if (self.currentRequest) {
            [self.webView loadRequest:self.currentRequest];
        } else {
            [self.webView reload];
        }
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            float progress = [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
            [self.progressView setProgress:progress animated:YES];
            
            if (progress == 1.0) {
                [UIView animateWithDuration:0.3 delay:0.3 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    self.progressView.alpha = 0.0;
                } completion:^(BOOL finished) {
                    [self.progressView setProgress:0.0 animated:NO];
                }];
            } else {
                self.progressView.alpha = 1.0;
            }
        });
    }
}

#pragma mark - AddressBarControllerDelegate

- (void)addressBarController:(AddressBarController *)controller didRequestNavigationToURL:(NSURL *)url {
    [self loadURL:url];
}

- (void)addressBarControllerDidRequestRefresh:(AddressBarController *)controller {
    [self reload];
}

- (void)addressBarControllerDidRequestGoBack:(AddressBarController *)controller {
    [self goBack];
}

- (void)addressBarControllerDidRequestGoForward:(AddressBarController *)controller {
    [self goForward];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.isLoading = YES;
    [self.addressBarController setLoadingState:YES];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    // Update address bar with current URL
    if (webView.URL) {
        [self.addressBarController updateURLDisplay:webView.URL.absoluteString];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.isLoading = NO;
    [self.addressBarController setLoadingState:NO];
    
    // Update current request for reload functionality
    if (webView.URL) {
        self.currentRequest = [NSURLRequest requestWithURL:webView.URL];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    self.isLoading = NO;
    [self.addressBarController setLoadingState:NO];
    
    // Handle navigation errors gracefully
    NSLog(@"Navigation failed: %@", error.localizedDescription);
    
    // Don't show error for cancelled requests
    if (error.code != NSURLErrorCancelled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showNavigationError:error];
        });
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self webView:webView didFailNavigation:navigation withError:error];
}

- (void)showNavigationError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Navigation Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - WKUIDelegate

- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    // Handle popup windows by loading in current web view
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler();
    }];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Confirm"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end