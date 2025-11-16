<!--
Sync Impact Report:
- Version: 0.0.0 → 1.0.0 (initial constitution creation from PRD)
- Principles Added: 8 core principles derived from PRD.md
- Added Sections: Technology Stack Requirements, UX & Design Constraints, Non-Functional Requirements, Governance
- Templates requiring updates: All templates checked for alignment
  ✅ plan-template.md (Constitution Check section aligns with principles)
  ✅ spec-template.md (aligned with requirements structure)
  ✅ tasks-template.md (aligned with task organization)
  ✅ checklist-template.md (no constitution-specific references to update)
- Follow-up TODOs: None (all placeholders resolved)
-->

# MIGA Constitution

## Core Principles

### I. Mindful by Design (NON-NEGOTIABLE)

All user interfaces MUST embody a calm, non-punitive aesthetic that encourages
conscious choice rather than restriction. Visual design MUST use neutral
palettes, calming tones, and slow animations. Copy tone MUST always be
supportive and empowering ("You are in control"), never judgmental or punitive.

**Rationale**: MIGA's core value proposition is transforming mindless scrolling
into mindful moments through intentional friction, not blocking. Users must feel
empowered, not restricted. The "Exit to Focus" action MUST trigger gentle
celebration animations to reinforce positive behavioral choices.

### II. Privacy-First Architecture

User data MUST NOT be stored remotely. All identifiers MUST be local-only.
Analytics events (Firebase) MUST NOT contain personally identifiable
information. Privacy-first design is mandatory—no tracking SDKs beyond minimal
Firebase Analytics for behavioral validation only.

**Rationale**: Privacy is a core differentiator and trust requirement. Users
seeking mindful technology use expect transparency and data sovereignty.
Local-only storage ensures user control and reduces privacy risks.

### III. Clean MVVM Architecture

All features MUST follow the MVVM (Model-View-ViewModel) pattern with
ViewModels per feature module. Code MUST be modular with clear separation of
concerns: OnboardingModule, GatewayModule, ContentModule, StatsModule,
SettingsModule. Each module MUST be independently testable.

**Rationale**: MVVM ensures maintainability, testability, and scalability. The
10-day MVP timeline requires clean architecture to prevent technical debt that
would impede future iterations. Modular design enables parallel development and
easy Firebase integration updates.

### IV. Performance Standards

Main screen load time MUST be < 1 second. All content MUST be pre-fetched with
local cache used for initial rendering. Crash-free sessions MUST meet ≥ 99%
target (<1 crash per 100 sessions). Core logic MUST be unit-tested to prevent
regressions.

**Rationale**: Performance directly impacts the mindful experience. Slow load
times add unintended friction that contradicts the app's purpose. Stability is
critical for user trust and retention. Meeting these targets validates the MVP
as production-ready.

### V. Offline-First Design

The app MUST function fully with cached content when offline. Firebase Firestore
sync is optional—local Core Data cache (10-20 entries) MUST provide fallback
content. Default local bundle content MUST be available if cache is empty or
unavailable.

**Rationale**: Users expect reliability regardless of connectivity. Offline
capability ensures the gateway timer and mindfulness content remain accessible
at all times, maintaining the behavioral intercept functionality even without
network access.

### VI. Accessibility Mandate

All UI components MUST comply with WCAG 2.1 AA standards. Dynamic Type support
MUST be implemented for all text. VoiceOver labels MUST be provided for all
interactive elements. Contrast ratio MUST meet 4.5:1 minimum. Typography MUST
prioritize readability with appropriate letter spacing and line height.

**Rationale**: Accessibility is not optional—it ensures MIGA serves all users,
including those with visual or motor impairments. Mindful design principles
demand inclusive experiences. Accessibility compliance also reduces App Store
rejection risk.

### VII. Intentional Friction (Core Feature)

The gateway timer MUST provide a configurable 15-45 second pause before social
app access. Timer duration MUST be customizable in settings. The "Proceed to
App" action MUST remain disabled until timer completes. This friction is the
core behavioral intercept mechanism and MUST NOT be bypassable or skippable.

**Rationale**: Intentional friction is MIGA's fundamental innovation. The
15-45 second window is validated research range—short enough to avoid
frustration, long enough to trigger reflection. Making this configurable honors
user agency while maintaining the core mindfulness mechanism.

