# MIGA — Product Requirements Document (Full Version)

**Project Type**: Greenfield (new product)  
**Platform**: iOS (SwiftUI, iOS 17+)  
**Version**: MVP v1.0  
**Primary Audience**: Internal development team  
**Created By**: John (Product Manager, BMAD Framework)

---

## 1. Executive Summary

### 1.1 Purpose

MIGA ("Mindful Gateway to Social Media") is an iOS application designed to help users regain conscious control over their social media habits. Instead of blocking or restricting, MIGA introduces **intentional mindfulness friction** — a short, rewarding pause before opening social apps. The app serves as a **behavioral intercept** that encourages reflection and empowers users to make conscious decisions.

### 1.2 Mission

"Empower users to reclaim time and awareness through mindful, intentional technology use."

MIGA encourages self-regulation and mindfulness over punitive app blocking, creating a positive digital wellbeing experience.

### 1.3 Goals

- Introduce **micro mindfulness moments** before social app use.
- Help users **build healthy digital habits** without restriction or guilt.
- Create a **lightweight, stable MVP** ready for TestFlight within 10 days.
- Collect usage analytics to validate behavioral impact (exits, wait times, retention).

---

## 2. Problem Definition

### 2.1 Background

Users often open social media on autopilot. This unconscious behavior leads to reduced productivity, diminished focus, and wasted time. Existing solutions (app blockers, screen-time dashboards) feel punitive or ineffective.

### 2.2 Core Problem

People need a way to **pause and reflect** before entering the social media attention loop — without feeling restricted or judged.

### 2.3 Problem Hypothesis

"If users are prompted to pause for 15–45 seconds before using social apps, they will make more conscious choices and reduce total social media time."

---

## 3. Users & Personas

### 3.1 Target Segments

| Segment | Description | Motivation |
| --- | --- | --- |
| Conscious Scroller (Primary) | 25–35, digital professional, aware of overuse | Wants small habit nudges to stay intentional |
| Recovering Overuser (Secondary) | 18–28, heavy app user (4–6 hrs/day) | Seeks non-punitive guidance to regain control |
| Mindful Minimalist (Tertiary) | 30–45, tech minimalism advocate | Values design, mindfulness, and calm UX |

### 3.2 Behavioral Insights

- Average phone unlocks per day: 90–120
- Average social app sessions: 50% autopilot
- Ideal friction: 15–45 seconds — short enough to avoid frustration, long enough to trigger reflection

---

## 4. Product Overview

### 4.1 Core Value Proposition

"MIGA transforms mindless scrolling into mindful moments."  
Through calming design, reflective content, and subtle delays, it allows users to consciously choose whether to proceed or take a break.

### 4.2 Key Features

| Category | Feature | Description | Priority |
| --- | --- | --- | --- |
| Gateway Timer | Mindful pause (15–45s) | Customizable duration before social app access | P0 |
| Mindfulness Content | Quotes, mini-articles, affirmations | Delivered via Firebase Firestore; cached locally | P0 |
| Navigation | Tab-based UI (Hub, Stats, Settings) | Simple SwiftUI TabView | P0 |
| Analytics | Exits, Reads, Wait Time, Streaks | Firebase + Core Data | P1 |
| Settings | Manage timer, app list, preferences | Local via UserDefaults | P1 |
| Monetization | 3-day trial → One-time purchase | StoreKit integration | P2 |

---

## 5. Functional Requirements

### 5.1 App Structure

| Screen | Description | Components |
| --- | --- | --- |
| Welcome / Onboarding | Introduces MIGA’s purpose | SwiftUI intro flow; local onboarding state |
| Hub Screen | Displays user’s social app shortcuts | Grid of icons linked via URL schemes |
| Gateway Screen | Core mindfulness interaction | Quote or article, animated timer, 3 actions (Exit / Read Next / Open App) |
| Statistics Tab | Local usage analytics | Charts for Exits, Reads, Minutes waited, Streaks |
| Settings Tab | Configuration | Timer length, app list, content categories, trial info |

### 5.2 Content Management

- Firestore collection: `/content` with fields `{type, text, category, length}`
- Local cache of 10–20 entries in Core Data
- Rotation logic: random non-repeating content display
- Fallback: default local bundle content if offline

### 5.3 Analytics

- Firebase Analytics + local Core Data mirror
- Track events:
  - `session_start`
  - `gateway_completed`
  - `exit_selected`
  - `open_selected`
  - `content_read`
- Derived metrics: streaks, session durations, exit rates

