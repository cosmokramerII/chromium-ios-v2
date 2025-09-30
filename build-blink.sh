#!/bin/bash
# Build script for Chromium iOS with Blink integration
# This script assumes you have the full Chromium source tree

set -e

echo "==================================="
echo "Chromium iOS Blink Integration Build"
echo "==================================="

# Configuration
CHROMIUM_SRC="${CHROMIUM_SRC:-$HOME/chromium/src}"
BUILD_DIR="out/ios"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Chromium source exists
if [ ! -d "$CHROMIUM_SRC" ]; then
    echo -e "${RED}Error: Chromium source not found at $CHROMIUM_SRC${NC}"
    echo "Please set CHROMIUM_SRC environment variable to your Chromium source directory"
    echo "Or fetch Chromium source first:"
    echo "  mkdir ~/chromium && cd ~/chromium"
    echo "  fetch ios"
    exit 1
fi

echo -e "${GREEN}✓ Found Chromium source at $CHROMIUM_SRC${NC}"

# Check for required tools
for tool in gn ninja python3; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}Error: $tool not found${NC}"
        echo "Please install depot_tools and ensure it's in your PATH"
        exit 1
    fi
done

echo -e "${GREEN}✓ All required tools found${NC}"

# Copy integration files to Chromium source
echo ""
echo "Copying integration files..."
mkdir -p "$CHROMIUM_SRC/ios/chrome/browser/web"
cp -v "$PROJECT_DIR/ios/chrome/browser/web"/*.{h,mm} "$CHROMIUM_SRC/ios/chrome/browser/web/" || true
cp -v "$PROJECT_DIR/ios/chrome/browser/web/BUILD.gn" "$CHROMIUM_SRC/ios/chrome/browser/web/"

echo -e "${GREEN}✓ Integration files copied${NC}"

# Copy args.gn
echo ""
echo "Configuring build..."
mkdir -p "$CHROMIUM_SRC/$BUILD_DIR"
cp -v "$PROJECT_DIR/out/ios/args.gn" "$CHROMIUM_SRC/$BUILD_DIR/"

echo -e "${GREEN}✓ Build configuration ready${NC}"

# Generate build files
echo ""
echo "Generating build files with GN..."
cd "$CHROMIUM_SRC"
gn gen "$BUILD_DIR"

echo -e "${GREEN}✓ Build files generated${NC}"

# Build
echo ""
echo "Building Chromium iOS with Blink..."
echo "This will take 2-4 hours on first build..."
echo ""

ninja -C "$BUILD_DIR" chrome_public_bundle

echo ""
echo -e "${GREEN}✓ Build complete!${NC}"

# Build the iOS app
echo ""
echo "Building iOS app..."
cd "$PROJECT_DIR/ChromiumApp"

xcodebuild -project ChromiumApp.xcodeproj \
           -scheme ChromiumApp \
           -configuration Release \
           -sdk iphoneos \
           -archivePath build/ChromiumApp.xcarchive \
           FRAMEWORK_SEARCH_PATHS="$CHROMIUM_SRC/$BUILD_DIR" \
           HEADER_SEARCH_PATHS="$CHROMIUM_SRC" \
           archive

echo ""
echo -e "${GREEN}✓ App built successfully${NC}"

# Export IPA
echo ""
echo "Exporting IPA..."
xcodebuild -exportArchive \
           -archivePath build/ChromiumApp.xcarchive \
           -exportPath build \
           -exportOptionsPlist ExportOptions.plist

cp build/ChromiumApp.ipa "$PROJECT_DIR/chromium-blink.ipa"

echo ""
echo -e "${GREEN}==================================="
echo "Build Complete!"
echo "===================================${NC}"
echo ""
echo "Output: chromium-blink.ipa"
echo ""
echo "Next steps:"
echo "1. Sign the app with your developer certificate"
echo "2. Install via Xcode or AltStore"
echo "3. Trust the developer profile on your device"
echo ""
