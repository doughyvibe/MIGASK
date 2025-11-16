# Feature Specification: MIGA MVP Complete Feature Set

**Feature Branch**: `001-miga-mvp-spec`  
**Created**: 2025-01-27  
**Status**: Draft  
**Input**: User description: "@ux-design.md I have attached a ux-design file. Please review the file entirely to draw full context in order to create our specification document. Please let me know if there is any information missing."

## Clarifications

### Session 2025-01-27

- Q: How should usage data (events, streaks, statistics) be stored - locally only, or with remote sync? → A: All usage data (events, streaks, statistics) stored locally only; no remote persistence of user activity
- Q: When and how should user name be collected for personalized greeting? → A: Never collect user name; always use generic "Your Mindful Hub." greeting
- Q: What is the source and refresh strategy for mindfulness content displayed on Gateway Screen? → A: Pre-bundled default content only; no remote updates (fully offline-capable)
- Q: How should F.R.E. handle incomplete setup if user exits before completing both phases? → A: Automatically resume F.R.E. from last incomplete phase on next Hub visit until setup completes
- Q: How does system detect Phase 2 completion after user manually hides apps? → A: When user returns to app after Phase 2.1, show Phase 2.2 with message asking to confirm completion (assumes they followed instructions)

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Gateway Mindfulness Intercept (Priority: P1)

A user opens a social media app from the MIGA Hub and is presented with a full-screen mindfulness gateway that requires a 15-45 second pause before accessing the target app. During this pause, they see a personalized quote/affirmation based on their interests, a circular timer counting down, and three action options: exit immediately to home screen (celebrating the choice), extend the pause with new content, or proceed to the app once the timer completes.

**Why this priority**: This is the core value proposition of MIGA - the intentional friction mechanism that transforms mindless scrolling into mindful moments. Without this, MIGA has no behavioral intercept functionality.

**Independent Test**: Can be fully tested by launching the Gateway Screen from the Hub, verifying timer behavior, content display, and all three action buttons. Delivers the fundamental mindfulness pause experience that is MIGA's primary feature.

**Acceptance Scenarios**:

1. **Given** a user has selected apps on their Hub, **When** they tap an app icon, **Then** the Gateway Screen appears with a mindfulness quote, a timer set to the configured duration (15-45 seconds), and three action buttons where "Exit to Focus" and "Deepen the Pause" are enabled immediately, while "Proceed to [App Name]" is disabled
2. **Given** the Gateway Screen is displayed, **When** the timer counts down from full duration to zero, **Then** the "Proceed to [App Name]" button becomes enabled and remains enabled until tapped
3. **Given** the Gateway Screen is displayed, **When** the user taps "Exit to Focus", **Then** MIGA closes entirely, returns to the device Home Screen, and displays a toast message "Control Reclaimed. That's a Win."
4. **Given** the Gateway Screen is displayed, **When** the user taps "Deepen the Pause", **Then** a new mindfulness quote is loaded, the timer resets to full duration, and both "Exit to Focus" and "Deepen the Pause" remain enabled
5. **Given** the Gateway Screen timer reaches zero, **When** the user taps "Proceed to [App Name]", **Then** the target social media app launches via URL scheme and the Gateway Screen closes
6. **Given** the Gateway Screen is displayed, **When** a user views the screen, **Then** the mindfulness quote/affirmation has the highest visual weight (largest font size) and is centered on screen

---

### User Story 2 - Initial Onboarding Experience (Priority: P1)

A new user opens MIGA for the first time and is guided through a 12-screen onboarding sequence that explains the app's value proposition, builds motivation, establishes trust, collects personalization preferences, and prepares them for the core experience.

**Why this priority**: Onboarding is essential for user understanding and engagement. Without clear explanation of MIGA's purpose and how it works, users cannot effectively use or benefit from the mindfulness intercept feature.

**Independent Test**: Can be fully tested by launching the app as a new user, progressing through all 12 onboarding screens, verifying each screen's content and interactions, and confirming completion navigates to the MIGA Hub. Delivers complete first-time user education and setup.

