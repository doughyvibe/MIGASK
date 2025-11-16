---
description: MIGA MVP Complete Feature Set - Actionable development tasks organized by user story with strict dependencies.
version: 1.0.0
last_updated: 2025-11-16
format_version: strict-checklist
---

# MIGA MVP Complete Feature Set: Development Tasks

**Feature Branch**: `001-miga-mvp-spec` | **Last Updated**: 2025-11-16

**Overview**: This document provides executable development tasks for the MIGA iOS app MVP. Tasks are organized by user story phase in strict priority order (P1 first). All tasks follow the required checklist format and include exact file paths for immediate implementation.

## Implementation Strategy

**MVP Scope**: User Stories 1-3 (full P1 features) represent the minimum viable product. Each story is independently testable and delivers working value.

**Tech Stack**: Swift 5.9+ (iOS 17.0+), SwiftUI, Core Data, Firebase (Analytics only), local-only storage

**Architecture**: MVVM with feature modules, Core Data + UserDefaults, pre-bundled content library

**Dependencies**:
- User Story 3 completion required before User Story 1 can be triggered
- User Story 2 must complete before User Story 3 can start
- All P1 user stories must be complete before developing P2 features

---

## Phase 1: Setup (Project Initialization)

**Goal**: Initialize project structure, dependencies, and core infrastructure required for all features.

- [ ] T001 Create Core Data models for UsageEvent entity in MIGASK/Core/Models/UsageEvent.swift
- [ ] T002 Create Core Data models for Streak entity in MIGASK/Core/Models/Streak.swift
- [ ] T003 Create Core Data models for SelectedApp entity in MIGASK/Core/Models/SelectedApp.swift
- [ ] T004 Create Codable struct for MindfulnessContent model in MIGASK/Core/Models/MindfulnessContent.swift
- [ ] T005 Add Persistence Controller singleton in MIGASK/Core/Data/PersistenceController.swift
- [ ] T006 Create ContentLibrary service for pre-bundled quotes in MIGASK/Core/Services/ContentLibrary.swift
- [ ] T007 Create URLSchemeLauncher service in MIGASK/Core/Services/URLSchemeLauncher.swift
- [ ] T008 Create StreakCalculator service in MIGASK/Core/Services/StreakCalculator.swift
- [ ] T009 Create StatisticsAggregator service in MIGASK/Core/Services/StatisticsAggregator.swift
- [ ] T010 Create MIGA color extension constants in MIGASK/Core/Utilities/ColorExtensions.swift
- [ ] T011 Create typography style constants in MIGASK/Core/Utilities/TypographyStyles.swift
- [ ] T012 Configure Firebase Analytics (optional) in MIGASK/App/MIGASKApp.swift
- [ ] T013 Create Firebase configuration file GoogleService-Info.plist in MIGASK/
- [ ] T014 Set up Core Data model file MIGASKDataModel.xcdatamodeld in MIGASK/
- [ ] T015 Populate ContentLibrary.plist with sample quotes in MIGASK/Resources/ContentLibrary.plist

---

## Phase 2: Foundational (Blocking Prerequisites)

**Goal**: Complete core infrastructure required for all user stories before development begins.

- [ ] T016 Implement StreakCalculator unit tests in MIGASKTests/Core/StreakCalculatorTests.swift
- [ ] T017 Implement StatisticsAggregator unit tests in MIGASKTests/Core/StatisticsAggregatorTests.swift
- [ ] T018 Implement basic MIGASKApp SwiftUI root view in MIGASK/MIGASKApp.swift
- [ ] T019 Implement AppDelegate for Firebase integration in MIGASK/App/AppDelegate.swift
- [ ] T020 Populate ContentLibrary.plist with 50+ mindfulness quotes in MIGASK/Resources/ContentLibrary.plist
- [ ] T021 Verify Core Data stack initialization works in PersistenceController.swift
- [ ] T022 Test URLSchemeLauncher with Instagram app launch in URLSchemeLauncherTests.swift

---

## Phase 3: User Story 2 - Initial Onboarding Experience

**Goal**: Build 12-screen onboarding flow with user preference collection and navigation to Hub.

