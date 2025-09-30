// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import <UIKit/UIKit.h>

#include <memory>
#include "ios/chrome/browser/web/blink_web_view_bridge.h"

NS_ASSUME_NONNULL_BEGIN

// Objective-C wrapper for BlinkWebViewBridge
// This provides the Swift/Objective-C interface to the C++ Blink integration
@interface BlinkWebViewController : UIViewController

// Initialize with a frame
- (instancetype)initWithFrame:(CGRect)frame;

// Load a URL
- (void)loadURL:(NSString *)urlString;

// Navigation
- (void)goBack;
- (void)goForward;
- (void)reload;
- (void)stopLoading;

// Properties
@property(nonatomic, readonly) BOOL canGoBack;
@property(nonatomic, readonly) BOOL canGoForward;
@property(nonatomic, readonly) NSString *currentURL;

@end

NS_ASSUME_NONNULL_END