### VIII. Positive Reinforcement

Exit actions ("Exit to Focus") MUST trigger celebration animations. Copy MUST
emphasize user agency and achievements ("Control Reclaimed. That's a Win.").
Statistics screens MUST highlight positive metrics (hours reclaimed, conscious
exits, streaks) rather than punitive measures. Negative language or high-
saturation warning colors MUST be avoided except for critical system warnings.

**Rationale**: Behavior change requires positive reinforcement, not punishment.
MIGA's mission is empowerment through mindfulness, not guilt through
restriction. Celebrating good choices builds sustainable habits and differentiates
MIGA from punitive blockers.

## Technology Stack Requirements

- **Platform**: iOS 17+ (SwiftUI, async/await patterns required)
- **Architecture**: MVVM with ViewModels per feature
- **Local Storage**: Core Data (primary) + UserDefaults (preferences)
- **Backend**: Firebase (Firestore for content, Analytics for events, Remote
  Config optional)
- **Monetization**: StoreKit (3-day trial → one-time purchase model)
- **Integration**: Custom URL Schemes for social app launch
- **Testing**: XCTest framework (unit tests for core logic mandatory)

**Rationale**: This stack balances MVP speed, maintainability, and scalability.
SwiftUI provides modern iOS development efficiency. MVVM enables testability and
modularity. Firebase offers backend-as-a-service for rapid content management
without custom server infrastructure. StoreKit provides native monetization.

## UX & Design Constraints

- **Visual Mode**: Strict light mode UI (#FFFFFF backgrounds) with generous
  whitespace
- **Color Palette**: Dark Navy/Deep Blue primary (#1A237E), Soft Sky Blue
  accent (#5B84B1), Teal secondary accent (#00A9B5) for enabled CTAs
- **Typography**: Modern sans-serif, highest visual weight for mindfulness
  content (Gateway quotes)
- **Component Radius**: Standardized rounded corners (8pt buttons, 12pt timer,
  16pt cards)
- **Navigation**: Three main tabs only (Hub, Stats, Settings) via TabView
- **Tone**: Supportive, empowering, non-restrictive language throughout

**Rationale**: Consistent design system ensures cohesive user experience.
Light mode maximizes focus and reduces visual distraction. Calming color palette
reinforces mindful aesthetic. Simple navigation (three tabs) aligns with
simplicity-first principle.

## Non-Functional Requirements

| Category | Requirement | Enforcement |
|----------|-------------|-------------|
| Performance | Load main screen < 1s | Pre-fetch + local cache validation |
| Reliability | <1 crash / 100 sessions (≥99%) | Unit tests + Firebase Crashlytics |
| Security | No user data stored remotely | Architecture review + code audit |
| Privacy | No tracking SDKs, minimal analytics | Dependency audit + privacy manifest |
| Accessibility | WCAG 2.1 AA compliance | Dynamic Type, VoiceOver testing |
| Offline Mode | Full functionality with cached content | Core Data cache validation |
| Maintainability | MVVM per feature module | Code review + architecture docs |
| Scalability | Modular Firebase integration | Content update via Firestore |

**Rationale**: These requirements ensure production-ready MVP quality. Each
category addresses specific risk areas identified in PRD. Enforcement mechanisms
provide measurable validation criteria for compliance reviews.

## Governance

The MIGA Constitution supersedes all other practices and guidelines. All
feature specifications, implementation plans, and code reviews MUST verify
compliance with these principles. Amendments require documentation of rationale,
impact assessment, and version bump per semantic versioning rules:

- **MAJOR** (X.0.0): Backward incompatible principle removals or redefinitions
- **MINOR** (0.X.0): New principle added or materially expanded guidance
- **PATCH** (0.0.X): Clarifications, wording improvements, non-semantic
  refinements

Constitution compliance MUST be checked at feature planning phase (before Phase
0 research) and re-validated after Phase 1 design. Any violations require
explicit justification in complexity tracking documentation. Use `.specify/`
templates (plan, spec, tasks) for runtime development guidance aligned with
these principles.

**Version**: 1.0.0 | **Ratified**: 2025-11-16 | **Last Amended**: 2025-11-16