**Story Requirements**: 12 sequential screens, determination slider, content interests tagging, Firebase Analytics integration.

**Independent Test Criteria**: Complete all screens and validate navigation to Hub, user preferences stored in UserDefaults.

- [ ] T023 Create OnboardingContainerView with NavigationStack in MIGASK/Features/Onboarding/Views/OnboardingContainerView.swift
- [ ] T024 Implement OnboardingViewModel with screen navigation in MIGASK/Features/Onboarding/ViewModels/OnboardingViewModel.swift
- [ ] T025 Create Onboarding screen 1 (Welcome) view in MIGASK/Features/Onboarding/Views/WelcomeView.swift
- [ ] T026 Create Onboarding screen 2 (Core Mission) view in MIGASK/Features/Onboarding/Views/CoreMissionView.swift
- [ ] T027 Create Onboarding screen 3 (Time Wasted) view in MIGASK/Features/Onboarding/Views/TimeWastedView.swift
- [ ] T028 Create Onboarding screen 4 (Time Saved) view in MIGASK/Features/Onboarding/Views/TimeSavedView.swift
- [ ] T029 Create Onboarding screen 5 (Reinforcement) view in MIGASK/Features/Onboarding/Views/ReinforcementView.swift
- [ ] T030 Create Onboarding screen 6 (Credibility) view in MIGASK/Features/Onboarding/Views/CredibilityView.swift
- [ ] T031 Create Onboarding screen 7 (Determination) slider view in MIGASK/Features/Onboarding/Views/DeterminationView.swift
- [ ] T032 Create Onboarding screen 8 (Trial Policy) view in MIGASK/Features/Onboarding/Views/TrialPolicyView.swift
- [ ] T033 Create Onboarding screen 9 (Content Interest) tagging view in MIGASK/Features/Onboarding/Views/ContentInterestView.swift
- [ ] T034 Create Onboarding screen 10 (Journey) view in MIGASK/Features/Onboarding/Views/JourneyView.swift
- [ ] T035 Create Onboarding screen 11 (Final Confirm) view in MIGASK/Features/Onboarding/Views/FinalConfirmView.swift
- [ ] T036 Integrate OnboardingViewModel with UserDefaults for preference storage in OnboardingViewModel.swift
- [ ] T037 Add Firebase Analytics events for onboarding completion in OnboardingViewModel.swift
- [ ] T038 Test full onboarding flow navigation and Hub transition

---

## Phase 4: User Story 3 - Hub App Selection and First Run Setup

**Goal**: Implement First Run Experience with app selection and manual iOS hiding instructions.

**Story Requirements**: App selection screen, F.R.E. phases, SelectedApp entity storage, automatic Hub display.

**Independent Test Criteria**: Complete Phase 1 app selection, Phase 2 manual instructions, Hub display with selected apps.

**Dependencies**: Requires User Story 2 completion (onboarding) before F.R.E. can trigger.

- [ ] T039 Create FREViewModel with phase state management in MIGASK/Features/FirstRunExperience/ViewModels/FREViewModel.swift
- [ ] T040 Create FREPhase1View (Context & Goal) in MIGASK/Features/FirstRunExperience/Views/FREPhase1View.swift
- [ ] T041 Create FRE app selection screen (Phase 1.2) in MIGASK/Features/FirstRunExperience/Views/AppSelectionView.swift
- [ ] T042 Create FREPhase2View (Manual Instructions) in MIGASK/Features/FirstRunExperience/Views/FREPhase2View.swift
- [ ] T043 Create FREPhase2ConfirmationView for completion in MIGASK/Features/FirstRunExperience/Views/FREPhase2ConfirmationView.swift
- [ ] T044 Implement app selection logic with pill-box buttons in FREViewModel.swift
- [ ] T045 Add SelectedApp entity creation and storage in FREViewModel.swift
- [ ] T046 Implement F.R.E. phase tracking in UserDefaults in FREViewModel.swift
- [ ] T047 Add automatic F.R.E. resumption on Hub visit in FREViewModel.swift
- [ ] T048 Integrate F.R.E. trigger from onboarding completion

