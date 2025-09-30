//
//  ChromiumApp-Bridging-Header.h
//  ChromiumApp
//
//  Bridging header to expose Objective-C/C++ classes to Swift
//

#ifndef ChromiumApp_Bridging_Header_h
#define ChromiumApp_Bridging_Header_h

// Import the Blink WebView controller so it can be used from Swift
// Note: This requires the ios/chrome/browser/web directory to be in the build path
#import "ios/chrome/browser/web/blink_web_view_controller.h"

#endif /* ChromiumApp_Bridging_Header_h */
