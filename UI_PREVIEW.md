# UI Preview - Chromium iOS v2

## Interface Layout

The Chromium iOS v2 browser features a clean, modern interface optimized for iOS 26:

### Address Bar Layout
```
┌─────────────────────────────────────────────────────────────┐
│ [◀] [▶] [↻]  [      Enter URL or search...    ] [Go]       │
└─────────────────────────────────────────────────────────────┘
```

**Components:**
- **Back Button (◀)**: Navigate to previous page
- **Forward Button (▶)**: Navigate to next page  
- **Refresh Button (↻)**: Reload current page / Stop loading
- **Address Field**: Smart URL/search input with validation
- **Go Button**: Execute navigation/search

### Full Browser Interface
```
┌─────────────────────────────────────────────────────────────┐
│ Status Bar (iOS 26)                                         │
├─────────────────────────────────────────────────────────────┤
│ [◀] [▶] [↻]  [      https://www.google.com     ] [Go]      │
├─────────────────────────────────────────────────────────────┤
│ ████████████████████████████████████████████████ (Progress) │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│                   WebView Content Area                      │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐    │
│  │                Google Homepage                      │    │
│  │  ┌─────────────────────────────────────────────┐     │    │
│  │  │           Search Input                      │     │    │
│  │  └─────────────────────────────────────────────┘     │    │
│  │                                                 │    │
│  │  [Google Search] [I'm Feeling Lucky]           │    │
│  └─────────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Key UI Features

### 1. Responsive Design
- Adapts to iPhone and iPad screen sizes
- Supports both portrait and landscape orientations
- Safe area layout guides for notched devices

### 2. Modern iOS 26 Styling
- System colors that adapt to light/dark mode
- SF Symbols for navigation buttons (when available)
- Native iOS form controls and animations

### 3. Smart Address Bar
- Auto-complete suggestions
- Search vs URL detection
- Visual feedback for invalid URLs
- Loading state indicators

### 4. Progress Indication
- Animated progress bar during page loads
- Visual loading state in refresh button
- Smooth transitions and animations

## Accessibility Features

### VoiceOver Support
- All controls properly labeled
- Logical navigation order
- Screen reader friendly descriptions

### Dynamic Type
- Text scales with system font size settings
- Maintains usability across all text sizes
- Proper font weight and contrast

### Color Accessibility
- High contrast support
- Color blind friendly indicators
- Sufficient color contrast ratios

## Error States

### Network Error
```
┌─────────────────────────────────────────────────────────────┐
│                    ⚠️ Connection Error                      │
│                                                             │
│    The page could not be loaded. Please check your         │
│           internet connection and try again.               │
│                                                             │
│                    [Try Again]                             │
└─────────────────────────────────────────────────────────────┘
```

### Invalid URL
```
┌─────────────────────────────────────────────────────────────┐
│ [◀] [▶] [↻]  [      invalid-url...          ] [Go]         │
│                      ^^^^^^^^^^^^                          │
│                    Red border indicates invalid URL        │
└─────────────────────────────────────────────────────────────┘
```

## Interactive Elements

### Address Bar Focus State
- Blue outline when focused
- Full text selection on tap
- Keyboard shows with URL optimized layout
- Clear button appears when editing

### Button States
- Normal, highlighted, and disabled states
- Proper visual feedback for all interactions
- Loading spinner for refresh button during navigation

### Gestures
- Swipe left/right for back/forward navigation
- Pull to refresh in web content
- Long press for context menus

## Dark Mode Support

The interface automatically adapts to system appearance:

**Light Mode:**
- White background with dark text
- Blue accent colors
- Light gray secondary elements

**Dark Mode:**
- Dark background with light text
- Blue accent colors (adjusted for dark mode)
- Dark gray secondary elements

## Performance Indicators

### Memory Usage (Debug Mode)
- Visual indicator of memory pressure
- Automatic cleanup notifications
- Performance metrics overlay

### Network Activity
- Loading progress in address bar
- Visual feedback for slow connections
- Offline mode indicators

This UI design ensures a familiar, intuitive browsing experience while maintaining the performance and stability improvements implemented in the crash fixes.