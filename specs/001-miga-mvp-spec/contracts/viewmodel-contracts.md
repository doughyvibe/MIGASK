# ViewModel Contracts: MIGA MVP

**Date**: 2025-01-27  
**Status**: Complete

## Overview

ViewModels follow MVVM pattern with `@Observable` macro (iOS 17+). Each ViewModel exposes state and actions for its corresponding View. Contracts define the interface between Views and business logic.

## GatewayViewModel

**Purpose**: Manages Gateway Screen state and timer logic.

### State Properties

```swift
@Observable
final class GatewayViewModel {
    // Timer state
    var timerProgress: Double = 1.0  // 0.0 to 1.0
    var timeRemaining: TimeInterval = 30.0  // seconds
    var isTimerComplete: Bool = false
    
    // Button states
    var isProceedEnabled: Bool = false
    var isExitEnabled: Bool = true
    var isDeepenEnabled: Bool = true
    
    // Content
    var mindfulnessQuote: String = ""
    var targetAppName: String = ""
    
    // Actions
    var onExitTapped: () -> Void
    var onDeepenTapped: () -> Void
    var onProceedTapped: () -> Void
}
```

### Methods

```swift
// Initialize Gateway Screen for target app
func initialize(for app: SelectedApp, timerDuration: TimeInterval)

// Start countdown timer
func startTimer()

// Stop timer (cleanup)
func stopTimer()

// Handle Exit to Focus action
func handleExitToFocus()

// Handle Deepen the Pause action
func handleDeepenPause()

// Handle Proceed to App action
func handleProceedToApp()

// Load new mindfulness quote
private func loadQuote(for interests: [String])
```

### Events

- **Timer Tick**: Updates `timerProgress` and `timeRemaining` every 0.1 seconds
- **Timer Complete**: Sets `isTimerComplete = true`, enables `isProceedEnabled`
- **Quote Loaded**: Updates `mindfulnessQuote` with filtered content

### Dependencies

- `ContentLibrary` (pre-bundled content filtering)
- `URLSchemeLauncher` (app launch)
- `PersistenceController` (save UsageEvent)

## HubViewModel

**Purpose**: Manages Hub Screen state and app launcher.

### State Properties

```swift
@Observable
final class HubViewModel {
    // Hub greeting
    var greeting: String = "Your Mindful Hub."
    
    // Streak banner
    var streakCount: Int = 0
    var showStreakBanner: Bool = false
    var streakMessage: String = ""
    
    // Selected apps
    @Published var selectedApps: [SelectedApp] = []
    
    // Navigation
    var navigationPath: NavigationPath = NavigationPath()
    
    // F.R.E. state
    var shouldShowFRE: Bool = false
    var frePhase: FREPhase = .notStarted
}
```

### Methods

```swift
// Load Hub data on appear
func loadHubData()

// Calculate and update streak
func updateStreak()

// Launch app (triggers Gateway Screen)
func launchApp(_ app: SelectedApp)

// Navigate to Statistics
func navigateToStatistics()

// Check if F.R.E. needed
func checkFREStatus()

// Handle F.R.E. completion
func completeFRE()
```

### Events

- **Hub Appear**: Loads streak, selected apps, checks F.R.E. status
- **Streak Updated**: Updates streak banner visibility and message
- **App Selected**: Triggers Gateway Screen for selected app

### Dependencies

- `StreakCalculator` (streak calculation)
- `@FetchRequest` (selected apps)
- `UserDefaults` (F.R.E. state, preferences)

## StatisticsViewModel

**Purpose**: Manages Statistics Screen data and aggregates.

### State Properties

```swift
@Observable
final class StatisticsViewModel {
    // KPI metrics
    var hoursReclaimed: Double = 0.0
    var totalConsciousExits: Int = 0
    var averagePauseTime: TimeInterval = 0.0
    var intentionalityScore: Double = 0.0  // 0.0 to 1.0
    
    // Trend data
    var dailyTrends: [DailyTrend] = []  // Last 30 days
    var isLoading: Bool = false
    
    // Header
    var headerTitle: String = "Proof It's Working."
}
```

### Methods