### 5.4 App Integration

- Custom URL schemes for supported social apps (Instagram, TikTok, Facebook)
- Graceful fallback message if app not found

---

## 6. Non-Functional Requirements

| Category | Requirement | Notes |
| --- | --- | --- |
| Performance | Load main screen < 1s | All content pre-fetched, local cache used |
| Reliability | <1 crash / 100 sessions | Unit-tested core logic |
| Security | No user data stored remotely | Local-only identifiers |
| Privacy | No tracking SDKs, minimal analytics | Privacy-first design |
| Accessibility | Dynamic Type, VoiceOver labels | Compliance with WCAG 2.1 AA |
| Offline Mode | Works with cached content | Firebase sync optional |
| Maintainability | Clean MVVM architecture | ViewModels per feature |
| Scalability | Modular Firebase integration | Easy content update via Firestore |

---

## 7. UX & Design Principles

| Principle | Implementation |
| --- | --- |
| Mindful by Design | Neutral palette, calming tones, slow animations |
| Positive Reinforcement | “Exit” action triggers gentle celebration animation |
| Simplicity First | Three main tabs only |
| Consistency | Reusable component library in SwiftUI |
| Accessibility | Contrast ratio 4.5:1, readable typography |
| No Judgment | Copy tone always supportive and non-restrictive |

---

## 8. System Architecture (Developer Summary)

### 8.1 Stack

- **Frontend**: SwiftUI + MVVM + async/await
- **Local Storage**: Core Data + UserDefaults
- **Backend**: Firebase (Firestore, Remote Config, Analytics)
- **Monetization**: StoreKit
- **Integration**: Custom URL Schemes

### 8.2 Data Flow Overview

User → UI (SwiftUI Views) → ViewModel (Timer, Content, Stats) → Local Storage (Core Data / UserDefaults) ↔ Firebase Firestore (content fetch & sync)

### 8.3 Modules

| Module | Purpose |
| --- | --- |
| `OnboardingModule` | Guides user setup |
| `GatewayModule` | Manages timer and mindfulness content |
| `ContentModule` | Handles content rotation, caching |
| `StatsModule` | Aggregates and displays analytics |
| `SettingsModule` | User preferences and timer configs |

---

## 9. Success Metrics

| KPI | Target | Measurement |
| --- | --- | --- |
| Timer Completion Rate | ≥ 60% | Firebase event ratio |
| Exit Rate | ≥ 30% by Day 7 | Derived metric |
| 7-Day Retention | ≥ 50% | Analytics cohort |
| Conversion Rate | ≥ 20% trial-to-purchase | StoreKit analytics |
| Crash-Free Sessions | ≥ 99% | Firebase Crashlytics |

---

## 10. Risks & Mitigations

| Risk | Description | Mitigation |
| --- | --- | --- |
| App Store Rejection | Perceived as “app blocker” | Emphasize voluntary mindfulness, not restriction |
| User Frustration | Delay feels annoying | Calming UI, short durations |
| Content Fatigue | Repeated content reduces engagement | Dynamic rotation, Firebase refresh |
| Technical Variability | URL scheme changes per app | Maintain config table and test quarterly |

---

## 11. Release Plan

| Phase | Deliverable | Owner | Timeline |
| --- | --- | --- | --- |
| Day 1–2 | PRD & Architecture Docs | PM + Architect | ✅ |
| Day 3–5 | SwiftUI prototype + core navigation | Dev |  |
| Day 6–7 | Timer + content module + settings | Dev |  |
| Day 8–9 | Local analytics + polish | Dev |  |
| Day 10 | TestFlight beta build | PM + QA |  |

### Versioning

- v1.0 (MVP) — Mindful Gateway + Timer + Stats
- v1.1 — Gamification, extended analytics
- v2.0 — Android + cross-platform expansion

---

## 12. Appendices

### 12.1 Future Enhancements

- Social sharing of progress
- Personalized content feed (ML-driven)
- Multi-device sync via iCloud
- WidgetKit support for daily reflection

### 12.2 Reference Documents

- **Architecture-Lite Doc**: forthcoming (`docs/architecture.md`)
- **UX Spec / Wireframes**: to be created by UX Expert
- **PRD Source**: Generated from `brief.md` using BMAD full PRD workflow

---

## ✅ Summary

MIGA’s MVP delivers intentional mindfulness without friction fatigue. Its design is technically lightweight yet behaviorally impactful, offering a practical route to validate user engagement and habit change before scaling.


