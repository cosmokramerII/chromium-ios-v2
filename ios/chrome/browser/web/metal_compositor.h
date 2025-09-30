// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef IOS_CHROME_BROWSER_WEB_METAL_COMPOSITOR_H_
#define IOS_CHROME_BROWSER_WEB_METAL_COMPOSITOR_H_

#include <memory>

#ifdef __OBJC__
@class CAMetalLayer;
#else
typedef void CAMetalLayer;
#endif

namespace ios {
namespace chrome {

// Metal compositor that renders Blink's compositor output to a CAMetalLayer
// This bridges between Blink's cc/compositor and iOS Metal rendering
class MetalCompositor {
 public:
  MetalCompositor();
  ~MetalCompositor();

  // Disable copy and assign
  MetalCompositor(const MetalCompositor&) = delete;
  MetalCompositor& operator=(const MetalCompositor&) = delete;

  // Initialize with a Metal layer
  bool Initialize(CAMetalLayer* layer);

  // Submit a frame for rendering
  void SubmitFrame();

  // Update the layer size
  void Resize(int width, int height);

  // Get the Metal device
  void* GetMetalDevice();

 private:
  // Metal objects (opaque pointers to avoid Objective-C in header)
  void* metal_device_;
  void* command_queue_;
  CAMetalLayer* metal_layer_;
  
  bool initialized_;
};

}  // namespace chrome
}  // namespace ios

#endif  // IOS_CHROME_BROWSER_WEB_METAL_COMPOSITOR_H_
