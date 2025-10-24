# Drip Savings Buffer Widget - Quick Start

I've created a square widget that displays your savings buffer amount with a 🛟 icon on a dark background.

## What's Been Created

All widget files have been created in the `DripWidget/` folder:
- **DripWidget.swift** - Widget implementation (systemSmall/square size)
- **FinancialState.swift** - Shared data model
- **Info.plist** & **DripWidget.entitlements** - Configuration files

The main app has been updated:
- **WidgetDataSync.swift** - Automatically syncs data to widget
- **FinanceStore.swift** - Now triggers widget updates when state changes
- **Drip.entitlements** - Added App Group support

## Quick Setup (5 minutes)

### Option 1: Automated Helper Script

```bash
cd /Users/pxlshpr/Developer/Drip
./setup_widget.sh open
```

This will open Xcode and show you the exact steps needed.

### Option 2: Manual Steps

1. **Open Xcode:**
   ```bash
   open Drip.xcodeproj
   ```

2. **Add Widget Extension Target:**
   - `File` → `New` → `Target`
   - Choose `Widget Extension`
   - Name: `DripWidget`
   - Bundle ID: `com.ahmdrghb.Drip.DripWidget`
   - Uncheck "Include Configuration Intent"
   - Click `Finish` and `Activate` the scheme

3. **Use Our Widget Files:**
   - **Delete** the `DripWidget` folder Xcode auto-generated
   - Right-click project → `Add Files to "Drip"...`
   - Select the `DripWidget` folder
   - Make sure:
     - ✓ "Create groups" is selected
     - ✓ Under "Add to targets", check **ONLY** `DripWidget`
   - Click `Add`

4. **Configure App Groups (Both Targets):**

   **For DripWidget target:**
   - Select `DripWidget` target
   - Go to `Signing & Capabilities` tab
   - Click `+ Capability` → Add `App Groups`
   - Check `group.com.ahmdrghb.Drip`

   **For Drip target:**
   - Select `Drip` target
   - Go to `Signing & Capabilities` tab
   - Verify `App Groups` capability exists with `group.com.ahmdrghb.Drip`
   - (It should already be there - I added it to the entitlements file)

5. **Add Widget Sync to Main App:**
   - Select `Drip/Utilities/WidgetDataSync.swift` in navigator
   - In File Inspector (right panel), under "Target Membership"
   - Ensure `Drip` is checked

## Build & Test

```bash
cd /Users/pxlshpr/Developer/Drip
xcodebuild -scheme Drip -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build
```

Or use the helper script:
```bash
./setup_widget.sh build
```

## Using the Widget

1. Run the app on the simulator first (this syncs the data)
2. Go to the simulator home screen
3. Long-press on home screen → Tap `+` (top-left)
4. Search for "Drip"
5. Select the "Savings Buffer" widget
6. Add it to your home screen

The widget is **square-sized** (systemSmall) and shows:
- 🛟 Icon at the top
- "Savings Buffer" label
- Your current main savings amount in green
- Dark blue/purple background

## Widget Features

- **Auto-updates**: Refreshes every 15 minutes
- **Real-time sync**: Updates whenever you make changes in the app
- **App Group sharing**: Data shared via `group.com.ahmdrghb.Drip`
- **Square size only**: Designed specifically for systemSmall family

## Troubleshooting

**Widget shows $0.00?**
- Open the main app at least once to sync data
- Check that App Groups are configured in both targets

**Widget doesn't appear in gallery?**
- Make sure DripWidget target builds without errors
- Try cleaning build folder: `Product` → `Clean Build Folder` in Xcode

**Build errors?**
- Verify WidgetDataSync.swift is added to Drip target
- Check that all widget files are added to DripWidget target
- Ensure App Groups capability is present in both targets

## Technical Details

The widget reads from `UserDefaults(suiteName: "group.com.ahmdrghb.Drip")` where the main app writes the complete `FinancialState` JSON. This allows the widget to access `mainSavings` (the buffer amount) without needing SwiftData or CloudKit access.

Every time the app modifies the financial state, it automatically calls `WidgetDataSync.syncToWidget()` which updates the shared UserDefaults and tells WidgetKit to reload the timeline.
