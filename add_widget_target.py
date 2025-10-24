#!/usr/bin/env python3
"""
Script to add DripWidget extension target to Drip.xcodeproj
Requires: pip install pbxproj
"""

import sys
import os

try:
    from pbxproj import XcodeProject
except ImportError:
    print("ERROR: pbxproj module not found")
    print("Install it with: pip3 install pbxproj")
    sys.exit(1)

def add_widget_target():
    project_path = '/Users/pxlshpr/Developer/Drip/Drip.xcodeproj/project.pbxproj'

    print(f"Opening project: {project_path}")
    project = XcodeProject.load(project_path)

    # Add widget extension target
    print("Adding DripWidget extension target...")

    # Create the widget target
    widget_target = project.add_target(
        name='DripWidget',
        target_type='app_extension',
        platform_name='iOS'
    )

    # Set bundle identifier
    project.set_flags('PRODUCT_BUNDLE_IDENTIFIER', 'com.ahmdrghb.Drip.DripWidget', target_name='DripWidget')

    # Add files to widget target
    widget_files = [
        'DripWidget/DripWidget.swift',
        'DripWidget/FinancialState.swift',
        'DripWidget/Info.plist',
    ]

    for file_path in widget_files:
        print(f"Adding file: {file_path}")
        project.add_file(file_path, target_name='DripWidget')

    # Add entitlements
    project.set_flags('CODE_SIGN_ENTITLEMENTS', 'DripWidget/DripWidget.entitlements', target_name='DripWidget')

    # Set deployment target
    project.set_flags('IPHONEOS_DEPLOYMENT_TARGET', '17.0', target_name='DripWidget')

    # Add WidgetKit framework
    project.add_framework('WidgetKit.framework', target_name='DripWidget')
    project.add_framework('SwiftUI.framework', target_name='DripWidget')

    # Save the project
    print("Saving project...")
    project.save()

    print("✅ Successfully added DripWidget target!")
    print("\nNext steps:")
    print("1. Open Drip.xcodeproj in Xcode")
    print("2. Build the project with: xcodebuild -scheme Drip -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build")
    print("3. Enable App Groups capability in both Drip and DripWidget targets")

if __name__ == '__main__':
    try:
        add_widget_target()
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