---

## Phase 5: User Story 1 - Gateway Mindfulness Intercept

**Goal**: Build core Gateway Screen with timer, mindfulness quotes, and three action buttons.

**Story Requirements**: 15-45s configurable timer, pre-bundled quotes, URL scheme launching, UsageEvent tracking.

**Independent Test Criteria**: Launch Gateway from Hub app tap, verify timer countdown, all buttons functional, app launch successful.

**Dependencies**: Requires User Story 3 completion (apps configured) for Gateway to trigger.

- [ ] T049 Create GatewayViewModel with timer logic in MIGASK/Features/Gateway/ViewModels/GatewayViewModel.swift
- [ ] T050 Create GatewayScreenView with quote display in MIGASK/Features/Gateway/Views/GatewayScreenView.swift
- [ ] T051 Create CircularTimerView component in MIGASK/Features/Gateway/Views/CircularTimerView.swift
- [ ] T052 Implement Combine Timer.publish for countdown in GatewayViewModel.swift
- [ ] T053 Add "Exit to Focus" button action with celebration animation in GatewayViewModel.swift
- [ ] T054 Add "Deepen the Pause" button action with quote refresh in GatewayViewModel.swift
- [ ] T055 Add "Proceed to [App]" button with enabled state logic in GatewayViewModel.swift
- [ ] T056 Integrate ContentLibrary for quote filtering in GatewayViewModel.swift
- [ ] T057 Implement UsageEvent creation and storage in GatewayViewModel.swift
- [ ] T058 Add URLSchemeLauncher integration for app launch in GatewayViewModel.swift
- [ ] T059 Create toast message display for "Exit to Focus" celebration
- [ ] T060 Testing Gateway Screen timer accuracy and button behaviors

---

## Phase 6: User Story 4 - Hub Navigation and Daily Usage

**Goal**: Complete Hub Screen with launcher grid, streak banner, and statistics navigation.

**Story Requirements**: Launcher grid with selected apps, streak calculation and display, Hub/Statistics tab navigation.

**Independent Test Criteria**: Hub displays with apps, streak banner shows for active streaks, navigation to Statistics works.

**Dependencies**: Requires User Story 1 (Gateway) completion for streak calculation display.

- [ ] T061 Create HubViewModel with data loading in MIGASK/Features/Hub/ViewModels/HubViewModel.swift
- [ ] T062 Create HubView with main layout in MIGASK/Features/Hub/Views/HubView.swift
- [ ] T063 Create LauncherGridView for app icons in MIGASK/Features/Hub/Views/LauncherGridView.swift
- [ ] T064 Implement GridItem layout for app icons in LauncherGridView.swift
- [ ] T065 Add streak banner with motivational message in HubView.swift
- [ ] T066 Integrate StreakCalculator for streak calculation in HubViewModel.swift
- [ ] T067 Add SelectedApp fetching with @FetchRequest in HubViewModel.swift
- [ ] T068 Implement bottom TabView with Hub/Statistics navigation in HubView.swift
- [ ] T069 Add Gateway Screen launch on app tap in HubViewModel.swift
- [ ] T070 Integrate FREViewModel for F.R.E. auto-triggering

---

## Phase 7: User Story 5 - Statistics and Progress Tracking

**Goal**: Build Statistics Screen with KPI metrics, trend graphs, and progress visualization.

**Story Requirements**: Three KPI cards, intentionality score, 30-day trends graph, Hub navigation.

**Independent Test Criteria**: Statistics load with accurate metrics, trend graph displays properly, navigation back to Hub works.

**Dependencies**: Requires User Story 4 completion for Statistics navigation, User Story 1 completion for usage data.

