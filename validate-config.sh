#!/bin/bash
# Validation script for Chromium iOS Blink integration
# Checks that all required files and configurations are in place

set -e

echo "===================================="
echo "Chromium iOS Blink Configuration Validator"
echo "===================================="
echo ""

ERRORS=0
WARNINGS=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

check_file() {
  if [ -f "$1" ]; then
    echo -e "${GREEN}✓${NC} Found: $1"
    return 0
  else
    echo -e "${RED}✗${NC} Missing: $1"
    ERRORS=$((ERRORS + 1))
    return 1
  fi
}

check_dir() {
  if [ -d "$1" ]; then
    echo -e "${GREEN}✓${NC} Found directory: $1"
    return 0
  else
    echo -e "${RED}✗${NC} Missing directory: $1"
    ERRORS=$((ERRORS + 1))
    return 1
  fi
}

warn_message() {
  echo -e "${YELLOW}⚠${NC} Warning: $1"
  WARNINGS=$((WARNINGS + 1))
}

info_message() {
  echo -e "${BLUE}ℹ${NC} Info: $1"
}

echo "Checking GN build configuration..."
check_file ".gn"
check_file "BUILD.gn"
check_file "out/ios/args.gn"

echo ""
echo "Checking C++ bridge layer files..."
check_dir "ios/chrome/browser/web"
check_file "ios/chrome/browser/web/BUILD.gn"
check_file "ios/chrome/browser/web/blink_web_view_bridge.h"
check_file "ios/chrome/browser/web/blink_web_view_bridge.mm"
check_file "ios/chrome/browser/web/blink_web_view_controller.h"
check_file "ios/chrome/browser/web/blink_web_view_controller.mm"
check_file "ios/chrome/browser/web/metal_compositor.h"
check_file "ios/chrome/browser/web/metal_compositor.mm"
check_file "ios/chrome/browser/web/web_state.h"
check_file "ios/chrome/browser/web/web_state.mm"

echo ""
echo "Checking iOS application files..."
check_dir "ChromiumApp"
check_file "ChromiumApp/Entitlements.plist"
check_file "ChromiumApp/ExportOptions.plist"
check_file "ChromiumApp/ChromiumApp/Info.plist"
check_file "ChromiumApp/ChromiumApp/ViewController.swift"

echo ""
echo "Checking build scripts..."
check_file "build-blink.sh"
if [ -f "build-blink.sh" ]; then
  if [ -x "build-blink.sh" ]; then
    echo -e "${GREEN}✓${NC} build-blink.sh is executable"
  else
    warn_message "build-blink.sh is not executable (run: chmod +x build-blink.sh)"
  fi
fi

echo ""
echo "Checking documentation..."
check_file "README.md"
check_file "BLINK_INTEGRATION.md"
check_file "BUILDING.md"

echo ""
echo "Validating GN args.gn configuration..."
if [ -f "out/ios/args.gn" ]; then
  # Check for required settings
  if grep -q "target_os.*=.*\"ios\"" out/ios/args.gn; then
    echo -e "${GREEN}✓${NC} target_os = \"ios\" configured"
  else
    echo -e "${RED}✗${NC} target_os = \"ios\" not found in args.gn"
    ERRORS=$((ERRORS + 1))
  fi
  
  if grep -q "use_blink.*=.*true" out/ios/args.gn; then
    echo -e "${GREEN}✓${NC} use_blink = true configured"
  else
    echo -e "${RED}✗${NC} use_blink = true not found in args.gn"
    ERRORS=$((ERRORS + 1))
  fi
  
  if grep -q "use_metal.*=.*true" out/ios/args.gn; then
    echo -e "${GREEN}✓${NC} use_metal = true configured"
  else
    warn_message "use_metal = true not found in args.gn"
  fi
  
  if grep -q "enable_webkit.*=.*false" out/ios/args.gn; then
    echo -e "${GREEN}✓${NC} enable_webkit = false configured"
  else
    warn_message "enable_webkit = false not found in args.gn"
  fi
fi

echo ""
echo "Validating Info.plist entitlements..."
if [ -f "ChromiumApp/ChromiumApp/Info.plist" ]; then
  if grep -q "com.apple.security.cs.allow-jit" ChromiumApp/ChromiumApp/Info.plist; then
    echo -e "${GREEN}✓${NC} JIT entitlement found"
  else
    warn_message "JIT entitlement not found in Info.plist"
  fi
  
  if grep -q "com.apple.developer.metal" ChromiumApp/ChromiumApp/Info.plist; then
    echo -e "${GREEN}✓${NC} Metal entitlement found"
  else
    warn_message "Metal entitlement not found in Info.plist"
  fi
fi

echo ""
echo "Checking for syntax errors in C++ files..."
for file in ios/chrome/browser/web/*.mm ios/chrome/browser/web/*.h; do
  if [ -f "$file" ]; then
    # Basic syntax check - look for matching braces
    open_braces=$(grep -o '{' "$file" | wc -l)
    close_braces=$(grep -o '}' "$file" | wc -l)
    if [ "$open_braces" -eq "$close_braces" ]; then
      echo -e "${GREEN}✓${NC} Syntax check passed: $(basename $file)"
    else
      echo -e "${RED}✗${NC} Brace mismatch in: $(basename $file) (open: $open_braces, close: $close_braces)"
      ERRORS=$((ERRORS + 1))
    fi
  fi
done

echo ""
echo "Checking unit tests..."
check_file "ios/chrome/browser/web/blink_web_view_bridge_unittest.mm"

echo ""
echo "===================================="
echo "Validation Summary"
echo "===================================="

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✓ All checks passed!${NC}"
  echo ""
  info_message "Configuration is ready for Chromium integration"
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠ Validation completed with $WARNINGS warning(s)${NC}"
  echo ""
  info_message "Configuration is functional but has minor issues"
  exit 0
else
  echo -e "${RED}✗ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
  echo ""
  echo "Please fix the errors above before proceeding."
  exit 1
fi
