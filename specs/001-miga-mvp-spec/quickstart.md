# Quickstart Guide: MIGA MVP Development

**Date**: 2025-01-27  
**Target Platform**: iOS 17.0+  
**Development Environment**: Xcode 15.0+, Swift 5.9+

## Prerequisites

- macOS 14.0+ (Sonoma)
- Xcode 15.0+ with iOS 17.0+ SDK
- Swift 5.9+
- CocoaPods or Swift Package Manager (for Firebase)
- Apple Developer Account (for device testing)

## Project Setup

### 1. Clone Repository

```bash
cd /Users/therealdoughy/Desktop/MIGASK
git checkout 001-miga-mvp-spec
```

### 2. Install Dependencies

**Firebase** (using Swift Package Manager):

1. Open `MIGASK.xcodeproj` in Xcode
2. File → Add Package Dependencies
3. Add Firebase SDK: `https://github.com/firebase/firebase-ios-sdk`
4. Select: Firestore, Analytics, Crashlytics
5. Add to MIGASK target

**Alternative** (CocoaPods):

```bash
cd /Users/therealdoughy/Desktop/MIGASK
pod init
# Add Firebase pods to Podfile
pod install
open MIGASK.xcworkspace
```

### 3. Configure Firebase

1. Create Firebase project at https://console.firebase.google.com
2. Add iOS app (Bundle ID: com.miga.app or match your project)
3. Download `GoogleService-Info.plist`
4. Add to Xcode project (MIGASK target, copy if needed)

**Note**: Firebase is optional for MVP (content sync future enhancement). Analytics can be minimal or disabled for local-only MVP.

### 4. Project Structure

Create feature-based module structure:

```
MIGASK/
├── App/
│   └── MIGASKApp.swift
├── Core/
│   ├── Models/
│   ├── Data/
│   ├── Services/
│   └── Utilities/
├── Features/
│   ├── Onboarding/
│   ├── FirstRunExperience/
│   ├── Hub/
│   ├── Gateway/
│   └── Statistics/
└── Resources/
    ├── Assets.xcassets/
    ├── ContentLibrary.plist
    └── Localizable.strings
```

### 5. Core Data Setup

1. File → New → File → Data Model
2. Name: `MIGASKDataModel.xcdatamodeld`
3. Add entities:
   - `UsageEvent` (see data-model.md)
   - `Streak` (see data-model.md)
   - `SelectedApp` (see data-model.md)
   - `MindfulnessContent` (optional, for future migration)

4. Create `PersistenceController.swift`:

```swift
import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    
    init() {
        container = NSPersistentContainer(name: "MIGASKDataModel")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func save() {
        let context = container.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}
```

### 6. Create Content Library

1. File → New → File → Property List
2. Name: `ContentLibrary.plist`
3. Structure:

```xml
<plist>
  <array>
    <dict>
      <key>id</key>
      <string>quote-001</string>
      <key>text</key>
      <string>Your quote text here</string>
      <key>category</key>
      <string>stoicism</string>
      <key>author</key>
      <string>Marcus Aurelius</string>
    </dict>
    <!-- More quotes -->
  </array>
</plist>
```

4. Populate with 50-100 mindfulness quotes
5. Categories: "stoicism", "productivity", "mindfulness", "psychology"

## Development Workflow

### 1. Start with Core Layer

**Models** (Core/Models/):
- `UsageEvent.swift` (Core Data entity)
- `Streak.swift` (Core Data entity)
- `SelectedApp.swift` (Core Data entity)
- `MindfulnessContent.swift` (Codable struct)

**Services** (Core/Services/):
- `StreakCalculator.swift`
- `StatisticsAggregator.swift`
- `URLSchemeLauncher.swift`
- `ContentLibrary.swift`

**Utilities** (Core/Utilities/):
- `ColorExtensions.swift` (MIGA color palette)
- `TypographyStyles.swift` (font styles)

### 2. Build Features in Priority Order

**P1 Features** (must-have for MVP):

1. **Onboarding** (12 screens)
   - Start with `OnboardingContainerView.swift`
   - Build screens 1-11 sequentially
   - Integrate with `OnboardingViewModel`

2. **First Run Experience** (F.R.E.)
   - `FREPhase1View.swift` (app selection)
   - `FREPhase2View.swift` (manual instructions)
   - Integrate with `FREViewModel`

3. **Gateway Screen** (core feature)
   - `GatewayScreenView.swift`
   - `CircularTimerView.swift`
   - Integrate with `GatewayViewModel`

4. **Hub** (main screen)
   - `HubView.swift`
   - `LauncherGridView.swift`
   - Integrate with `HubViewModel`

