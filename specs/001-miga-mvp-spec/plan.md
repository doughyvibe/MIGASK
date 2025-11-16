# Implementation Plan: MIGA MVP Complete Feature Set

**Branch**: `001-miga-mvp-spec` | **Date**: 2025-01-27 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-miga-mvp-spec/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

MIGA is a native iOS mindfulness app built with SwiftUI that provides intentional friction before accessing social media apps. Users configure monitored apps on a Hub, and tapping an app icon triggers a Gateway Screen with a 15-45 second mindfulness pause featuring quotes/affirmations. The app tracks usage statistics, streaks, and provides progress visualization. All data is stored locally only with no remote persistence. The MVP includes 12-screen onboarding, First Run Experience for app setup, Hub launcher grid, Gateway Screen with timer, and Statistics screen. Technical approach uses SwiftUI with MVVM architecture, Core Data for local storage, and Firebase for optional content sync (fully offline-capable).

## Technical Context

**Language/Version**: Swift 5.9+ (iOS 17.0+ deployment target)  
**Primary Dependencies**: SwiftUI, Core Data, Firebase (Firestore, Analytics), StoreKit  
**Storage**: Core Data (primary persistent store for events, streaks, statistics) + UserDefaults (user preferences, F.R.E. state, timer config)  
**Testing**: XCTest framework (unit tests for core logic, streak calculations, statistics aggregates)  
**Target Platform**: iOS 17.0+ (iPhone only, no iPad support for MVP)  
**Project Type**: mobile (native iOS SwiftUI app)  
**Performance Goals**: Main screen load time < 1 second; Gateway Screen renders < 500ms; 60fps animations; crash-free rate ≥ 99%  
**Constraints**: Fully offline-capable (pre-bundled content), no remote user data storage, WCAG 2.1 AA accessibility compliance, strict light mode UI only, local-only analytics  
**Scale/Scope**: MVP scope with ~12 screens (onboarding sequence, Hub, Gateway, Statistics), ~8-10 pre-configured social apps, pre-bundled mindfulness content library (~50-100 quotes), single-user local data model

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

