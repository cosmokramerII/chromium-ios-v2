//
//  AddressBarController.m
//  ChromiumIOSv2
//
//  Address bar controller with crash fixes and iOS 26 compatibility
//

#import "AddressBarController.h"

@interface AddressBarController ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableString *currentURL;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, strong) NSTimer *debounceTimer;

@end

@implementation AddressBarController

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        [self setupView];
        _currentURL = [[NSMutableString alloc] init];
        _isEditing = NO;
    }
    return self;
}

- (void)dealloc {
    // Critical: Prevent crash by invalidating timer and clearing delegates
    [self.debounceTimer invalidate];
    self.debounceTimer = nil;
    self.addressTextField.delegate = nil;
    self.delegate = nil;
    
    // Remove observers to prevent crashes
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
    [self setupConstraints];
    [self setupNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // Ensure we're on main thread for UI updates
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUIState];
    });
}

- (void)setupView {
    // Container view for all controls
    self.containerView = [[UIView alloc] init];
    self.containerView.backgroundColor = [UIColor systemBackgroundColor];
    self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.containerView];
    
    // Back button
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setTitle:@"◀" forState:UIControlStateNormal];
    self.backButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backButton addTarget:self action:@selector(backButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.backButton];
    
    // Forward button
    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setTitle:@"▶" forState:UIControlStateNormal];
    self.forwardButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.forwardButton addTarget:self action:@selector(forwardButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.forwardButton];
    
    // Refresh button
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.refreshButton setTitle:@"↻" forState:UIControlStateNormal];
    self.refreshButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.refreshButton addTarget:self action:@selector(refreshButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.refreshButton];
    
    // Address text field with proper crash prevention
    self.addressTextField = [[UITextField alloc] init];
    self.addressTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.addressTextField.placeholder = @"Enter URL";
    self.addressTextField.keyboardType = UIKeyboardTypeURL;
    self.addressTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.addressTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.addressTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.addressTextField.translatesAutoresizingMaskIntoConstraints = NO;
    self.addressTextField.delegate = self;
    
    // Add target for text changes with debouncing to prevent crashes
    [self.addressTextField addTarget:self action:@selector(textFieldDidChangeWithDebounce:) forControlEvents:UIControlEventEditingChanged];
    
    [self.containerView addSubview:self.addressTextField];
    
    // Go button
    self.goButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.goButton setTitle:@"Go" forState:UIControlStateNormal];
    self.goButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.goButton addTarget:self action:@selector(goButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.containerView addSubview:self.goButton];
}

- (void)setupConstraints {
    [NSLayoutConstraint activateConstraints:@[
        // Container view constraints
        [self.containerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.containerView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.containerView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.containerView.heightAnchor constraintEqualToConstant:60.0],
        
        // Back button
        [self.backButton.leadingAnchor constraintEqualToAnchor:self.containerView.leadingAnchor constant:8.0],
        [self.backButton.centerYAnchor constraintEqualToAnchor:self.containerView.centerYAnchor],
        [self.backButton.widthAnchor constraintEqualToConstant:40.0],
        [self.backButton.heightAnchor constraintEqualToConstant:40.0],
        
        // Forward button
        [self.forwardButton.leadingAnchor constraintEqualToAnchor:self.backButton.trailingAnchor constant:4.0],
        [self.forwardButton.centerYAnchor constraintEqualToAnchor:self.containerView.centerYAnchor],
        [self.forwardButton.widthAnchor constraintEqualToConstant:40.0],
        [self.forwardButton.heightAnchor constraintEqualToConstant:40.0],
        
        // Refresh button
        [self.refreshButton.leadingAnchor constraintEqualToAnchor:self.forwardButton.trailingAnchor constant:4.0],
        [self.refreshButton.centerYAnchor constraintEqualToAnchor:self.containerView.centerYAnchor],
        [self.refreshButton.widthAnchor constraintEqualToConstant:40.0],
        [self.refreshButton.heightAnchor constraintEqualToConstant:40.0],
        
        // Address text field
        [self.addressTextField.leadingAnchor constraintEqualToAnchor:self.refreshButton.trailingAnchor constant:8.0],
        [self.addressTextField.centerYAnchor constraintEqualToAnchor:self.containerView.centerYAnchor],
        [self.addressTextField.heightAnchor constraintEqualToConstant:40.0],
        
        // Go button
        [self.goButton.leadingAnchor constraintEqualToAnchor:self.addressTextField.trailingAnchor constant:8.0],
        [self.goButton.trailingAnchor constraintEqualToAnchor:self.containerView.trailingAnchor constant:-8.0],
        [self.goButton.centerYAnchor constraintEqualToAnchor:self.containerView.centerYAnchor],
        [self.goButton.widthAnchor constraintEqualToConstant:50.0],
        [self.goButton.heightAnchor constraintEqualToConstant:40.0]
    ]];
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillHide:) 
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
}

