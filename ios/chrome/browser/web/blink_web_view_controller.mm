// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#import "ios/chrome/browser/web/blink_web_view_controller.h"
#import "ios/chrome/browser/web/metal_compositor.h"

#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

#include "base/logging.h"
#include "ui/gfx/geometry/size.h"

@interface BlinkWebViewController () {
  std::unique_ptr<ios::chrome::BlinkWebViewBridge> _blinkBridge;
  std::unique_ptr<ios::chrome::MetalCompositor> _compositor;
}

@property(nonatomic, strong) CAMetalLayer *metalLayer;
@property(nonatomic, strong) UILabel *statusLabel;

@end

@implementation BlinkWebViewController

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super init];
  if (self) {
    LOG(INFO) << "BlinkWebViewController initialized";
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  // Create Metal layer for rendering
  _metalLayer = [CAMetalLayer layer];
  _metalLayer.frame = self.view.bounds;
  _metalLayer.pixelFormat = MTLPixelFormatBGRA8Unorm;
  [self.view.layer addSublayer:_metalLayer];
  
  // Create status label (for demonstration)
  _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 
                                                             self.view.bounds.size.width - 20, 
                                                             40)];
  _statusLabel.text = @"Blink WebView (Mock Implementation)";
  _statusLabel.textAlignment = NSTextAlignmentCenter;
  _statusLabel.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
  _statusLabel.layer.cornerRadius = 8;
  _statusLabel.clipsToBounds = YES;
  [self.view addSubview:_statusLabel];
  
  // Initialize Blink bridge
  _blinkBridge = std::make_unique<ios::chrome::BlinkWebViewBridge>();
  
  CGSize viewSize = self.view.bounds.size;
  if (viewSize.width <= 0 || viewSize.height <= 0) {
    LOG(ERROR) << "Invalid view size for initialization";
    _statusLabel.text = @"Error: Invalid view size";
    return;
  }
  
  gfx::Size size(static_cast<int>(viewSize.width), 
                 static_cast<int>(viewSize.height));
  
  if (!_blinkBridge->Initialize(size)) {
    LOG(ERROR) << "Failed to initialize Blink WebView";
    _statusLabel.text = @"Error: Blink initialization failed";
    return;
  }
  
  LOG(INFO) << "Blink WebView initialized successfully";
  
  // Initialize compositor
  _compositor = std::make_unique<ios::chrome::MetalCompositor>();
  if (!_compositor->Initialize(_metalLayer)) {
    LOG(ERROR) << "Failed to initialize Metal compositor";
    _statusLabel.text = @"Error: Metal initialization failed";
    return;
  }
  
  LOG(INFO) << "Metal compositor initialized successfully";
  _statusLabel.text = @"Ready: Blink WebView + Metal Compositor";
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  _metalLayer.frame = self.view.bounds;
  
  CGSize viewSize = self.view.bounds.size;
  gfx::Size size(static_cast<int>(viewSize.width), 
                 static_cast<int>(viewSize.height));
  
  if (_blinkBridge) {
    _blinkBridge->Resize(size);
  }
}

- (void)loadURL:(NSString *)urlString {
  if (!urlString || urlString.length == 0) {
    LOG(WARNING) << "Attempted to load nil or empty URL";
    return;
  }
  
  if (_blinkBridge) {
    std::string url = [urlString UTF8String];
    _blinkBridge->LoadURL(url);
    _statusLabel.text = [NSString stringWithFormat:@"Loading: %@", urlString];
  } else {
    LOG(ERROR) << "Cannot load URL - Blink bridge not initialized";
    _statusLabel.text = @"Error: Blink not initialized";
  }
}

- (void)goBack {
  if (_blinkBridge) {
    _blinkBridge->GoBack();
  }
}

- (void)goForward {
  if (_blinkBridge) {
    _blinkBridge->GoForward();
  }
}

- (void)reload {
  if (_blinkBridge) {
    _blinkBridge->Reload();
  }
}

- (void)stopLoading {
  if (_blinkBridge) {
    _blinkBridge->Stop();
  }
}

- (BOOL)canGoBack {
  return _blinkBridge ? _blinkBridge->CanGoBack() : NO;
}

- (BOOL)canGoForward {
  return _blinkBridge ? _blinkBridge->CanGoForward() : NO;
}

- (NSString *)currentURL {
  if (_blinkBridge) {
    std::string url = _blinkBridge->GetCurrentURL();
    return [NSString stringWithUTF8String:url.c_str()];
  }
  return @"about:blank";
}

- (void)dealloc {
  LOG(INFO) << "BlinkWebViewController deallocated";
}

@end
