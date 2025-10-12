#!/bin/bash

# Validation script for ChromiumIOSv2 (WebKit-based browser)
# This script checks if the project is properly configured

set -e

echo "🔍 Validating ChromiumIOSv2 project..."
echo ""

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

# Check 1: Project structure
echo "📁 Checking project structure..."
if [ -d "ChromiumIOSv2.xcodeproj" ] && [ -f "ChromiumIOSv2.xcodeproj/project.pbxproj" ]; then
    echo -e "${GREEN}✓${NC} Xcode project structure is correct"
else
    echo -e "${RED}✗${NC} Xcode project structure is incorrect"
    ERRORS=$((ERRORS + 1))
fi

# Check 2: Assets catalog
echo "📱 Checking Assets catalog..."
if [ -d "ChromiumIOSv2/Assets.xcassets" ] && \
   [ -d "ChromiumIOSv2/Assets.xcassets/AppIcon.appiconset" ] && \
   [ -d "ChromiumIOSv2/Assets.xcassets/AccentColor.colorset" ]; then
    echo -e "${GREEN}✓${NC} Assets catalog is properly configured"
else
    echo -e "${RED}✗${NC} Assets catalog is missing or incomplete"
    ERRORS=$((ERRORS + 1))
fi

# Check 3: Deployment target
echo "🎯 Checking deployment target..."
if grep -q "IPHONEOS_DEPLOYMENT_TARGET = 14.0;" ChromiumIOSv2.xcodeproj/project.pbxproj; then
    echo -e "${GREEN}✓${NC} Deployment target is set to iOS 14.0"
else
    echo -e "${RED}✗${NC} Deployment target is not set to iOS 14.0"
    ERRORS=$((ERRORS + 1))
fi

# Check 4: Info.plist not in Resources
echo "📄 Checking Info.plist configuration..."
if ! grep -q "Info.plist in Resources" ChromiumIOSv2.xcodeproj/project.pbxproj; then
    echo -e "${GREEN}✓${NC} Info.plist is not in Resources (correct)"
else
    echo -e "${YELLOW}⚠${NC} Info.plist is in Resources (should be removed)"
    WARNINGS=$((WARNINGS + 1))
fi

# Check 5: Source files exist
echo "📝 Checking source files..."
REQUIRED_FILES=(
    "ChromiumIOSv2/AppDelegate.h"
    "ChromiumIOSv2/AppDelegate.m"
    "ChromiumIOSv2/SceneDelegate.h"
    "ChromiumIOSv2/SceneDelegate.m"
    "ChromiumIOSv2/ViewController.h"
    "ChromiumIOSv2/ViewController.m"
    "ChromiumIOSv2/BrowserViewController.h"
    "ChromiumIOSv2/BrowserViewController.m"
    "ChromiumIOSv2/AddressBarController.h"
    "ChromiumIOSv2/AddressBarController.m"
    "ChromiumIOSv2/main.m"
    "ChromiumIOSv2/Info.plist"
    "ChromiumIOSv2/Main.storyboard"
    "ChromiumIOSv2/LaunchScreen.storyboard"
)

MISSING_FILES=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗${NC} Missing: $file"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

if [ $MISSING_FILES -eq 0 ]; then
    echo -e "${GREEN}✓${NC} All required source files exist"
else
    echo -e "${RED}✗${NC} $MISSING_FILES source files are missing"
    ERRORS=$((ERRORS + 1))
fi

# Check 6: No iOS 26 references
echo "🔢 Checking for iOS 26 references..."
if grep -r "iOS 26" ChromiumIOSv2/ 2>/dev/null | grep -v ".xcassets" | grep -v ".png" | grep -v ".jpg"; then
    echo -e "${YELLOW}⚠${NC} Found references to iOS 26 (should be updated to iOS 14+)"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓${NC} No iOS 26 references found"
fi

# Check 7: Build script exists
echo "🔨 Checking build script..."
if [ -f "build.sh" ] && [ -x "build.sh" ]; then
    echo -e "${GREEN}✓${NC} Build script exists and is executable"
else
    if [ -f "build.sh" ]; then
        echo -e "${YELLOW}⚠${NC} Build script exists but is not executable (run: chmod +x build.sh)"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${RED}✗${NC} Build script is missing"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Check 8: Xcode installation (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Checking Xcode installation..."
    if command -v xcodebuild &> /dev/null; then
        XCODE_VERSION=$(xcodebuild -version | head -1)
        echo -e "${GREEN}✓${NC} Xcode is installed: $XCODE_VERSION"
        
        # Check for iOS SDK
        if xcodebuild -showsdks | grep -q "iphoneos"; then
            SDK_VERSION=$(xcodebuild -showsdks | grep iphoneos | tail -1 | awk '{print $NF}')
            echo -e "${GREEN}✓${NC} iOS SDK is available: $SDK_VERSION"
        else
            echo -e "${RED}✗${NC} iOS SDK is not available"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo -e "${RED}✗${NC} Xcode is not installed"
        echo "   Install from: https://apps.apple.com/app/xcode/id497799835"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo -e "${YELLOW}ℹ${NC}  Not running on macOS - skipping Xcode check"
    echo "   This project requires macOS with Xcode to build"
fi

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Validation complete: All checks passed!${NC}"
    echo ""
    echo "The project is ready to build. To create an IPA:"
    echo "  ./build.sh"
    echo ""
    echo "For detailed build instructions, see: BUILD_IPA.md"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Validation complete with $WARNINGS warning(s)${NC}"
    echo ""
    echo "The project should build, but you may want to fix the warnings."
    echo "See above for details."
    exit 0
else
    echo -e "${RED}✗ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    echo ""
    echo "Please fix the errors above before attempting to build."
    echo "For help, see: FIXES_APPLIED.md"
    exit 1
fi