### I. Mindful by Design (NON-NEGOTIABLE)
✅ **PASS**: Design uses calm, non-punitive aesthetic. Light mode with neutral palette (#FFFFFF backgrounds, Dark Navy #1A237E primary). Supportive copy ("Control Reclaimed. That's a Win."). "Exit to Focus" triggers celebration animations.

### II. Privacy-First Architecture
✅ **PASS**: All user data stored locally only (Core Data + UserDefaults). No remote persistence of usage events, streaks, or statistics. Firebase Analytics limited to minimal behavioral validation with no PII.

### III. Clean MVVM Architecture
✅ **PASS**: SwiftUI Views with ViewModels per feature module (OnboardingViewModel, GatewayViewModel, HubViewModel, StatisticsViewModel). Clear separation of concerns enables testability and maintainability.

### IV. Performance Standards
✅ **PASS**: Pre-bundled content enables < 1s main screen load. Local Core Data cache for initial rendering. Crash-free target ≥ 99% via unit tests and Firebase Crashlytics.

### V. Offline-First Design
✅ **PASS**: Fully offline-capable. Pre-bundled mindfulness content library included in app bundle. Core Data local storage. No network dependency for core functionality.

### VI. Accessibility Mandate
✅ **PASS**: Dynamic Type support required for all text. VoiceOver labels for interactive elements. WCAG 2.1 AA contrast ratios (4.5:1 minimum). Readable typography with appropriate spacing.

### VII. Intentional Friction (Core Feature)
✅ **PASS**: Gateway timer 15-45 seconds configurable. "Proceed to [App]" disabled until timer completes. Non-bypassable core behavioral intercept mechanism.

### VIII. Positive Reinforcement
✅ **PASS**: "Exit to Focus" triggers celebration animations. Positive copy emphasizes achievements. Statistics highlight hours reclaimed, streaks, not punitive measures.

**Gate Status**: ✅ **ALL GATES PASSED** - Proceed to Phase 0 research.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
MIGASK/
├── MIGASK/
│   ├── App/
│   │   ├── MIGASKApp.swift
│   │   └── AppDelegate.swift (if needed for Firebase)
│   ├── Core/
│   │   ├── Models/
│   │   │   ├── UsageEvent.swift
│   │   │   ├── Streak.swift
│   │   │   ├── SelectedApp.swift
│   │   │   └── MindfulnessContent.swift
│   │   ├── Data/
│   │   │   ├── PersistenceController.swift
│   │   │   ├── CoreDataStack.swift
│   │   │   └── ContentLibrary.swift (pre-bundled content)
│   │   ├── Services/
│   │   │   ├── StreakCalculator.swift
│   │   │   ├── StatisticsAggregator.swift
│   │   │   └── URLSchemeLauncher.swift
│   │   └── Utilities/
│   │       ├── ColorExtensions.swift
│   │       └── TypographyStyles.swift
│   ├── Features/
│   │   ├── Onboarding/
│   │   │   ├── Views/
│   │   │   │   ├── OnboardingContainerView.swift
│   │   │   │   └── [12 onboarding screen views]
│   │   │   └── ViewModels/
│   │   │       └── OnboardingViewModel.swift
│   │   ├── FirstRunExperience/
│   │   │   ├── Views/
│   │   │   │   ├── FREPhase1View.swift
│   │   │   │   ├── FREPhase2View.swift
│   │   │   │   └── AppSelectionView.swift
│   │   │   └── ViewModels/
│   │   │       └── FREViewModel.swift
│   │   ├── Hub/
│   │   │   ├── Views/
│   │   │   │   ├── HubView.swift
│   │   │   │   └── LauncherGridView.swift
│   │   │   └── ViewModels/
│   │   │       └── HubViewModel.swift
│   │   ├── Gateway/
│   │   │   ├── Views/
│   │   │   │   ├── GatewayScreenView.swift
│   │   │   │   └── CircularTimerView.swift
│   │   │   └── ViewModels/
│   │   │       └── GatewayViewModel.swift
│   │   └── Statistics/
│   │       ├── Views/
│   │       │   ├── StatisticsView.swift
│   │       │   ├── KPICardView.swift
│   │       │   └── TrendsGraphView.swift
│   │       └── ViewModels/
│   │           └── StatisticsViewModel.swift
│   └── Resources/
│       ├── Assets.xcassets/
│       ├── ContentLibrary.plist (or JSON)
│       └── Localizable.strings
├── MIGASKTests/
│   ├── Core/
│   │   ├── StreakCalculatorTests.swift
│   │   └── StatisticsAggregatorTests.swift
│   └── Features/
│       ├── GatewayViewModelTests.swift
│       └── HubViewModelTests.swift
└── MIGASK.xcodeproj/
```

**Structure Decision**: Native iOS SwiftUI project structure with feature-based modules. Each feature contains Views and ViewModels following MVVM pattern. Core layer contains shared models, data persistence (Core Data), services (streak calculation, statistics), and utilities (color extensions, typography). Resources folder contains pre-bundled mindfulness content library. Tests organized mirroring source structure.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

*No violations detected. All design decisions align with Constitution principles.*

## Post-Design Constitution Check

*Re-evaluation after Phase 1 design completion.*

### I. Mindful by Design (NON-NEGOTIABLE)
✅ **PASS**: Design uses calm color palette (#FFFFFF backgrounds, #1A237E primary), supportive copy, celebration animations for "Exit to Focus". Gateway Screen quote has highest visual weight. All interactions reinforce positive choices.

### II. Privacy-First Architecture
✅ **PASS**: Data model stores all data locally (Core Data + UserDefaults). No remote persistence of UsageEvent, Streak, or SelectedApp. Firebase Analytics limited to minimal behavioral validation with no PII.

### III. Clean MVVM Architecture
✅ **PASS**: Feature-based modules (Onboarding, Gateway, Hub, Statistics) with ViewModels per feature. Clear separation: Views (SwiftUI), ViewModels (`@Observable`), Services (business logic), Models (Core Data). Each module independently testable.

### IV. Performance Standards
✅ **PASS**: Pre-bundled content enables < 1s load time. Core Data queries indexed on `timestamp` and `eventType`. Services cache results (StreakCalculator, StatisticsAggregator). Local-only storage eliminates network latency.

### V. Offline-First Design
✅ **PASS**: Pre-bundled ContentLibrary.plist provides offline mindfulness quotes. Core Data local persistence. No network dependency for core functionality (Gateway timer, Hub launcher, Statistics).

### VI. Accessibility Mandate
✅ **PASS**: Dynamic Type support via system fonts and `.dynamicTypeSize()`. VoiceOver labels via `.accessibilityLabel()` and `.accessibilityHint()`. WCAG 2.1 AA contrast ratios enforced (4.5:1 minimum). SF Symbols provide accessible icons.

### VII. Intentional Friction (Core Feature)
✅ **PASS**: Gateway timer 15-45 seconds configurable via UserDefaults. `GatewayViewModel` enforces `isProceedEnabled = false` until `isTimerComplete = true`. Timer non-bypassable (core behavioral intercept).

### VIII. Positive Reinforcement
✅ **PASS**: "Exit to Focus" triggers celebration animations (SwiftUI `.animation()` with spring effect). Statistics highlight positive metrics (hours reclaimed, conscious exits, streaks). No punitive language or high-saturation warning colors.

**Post-Design Gate Status**: ✅ **ALL GATES PASSED** - Design complete and Constitution-compliant.

## Phase 0: Research (Complete)

**Output**: `research.md` - Technical decisions for iOS 17+, SwiftUI, Core Data, SF Symbols, accessibility, and performance optimization.

**Key Decisions**:
- Use `@Observable` macro (iOS 17+) for ViewModels
- Pre-bundle mindfulness content as Plist/JSON
- Use SF Symbols for icons and navigation
- Implement Dynamic Type and VoiceOver support
- Use Core Data with `@FetchRequest` for persistence
- Use Timer.publish() with Combine for countdown

**Status**: ✅ All NEEDS CLARIFICATION items resolved. Context7 unavailable; decisions based on current iOS/SwiftUI best practices.

## Phase 1: Design & Contracts (Complete)

**Outputs**:
- `data-model.md` - Core Data entities, UserDefaults keys, data flow
- `contracts/viewmodel-contracts.md` - ViewModel interfaces (MVVM pattern)
- `contracts/service-contracts.md` - Service interfaces (StreakCalculator, StatisticsAggregator, etc.)
- `quickstart.md` - Development setup and workflow guide
- Agent context updated: `.cursor/rules/specify-rules.mdc`

**Key Artifacts**:
- **Data Model**: UsageEvent, Streak, SelectedApp, MindfulnessContent entities
- **ViewModel Contracts**: GatewayViewModel, HubViewModel, StatisticsViewModel, OnboardingViewModel, FREViewModel
- **Service Contracts**: StreakCalculator, StatisticsAggregator, URLSchemeLauncher, ContentLibrary
- **Architecture**: MVVM with feature-based modules, Core Data persistence, UserDefaults preferences

**Status**: ✅ Design complete. All contracts defined. Agent context updated.

## Phase 2: Task Planning

*Phase 2 is executed by `/speckit.tasks` command, not `/speckit.plan`. This phase generates `tasks.md` from the implementation plan.*

**Next Command**: Run `/speckit.tasks` to break the plan into actionable development tasks.

## Summary

**Branch**: `001-miga-mvp-spec`  
**Implementation Plan**: `/Users/therealdoughy/Desktop/MIGASK/specs/001-miga-mvp-spec/plan.md`

**Generated Artifacts**:
- ✅ `research.md` - Technical decisions and research findings
- ✅ `data-model.md` - Core Data entities and data flow
- ✅ `contracts/viewmodel-contracts.md` - ViewModel interfaces
- ✅ `contracts/service-contracts.md` - Service interfaces
- ✅ `quickstart.md` - Development setup guide
- ✅ Agent context updated for Cursor IDE

**Constitution Compliance**: ✅ All 8 principles verified pre-research and post-design.

**Next Steps**:
1. Review generated artifacts
2. Run `/speckit.tasks` to create task breakdown
3. Begin implementation following quickstart guide
4. Build features in priority order (P1: Onboarding, F.R.E., Gateway, Hub)

**Implementation Ready**: ✅ Yes. All design artifacts complete. Ready for task planning and development.