```swift
// Load statistics data
func loadStatistics()

// Calculate KPI metrics
private func calculateKPIs()

// Generate trend data for last 30 days
private func generateTrends()

// Refresh statistics (pull-to-refresh)
func refreshStatistics()
```

### Events

- **Statistics Load**: Fetches UsageEvent records, calculates aggregates
- **Trend Update**: Updates `dailyTrends` array for chart display
- **Refresh**: Recalculates all metrics

### Dependencies

- `StatisticsAggregator` (metric calculations)
- `@FetchRequest` (usage events)
- `TrendsGraphView` (visualization)

## OnboardingViewModel

**Purpose**: Manages 12-screen onboarding flow.

### State Properties

```swift
@Observable
final class OnboardingViewModel {
    // Current screen index (0-11)
    var currentScreenIndex: Int = 0
    
    // Navigation path
    var navigationPath: NavigationPath = NavigationPath()
    
    // Screen 7: Determination
    var determinationLevel: Int = 5  // 1-10 slider
    
    // Screen 8: Content Interest
    var selectedInterests: [String] = []
    var availableInterests: [String] = ["Stoicism", "Productivity", "Mindfulness", "Psychology"]
    
    // Completion
    var isComplete: Bool = false
}
```

### Methods

```swift
// Progress to next screen
func nextScreen()

// Go to previous screen
func previousScreen()

// Update determination level (Screen 7)
func updateDeterminationLevel(_ level: Int)

// Toggle interest selection (Screen 8)
func toggleInterest(_ interest: String)

// Complete onboarding
func completeOnboarding()

// Save onboarding data
private func saveOnboardingData()
```

### Events

- **Screen Progress**: Updates `currentScreenIndex`, pushes to `navigationPath`
- **Interest Toggled**: Updates `selectedInterests` array
- **Completion**: Saves data, navigates to Hub

### Dependencies

- `UserDefaults` (save determination level, interests)
- `NavigationStack` (onboarding flow)

## FREViewModel

**Purpose**: Manages First Run Experience (Phase 1 & 2).

### State Properties

```swift
@Observable
final class FREViewModel {
    // Current phase
    var currentPhase: FREPhase = .notStarted
    
    // Phase 1: App Selection
    var availableApps: [AppOption] = []  // Pre-configured + system apps
    var selectedApps: [SelectedApp] = []
    var isAppSelectionComplete: Bool = false
    
    // Phase 2: Manual Instructions
    var showInstructions: Bool = false
    var isPhase2Complete: Bool = false
    
    // Navigation
    var navigationPath: NavigationPath = NavigationPath()
}
```

### Methods

```swift
// Initialize F.R.E. based on saved state
func initialize()

// Phase 1.1: Show context & goal
func startPhase1()

// Phase 1.2: Show app selection
func showAppSelection()

// Toggle app selection
func toggleAppSelection(_ app: AppOption)

// Complete Phase 1
func completePhase1()

// Phase 2.1: Show manual instructions
func showPhase2Instructions()

// Phase 2.2: Show confirmation
func showPhase2Confirmation()

// Complete Phase 2
func completePhase2()

// Save selected apps to Core Data
private func saveSelectedApps()
```

### Events

- **Phase Start**: Displays appropriate phase screen
- **App Selected**: Updates `selectedApps`, enables proceed button
- **Phase Complete**: Updates `UserDefaults` state, progresses to next phase

### Dependencies

- `PersistenceController` (save SelectedApp entities)
- `UserDefaults` (save F.R.E. phase state)
- `AppDetection` (check installed apps)

## Contract Guarantees

### Thread Safety

- ViewModels use `@MainActor` for state updates
- Background operations (Core Data saves) return to main thread for UI updates
- Timer updates occur on main queue

### Error Handling

- All ViewModel methods handle errors gracefully
- Errors logged to console (Firebase Crashlytics in production)
- User-facing errors shown via alert or toast

### State Consistency

- ViewModel state always reflects current data model
- `@FetchRequest` updates automatically trigger ViewModel refresh
- UserDefaults changes sync with ViewModel state

## Summary

ViewModels provide clean separation between Views and business logic. Each ViewModel follows `@Observable` pattern for SwiftUI integration. Contracts ensure consistent interface across features while maintaining MVVM architecture.

