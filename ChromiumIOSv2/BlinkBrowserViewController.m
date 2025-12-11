//
//  BlinkBrowserViewController.m
//  ChromiumIOSv2
//
//  Main browser view controller using Blink rendering engine
//  NOTE: This is a conceptual implementation. iOS does not support alternative browser engines.
//

#import "BlinkBrowserViewController.h"
#import "BlinkEngine.h"
#import "BlinkContentClient.h"

@interface BlinkBrowserViewController ()

@property (nonatomic, strong) NSURLRequest *currentRequest;
@property (nonatomic, assign) BOOL isLoading;

@end

@implementation BlinkBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBlinkEngine];
    [self setupUI];
    [self setupConstraints];
    [self loadDefaultPage];
}

- (void)dealloc {
    // Clean up to prevent crashes
    if (self.blinkWebView) {
        self.blinkWebView.navigationDelegate = nil;
        [self.blinkWebView stopLoading];
    }
    
    self.addressBarController.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupBlinkEngine {
    // Initialize Blink engine and content client
    [[BlinkEngine sharedInstance] initializeEngine];
    [[BlinkContentClient sharedInstance] initialize];
    
    NSLog(@"[BlinkBrowserViewController] Blink engine initialized");
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
    
    // Setup Blink Web View
    @try {
        self.blinkWebView = [[BlinkWebView alloc] initWithFrame:CGRectZero];
        self.blinkWebView.translatesAutoresizingMaskIntoConstraints = NO;
        self.blinkWebView.navigationDelegate = self;
        
        [self.view addSubview:self.blinkWebView];
        
        NSLog(@"[BlinkBrowserViewController] BlinkWebView created successfully");
    } @catch (NSException *exception) {
        NSLog(@"Error creating BlinkWebView: %@", exception.reason);
        [self showBlinkViewError];
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
    
    if (self.blinkWebView) {
        [NSLayoutConstraint activateConstraints:@[
            // Blink Web View
            [self.blinkWebView.topAnchor constraintEqualToAnchor:self.progressView.bottomAnchor],
            [self.blinkWebView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
            [self.blinkWebView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
            [self.blinkWebView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
        ]];
    }
}

- (void)loadDefaultPage {
    NSURL *defaultURL = [NSURL URLWithString:@"https://www.google.com"];
    [self loadURL:defaultURL];
}

- (void)showBlinkViewError {
    UILabel *errorLabel = [[UILabel alloc] init];
    errorLabel.text = @"Error initializing Blink rendering engine. Please restart the app.";
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
    if (!url || !self.blinkWebView) {
        return;
    }
    
    // Thread-safe URL loading
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURLRequest *request = [NSURLRequest requestWithURL:url 
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy 
                                             timeoutInterval:30.0];
        self.currentRequest = request;
        [self.blinkWebView loadURL:url];
        
        // Update address bar
        [self.addressBarController updateURLDisplay:url.absoluteString];
    });
}

- (void)goBack {
    if (self.blinkWebView && self.blinkWebView.canGoBack) {
        [self.blinkWebView goBack];
    }
}

- (void)goForward {
    if (self.blinkWebView && self.blinkWebView.canGoForward) {
        [self.blinkWebView goForward];
    }
}

- (void)reload {
    if (self.blinkWebView) {
        [self.blinkWebView reload];
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

#pragma mark - BlinkWebViewNavigationDelegate

- (void)blinkWebView:(BlinkWebView *)webView didStartLoadingURL:(NSURL *)url {
    self.isLoading = YES;
    [self.addressBarController setLoadingState:YES];
    NSLog(@"[BlinkBrowserViewController] Started loading: %@", url.absoluteString);
}

- (void)blinkWebView:(BlinkWebView *)webView didFinishLoadingURL:(NSURL *)url {
    self.isLoading = NO;
    [self.addressBarController setLoadingState:NO];
    
    // Update current request
    if (url) {
        self.currentRequest = [NSURLRequest requestWithURL:url];
        [self.addressBarController updateURLDisplay:url.absoluteString];
    }
    
    NSLog(@"[BlinkBrowserViewController] Finished loading: %@", url.absoluteString);
}

- (void)blinkWebView:(BlinkWebView *)webView didFailToLoadURL:(NSURL *)url withError:(NSError *)error {
    self.isLoading = NO;
    [self.addressBarController setLoadingState:NO];
    
    NSLog(@"[BlinkBrowserViewController] Failed to load: %@, error: %@", url.absoluteString, error.localizedDescription);
    
    // Don't show error for cancelled requests
    if (error.code != NSURLErrorCancelled) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showNavigationError:error];
        });
    }
}

- (void)blinkWebView:(BlinkWebView *)webView didUpdateProgress:(double)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressView setProgress:progress animated:YES];
        
        if (progress >= 1.0) {
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

- (void)showNavigationError:(NSError *)error {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Navigation Error"
                                                                   message:error.localizedDescription
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

@end
