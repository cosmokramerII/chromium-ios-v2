//
//  ChromiumConfig.h
//  ChromiumIOSv2
//
//  Chromium-specific configuration constants
//

#ifndef ChromiumConfig_h
#define ChromiumConfig_h

// Chromium version info
#define CHROMIUM_VERSION @"91.0.4472.114"
#define CHROMIUM_USER_AGENT_SUFFIX @"Chrome/91.0.4472.114 Mobile Safari/537.36"

// Feature flags for iOS 26 compatibility
#define ENABLE_MODERN_WEBKIT_FEATURES 1
#define ENABLE_JAVASCRIPT_JIT 1
#define ENABLE_HARDWARE_ACCELERATION 1

// Crash prevention settings
#define MAX_URL_LENGTH 2048
#define ADDRESS_BAR_DEBOUNCE_INTERVAL 0.3
#define MEMORY_WARNING_THRESHOLD 0.8

// Default URLs
#define DEFAULT_HOMEPAGE_URL @"https://www.google.com"
#define SEARCH_ENGINE_URL @"https://www.google.com/search?q=%@"

// Error handling
#define ENABLE_CRASH_REPORTING 1
#define ENABLE_PERFORMANCE_MONITORING 1

#endif /* ChromiumConfig_h */