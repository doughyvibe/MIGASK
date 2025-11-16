# Service Contracts: MIGA MVP

**Date**: 2025-01-27  
**Status**: Complete

## Overview

Services encapsulate business logic and data operations. Contracts define interfaces for core services: StreakCalculator, StatisticsAggregator, URLSchemeLauncher, and ContentLibrary.

## StreakCalculator

**Purpose**: Calculates consecutive days with "Exit to Focus" actions.

### Interface

```swift
protocol StreakCalculating {
    func calculateStreak(from events: [UsageEvent]) -> Streak?
    func updateStreak(from newEvent: UsageEvent) -> Streak
}

final class StreakCalculator: StreakCalculating {
    // Implementation
}
```

### Methods

#### calculateStreak(from:)

```swift
func calculateStreak(from events: [UsageEvent]) -> Streak?
```

**Input**: Array of UsageEvent records (filtered to "exit_to_focus" type)

**Output**: Optional Streak entity with:
- `startDate`: Date when current streak began
- `currentDayCount`: Int consecutive days
- `lastActivityDate`: Date of most recent exit

**Logic**:
1. Filter events to "exit_to_focus" type
2. Group by calendar day (using device timezone)
3. Identify consecutive days with exits
4. Calculate longest consecutive sequence
5. Return Streak entity or nil if no exits

**Example**:
- Events on: Day 1, Day 2, Day 3, Day 5
- Streak: 3 days (Day 1-3, broken on Day 4, resumed Day 5 = new 1-day streak)

#### updateStreak(from:)

```swift
func updateStreak(from newEvent: UsageEvent) -> Streak
```

**Input**: New UsageEvent (must be "exit_to_focus" type)

**Output**: Updated Streak entity

**Logic**:
1. Load existing Streak from Core Data (if exists)
2. Compare `newEvent.timestamp` with `streak.lastActivityDate`
3. If same calendar day: Keep streak, update `lastActivityDate`
4. If next calendar day: Increment `currentDayCount`, update `lastActivityDate`
5. If gap (1+ days): Reset streak to day 1, update `startDate`
6. Save updated Streak to Core Data
7. Return Streak entity

**Time Zone Handling**:
- All date comparisons use device local timezone
- Day boundaries determined by calendar day in local timezone

**Edge Cases**:
- Device date/time change during streak: Use timestamp from events (not system clock)
- First exit ever: Create new Streak with day 1
- Multiple exits in same day: Update `lastActivityDate` but don't increment count

## StatisticsAggregator

**Purpose**: Aggregates usage data into statistics metrics.

### Interface

```swift
protocol StatisticsAggregating {
    func calculateKPIs(from events: [UsageEvent]) -> KPIStats
    func generateTrends(from events: [UsageEvent], days: Int) -> [DailyTrend]
}

struct KPIStats {
    let hoursReclaimed: Double
    let totalConsciousExits: Int
    let averagePauseTime: TimeInterval
    let intentionalityScore: Double
}

struct DailyTrend {
    let date: Date
    let consciousExits: Int
    let totalAttempts: Int
    let averagePauseTime: TimeInterval
}

final class StatisticsAggregator: StatisticsAggregating {
    // Implementation
}
```

### Methods

#### calculateKPIs(from:)

```swift
func calculateKPIs(from events: [UsageEvent]) -> KPIStats
```

**Input**: Array of all UsageEvent records

**Output**: KPIStats struct with metrics

**Calculations**:

1. **Hours Reclaimed**:
   - Filter events to "exit_to_focus" type
   - Sum all `pauseDuration` values
   - Convert seconds to hours (divide by 3600)
   - Round to 1 decimal place

2. **Total Conscious Exits**:
   - Count events with `eventType == "exit_to_focus"`

3. **Average Pause Time**:
   - Calculate average `pauseDuration` across all events
   - Return as TimeInterval (seconds)

4. **Intentionality Score**:
   - Count "exit_to_focus" events (exits)
   - Count total events (exits + proceeds + deepens)
   - Calculate ratio: `exits / total`
   - Return as Double (0.0 to 1.0)
   - If no events: Return 0.0

**Example**:
- 10 events: 5 exits, 3 proceeds, 2 deepens
- Hours Reclaimed: Sum of 5 exit durations (e.g., 45 min = 0.75 hours)
- Total Conscious Exits: 5
- Average Pause Time: Average of all 10 pause durations
- Intentionality Score: 5 / 10 = 0.5 (50%)

#### generateTrends(from:days:)

```swift
func generateTrends(from events: [UsageEvent], days: Int) -> [DailyTrend]
```

**Input**: 
- Array of all UsageEvent records
- Number of days to generate trends for (default: 30)

**Output**: Array of DailyTrend structs (one per day)

**Logic**:
1. Get date range: Last N days from today (using device timezone)
2. Group events by calendar day
3. For each day:
   - Count "exit_to_focus" events → `consciousExits`
   - Count total events → `totalAttempts`
   - Calculate average `pauseDuration` for that day → `averagePauseTime`