**Acceptance Scenarios**:

1. **Given** a user opens MIGA for the first time, **When** the app launches, **Then** they see the Welcome screen with headline "The Intentional Life Starts Now." and CTA "Begin My Journey"
2. **Given** a user is on the Welcome screen, **When** they tap "Begin My Journey", **Then** they proceed to the first onboarding screen (Core Mission)
3. **Given** a user progresses through onboarding, **When** they reach screen 7 (Determination), **Then** they see a full-width slider/scale (1-10) to indicate their readiness to change
4. **Given** a user progresses through onboarding, **When** they reach screen 8 (Content Interest), **Then** they see selectable tags (e.g., Stoicism, Productivity) for personalizing mindfulness content
5. **Given** a user completes all 11 onboarding screens, **When** they tap "Let's Go!" on the Final Confirm screen, **Then** they navigate to the MIGA Hub
6. **Given** a user completes onboarding, **When** they reach the MIGA Hub, **Then** the First Run Experience (F.R.E.) is triggered automatically

---

### User Story 3 - Hub App Selection and First Run Setup (Priority: P1)

A user who has completed onboarding arrives at the MIGA Hub for the first time and is guided through selecting which apps to monitor, then receives instructions for manually hiding those apps at the OS level to enable the interception mechanism.

**Why this priority**: Users must configure which apps to monitor and enable the interception feature. Without this setup, the Gateway Screen cannot be triggered, and MIGA cannot function as designed.

**Independent Test**: Can be fully tested by completing onboarding, verifying the F.R.E. triggers, selecting apps in Phase 1, following Phase 2 instructions, and confirming the Hub is populated with selected apps. Delivers complete app configuration and setup.

**Acceptance Scenarios**:

1. **Given** a user has completed onboarding and arrives at the Hub for the first time, **When** they land on the Hub, **Then** the First Run Experience (F.R.E.) Phase 1 screen appears automatically
2. **Given** a user is on Phase 1.1 (Context & Goal), **When** they tap "Select Apps Now", **Then** they proceed to the app selection screen (Phase 1.2)
3. **Given** a user is on the app selection screen, **When** they view the screen, **Then** they see pill-box style buttons for 8-10 common social apps (TikTok, Instagram, X, Reddit, YouTube) and a "Find other apps..." option to access the full system list
4. **Given** a user is selecting apps, **When** they select at least one app, **Then** the CTA "Hub Ready. Proceed to Phase 2 Setup" becomes enabled
5. **Given** a user has selected one or more apps, **When** they tap "Hub Ready. Proceed to Phase 2 Setup", **Then** the selected apps are stored and they proceed to Phase 2.1 (Manual Instructions)
6. **Given** a user is on Phase 2.1, **When** they tap "I Understand & Ready to Begin", **Then** MIGA closes and returns to the Home Screen so they can complete the app hiding process
7. **Given** a user has tapped "I Understand & Ready to Begin" on Phase 2.1 and returns to MIGA after following manual app hiding instructions, **When** they return to the app, **Then** they see Phase 2.2 (Final Confirmation) with the message "Setup Complete. Your Gateway is Active."
8. **Given** a user completes Phase 2.2, **When** they tap "Go to Your Mindful Hub", **Then** they navigate to the fully configured MIGA Hub with their selected apps visible in the Launcher Grid
9. **Given** a user has completed onboarding but exits before completing Phase 1 or Phase 2 of F.R.E., **When** they return to the Hub, **Then** the F.R.E. automatically resumes from the last incomplete phase
10. **Given** a user has started Phase 1.2 (app selection) but exited before selecting apps, **When** they return to the Hub, **Then** Phase 1.2 (app selection) screen appears automatically
11. **Given** a user has completed Phase 1 (selected apps) but exits before completing Phase 2, **When** they return to the Hub, **Then** Phase 2.1 (Manual Instructions) screen appears automatically

---

### User Story 4 - Hub Navigation and Daily Usage (Priority: P2)

A user interacts with the MIGA Hub to launch apps, view their streak, and access statistics. The Hub serves as the primary action screen for daily mindfulness practice.

