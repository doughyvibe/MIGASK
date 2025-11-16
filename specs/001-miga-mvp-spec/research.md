# Research & Technical Decisions: MIGA MVP

**Date**: 2025-01-27  
**Status**: Complete  
**Note**: Context7 unavailable during research phase. Decisions based on current iOS/SwiftUI best practices and Apple Human Interface Guidelines.

## iOS Human Interface Guidelines (HIG) Compliance

### Decision: Follow iOS 17+ HIG Principles
**Rationale**: Apple's HIG ensures apps feel native, intuitive, and accessible. For iOS 17+, key principles include:
- **Clarity**: Use SF Symbols, system fonts (SF Pro), and native components
- **Deference**: Content takes priority; UI supports content without competing
- **Depth**: Use visual layers, motion, and transitions to convey hierarchy

**Alternatives considered**: 
- Custom icon sets → Rejected: SF Symbols provide consistency and accessibility
- Custom typography → Rejected: System Dynamic Type ensures accessibility and familiarity
- Heavy UI customization → Rejected: Native feel requires deference to iOS design language

### Decision: Use Dynamic Type for All Text
**Rationale**: Dynamic Type is mandatory for accessibility (WCAG 2.1 AA) and supports user preference scaling. SwiftUI `Text` with system fonts automatically supports Dynamic Type.

**Implementation**: Use `.font(.system(size:style:))` or semantic styles (`.title`, `.headline`, `.body`) for all text. Gateway Screen quotes use `.largeTitle` or custom large size with `.dynamicTypeSize()` support.

