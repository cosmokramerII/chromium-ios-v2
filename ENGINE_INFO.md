# Browser Engine Information

## Why This Browser Uses WebKit, Not Blink

### Apple's Requirement
All web browsers on iOS **must** use Apple's WebKit engine. This is a strict requirement enforced by Apple's App Store Review Guidelines (section 2.5.6).

**This means:**
- Chrome on iOS uses WebKit (not Blink)
- Firefox on iOS uses WebKit (not Gecko)  
- Edge on iOS uses WebKit (not Blink)
- Opera on iOS uses WebKit (not Presto/Blink)
- Safari on iOS uses WebKit

### What is WebKit?
WebKit is the browser engine developed by Apple. It's the same engine that powers Safari on iOS and macOS.

### What is Blink?
Blink is the browser engine used by:
- Chrome on Windows, Linux, Android, and macOS
- Edge on Windows, Linux, Android, and macOS
- Opera on Windows, Linux, Android, and macOS

**Blink is NOT available on iOS** due to Apple's restrictions.

### This Browser
This browser (ChromiumIOSv2):
- ✅ Uses **WebKit** (WKWebView) - Apple's required engine
- ✅ Styled after Chrome's interface
- ✅ Uses Chrome-compatible user agent for site compatibility
- ❌ Does NOT use Blink (impossible on iOS)
- ❌ Does NOT use Chrome's rendering engine (impossible on iOS)

### User Agent String
The browser uses a Chrome-compatible user agent string:
```
ChromiumIOSv2/2.0 (iPhone; iOS 14.0) Chrome/91.0.4472.114 Mobile Safari/537.36
```

**Important:** This is only for website compatibility. It tells websites "treat me like Chrome", but the actual rendering is done by WebKit, not Blink.

### Technical Details

#### What WKWebView Provides
- HTML5 rendering via WebKit
- JavaScript execution via JavaScriptCore
- CSS rendering and layout
- DOM manipulation
- Web APIs (localStorage, fetch, etc.)

#### What This Browser Adds
- Custom user interface
- Address bar with URL validation
- Navigation controls (back, forward, refresh)
- Chrome-style UI design
- Crash prevention and memory management
- Thread-safe operations

### Limitations
Because this browser uses WebKit instead of Blink:
1. **Different JavaScript engine**: Uses JavaScriptCore instead of V8
2. **Different rendering**: Some sites may render slightly differently than desktop Chrome
3. **Different performance**: WebKit has different performance characteristics than Blink
4. **Different features**: Some Blink-specific features are not available

### Why the "Chromium" Name?
The project is named "ChromiumIOSv2" because:
- It's inspired by Chrome's user interface design
- It aims for Chrome-compatible behavior where possible
- It uses a Chrome user agent for site compatibility

However, it's important to understand that **it is not actually running Chromium/Blink** - it's a WebKit-based browser styled like Chrome.

### Comparison

| Feature | Desktop Chrome | This Browser |
|---------|---------------|--------------|
| Rendering Engine | Blink | WebKit |
| JavaScript Engine | V8 | JavaScriptCore |
| UI | Chrome UI | Chrome-inspired UI |
| User Agent | Chrome | Chrome-compatible |
| Platform | Win/Mac/Linux/Android | iOS only |
| Developer | Google | Independent |

### Further Reading
- [Apple's App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [WebKit Project](https://webkit.org/)
- [Blink Project](https://www.chromium.org/blink/)
- [Why iOS browsers all use WebKit](https://infrequently.org/2021/08/webkit-ios-deep-dive/)

## Conclusion

While this browser is styled after Chrome and aims for compatibility with Chrome, **it uses Apple's WebKit engine** because that is the only option available for iOS browsers. This is not a limitation of this project, but a requirement imposed by Apple on all iOS browsers.