**Why this priority**: The Hub is the main entry point for daily usage. While the Gateway Screen provides the core value, the Hub enables users to access it and provides motivation through streak visibility.

**Independent Test**: Can be fully tested by accessing the Hub, verifying the greeting, streak banner, launcher grid, and tab navigation work correctly. Delivers the primary user interface for daily app access.

**Acceptance Scenarios**:

1. **Given** a user has completed setup, **When** they open MIGA, **Then** they land on the MIGA Hub with the greeting "Your Mindful Hub."
2. **Given** a user has at least one "Exit to Focus" action in their history, **When** they view the Hub, **Then** they see a prominent motivational banner displaying their streak count (e.g., "🔥 [X]-Day Control Streak. Keep the momentum going!")
3. **Given** a user is on the Hub, **When** they view the screen, **Then** they see a grid of icons representing their selected apps in the Launcher Grid
4. **Given** a user is on the Hub, **When** they tap any app icon in the Launcher Grid, **Then** the Gateway Screen is triggered for that specific app
5. **Given** a user is on the Hub, **When** they tap the Statistics tab in the bottom tab bar, **Then** they navigate to the Statistics Screen
6. **Given** a user is on the Hub, **When** they view the bottom tab bar, **Then** the HUB tab appears active and the STATS tab appears passive

---

### User Story 5 - Statistics and Progress Tracking (Priority: P2)

A user views their Statistics Screen to see quantified benefits of using MIGA, including hours reclaimed, total conscious exits, average pause time, trends over time, and their intentionality score.

**Why this priority**: Statistics provide validation and motivation. Users need to see proof that MIGA is working to maintain engagement and build long-term habits.

**Independent Test**: Can be fully tested by navigating to the Statistics Screen, verifying all metrics display correctly, checking the trends graph shows data, and confirming the intentionality score calculation. Delivers user validation and behavioral insight.

**Acceptance Scenarios**:

1. **Given** a user has used MIGA, **When** they navigate to the Statistics Screen, **Then** they see the header "Proof It's Working." with a Settings icon in the top-right
2. **Given** a user views the Statistics Screen, **When** they scroll through the screen, **Then** they see three KPI cards at the top: "Hours Reclaimed", "Total Conscious Exits", and "Average Pause Time"
3. **Given** a user has used MIGA for multiple days, **When** they view the Statistics Screen, **Then** they see a trends graph showing Daily Conscious Exits vs. Daily Attempts over the last 30 days
4. **Given** a user has both exits and pauses in their history, **When** they view the Statistics Screen, **Then** they see an "Intentionality Score" card displaying the ratio of Exits vs. Pauses
5. **Given** a user views the Statistics Screen, **When** they scroll to the bottom, **Then** they see a footer message "Keep choosing wisely."
6. **Given** a user is on the Statistics Screen, **When** they tap the Hub tab in the bottom tab bar, **Then** they navigate back to the MIGA Hub

---

### Edge Cases

