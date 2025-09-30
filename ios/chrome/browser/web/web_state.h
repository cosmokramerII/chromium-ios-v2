// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_WEB_WEB_STATE_H_
#define IOS_CHROME_BROWSER_WEB_WEB_STATE_H_

#include <memory>
#include <string>

#include "base/memory/weak_ptr.h"

namespace ios {
namespace chrome {

class BlinkWebViewBridge;

// WebState manages the state of a web page
// This is analogous to content::WebContents in Chromium
class WebState {
 public:
  WebState();
  ~WebState();

  // Disable copy and assign
  WebState(const WebState&) = delete;
  WebState& operator=(const WebState&) = delete;

  // Navigation
  void LoadURL(const std::string& url);
  void GoBack();
  void GoForward();
  void Reload();
  void Stop();

  // State queries
  bool CanGoBack() const;
  bool CanGoForward() const;
  bool IsLoading() const;
  std::string GetCurrentURL() const;
  std::string GetTitle() const;

  // Get the underlying Blink bridge
  BlinkWebViewBridge* GetBlinkBridge() { return blink_bridge_.get(); }

 private:
  std::unique_ptr<BlinkWebViewBridge> blink_bridge_;
  bool is_loading_;
  std::string current_url_;
  std::string title_;

  base::WeakPtrFactory<WebState> weak_ptr_factory_{this};
};

}  // namespace chrome
}  // namespace ios

#endif  // IOS_CHROME_BROWSER_WEB_WEB_STATE_H_
