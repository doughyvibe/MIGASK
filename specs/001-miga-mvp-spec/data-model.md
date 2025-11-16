# Data Model: MIGA MVP

**Date**: 2025-01-27  
**Status**: Complete

## Overview

MIGA uses a local-only data model stored in Core Data with UserDefaults for lightweight preferences. All data persists on-device only; no remote synchronization. The data model supports usage tracking, streak calculation, statistics aggregation, and app configuration.

## Core Data Entities

### UsageEvent

Represents a user interaction with the Gateway Screen.

**Attributes**:
- `id`: UUID (primary key)
- `eventType`: String (enum: "exit_to_focus", "deepen_pause", "proceed_to_app")
- `timestamp`: Date (when event occurred)
- `targetAppName`: String (name of social media app user was accessing)
- `pauseDuration`: Double (time in seconds spent on Gateway Screen before action)
- `timerDuration`: Double (configured timer duration at time of event)

**Relationships**:
- None (standalone event record)

**Validation Rules**:
- `eventType` must be one of three valid values
- `timestamp` cannot be nil
- `targetAppName` cannot be empty if `eventType` is "proceed_to_app"
- `pauseDuration` must be ≥ 0 and ≤ `timerDuration`

**Indexes**:
- `timestamp` (for efficient date-based queries in statistics)
- `eventType` (for filtering exits vs. proceeds)

### Streak

Represents consecutive days with at least one "Exit to Focus" action.

**Attributes**:
- `id`: UUID (primary key)
- `startDate`: Date (when current streak began)
- `currentDayCount`: Int (consecutive days with exits)
- `lastActivityDate`: Date (most recent day with exit action)

**Relationships**:
- None (calculated from UsageEvent records)

**Validation Rules**:
- `currentDayCount` must be ≥ 1
- `lastActivityDate` cannot be nil
- `startDate` cannot be later than `lastActivityDate`

**Business Logic**:
- Streak calculated on-demand from UsageEvent records
- Day boundary uses device local timezone
- Streak breaks if no "Exit to Focus" events for a full calendar day
- Streak persists across app launches via Core Data

**State Transitions**:
1. **New Streak**: First "Exit to Focus" → `startDate` = today, `currentDayCount` = 1, `lastActivityDate` = today
2. **Continue Streak**: Exit on consecutive day → `currentDayCount`++, `lastActivityDate` = today
3. **Break Streak**: No exit for 24+ hours → Reset to day 1 when next exit occurs

### SelectedApp

Represents a social media app the user has chosen to monitor.

**Attributes**:
- `id`: UUID (primary key)
- `appName`: String (display name, e.g., "Instagram")
- `urlScheme`: String (iOS URL scheme for launching, e.g., "instagram://")
- `iconName`: String (SF Symbol name or asset identifier)
- `isInstalled`: Bool (whether app is currently installed on device)
- `dateAdded`: Date (when user added app to Hub)
- `orderIndex`: Int (display order in Launcher Grid)

**Relationships**:
- None (standalone app configuration)

**Validation Rules**:
- `appName` cannot be empty
- `urlScheme` must be valid URL scheme format
- `orderIndex` must be ≥ 0 (used for Launcher Grid ordering)
- `iconName` cannot be empty

**State Transitions**:
1. **Added**: User selects app in F.R.E. Phase 1 → Create entity with `dateAdded` = now
2. **Reordered**: User changes Launcher Grid order → Update `orderIndex`
3. **Uninstalled**: System detects app removal → `isInstalled` = false (app remains in Hub but marked)
4. **Reinstalled**: System detects app return → `isInstalled` = true

### MindfulnessContent

Pre-bundled quotes/affirmations displayed on Gateway Screen.

**Note**: This entity represents the data structure for content library, but actual content stored in Plist/JSON file in Resources (see research.md). Entity definition provided for Core Data if future migration needed.

**Attributes**:
- `id`: String (content identifier)
- `text`: String (quote/affirmation text)
- `category`: String (content interest tag, e.g., "stoicism", "productivity")
- `author`: String? (optional author/source attribution)
- `displayCount`: Int (how many times shown to user)

**Relationships**:
- None (read-only content library)

**Validation Rules**:
- `text` cannot be empty
- `category` must match one of user's selected interests (filtering)
- `displayCount` used for rotation logic (avoid showing same quote too frequently)