4. Return array sorted by date (oldest first)

**Edge Cases**:
- Days with no events: Include with zeros for all metrics
- Partial days: Include today even if incomplete
- Date changes: Use event timestamps, not system clock

## URLSchemeLauncher

**Purpose**: Launches external social media apps via URL schemes.

### Interface

```swift
protocol URLSchemeLaunching {
    func launchApp(urlScheme: String, appName: String) -> Result<Void, LaunchError>
    func canLaunchApp(urlScheme: String) -> Bool
}

enum LaunchError: Error {
    case invalidURLScheme
    case appNotInstalled
    case launchFailed
}

final class URLSchemeLauncher: URLSchemeLaunching {
    // Implementation
}
```

### Methods

#### canLaunchApp(urlScheme:)

```swift
func canLaunchApp(urlScheme: String) -> Bool
```

**Input**: URL scheme string (e.g., "instagram://")

**Output**: Boolean indicating if app can be launched

**Logic**:
1. Validate URL scheme format
2. Create URL from scheme
3. Call `UIApplication.shared.canOpenURL(url)`
4. Return result

**Use Case**: Check if app is installed before showing in app selection

#### launchApp(urlScheme:appName:)

```swift
func launchApp(urlScheme: String, appName: String) -> Result<Void, LaunchError>
```

**Input**: 
- URL scheme string
- App display name (for error messages)

**Output**: Result enum (success or error)

**Logic**:
1. Validate URL scheme format → `.invalidURLScheme` if invalid
2. Check if app can be launched → `.appNotInstalled` if false
3. Create URL from scheme
4. Call `UIApplication.shared.open(url, options: [:])`
5. Return `.success(())` or `.launchFailed` on error

**Error Handling**:
- Invalid scheme: Return `.invalidURLScheme`
- App not installed: Return `.appNotInstalled`
- Launch failure: Return `.launchFailed`

**URL Schemes** (common social apps):
- Instagram: `"instagram://"`
- TikTok: `"tiktok://"`
- X (Twitter): `"twitter://"` or `"tweetbot://"`
- Reddit: `"reddit://"`
- YouTube: `"youtube://"`
- Facebook: `"fb://"`
- Snapchat: `"snapchat://"`
- LinkedIn: `"linkedin://"`

## ContentLibrary

**Purpose**: Manages pre-bundled mindfulness content filtering and selection.

### Interface

```swift
protocol ContentLibraryProviding {
    func loadContent() -> [MindfulnessContent]
    func filterContent(by interests: [String]) -> [MindfulnessContent]
    func selectRandomQuote(for interests: [String]) -> MindfulnessContent?
}

final class ContentLibrary: ContentLibraryProviding {
    // Implementation
}
```

### Methods

#### loadContent()

```swift
func loadContent() -> [MindfulnessContent]
```

**Input**: None

**Output**: Array of all MindfulnessContent items

**Logic**:
1. Load `ContentLibrary.plist` (or JSON) from Resources bundle
2. Parse into MindfulnessContent structs
3. Return array

**Error Handling**:
- File not found: Return empty array, log error
- Parse error: Return empty array, log error

#### filterContent(by:)

```swift
func filterContent(by interests: [String]) -> [MindfulnessContent]
```

**Input**: Array of interest tag strings (from onboarding)

**Output**: Array of MindfulnessContent items matching interests

**Logic**:
1. Load all content via `loadContent()`
2. Filter where `content.category` is in `interests` array
3. Return filtered array

**Edge Cases**:
- Empty interests array: Return all content (no filter)
- No matches: Return empty array

#### selectRandomQuote(for:)

```swift
func selectRandomQuote(for interests: [String]) -> MindfulnessContent?
```

**Input**: Array of interest tag strings

**Output**: Optional MindfulnessContent item

**Logic**:
1. Filter content by interests
2. If filtered array empty, load all content (fallback)
3. Select random item from array
4. Return item or nil if no content available

**Use Case**: Called when Gateway Screen loads or "Deepen the Pause" tapped

**Rotation Logic** (future enhancement):
- Track `displayCount` for each quote
- Prefer quotes with lower display counts
- Ensure variety over time

## Service Dependencies

### Core Data Access

Services that need Core Data access:
- `StreakCalculator`: Reads UsageEvent, writes Streak
- `StatisticsAggregator`: Reads UsageEvent (read-only)

**Pattern**: Services receive data via method parameters (dependency injection). ViewModels fetch data via `@FetchRequest` and pass to services.

### UserDefaults Access

Services that need UserDefaults:
- None (ViewModels handle UserDefaults directly)

## Testing Contracts

All services are unit-testable with mock data:

```swift
// Example: StreakCalculator test
let events: [UsageEvent] = [/* mock events */]
let calculator = StreakCalculator()
let streak = calculator.calculateStreak(from: events)
XCTAssertEqual(streak?.currentDayCount, 3)
```

## Summary

Services encapsulate business logic with clear interfaces. All services are protocol-based for testability. Services receive data via parameters (no direct Core Data access) to maintain separation of concerns and enable unit testing.