**P2 Features** (nice-to-have):

5. **Statistics Screen**
   - `StatisticsView.swift`
   - `KPICardView.swift`
   - `TrendsGraphView.swift`
   - Integrate with `StatisticsViewModel`

### 3. Testing Strategy

**Unit Tests** (MIGASKTests/):

```swift
// Example: StreakCalculatorTests.swift
import XCTest
@testable import MIGASK

final class StreakCalculatorTests: XCTestCase {
    func testCalculateStreak_consecutiveDays() {
        let calculator = StreakCalculator()
        let events = createMockEvents() // Helper method
        let streak = calculator.calculateStreak(from: events)
        XCTAssertEqual(streak?.currentDayCount, 3)
    }
}
```

**Preview Testing** (SwiftUI Previews):

```swift
#Preview {
    GatewayScreenView()
        .environmentObject(GatewayViewModel())
}
```

### 4. Iteration Checklist

For each feature:

- [ ] Create ViewModel with `@Observable` macro
- [ ] Implement View with SwiftUI
- [ ] Add Dynamic Type support
- [ ] Add VoiceOver labels
- [ ] Test with SwiftUI Previews
- [ ] Write unit tests for business logic
- [ ] Test on physical device (iOS 17+)
- [ ] Verify light mode only UI
- [ ] Check WCAG 2.1 AA contrast ratios

## Color Palette

Define in `ColorExtensions.swift`:

```swift
extension Color {
    static let migaNavy = Color(hex: "#1A237E")
    static let migaSkyBlue = Color(hex: "#5B84B1")
    static let migaTeal = Color(hex: "#00A9B5")
    static let migaWhite = Color(hex: "#FFFFFF")
}
```

## Typography

Define in `TypographyStyles.swift`:

```swift
extension Font {
    static let migaLargeTitle = Font.system(size: 34, weight: .bold)
    static let migaHeadline = Font.system(size: 22, weight: .semibold)
    static let migaBody = Font.system(size: 17, weight: .regular)
}
```

Use Dynamic Type support:

```swift
Text("Your Mindful Hub.")
    .font(.migaHeadline)
    .dynamicTypeSize(...dynamicTypeSize)
```

## Common URL Schemes

Define in `URLSchemeLauncher.swift`:

```swift
enum AppURLScheme: String {
    case instagram = "instagram://"
    case tiktok = "tiktok://"
    case twitter = "twitter://"
    case reddit = "reddit://"
    case youtube = "youtube://"
}
```

## Build Configuration

### Debug
- Enable verbose logging
- Disable Firebase Analytics (or use debug mode)
- Show Core Data SQL debugging

### Release
- Disable verbose logging
- Enable Firebase Crashlytics
- Optimize Core Data queries
- Test performance (< 1s load time)

## Device Testing

**Required Devices**:
- iPhone 15 Pro (iOS 17.0+)
- iPhone 14 (iOS 17.0+)
- iPhone SE (iOS 17.0+) - accessibility testing

**Test Scenarios**:
1. First launch → Onboarding → F.R.E. → Hub
2. Gateway Screen timer countdown
3. "Exit to Focus" → celebration animation
4. "Deepen the Pause" → new quote loads
5. Statistics screen aggregates
6. Streak calculation accuracy
7. App launch via URL scheme

## Performance Targets

- **Main screen load**: < 1 second
- **Gateway Screen render**: < 500ms
- **Animations**: 60fps
- **Crash-free rate**: ≥ 99%

## Debugging Tips

**Core Data**:
```swift
// Enable SQL debugging
let context = PersistenceController.shared.container.viewContext
context.shouldDeleteInaccessibleFaults = true
```

**View Model State**:
```swift
// Add print statements in ViewModel
print("Timer progress: \(timerProgress)")
```

**Firebase Analytics** (debug mode):
```swift
Analytics.setAnalyticsCollectionEnabled(true)
```

## Next Steps

1. Review `data-model.md` for Core Data entity definitions
2. Review `contracts/` for ViewModel and Service interfaces
3. Start with Core layer (Models, Services, Utilities)
4. Build P1 features in priority order
5. Test each feature before moving to next

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui/)
- [Core Data Programming Guide](https://developer.apple.com/documentation/coredata)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SF Symbols App](https://developer.apple.com/sf-symbols/)
- [Firebase iOS SDK](https://firebase.google.com/docs/ios/setup)

## Summary

This quickstart provides the foundation for MIGA MVP development. Follow the feature priority order, implement MVVM architecture, and test on physical devices. All data is local-only with no remote persistence required for MVP.