**Content Selection Logic**:
- Filter by user's selected interest tags from onboarding
- Rotate through available content within selected categories
- When "Deepen the Pause" tapped, select different quote from same filtered set

## UserDefaults Keys

Lightweight preferences stored in UserDefaults (not Core Data):

### FRE Phase State
- **Key**: `"frePhase"`
- **Type**: String (enum: "notStarted", "phase1Complete", "phase2Complete")
- **Purpose**: Track First Run Experience completion state
- **Default**: `"notStarted"`

### Onboarding Complete
- **Key**: `"hasCompletedOnboarding"`
- **Type**: Bool
- **Purpose**: Flag indicating user has finished 12-screen onboarding
- **Default**: `false`

### Timer Duration
- **Key**: `"gatewayTimerDuration"`
- **Type**: Double (seconds, range: 15.0 - 45.0)
- **Purpose**: Configurable Gateway Screen timer duration
- **Default**: `30.0` (30 seconds)

### Determination Level
- **Key**: `"onboardingDeterminationLevel"`
- **Type**: Int (range: 1-10)
- **Purpose**: User's readiness level from onboarding screen 7
- **Default**: `5`

### Selected Interest Tags
- **Key**: `"selectedInterestTags"`
- **Type**: [String] (array of interest category names)
- **Purpose**: User's selected content interests from onboarding screen 8
- **Default**: `[]` (empty array)

## Core Data Stack

### Persistence Controller

Singleton managing Core Data stack:

```swift
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

### Context Usage

- **Main Context**: UI-bound reads via `@FetchRequest` in SwiftUI views
- **Background Context**: Write operations (usage events, streak updates) on background queue
- **Auto-save**: Main context auto-saves on app lifecycle events (willResignActive, didEnterBackground)

## Data Flow

### Usage Event Creation

1. User interacts with Gateway Screen (Exit, Deepen, Proceed)
2. `GatewayViewModel` creates UsageEvent entity on background context
3. Event saved to Core Data
4. `StatisticsAggregator` notified to recalculate metrics
5. `StreakCalculator` notified to update streak if event is "exit_to_focus"

### Streak Calculation

1. `StreakCalculator` queries UsageEvent for "exit_to_focus" events
2. Groups by calendar day (using device timezone)
3. Identifies consecutive days with exits
4. Updates or creates Streak entity with current count and dates
5. Streak displayed on Hub view via `@FetchRequest`

### Statistics Aggregation

1. `StatisticsAggregator` queries UsageEvent records for date range
2. Calculates:
   - **Hours Reclaimed**: Sum of `pauseDuration` for "exit_to_focus" events, converted to hours
   - **Total Conscious Exits**: Count of "exit_to_focus" events
   - **Average Pause Time**: Average `pauseDuration` across all events
   - **Intentionality Score**: Ratio of "exit_to_focus" events to total events
3. Generates trend data for last 30 days (daily aggregates)
4. Results cached in ViewModel for Statistics Screen display

### App Selection & F.R.E.

1. User selects apps in F.R.E. Phase 1.2
2. `FREViewModel` creates SelectedApp entities for each selection
3. UserDefaults `"frePhase"` updated to "phase1Complete"
4. User completes Phase 2 (manual app hiding)
5. UserDefaults `"frePhase"` updated to "phase2Complete"
6. Hub view loads SelectedApp entities via `@FetchRequest` for Launcher Grid

## Migration Strategy

MVP uses Core Data version 1. Future schema changes will require:

1. Create new Core Data model version
2. Add migration mapping model if attribute changes needed
3. Test migration with sample data
4. Version bump in `PersistenceController`

## Security & Privacy

- All data stored locally on device only
- No encryption needed (sensitive data is user's own usage patterns)
- User can delete all data by uninstalling app (Core Data + UserDefaults cleared)
- No network synchronization → No data transmission risk

## Performance Considerations

- UsageEvent records may grow large over time → Implement data retention policy (keep last 90 days, archive older)
- Statistics queries use indexes on `timestamp` and `eventType` for efficiency
- Streak calculation cached in ViewModel, recalculated only on new events
- SelectedApp list is small (8-10 apps) → No pagination needed

## Summary

The data model supports local-only persistence of user activity, preferences, and configuration. Core Data handles complex relationships and queries, while UserDefaults manages lightweight preferences. All entities follow Constitution requirements: privacy-first (local-only), performance-optimized (indexed queries), and offline-capable (no remote dependencies).

