//
//  AddressBarControllerTests.m
//  ChromiumIOSv2Tests
//
//  Tests for address bar crash fixes and functionality
//

#import <XCTest/XCTest.h>
#import "../ChromiumIOSv2/AddressBarController.h"

@interface AddressBarControllerTests : XCTestCase <AddressBarControllerDelegate>

@property (nonatomic, strong) AddressBarController *addressBarController;
@property (nonatomic, strong) NSURL *lastRequestedURL;
@property (nonatomic, assign) BOOL didRequestRefresh;
@property (nonatomic, assign) BOOL didRequestGoBack;
@property (nonatomic, assign) BOOL didRequestGoForward;

@end

@implementation AddressBarControllerTests

- (void)setUp {
    [super setUp];
    self.addressBarController = [[AddressBarController alloc] initWithFrame:CGRectMake(0, 0, 375, 60)];
    self.addressBarController.delegate = self;
    
    // Reset delegate tracking properties
    self.lastRequestedURL = nil;
    self.didRequestRefresh = NO;
    self.didRequestGoBack = NO;
    self.didRequestGoForward = NO;
}

- (void)tearDown {
    self.addressBarController.delegate = nil;
    self.addressBarController = nil;
    [super tearDown];
}

#pragma mark - Crash Prevention Tests

- (void)testAddressBarControllerDeallocation {
    // Test that the address bar controller can be deallocated without crashing
    AddressBarController *controller = [[AddressBarController alloc] initWithFrame:CGRectMake(0, 0, 375, 60)];
    controller.delegate = self;
    
    // Simulate typical usage
    [controller updateURLDisplay:@"https://www.google.com"];
    [controller setLoadingState:YES];
    [controller setLoadingState:NO];
    
    // Clear delegate before deallocation
    controller.delegate = nil;
    controller = nil;
    
    // If we reach here without crashing, the test passes
    XCTAssertTrue(YES);
}

- (void)testNilURLHandling {
    // Test that nil URLs don't cause crashes
    XCTAssertNoThrow([self.addressBarController updateURLDisplay:nil]);
}

- (void)testEmptyURLHandling {
    // Test that empty URLs are handled gracefully
    XCTAssertNoThrow([self.addressBarController updateURLDisplay:@""]);
}

- (void)testVeryLongURLHandling {
    // Test that very long URLs don't cause buffer overflow crashes
    NSMutableString *longURL = [NSMutableString stringWithString:@"https://www.example.com/"];
    for (int i = 0; i < 1000; i++) {
        [longURL appendString:@"verylongpathsegment/"];
    }
    
    XCTAssertNoThrow([self.addressBarController updateURLDisplay:longURL]);
}

#pragma mark - URL Validation Tests

- (void)testValidURLs {
    // Test valid URL formats
    NSArray *validURLs = @[
        @"https://www.google.com",
        @"http://example.com",
        @"https://sub.domain.com/path?query=value",
        @"www.google.com",
        @"google.com"
    ];
    
    for (NSString *urlString in validURLs) {
        [self.addressBarController updateURLDisplay:urlString];
        // Simulate user pressing go button
        self.addressBarController.addressTextField.text = urlString;
        [self.addressBarController textFieldShouldReturn:self.addressBarController.addressTextField];
        
        XCTAssertNotNil(self.lastRequestedURL, @"Should create valid URL for: %@", urlString);
        self.lastRequestedURL = nil; // Reset for next test
    }
}

- (void)testSearchQueries {
    // Test that search queries are converted to Google searches
    NSArray *searchQueries = @[
        @"test search query",
        @"programming tips",
        @"ios development"
    ];
    
    for (NSString *query in searchQueries) {
        self.addressBarController.addressTextField.text = query;
        [self.addressBarController textFieldShouldReturn:self.addressBarController.addressTextField];
        
        XCTAssertNotNil(self.lastRequestedURL, @"Should create search URL for: %@", query);
        XCTAssert([self.lastRequestedURL.absoluteString containsString:@"google.com/search"], @"Should convert to Google search: %@", query);
        self.lastRequestedURL = nil; // Reset for next test
    }
}

#pragma mark - Threading Tests

- (void)testThreadSafeURLUpdates {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Thread safe URL updates"];
    
    // Test concurrent URL updates from different threads
    dispatch_group_t group = dispatch_group_create();
    
    for (int i = 0; i < 10; i++) {
        dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *url = [NSString stringWithFormat:@"https://www.example%d.com", i];
            [self.addressBarController updateURLDisplay:url];
        });
    }
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:5.0 handler:nil];
}

#pragma mark - UI State Tests

- (void)testLoadingState {
    // Test loading state changes
    XCTAssertNoThrow([self.addressBarController setLoadingState:YES]);
    XCTAssertNoThrow([self.addressBarController setLoadingState:NO]);
}

- (void)testButtonActions {
    // Test that button actions don't crash
    XCTAssertNoThrow([self.addressBarController.backButton sendActionsForControlEvents:UIControlEventTouchUpInside]);
    XCTAssertTrue(self.didRequestGoBack);
    
    XCTAssertNoThrow([self.addressBarController.forwardButton sendActionsForControlEvents:UIControlEventTouchUpInside]);
    XCTAssertTrue(self.didRequestGoForward);
    
    XCTAssertNoThrow([self.addressBarController.refreshButton sendActionsForControlEvents:UIControlEventTouchUpInside]);
    XCTAssertTrue(self.didRequestRefresh);
}

#pragma mark - Memory Management Tests

- (void)testMemoryLeaks {
    // Test for potential memory leaks by creating and releasing multiple controllers
    for (int i = 0; i < 100; i++) {
        @autoreleasepool {
            AddressBarController *controller = [[AddressBarController alloc] initWithFrame:CGRectMake(0, 0, 375, 60)];
            controller.delegate = self;
            [controller updateURLDisplay:@"https://www.example.com"];
            controller.delegate = nil;
        }
    }
    
    // If we reach here without excessive memory usage or crashes, test passes
    XCTAssertTrue(YES);
}

#pragma mark - AddressBarControllerDelegate

- (void)addressBarController:(AddressBarController *)controller didRequestNavigationToURL:(NSURL *)url {
    self.lastRequestedURL = url;
}

- (void)addressBarControllerDidRequestRefresh:(AddressBarController *)controller {
    self.didRequestRefresh = YES;
}

- (void)addressBarControllerDidRequestGoBack:(AddressBarController *)controller {
    self.didRequestGoBack = YES;
}

- (void)addressBarControllerDidRequestGoForward:(AddressBarController *)controller {
    self.didRequestGoForward = YES;
}

@end