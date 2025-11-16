# MIGA MVP: UX Handoff Specification (v1.0)

**Project:** MIGA (Mindful Gateway to Social Media)  
**Status:** UX Specification Complete  
**Date:** [Current Date]  
**Objective:** Provide full technical documentation for the development and QA of all core MVP screens.

---

## A. Global Design System & Aesthetic Principles (Finalized for Handoff)

All UI components must adhere strictly to the **"Mindful by Design"** aesthetic—calm, non-punitive, and highly focused, as validated against the provided visual references.

| Element | Specification | Notes for Dev |
| :--- | :--- | :--- |
| **Visual Mode** | **Strict Light Mode UI** with generous whitespace. | Use `#FFFFFF` for backgrounds to maximize focus and minimize visual distraction. |
| **Color Palette** | **Primary Text/Controls:** Dark Navy or Deep Blue (High Contrast). **Accent Color:** Soft Sky Blue. **Secondary Accent:** Teal for critical enabled CTAs. | **Dark Navy:** `#1A237E` (or similar deep, warm tone). **Soft Sky Blue:** `#5B84B1` (Used for Timer progress, Streak text). **Teal (Secondary):** `#00A9B5` (Used for enabled CTA backgrounds, e.g., "Proceed"). |
| **Typography** | Modern, clean **Sans-Serif**. | **CRITICAL:** Mindfulness Quote on Gateway must use the largest font size/highest weight. Prioritize letter spacing and line height to reduce visual density. |
| **Components: Radius** | **Generous Rounded Corners** standardized across all views. | **Small (Buttons, Pills):** 8pt Radius. **Medium (Timer, Modals):** 12pt Radius. **Large (Hub Cards):** 16pt Radius. |
| **Tone** | Supportive and empowering ("You are in control"). | Avoid punitive language or high-saturation colors (red/orange) except for warnings. |

---

## B. Core Interaction: Gateway Screen (P0)

This full-screen, modal intercept is triggered when a user taps an app on the MIGA Hub.

| Area/Component | Detail/Functionality | Final Copy (String Key) | Interaction Logic |
| :--- | :--- | :--- | :--- |
| **Context** (Top) | Small, subtle icon of the linked app. | N/A | Non-interactive. For context only. |
| **Focus Content** | Centered, full-screen quote/affirmation (The "Article View"). | Dynamic content source (from user-selected interests). | **Must be the highest visual weight.** |
| **Friction Timer** | Circular Progress Bar, counting down **15–45 seconds**. | N/A | Timer duration must be configurable in settings (P1). |
| **Action 1 (Success)** | **Immediately Enabled.** Tapping closes MIGA entirely (returns to device Home Screen). | **"Exit to Focus"** | **CRITICAL:** Triggers the **"Control Reclaimed. That's a Win."** toast message. |
| **Action 2 (Extension)** | **Immediately Enabled.** Tapping loads a new quote and **resets the timer to full duration**. | **"Deepen the Pause"** | Voluntary self-extension. Must refresh the content string. |
| **Action 3 (Proceed)** | **Disabled** on launch. Only **enables** when the Timer Status reaches 0:00. | **"Proceed to [App Name]"** | Must dynamically insert the social media app's name. Launches the external app via URL scheme. |

---

## C. Flow 1: Onboarding Sequence (12 Screens)

The sequence is **Value → Motivation → Trust → Personalization → Action** (Total 12 screens including Welcome).

| Screen # | Focus Area | **Refined Headline (Final Copy)** | Interaction / Notes |
| :--- | :--- | :--- | :--- |
| **0. Welcome** | Introduction | **The Intentional Life Starts Now.** | CTA: "Begin My Journey". |
| **1. Core Mission** | Value Proposition | **Your Attention Is Valuable.** | Body: Empower you to choose when and why you scroll. |
| **2. Time Wasted** | Quantify Problem | **What's Autopilot Costing You?** | Visual: Draining hourglass. Body includes "60 minutes a day lost." |
| **3. Time Saved** | Quantify Benefit | **Your Time. Your Purpose.** | Visual: Aspirational image (reading/exercising). |
| **4. Reinforcement** | Behavioral Goal | **Stop Reacting. Start Choosing.** | Active verbs for motivation. |
| **5. Credibility** | Build Authority | **Habit Change Backed by Science.** | Body references 14-day high chance of habit shift. |
| **6. Trial Policy** | Reduce Anxiety | **Risk-Free Clarity. Try MIGA Today.** | States the app is completely free to try. |
| **7. Determination** | Commitment | **How Ready Are You to Change?** | **Interaction:** Full-width Slider/Scale (1-10). |
| **8. Content Interest** | Personalization | **Make Your Pause Productive.** | **Interaction:** Selectable Tags (e.g., Stoicism, Productivity). |
| **9. Journey** | Explain the Flow | **Your 4 Steps to Freedom.** | Visual flow: Launch → Pause → Choose → Win. |
| **10. Final Confirm** | Finish | **You’re Ready to Reclaim Your Focus.** | Final CTA: "Let's Go!" (Navigates to MIGA Hub). |
| **CRITICAL NOTE** | **App Hiding Setup** | N/A | Instructions are **deferred** entirely to the **MIGA Hub F.R.E.** (First Run Experience). |

---

## D. Flow 2: Hub & Statistics Screens (P1)

Both views are connected by a dedicated **Bottom Tab Bar**.

### D.1. MIGA Hub (Launcher - Action Screen)