#pragma mark - Public Methods

- (void)updateURLDisplay:(NSString *)urlString {
    // Thread-safe URL update to prevent crashes
    dispatch_async(dispatch_get_main_queue(), ^{
        if (urlString && !self.isEditing) {
            [self.currentURL setString:urlString];
            self.addressTextField.text = urlString;
        }
    });
}

- (void)setLoadingState:(BOOL)isLoading {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.refreshButton.enabled = !isLoading;
        self.goButton.enabled = !isLoading;
        
        if (isLoading) {
            [self.refreshButton setTitle:@"✕" forState:UIControlStateNormal];
        } else {
            [self.refreshButton setTitle:@"↻" forState:UIControlStateNormal];
        }
    });
}

#pragma mark - Private Methods

- (void)updateUIState {
    // Safe UI state update
    if (self.addressTextField && self.currentURL) {
        if (!self.isEditing && self.currentURL.length > 0) {
            self.addressTextField.text = [NSString stringWithString:self.currentURL];
        }
    }
}

- (NSURL *)validateAndCreateURL:(NSString *)urlString {
    // Comprehensive URL validation to prevent crashes
    if (!urlString || urlString.length == 0) {
        return nil;
    }
    
    // Trim whitespace
    NSString *trimmedURL = [urlString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (trimmedURL.length == 0) {
        return nil;
    }
    
    // Check if it looks like a search query rather than URL
    if (![trimmedURL containsString:@"."] && ![trimmedURL hasPrefix:@"http://"] && ![trimmedURL hasPrefix:@"https://"]) {
        // Convert to Google search
        NSString *encodedQuery = [trimmedURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        trimmedURL = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", encodedQuery];
    } else if (![trimmedURL hasPrefix:@"http://"] && ![trimmedURL hasPrefix:@"https://"]) {
        // Add https:// prefix if missing
        trimmedURL = [@"https://" stringByAppendingString:trimmedURL];
    }
    
    return [NSURL URLWithString:trimmedURL];
}

- (void)textFieldDidChangeWithDebounce:(UITextField *)textField {
    // Debounce text changes to prevent excessive processing and potential crashes
    [self.debounceTimer invalidate];
    self.debounceTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                          target:self
                                                        selector:@selector(processTextFieldChange)
                                                        userInfo:nil
                                                         repeats:NO];
}

- (void)processTextFieldChange {
    // Safe text processing
    if (self.addressTextField && self.addressTextField.text) {
        // Update current URL tracking
        [self.currentURL setString:self.addressTextField.text];
    }
}

#pragma mark - Button Actions

- (void)backButtonTapped:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addressBarControllerDidRequestGoBack:)]) {
        [self.delegate addressBarControllerDidRequestGoBack:self];
    }
}

- (void)forwardButtonTapped:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addressBarControllerDidRequestGoForward:)]) {
        [self.delegate addressBarControllerDidRequestGoForward:self];
    }
}

- (void)refreshButtonTapped:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(addressBarControllerDidRequestRefresh:)]) {
        [self.delegate addressBarControllerDidRequestRefresh:self];
    }
}

- (void)goButtonTapped:(UIButton *)sender {
    [self navigateToEnteredURL];
}

- (void)navigateToEnteredURL {
    NSString *urlText = self.addressTextField.text;
    NSURL *url = [self validateAndCreateURL:urlText];
    
    if (url) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(addressBarController:didRequestNavigationToURL:)]) {
            [self.delegate addressBarController:self didRequestNavigationToURL:url];
        }
        [self.addressTextField resignFirstResponder];
        self.isEditing = NO;
    } else {
        // Show error feedback
        dispatch_async(dispatch_get_main_queue(), ^{
            self.addressTextField.layer.borderColor = [UIColor systemRedColor].CGColor;
            self.addressTextField.layer.borderWidth = 1.0;
            
            // Reset border after delay
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.addressTextField.layer.borderWidth = 0.0;
            });
        });
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    self.isEditing = YES;
    // Select all text for easy replacement
    [textField selectAll:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.isEditing = NO;
    // Update display if URL hasn't changed
    if ([textField.text isEqualToString:[NSString stringWithString:self.currentURL]]) {
        [self updateUIState];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self navigateToEnteredURL];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // Prevent potential buffer overflow crashes
    NSString *proposedText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    // Limit URL length to prevent crashes
    if (proposedText.length > 2048) {
        return NO;
    }
    
    return YES;
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
    // Handle keyboard appearance if needed
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // Handle keyboard dismissal if needed
}

@end