# Widget Setup Instructions

I've created all the necessary files for the Drip widget extension, but the widget target needs to be added to the Xcode project. Here's how to do it:

## Files Created

1. **DripWidget/DripWidget.swift** - Main widget implementation with square (systemSmall) size
2. **DripWidget/FinancialState.swift** - Shared data model for decoding
3. **DripWidget/Info.plist** - Widget extension info
4. **DripWidget/DripWidget.entitlements** - App Group entitlements
5. **Drip/Utilities/WidgetDataSync.swift** - Syncs data from app to widget
6. **Drip/Drip.entitlements** - Updated with App Group

## Steps to Add Widget Extension in Xcode

### Option 1: Use Xcode GUI (Recommended)

1. Open `Drip.xcodeproj` in Xcode
2. Click on the project in the navigator
3. Click the **+** button at the bottom of the targets list
4. Select **Widget Extension**
5. Configure:
   - **Product Name**: `DripWidget`
   - **Bundle Identifier**: `com.ahmdrghb.Drip.DripWidget`
   - Uncheck "Include Configuration Intent" (we don't need it)
6. Click **Finish**
7. When asked "Activate DripWidget scheme?", click **Activate**

### Option 2: Delete Xcode's Generated Files and Use Our Files

After creating the target in Xcode:

1. In the Project Navigator, **delete** the `DripWidget` folder that Xcode created
2. Right-click on the project and select **Add Files to "Drip"...**
3. Navigate to and select the `DripWidget` folder we created
4. Make sure "Create groups" is selected
5. Under "Add to targets", check **only** `DripWidget` (not the main app)
6. Click **Add**

### Configure Build Settings

1. Select the `DripWidget` target
2. Go to **Build Settings**
3. Search for "App Groups" and ensure `group.com.ahmdrghb.Drip` is listed
4. Go to **Signing & Capabilities**
5. Ensure **App Groups** capability is added with `group.com.ahmdrghb.Drip`

### Configure Main App

1. Select the `Drip` target
2. Go to **Signing & Capabilities**
3. Add **App Groups** capability if not present
4. Add `group.com.ahmdrghb.Drip` to the App Groups

### Add WidgetDataSync.swift to Main App Target

1. Make sure `Drip/Utilities/WidgetDataSync.swift` is included in the main Drip target
2. Check the file's target membership in the File Inspector

## Build and Run

```bash
# Build the app with widget
xcodebuild -scheme Drip -destination 'platform=iOS Simulator,name=iPhone 17 Pro' clean build

# Run the app
xcodebuild -scheme Drip -destination 'platform=iOS Simulator,name=iPhone 17 Pro' run
```

## Testing the Widget

1. Run the app on the simulator
2. Long-press on the home screen
3. Tap the **+** button in the top-left corner
4. Search for "Drip"
5. Add the **Savings Buffer** widget
6. It should show your current savings buffer with a 🛟 icon on a dark background

## Troubleshooting

- If the widget shows $0.00, make sure you've opened the app at least once to sync data
- If the widget doesn't appear in the widget gallery, make sure the DripWidget target builds successfully
- Check that App Groups are properly configured in both targets
