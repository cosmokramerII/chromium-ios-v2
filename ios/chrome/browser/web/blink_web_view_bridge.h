// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_WEB_BLINK_WEB_VIEW_BRIDGE_H_
#define IOS_CHROME_BROWSER_WEB_BLINK_WEB_VIEW_BRIDGE_H_

#include <memory>
#include "base/memory/weak_ptr.h"

// Forward declarations for Blink types
namespace blink {
class WebView;
class WebViewClient;
class WebInputEvent;
}  // namespace blink

namespace gfx {
class Size;
}  // namespace gfx

namespace ios {
namespace chrome {

// C++ bridge that wraps Blink's WebView for iOS
// This class provides the interface between Swift/Objective-C and Blink C++ code
class BlinkWebViewBridge {
 public:
  BlinkWebViewBridge();
  ~BlinkWebViewBridge();

  // Disable copy and assign
  BlinkWebViewBridge(const BlinkWebViewBridge&) = delete;
  BlinkWebViewBridge& operator=(const BlinkWebViewBridge&) = delete;

  // Initialize the Blink WebView with given size
  bool Initialize(const gfx::Size& size);

  // Load a URL in the web view
  void LoadURL(const std::string& url);

  // Resize the web view
  void Resize(const gfx::Size& new_size);

  // Handle input events
  void HandleInputEvent(const blink::WebInputEvent& event);

  // Navigation controls
  void GoBack();
  void GoForward();
  void Reload();
  void Stop();

  // Get the current URL
  std::string GetCurrentURL() const;

  // Check if can navigate
  bool CanGoBack() const;
  bool CanGoForward() const;

  // Get the compositor layer for Metal rendering
  void* GetCompositorLayer();

  // Trigger a repaint
  void Paint();

 private:
  // Initialize Blink runtime (called once)
  static void InitializeBlinkPlatform();
  static bool blink_initialized_;

  // The actual Blink WebView instance
  std::unique_ptr<blink::WebView> web_view_;
  std::unique_ptr<blink::WebViewClient> web_view_client_;

  base::WeakPtrFactory<BlinkWebViewBridge> weak_ptr_factory_{this};
};

}  // namespace chrome
}  // namespace ios

#endif  // IOS_CHROME_BROWSER_WEB_BLINK_WEB_VIEW_BRIDGE_H_