- What happens when a user selects no apps during Phase 1.2 (they should be unable to proceed until at least one app is selected)?
- How does the system handle app hiding instructions for Android vs iOS (the UX document notes Android implementation needs verification)?
- What happens when the timer is configured but the user's device time changes during the countdown?
- System MUST automatically resume F.R.E. from last incomplete phase on next Hub visit until setup completes (already clarified in FR-044)
- What happens when a selected app is uninstalled from the device after being added to the Hub?
- How does the system handle the streak calculation when a user's device date/time is changed (to prevent streak manipulation)?
- What happens when a user taps "Deepen the Pause" multiple times consecutively (should content refresh each time)?
- How does the Gateway Screen handle selection of content when user has multiple interest tags (should rotate across all selected interests or weight by preference)?
- What happens if a URL scheme for a target app is invalid or the app is not installed?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: System MUST display a full-screen Gateway Screen when a user taps an app icon in the MIGA Hub Launcher Grid
- **FR-002**: System MUST display a mindfulness quote/affirmation on the Gateway Screen with the highest visual weight (largest font size) among all screen elements, sourced from pre-bundled default content library
- **FR-003**: System MUST display a circular progress timer on the Gateway Screen that counts down from a configurable duration of 15-45 seconds
- **FR-004**: System MUST disable the "Proceed to [App Name]" button on Gateway Screen launch and only enable it when the timer reaches zero
- **FR-005**: System MUST enable "Exit to Focus" and "Deepen the Pause" buttons immediately upon Gateway Screen launch
- **FR-006**: System MUST close MIGA entirely and return to device Home Screen when user taps "Exit to Focus"
- **FR-007**: System MUST display toast message "Control Reclaimed. That's a Win." when user taps "Exit to Focus"
- **FR-008**: System MUST load a new mindfulness quote from the pre-bundled content library and reset the timer to full duration when user taps "Deepen the Pause"
- **FR-009**: System MUST dynamically insert the target social media app's name into the "Proceed to [App Name]" button text
- **FR-010**: System MUST launch the target social media app via URL scheme when user taps "Proceed to [App Name]" after timer completion
- **FR-011**: System MUST present a 12-screen onboarding sequence to new users in the order: Welcome → Core Mission → Time Wasted → Time Saved → Reinforcement → Credibility → Trial Policy → Determination → Content Interest → Journey → Final Confirm
- **FR-012**: System MUST collect user's readiness level (1-10) via slider on the Determination screen during onboarding
- **FR-013**: System MUST collect user's content interests via selectable tags on the Content Interest screen during onboarding
- **FR-014**: System MUST navigate users to the MIGA Hub after completing onboarding
- **FR-015**: System MUST trigger the First Run Experience (F.R.E.) automatically when a user arrives at the Hub for the first time after onboarding, and MUST automatically resume from the last incomplete phase on subsequent Hub visits until setup completes
- **FR-016**: System MUST present Phase 1.1 (Context & Goal) of F.R.E. with option to proceed to app selection
- **FR-017**: System MUST display 8-10 common social apps as pill-box style buttons on the app selection screen (Phase 1.2)
- **FR-018**: System MUST provide a "Find other apps..." option to access the full system app list on the app selection screen
- **FR-019**: System MUST require at least one app to be selected before allowing users to proceed from Phase 1.2
- **FR-020**: System MUST store selected apps and populate the Launcher Grid with those apps
- **FR-021**: System MUST present Phase 2.1 (Manual Instructions) with platform-specific instructions for hiding apps (iOS instructions specified; Android needs verification)
- **FR-022**: System MUST close MIGA when user taps "I Understand & Ready to Begin" on Phase 2.1
- **FR-023**: System MUST present Phase 2.2 (Final Confirmation) when user returns to the app after Phase 2.1; System MUST assume user has completed manual app hiding instructions
- **FR-024**: System MUST display the greeting "Your Mindful Hub." on the MIGA Hub
- **FR-025**: System MUST display a prominent motivational streak banner on the Hub when user has at least one consecutive day with an "Exit to Focus" action
- **FR-026**: System MUST calculate streak as consecutive days with at least one "Exit to Focus" tap
- **FR-027**: System MUST display the Launcher Grid on the Hub with icons representing all selected apps
- **FR-028**: System MUST provide bottom tab bar navigation between Hub and Statistics screens
- **FR-029**: System MUST highlight the active tab (HUB or STATS) in the bottom tab bar
- **FR-030**: System MUST display "Proof It's Working." as the header on the Statistics Screen with a Settings icon in the top-right
- **FR-031**: System MUST display three KPI cards on Statistics Screen: "Hours Reclaimed", "Total Conscious Exits", and "Average Pause Time"
- **FR-032**: System MUST display a trends graph on Statistics Screen showing Daily Conscious Exits vs. Daily Attempts over the last 30 days
- **FR-033**: System MUST calculate and display "Intentionality Score" as the ratio of Exits vs. Pauses on the Statistics Screen
- **FR-034**: System MUST display "Keep choosing wisely." as footer message on Statistics Screen
- **FR-035**: System MUST use strict light mode UI with white backgrounds (#FFFFFF) across all screens
- **FR-036**: System MUST use Dark Navy/Deep Blue (#1A237E) for primary text and controls, Soft Sky Blue (#5B84B1) for accents, and Teal (#00A9B5) for enabled CTAs
- **FR-037**: System MUST use modern sans-serif typography with highest visual weight for mindfulness content
- **FR-038**: System MUST use standardized rounded corners: 8pt for buttons/pills, 12pt for timer/modals, 16pt for hub cards
- **FR-039**: System MUST use supportive, empowering language throughout (e.g., "You are in control") and avoid punitive language
- **FR-040**: System MUST make timer duration configurable in settings (15-45 second range)
- **FR-041**: System MUST store all usage data (events, streaks, statistics) locally on device only with no remote persistence
- **FR-042**: System MUST use pre-bundled mindfulness content library included in app bundle; content MUST be filtered by user-selected interests from onboarding
- **FR-043**: System MUST function fully offline; mindfulness content MUST NOT require network connectivity to display
- **FR-044**: System MUST persist F.R.E. completion state locally; if F.R.E. is incomplete, System MUST automatically resume from last incomplete phase when user returns to Hub

### Key Entities *(include if feature involves data)*

- **User Profile**: Represents a user's preferences and settings, including content interests (selected during onboarding), determination level (1-10 scale), timer configuration preference (15-45 seconds), and F.R.E. completion state (tracks which phase was last completed)
- **Selected App**: Represents a social media app that the user has chosen to monitor, including app name, app icon, URL scheme for launching, and association with the user's Hub configuration
- **Mindfulness Content**: Represents quotes/affirmations displayed on the Gateway Screen, including content text, source category (based on user's selected interests), and association with content interest tags. All content is pre-bundled in the app with no remote fetching required.
- **Usage Event**: Represents a user interaction with the Gateway Screen, including event type ("Exit to Focus", "Deepen the Pause", or "Proceed to App"), timestamp, target app name, pause duration (time spent on Gateway Screen), and associated user. Stored locally only on device.
- **Streak**: Represents consecutive days with at least one "Exit to Focus" action, including start date, current day count, last activity date, and association with user profile. Stored locally only on device.
- **Statistics Aggregate**: Represents calculated metrics for display on Statistics Screen, including hours reclaimed (cumulative time from all "Exit to Focus" actions), total conscious exits (count of "Exit to Focus" events), average pause time (average duration on Gateway Screen before any action), and intentionality score (ratio of exits to total attempts). All source data and calculations stored locally only on device.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can complete the full onboarding sequence (12 screens) and reach the MIGA Hub in under 3 minutes
- **SC-002**: Users can complete the First Run Experience (both Phase 1 and Phase 2) and have a fully configured Hub in under 5 minutes
- **SC-003**: The Gateway Screen timer accurately counts down from configured duration (15-45 seconds) with visual progress indication
- **SC-004**: 90% of users who complete onboarding successfully configure at least one app on their Hub during F.R.E.
- **SC-005**: Mindfulness content loads and displays on the Gateway Screen immediately (no network delay) since it is pre-bundled
- **SC-006**: All three Gateway Screen actions ("Exit to Focus", "Deepen the Pause", "Proceed to [App Name]") respond to user taps within 500 milliseconds
- **SC-007**: Streak calculation accurately reflects consecutive days with "Exit to Focus" actions and updates correctly when new exits occur
- **SC-008**: Statistics Screen displays all metrics (Hours Reclaimed, Total Conscious Exits, Average Pause Time, Intentionality Score) accurately based on user's usage history
- **SC-009**: Trends graph on Statistics Screen displays data correctly for up to 30 days of usage history
- **SC-010**: Hub Launcher Grid displays all selected apps with correct icons and names
- **SC-011**: Bottom tab navigation switches between Hub and Statistics screens without delay or visual glitches
- **SC-012**: Target social media apps launch successfully via URL scheme when "Proceed to [App Name]" is tapped after timer completion (95% success rate for valid apps)