| Component | Detail/Functionality | **Refined Copy** | Logic & Placement |
| :--- | :--- | :--- | :--- |
| **Navigation** | **Bottom Tab Bar** (HUB active, STATS passive). | N/A | Consistent navigation structure. |
| **Top Line** | Personalized Greeting. | "Hello, [User's Name]" or "Your Mindful Hub." | Minimalist, top-aligned text. |
| **P1 Motivational Banner** | **Prominent, top-aligned banner.** | **🔥 [X]-Day Control Streak. Keep the momentum going!** | **CRITICAL PLACEMENT:** Above the Launcher Grid for maximum visibility. |
| **Streak Metric** | **Definition:** Consecutive days with at least one **"Exit to Focus"** tap. | N/A | Must be calculated server-side/securely stored. |
| **Launcher Grid** | Grid of linked app icons. | N/A | Tapping any icon triggers the **Gateway Screen**. |
| **Setup F.R.E.** | One-time tooltip/overlay. | Guides the user on the manual **App Hiding** process. | Triggered only on first visit to the Hub; dismissible. |

### D.2. Statistics Screen (Reflection Screen)

| Component | Detail/Functionality | **Refined Copy / Metric Name** | Rationale |
| :--- | :--- | :--- | :--- |
| **Header** | Title and Settings access. | **Proof It's Working.** (Settings icon in top-right). | Focuses on validation. |
| **P2 KPIs** | Cumulative Impact Cards (Top Section). | **1. [X] Hours Reclaimed. What's next?** **2. Total Conscious Exits.** **3. Average Pause Time.** | Displays lifetime achievements and quantified benefit. |
| **Trends Graph** | Dominant visual chart. | Shows **Daily Conscious Exits vs. Daily Attempts** over the last 30 days. | Allows visualization of long-term habit pattern shift. |
| **Insight Card** | Ratio of positive choices. | **Your Intentionality Score** (Ratio of Exits vs. Pauses). | Provides deep behavioral insight. |
| **Footer** | Sign-off. | **Keep choosing wisely.** | Supportive, final message. |
| **Navigation** | **Bottom Tab Bar** (STATS active, HUB passive). | N/A | Consistent navigation structure. |

## E. Flow 3: MIGA Hub First Run Experience (F.R.E.) - Finalized

**Objective:** To guide the user through the two required setup phases: 1) Personalizing the Hub and 2) Manually enabling the app-interception feature at the OS level. This flow is mandatory on the first visit to the MIGA Hub.

---

### Phase 1: Populating the MIGA Hub (The Selection Win)

The goal of Phase 1 is to teach the user how MIGA works and to get the necessary input (which apps to monitor).

| Screen/Step | Focus Area | Headline/Copy (Tone: Intentional) | Interaction Logic / Visuals |
| :--- | :--- | :--- | :--- |
| **P1.1: Context & Goal** | **Value Proposition** | **Phase 1: Create Your Intentional Hub.** | **Rationale:** Sets the tone and establishes the user's agency. |
| | **Body** | "MIGA works by intervening when you try to open apps you want to use more mindfully. To begin, select which apps to put onto your Hub." | Illustration showing the MIGA Hub (Launcher Grid) with empty spots. |
| | **CTA** | **"Select Apps Now"** | Proceeds to the app selection screen. |
| **P1.2: App Selection** | **User Input & Personalization** | **Which Apps Are You Reclaiming Time From?** | **CRITICAL:** Selected apps populate the **Launcher Grid**. |
| | **Interaction (Pill Boxes)** | **Primary Input:** A visible block of **pill-box style buttons** for 8-10 common time-sink/social apps (e.g., TikTok, Instagram, X, Reddit, YouTube). **Secondary Input:** A clearly visible "Find other apps..." link or search bar to access the full system list if needed. | Must display an explicit minimum of 1 app selected to proceed. |
| | **CTA** | **"Hub Ready. Proceed to Phase 2 Setup"** | Stores the selected apps as the content for the Hub. |

---

### Phase 2: Enabling the Gateway (The Manual Action)

The goal of Phase 2 is to provide clear, step-by-step guidance for the single manual task required to enable MIGA's core interception feature.

| Screen/Step | Focus Area | Headline/Copy (Tone: Supportive) | Interaction Logic / Visuals |
| :--- | :--- | :--- | :--- |
| **P2.1: The Manual Instructions (PLATFORM SPECIFIC)** | **Actionable Guide** | **Phase 2: Secure Your Focus. (The 3-Step Hiding Process)** | **Rationale:** Direct, clear instructions for the manual OS task, specific to iOS (as detailed by the UX team). **(Developer Note: This must be checked for Android implementation.)** |
| | **Body** | "To ensure MIGA launches instead of the original app, you must now **secure and hide** the icons of the **[X] apps** you selected. This is a one-time step for deep focus." | Minimalist screen with persistent, numbered instructions visible. |
| | **Instruction Body (iOS Example)** | **1. Exit MIGA to Home Screen.** We will close MIGA now so you can find your apps. **2. Secure the App:** Locate one of the selected apps on your Home Screen. **Touch and hold** the icon, then tap **'Require Face ID'** (or Passcode). **3. Hide & Authenticate:** Tap **'Hide and Require Face ID'**, authenticate using your method, then tap **'Hide App'**. The app will move to the Hidden folder. **Once done for all selected apps, re-open MIGA immediately.** | **CRITICAL CTA:** **"I Understand & Ready to Begin"** (This button must close MIGA). The user starts this process on their Home Screen. |
| **P2.2: Final Confirmation** | **Positive Reinforcement** | **Setup Complete. Your Gateway is Active.** | **Rationale:** The final reward/confirmation of a completed task. |
| | **Body** | "You’ve successfully set your intentional triggers. The original app icons are secured, and the MIGA Hub will now launch your pause experience. Your focus is now protected." | |
| | **CTA** | **"Go to Your Mindful Hub"** | Navigates to the D.1. MIGA Hub screen (with the **Motivational Banner** visible). |

***
*End of MIGA MVP UX Handoff Specification v1.0*