- [ ] T071 Create StatisticsViewModel with metrics calculation in MIGASK/Features/Statistics/ViewModels/StatisticsViewModel.swift
- [ ] T072 Create StatisticsView with KPI display in MIGASK/Features/Statistics/Views/StatisticsView.swift
- [ ] T073 Create KPICardView component for metrics cards in MIGASK/Features/Statistics/Views/KPICardView.swift
- [ ] T074 Create TrendsGraphView for daily charts in MIGASK/Features/Statistics/Views/TrendsGraphView.swift
- [ ] T075 Integrate StatisticsAggregator service in StatisticsViewModel.swift
- [ ] T076 Add KPI calculation for hours reclaimed in StatisticsViewModel.swift
- [ ] T077 Add usage events fetching with @FetchRequest in StatisticsViewModel.swift
- [ ] T078 Implement trend data generation for 30 days in StatisticsViewModel.swift
- [ ] T079 Add intentionality score calculation in StatisticsViewModel.swift
- [ ] T080 Test Statistics Screen data accuracy and graph rendering

---

## Final Phase: Polish & Cross-Cutting Concerns

**Goal**: Complete accessibility, performance optimization, and cross-cutting requirements.

**Story Requirements**: WCAG 2.1 AA compliance, Dynamic Type, VoiceOver, light mode enforcement.

**Independent Test Criteria**: App passes accessibility audit, performance targets met, all edge cases handled.

- [ ] T081 Add VoiceOver labels to all interactive elements across all screens
- [ ] T082 Implement Dynamic Type scaling support for all text sizes
- [ ] T083 Force light mode UI with preferredColorScheme modifier
- [ ] T084 Add SF Symbols for app icons and navigation elements
- [ ] T085 Implement celebration animations for "Exit to Focus" action
- [ ] T086 Add Firebase Crashlytics error reporting
- [ ] T087 Optimize Core Data queries for performance (<1s load times)
- [ ] T088 Implement automatic F.R.E. phase resumption on app relaunch
- [ ] T089 Add timer duration user preference (15-45s) in settings
- [ ] T090 Test edge cases: app uninstalled, timer changes, date changes
- [ ] T091 Implement data retention policy for old UsageEvents
- [ ] T092 Final performance testing and crash rate verification
- [ ] T093 Add app icon and launch screen assets
- [ ] T094 Create Localizable.strings for string constants
- [ ] T095 Final accessibility audit and WCAG 2.1 AA verification

---

## Task Completion Summary & Report

### Implementation Strategy
- **MVP Completion**: Tasks T001-T060 (User Stories 1-3) represent full MVP with minimal working behavior
- **Priority Order**: P1 user stories (1-3) complete functional app, P2 features enhance engagement
- **Parallel Opportunities**: User Stories 1-3 can be developed in parallel once setup complete (T001-T022)
- **Quality Gates**: Each user story phase has independent test criteria for incremental delivery

### Task Metrics
- **Total Tasks**: 95
- **MVP Tasks**: 60 (T001-T060 covering P1 user stories)
- **Parallel Executable**: 48 tasks marked with [P] for independent development
- **Setup Phase**: 15 tasks (T001-T015)
- **Foundational Phase**: 8 tasks (T016-T023)
- **User Story Phases**: 72 tasks across 5 user stories
- **Polish Phase**: 15 tasks (T081-T095)

### User Story Task Distribution
- **User Story 1 (Gateway)**: 12 tasks (T049-T060)
- **User Story 2 (Onboarding)**: 16 tasks (T023-T038)
- **User Story 3 (F.R.E.)**: 10 tasks (T039-T048)
- **User Story 4 (Hub)**: 10 tasks (T061-T070)
- **User Story 5 (Statistics)**: 10 tasks (T071-T080)

### Dependencies & Execution Order
1. **T001-T022**: Must complete serially (setup + foundational)
2. **T023-T048**: User Stories 2 & 3 can execute in parallel after foundational
3. **T049-T060**: User Story 1 blocked until User Story 3 completes
4. **T061-T090**: P2 features blocked until P1 features complete
5. **T081-T095**: Cross-cutting concerns can execute throughout all phases

### Format Validation
✅ **Task Format**: All tasks follow strict checklist format: `- [ ] [TaskID] [P?] [Story?] Description with file path`
✅ **File Paths**: All tasks specify exact Swift file paths in MIGASK/ codebase
✅ **Story Labels**: User story phases have [US1], [US2], etc. labels
✅ **Parallel Markers**: Tasks safe for parallel execution marked with [P]
✅ **Sequential IDs**: Tasks numbered
