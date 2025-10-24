#!/bin/bash

# Drip Widget Setup Script
# This script provides instructions and verification for adding the widget extension

set -e

PROJECT_DIR="/Users/pxlshpr/Developer/Drip"
PROJECT_FILE="$PROJECT_DIR/Drip.xcodeproj"
WIDGET_DIR="$PROJECT_DIR/DripWidget"

echo "============================================"
echo "Drip Widget Extension Setup"
echo "============================================"
echo ""

# Check if all files exist
echo "✓ Checking widget files..."
FILES=(
    "$WIDGET_DIR/DripWidget.swift"
    "$WIDGET_DIR/FinancialState.swift"
    "$WIDGET_DIR/Info.plist"
    "$WIDGET_DIR/DripWidget.entitlements"
    "$PROJECT_DIR/Drip/Utilities/WidgetDataSync.swift"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✓ $(basename $file)"
    else
        echo "  ✗ MISSING: $file"
        exit 1
    fi
done

echo ""
echo "All widget files are present!"
echo ""
echo "============================================"
echo "Manual Steps Required in Xcode"
echo "============================================"
echo ""
echo "Since Xcode project files cannot be safely edited via script,"
echo "please follow these steps in Xcode:"
echo ""
echo "1. Open Drip.xcodeproj in Xcode:"
echo "   open '$PROJECT_FILE'"
echo ""
echo "2. Add Widget Extension Target:"
echo "   • File → New → Target"
echo "   • Select 'Widget Extension'"
echo "   • Product Name: DripWidget"
echo "   • Bundle ID: com.ahmdrghb.Drip.DripWidget"
echo "   • Uncheck 'Include Configuration Intent'"
echo "   • Click Finish"
echo ""
echo "3. Replace Generated Files:"
echo "   • Delete the DripWidget folder Xcode created"
echo "   • Right-click project → Add Files to 'Drip'"
echo "   • Select the DripWidget folder at: $WIDGET_DIR"
echo "   • Make sure 'Create groups' is selected"
echo "   • Under 'Add to targets', check ONLY 'DripWidget'"
echo ""
echo "4. Configure App Groups (DripWidget target):"
echo "   • Select DripWidget target"
echo "   • Go to 'Signing & Capabilities'"
echo "   • Click '+' and add 'App Groups'"
echo "   • Add group: group.com.ahmdrghb.Drip"
echo ""
echo "5. Configure App Groups (Drip target):"
echo "   • Select Drip target"
echo "   • Go to 'Signing & Capabilities'"
echo "   • Verify 'App Groups' capability exists"
echo "   • Verify group.com.ahmdrghb.Drip is listed"
echo ""
echo "6. Add WidgetDataSync.swift to Drip target:"
echo "   • Select Drip/Utilities/WidgetDataSync.swift"
echo "   • In File Inspector, check 'Drip' under Target Membership"
echo ""
echo "============================================"
echo "After Completing Manual Steps"
echo "============================================"
echo ""
echo "Run this to build and test:"
echo "  xcodebuild -scheme Drip -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build"
echo ""
echo "Or run this script with the 'build' argument:"
echo "  ./setup_widget.sh build"
echo ""

if [ "$1" == "build" ]; then
    echo "Building..."
    echo ""
    xcodebuild -scheme Drip -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
fi

if [ "$1" == "open" ]; then
    echo "Opening Xcode..."
    open "$PROJECT_FILE"
fi
