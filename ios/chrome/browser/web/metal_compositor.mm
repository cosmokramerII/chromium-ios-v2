// Copyright 2024 The Chromium Authors
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#include "ios/chrome/browser/web/metal_compositor.h"

#import <Metal/Metal.h>
#import <QuartzCore/QuartzCore.h>

#include "base/logging.h"

namespace ios {
namespace chrome {

MetalCompositor::MetalCompositor()
    : metal_device_(nullptr),
      command_queue_(nullptr),
      metal_layer_(nullptr),
      initialized_(false) {
  LOG(INFO) << "MetalCompositor created";
}

MetalCompositor::~MetalCompositor() {
  LOG(INFO) << "MetalCompositor destroyed";
  
  // Release Metal objects
  if (command_queue_) {
    CFRelease(command_queue_);
    command_queue_ = nullptr;
  }
  if (metal_device_) {
    CFRelease(metal_device_);
    metal_device_ = nullptr;
  }
}

bool MetalCompositor::Initialize(CAMetalLayer* layer) {
  if (!layer) {
    LOG(ERROR) << "Cannot initialize with null layer";
    return false;
  }

  metal_layer_ = layer;

  // Create Metal device
  id<MTLDevice> device = MTLCreateSystemDefaultDevice();
  if (!device) {
    LOG(ERROR) << "Failed to create Metal device";
    return false;
  }

  metal_device_ = (__bridge_retained void*)device;

  // Create command queue
  id<MTLCommandQueue> queue = [device newCommandQueue];
  if (!queue) {
    LOG(ERROR) << "Failed to create Metal command queue";
    CFRelease(metal_device_);
    metal_device_ = nullptr;
    return false;
  }

  command_queue_ = (__bridge_retained void*)queue;

  // Configure the Metal layer
  layer.device = device;
  layer.framebufferOnly = YES;
  layer.presentsWithTransaction = NO;

  initialized_ = true;
  LOG(INFO) << "Metal compositor initialized successfully";

  return true;
}

void MetalCompositor::SubmitFrame() {
  if (!initialized_) {
    LOG(WARNING) << "Cannot submit frame - compositor not initialized";
    return;
  }

  // In a real implementation, this would:
  // 1. Get the drawable from the Metal layer
  // 2. Create a command buffer
  // 3. Render Blink's compositor output using Metal shaders
  // 4. Present the drawable
  //
  // Example (simplified):
  // id<CAMetalDrawable> drawable = [metal_layer_ nextDrawable];
  // id<MTLCommandBuffer> commandBuffer = [commandQueue newCommandBuffer];
  // // ... render commands ...
  // [commandBuffer presentDrawable:drawable];
  // [commandBuffer commit];

  @autoreleasepool {
    id<MTLCommandQueue> queue = (__bridge id<MTLCommandQueue>)command_queue_;
    id<CAMetalDrawable> drawable = [metal_layer_ nextDrawable];
    
    if (!drawable) {
      return;
    }

    id<MTLCommandBuffer> commandBuffer = [queue commandBuffer];
    
    // Simple clear operation for demonstration
    MTLRenderPassDescriptor *renderPassDescriptor = [MTLRenderPassDescriptor renderPassDescriptor];
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture;
    renderPassDescriptor.colorAttachments[0].loadAction = MTLLoadActionClear;
    renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(1.0, 1.0, 1.0, 1.0);
    renderPassDescriptor.colorAttachments[0].storeAction = MTLStoreActionStore;
    
    id<MTLRenderCommandEncoder> renderEncoder = 
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
    [renderEncoder endEncoding];
    
    [commandBuffer presentDrawable:drawable];
    [commandBuffer commit];
  }
}

void MetalCompositor::Resize(int width, int height) {
  if (!initialized_) {
    return;
  }

  LOG(INFO) << "Resizing Metal compositor to " << width << "x" << height;
  
  // Update the drawable size
  metal_layer_.drawableSize = CGSizeMake(width, height);
}

void* MetalCompositor::GetMetalDevice() {
  return metal_device_;
}

}  // namespace chrome
}  // namespace ios
