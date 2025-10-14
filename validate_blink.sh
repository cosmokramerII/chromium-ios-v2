#!/bin/bash
#
# Validate Blink Integration
# Checks that all necessary files are present and properly structured
#

echo "================================"
echo "Blink Integration Validation"
echo "================================"
echo ""

# Color codes for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

FAILED=0
WARNINGS=0

# Function to check if file exists
check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1 - MISSING"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Function to check if file contains string
check_contains() {
    if grep -q "$2" "$1" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} $1 contains '$2'"
        return 0
    else
        echo -e "${YELLOW}⚠${NC} $1 does not contain '$2'"
        WARNINGS=$((WARNINGS + 1))
        return 1
    fi
}

echo "Checking Blink Core Files..."
echo "----------------------------"
check_file "ChromiumIOSv2/BlinkEngine.h"
check_file "ChromiumIOSv2/BlinkEngine.m"
check_file "ChromiumIOSv2/BlinkWebView.h"
check_file "ChromiumIOSv2/BlinkWebView.m"
check_file "ChromiumIOSv2/BlinkContentClient.h"
check_file "ChromiumIOSv2/BlinkContentClient.m"
check_file "ChromiumIOSv2/BlinkBrowserViewController.h"
check_file "ChromiumIOSv2/BlinkBrowserViewController.m"
echo ""

echo "Checking Configuration Files..."
echo "-------------------------------"
check_file "ChromiumIOSv2/ChromiumConfig.h"
check_contains "ChromiumIOSv2/ChromiumConfig.h" "ENABLE_BLINK_RENDERING_ENGINE"
check_contains "ChromiumIOSv2/ChromiumConfig.h" "ENABLE_V8_JAVASCRIPT_ENGINE"
check_contains "ChromiumIOSv2/ChromiumConfig.h" "BLINK_VERSION"
echo ""

echo "Checking Integration Files..."
echo "-----------------------------"
check_file "ChromiumIOSv2/AppDelegate.m"
check_contains "ChromiumIOSv2/AppDelegate.m" "BlinkEngine"
check_contains "ChromiumIOSv2/AppDelegate.m" "BlinkContentClient"
check_file "ChromiumIOSv2/ViewController.h"
check_contains "ChromiumIOSv2/ViewController.h" "BlinkBrowserViewController"
check_file "ChromiumIOSv2/ViewController.m"
check_contains "ChromiumIOSv2/ViewController.m" "BlinkBrowserViewController"
echo ""

echo "Checking Documentation..."
echo "-------------------------"
check_file "README.md"
check_file "BLINK_INTEGRATION.md"
check_contains "README.md" "Blink"
check_contains "BLINK_INTEGRATION.md" "Blink"
echo ""

echo "Checking Deprecated Files..."
echo "----------------------------"
check_file "ChromiumIOSv2/BrowserViewController_WebKit_Deprecated.h"
check_file "ChromiumIOSv2/BrowserViewController_WebKit_Deprecated.m"
check_contains "ChromiumIOSv2/BrowserViewController_WebKit_Deprecated.h" "DEPRECATED"
echo ""

echo "Checking Project File..."
echo "------------------------"
check_file "ChromiumIOSv2.xcodeproj/project.pbxproj"
check_contains "ChromiumIOSv2.xcodeproj/project.pbxproj" "BlinkEngine.m"
check_contains "ChromiumIOSv2.xcodeproj/project.pbxproj" "BlinkWebView.m"
check_contains "ChromiumIOSv2.xcodeproj/project.pbxproj" "BlinkBrowserViewController.m"
echo ""

echo "Checking for WebKit References..."
echo "----------------------------------"
# Check that main files no longer reference WebKit
if ! grep -q "WebKit/WebKit.h" "ChromiumIOSv2/ViewController.h" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} ViewController.h - No WebKit imports"
else
    echo -e "${YELLOW}⚠${NC} ViewController.h still has WebKit imports"
    WARNINGS=$((WARNINGS + 1))
fi

if ! grep -q "WebKit/WebKit.h" "ChromiumIOSv2/ViewController.m" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} ViewController.m - No WebKit imports"
else
    echo -e "${YELLOW}⚠${NC} ViewController.m still has WebKit imports"
    WARNINGS=$((WARNINGS + 1))
fi

if ! grep -q "WKWebView" "ChromiumIOSv2/AppDelegate.m" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} AppDelegate.m - No WKWebView references"
else
    echo -e "${YELLOW}⚠${NC} AppDelegate.m still has WKWebView references"
    WARNINGS=$((WARNINGS + 1))
fi

if ! grep -q "ENABLE_MODERN_WEBKIT_FEATURES" "ChromiumIOSv2/ChromiumConfig.h" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} ChromiumConfig.h - WebKit flags removed"
else
    echo -e "${YELLOW}⚠${NC} ChromiumConfig.h still has WebKit flags"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

echo "Checking Objective-C Syntax..."
echo "------------------------------"
# Basic syntax checks - check for @implementation blocks  
for file in ChromiumIOSv2/Blink*.m ChromiumIOSv2/AppDelegate.m ChromiumIOSv2/ViewController.m; do
    if [ -f "$file" ]; then
        # Check that file has at least one @implementation
        impl_count=$(grep -c "^@implementation" "$file" 2>/dev/null || echo 0)
        
        if [ "$impl_count" -gt 0 ]; then
            echo -e "${GREEN}✓${NC} $file - Contains @implementation block"
        else
            echo -e "${RED}✗${NC} $file - Missing @implementation block"
            FAILED=$((FAILED + 1))
        fi
    fi
done
echo ""

echo "================================"
echo "Validation Summary"
echo "================================"
echo ""
echo "Failed checks: $FAILED"
echo "Warnings: $WARNINGS"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All critical checks passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Open ChromiumIOSv2.xcodeproj in Xcode"
    echo "  2. Build the project (⌘+B)"
    echo "  3. Run on simulator or device (⌘+R)"
    echo ""
    echo "Note: This is a conceptual implementation."
    echo "iOS does not support Blink rendering engine."
    exit 0
else
    echo -e "${RED}✗ $FAILED critical checks failed${NC}"
    echo ""
    echo "Please fix the errors above before building."
    exit 1
fi
