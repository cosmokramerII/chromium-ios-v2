// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "ios/chrome/browser/web/web_state.h"

#include "base/logging.h"
#include "ios/chrome/browser/web/blink_web_view_bridge.h"

namespace ios {
namespace chrome {

WebState::WebState() : is_loading_(false), current_url_("about:blank") {
  LOG(INFO) << "WebState created";
  blink_bridge_ = std::make_unique<BlinkWebViewBridge>();
}

WebState::~WebState() {
  LOG(INFO) << "WebState destroyed";
}

void WebState::LoadURL(const std::string& url) {
  LOG(INFO) << "WebState loading URL: " << url;
  current_url_ = url;
  is_loading_ = true;
  
  if (blink_bridge_) {
    blink_bridge_->LoadURL(url);
  }
}

void WebState::GoBack() {
  if (blink_bridge_) {
    blink_bridge_->GoBack();
  }
}

void WebState::GoForward() {
  if (blink_bridge_) {
    blink_bridge_->GoForward();
  }
}

void WebState::Reload() {
  if (blink_bridge_) {
    blink_bridge_->Reload();
  }
}

void WebState::Stop() {
  if (blink_bridge_) {
    blink_bridge_->Stop();
  }
  is_loading_ = false;
}

bool WebState::CanGoBack() const {
  return blink_bridge_ ? blink_bridge_->CanGoBack() : false;
}

bool WebState::CanGoForward() const {
  return blink_bridge_ ? blink_bridge_->CanGoForward() : false;
}

bool WebState::IsLoading() const {
  return is_loading_;
}

std::string WebState::GetCurrentURL() const {
  return current_url_;
}

std::string WebState::GetTitle() const {
  return title_;
}

}  // namespace chrome
}  // namespace ios
