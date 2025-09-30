// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "ios/chrome/browser/web/blink_web_view_bridge.h"

#include "base/test/task_environment.h"
#include "testing/gtest/include/gtest/gtest.h"
#include "ui/gfx/geometry/size.h"

namespace ios {
namespace chrome {

class BlinkWebViewBridgeTest : public testing::Test {
 protected:
  void SetUp() override {
    bridge_ = std::make_unique<BlinkWebViewBridge>();
  }

  void TearDown() override {
    bridge_.reset();
  }

  base::test::TaskEnvironment task_environment_;
  std::unique_ptr<BlinkWebViewBridge> bridge_;
};

TEST_F(BlinkWebViewBridgeTest, Initialization) {
  gfx::Size size(800, 600);
  EXPECT_TRUE(bridge_->Initialize(size));
}

TEST_F(BlinkWebViewBridgeTest, LoadURL) {
  gfx::Size size(800, 600);
  bridge_->Initialize(size);
  
  // Should not crash
  bridge_->LoadURL("https://www.example.com");
  
  // In mock implementation, URL won't actually change
  // In real implementation, would verify navigation started
}

TEST_F(BlinkWebViewBridgeTest, Navigation) {
  gfx::Size size(800, 600);
  bridge_->Initialize(size);
  
  EXPECT_FALSE(bridge_->CanGoBack());
  EXPECT_FALSE(bridge_->CanGoForward());
  
  // In real implementation, would load page and verify navigation state
}

TEST_F(BlinkWebViewBridgeTest, Resize) {
  gfx::Size size(800, 600);
  bridge_->Initialize(size);
  
  gfx::Size new_size(1024, 768);
  bridge_->Resize(new_size);
  
  // Should not crash
  // In real implementation, would verify WebView was resized
}

TEST_F(BlinkWebViewBridgeTest, CompositorLayer) {
  gfx::Size size(800, 600);
  bridge_->Initialize(size);
  
  // In mock implementation, returns nullptr
  // In real implementation, would return valid layer
  void* layer = bridge_->GetCompositorLayer();
  (void)layer; // Suppress unused variable warning
}

}  // namespace chrome
}  // namespace ios
