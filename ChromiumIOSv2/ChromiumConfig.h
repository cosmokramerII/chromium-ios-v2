//
//  ChromiumConfig.h
//  ChromiumIOSv2
//
//  Chromium-specific configuration constants with Blink rendering engine
//  NOTE: This is a conceptual implementation. iOS does not support alternative browser engines.
//

#ifndef ChromiumConfig_h
#define ChromiumConfig_h

// Chromium/Blink version info
#define CHROMIUM_VERSION @"120.0.6099.0"
#define BLINK_VERSION @"120.0.6099.0"
#define V8_VERSION @"12.0.267.1"
#define CHROMIUM_USER_AGENT_SUFFIX @"Chrome/120.0.6099.0 Mobile Safari/537.36"

// Blink feature flags
#define ENABLE_BLINK_RENDERING_ENGINE 1
#define ENABLE_V8_JAVASCRIPT_ENGINE 1
#define ENABLE_GPU_ACCELERATION 1
#define ENABLE_COMPOSITOR_THREAD 1
#define ENABLE_BLINK_SCHEDULER 1

// Performance settings
#define MAX_URL_LENGTH 2048
#define ADDRESS_BAR_DEBOUNCE_INTERVAL 0.3
#define MEMORY_WARNING_THRESHOLD 0.8
#define BLINK_RENDERER_PROCESS_LIMIT 4

// Default URLs
#define DEFAULT_HOMEPAGE_URL @"https://www.google.com"
#define SEARCH_ENGINE_URL @"https://www.google.com/search?q=%@"

// Error handling and diagnostics
#define ENABLE_CRASH_REPORTING 1
#define ENABLE_PERFORMANCE_MONITORING 1
#define ENABLE_BLINK_DEBUGGING 1

// Content module settings
#define ENABLE_CHROMIUM_CONTENT_API 1
#define ENABLE_MOJO_IPC 1

#endif /* ChromiumConfig_h */