### Decision: Strict Light Mode UI Only
**Rationale**: Constitution requirement for calm aesthetic (#FFFFFF backgrounds). While iOS 17+ supports automatic dark mode via `.colorScheme(.light)`, MVP explicitly enforces light mode.

**Implementation**: Apply `.preferredColorScheme(.light)` at app root level to override system preference.

## SF Symbols Integration

### Decision: Use SF Symbols for App Icons in Launcher Grid
**Rationale**: SF Symbols provide consistent, scalable, accessible icons that automatically adapt to Dynamic Type and system settings. iOS 17+ includes extensive symbol library.

**Selected Symbols**:
- Social apps: Use system-provided or custom SF Symbols variants
- Navigation: `house.fill` for Hub, `chart.bar.fill` for Statistics
- Actions: `xmark.circle.fill` for Exit, `arrow.right.circle.fill` for Proceed
- Timer: `clock.fill` or custom circular progress indicator

**Alternatives considered**:
- Custom icon assets → Rejected: SF Symbols provide better accessibility and system integration
- Third-party icon libraries → Rejected: Adds dependency, potential licensing issues

**Implementation**: Use `Image(systemName:)` with SF Symbol names. For custom symbols, use SF Symbols app to create compatible variants.

## SwiftUI Best Practices & iOS 17+ Features

### Decision: Use Observable Macro for ViewModels
**Rationale**: iOS 17+ introduces `@Observable` macro, replacing `ObservableObject` and `@Published`. Provides cleaner syntax and better performance.

**Implementation**:
```swift
@Observable
final class GatewayViewModel {
    var timerProgress: Double = 1.0
    var isProceedEnabled: Bool = false
    // ...
}
```

**Alternatives considered**:
- `ObservableObject` with `@Published` → Rejected: `@Observable` is more modern and efficient for iOS 17+
- Manual Combine publishers → Rejected: `@Observable` provides automatic observation

### Decision: Use SwiftUI NavigationStack for Onboarding Flow
**Rationale**: iOS 16+ `NavigationStack` (replaces `NavigationView`) provides programmatic navigation and better state management for multi-screen flows.

**Implementation**: 
```swift
NavigationStack(path: $viewModel.navigationPath) {
    // Onboarding screens with navigation
}
```

**Alternatives considered**:
- Tab-based navigation → Rejected: Onboarding requires sequential flow, not tabbed
- Custom container → Rejected: `NavigationStack` provides native back button and transitions

### Decision: Use Core Data with SwiftUI @FetchRequest
**Rationale**: Core Data provides robust local persistence. SwiftUI's `@FetchRequest` property wrapper simplifies data fetching in views. Constitution requires local-only storage.

**Implementation**:
```swift
@FetchRequest(
    sortDescriptors: [NSSortDescriptor(keyPath: \UsageEvent.timestamp, ascending: false)]
) private var usageEvents: FetchedResults<UsageEvent>
```

**Alternatives considered**:
- Realm → Rejected: Core Data is native, no external dependency
- SQLite directly → Rejected: Core Data provides better SwiftUI integration and migration support
- UserDefaults → Rejected: Only suitable for small preferences, not complex data models

### Decision: Use Timer with Combine for Gateway Countdown
**Rationale**: Swift's `Timer.publish()` with Combine provides reactive countdown updates. Integrates well with SwiftUI `@State` and ViewModels.

**Implementation**:
```swift
Timer.publish(every: 0.1, on: .main, in: .common)
    .autoconnect()
    .sink { [weak self] _ in
        self?.updateTimer()
    }
```

**Alternatives considered**:
- DispatchSourceTimer → Rejected: Combine provides better SwiftUI integration
- CADisplayLink → Rejected: Overkill for 0.1s updates; Timer is sufficient

## Accessibility Implementation

### Decision: Implement VoiceOver Labels for All Interactive Elements
**Rationale**: WCAG 2.1 AA compliance and Constitution requirement. iOS VoiceOver is primary screen reader.

**Implementation**: Use `.accessibilityLabel()` and `.accessibilityHint()` modifiers:
```swift
Button("Exit to Focus") {
    viewModel.exitToFocus()
}
.accessibilityLabel("Exit to Focus")
.accessibilityHint("Closes MIGA and returns to Home Screen, celebrating your mindful choice")
```

### Decision: Support Dynamic Type Scaling (up to XXXL)
**Rationale**: Accessibility requirement. Users may need up to largest Dynamic Type size (Accessibility sizes).

**Implementation**: Test all views with `.environment(\.dynamicTypeSize, .accessibility5)` in previews. Ensure text truncates gracefully or layouts adapt.

## Performance Optimization

### Decision: Pre-bundle Mindfulness Content as Plist/JSON
**Rationale**: Constitution requires offline-capable, pre-bundled content. Plist/JSON provides easy parsing and filtering by interest tags.

**Implementation**: Create `ContentLibrary.plist` or `ContentLibrary.json` in Resources. Parse at app launch into memory. Filter by user-selected interests for Gateway Screen.

**Structure**:
```swift
struct MindfulnessContent: Codable {
    let id: String
    let text: String
    let category: String  // maps to interest tags
    let author: String?
}
```

**Alternatives considered**:
- Core Data entities → Rejected: Overkill for read-only content
- Remote API → Rejected: Must be fully offline-capable

### Decision: Lazy Loading for Statistics Screen
**Rationale**: Statistics aggregates may require processing large datasets. Lazy loading prevents blocking UI.

**Implementation**: Use `@State` with computed properties that calculate on-demand. Cache results when data hasn't changed.

## URL Scheme Handling

### Decision: Use URL Schemes for Social App Launch
**Rationale**: iOS native mechanism for inter-app communication. Each social app exposes custom URL scheme.

**Implementation**:
```swift
func launchApp(urlScheme: String) {
    guard let url = URL(string: urlScheme) else { return }
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    } else {
        // Handle app not installed
    }
}
```

**Common URL Schemes**:
- Instagram: `instagram://`
- TikTok: `tiktok://`
- X (Twitter): `twitter://` or `tweetbot://`
- Reddit: `reddit://`
- YouTube: `youtube://`

**Alternatives considered**:
- Universal Links → Rejected: Requires server setup, not needed for simple launch
- App Intents → Rejected: iOS 16+ only, more complex for simple launch use case

## State Management & F.R.E. Persistence

### Decision: Use UserDefaults for F.R.E. Completion State
**Rationale**: Simple boolean/string flags don't need Core Data. UserDefaults is appropriate for lightweight preferences.

**Implementation**:
```swift
enum FREPhase: String {
    case notStarted
    case phase1Complete
    case phase2Complete
}

UserDefaults.standard.set(FREPhase.phase1Complete.rawValue, forKey: "frePhase")
```

**Alternatives considered**:
- Core Data → Rejected: Overkill for simple state flag
- @AppStorage → Rejected: UserDefaults provides more explicit control

## Animation & Visual Feedback

### Decision: Use SwiftUI Native Animations for Celebration
**Rationale**: SwiftUI `.animation()` modifiers provide smooth, performant animations. Constitution requires celebration animations for "Exit to Focus".

**Implementation**:
```swift
.animation(.spring(response: 0.6, dampingFraction: 0.8), value: showCelebration)
.scaleEffect(showCelebration ? 1.1 : 1.0)
```

**Alternatives considered**:
- UIKit animations → Rejected: SwiftUI animations are declarative and integrate better
- Lottie files → Rejected: Adds dependency; native animations are sufficient

## Testing Strategy

### Decision: XCTest for Unit Tests, SwiftUI Preview for UI Testing
**Rationale**: XCTest is native iOS testing framework. SwiftUI Previews provide rapid UI iteration. Constitution requires unit tests for core logic.

**Implementation**:
- Unit tests for `StreakCalculator`, `StatisticsAggregator`, timer logic
- Preview providers for all SwiftUI views
- Manual UI testing via TestFlight (MVP scope doesn't include automated UI tests)

**Alternatives considered**:
- Quick/Nimble → Rejected: XCTest is native, no external dependency
- XCUITest → Rejected: Overkill for MVP; manual testing sufficient

## Firebase Integration (Optional)

### Decision: Firebase Analytics Only (No Firestore for User Data)
**Rationale**: Constitution requires no remote user data storage. Analytics provides behavioral validation only. Content sync via Firestore is optional future enhancement.

**Implementation**: Configure Firebase Analytics with minimal events. Ensure no PII in event parameters.

## Summary of Key Decisions

| Category | Decision | Rationale |
|----------|----------|-----------|
| UI Framework | SwiftUI with iOS 17+ features | Native, modern, declarative |
| State Management | `@Observable` macro | iOS 17+ standard, efficient |
| Local Storage | Core Data + UserDefaults | Robust persistence + simple prefs |
| Content | Pre-bundled Plist/JSON | Offline-capable, easy filtering |
| Icons | SF Symbols | Accessibility, consistency |
| Navigation | NavigationStack | Modern, programmatic control |
| Timer | Timer.publish() with Combine | Reactive, SwiftUI-friendly |
| Accessibility | Dynamic Type + VoiceOver | WCAG 2.1 AA compliance |
| Testing | XCTest + SwiftUI Previews | Native, rapid iteration |

**All NEEDS CLARIFICATION items resolved. Ready for Phase 1 design.**

