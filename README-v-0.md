# ?? Project XenoMirror: Game Design Document

**Version:** 1.0 (MVP)
**Status:** Pre-production
**Target Platform:** Mobile (iOS/Android)
**Core Concept:** "The Mirror Soul" � RPG Habit Tracker with Procedural AI Evolution.

---

## 1. High Concept

**XenoMirror** is a gamified self-improvement app where the user nurtures a digital entity�an alien mimic found in a cryo-pod.
Unlike standard virtual pets, **you do not feed it virtual food. You feed it your real-life habits.**

The creature is a **mirror of your lifestyle**:

- **Action:** You work out ? The creature grows cybernetic/muscular legs.
- **Action:** You read books ? The creature develops a "Third Eye" or Halo.
- **Inaction:** You neglect yourself ? The creature's light fades, and it becomes glitchy.

**The Hook:** "Don't just level up a character. Build a better version of yourself, and watch it come alive."

---

## 2. Narrative & Lore

**Setting:** You have recovered a drifting life-pod containing a shapeless "Proto-Mimic."
**Role:** You are the Custodian. The creature has no context of Earth. It learns what it means to be alive by observing _you_.
**AI Persona:**

- _Phase 1 (The Stranger):_ Cold, analytical, confused. Uses scientific jargon.
- _Phase 2 (The Student):_ Curious, tries to mimic user's slang, asks "Why?".
- _Phase 3 (The Symbiont):_ Deeply empathetic, encouraging, your "best self."

---

## 3. Core Gameplay Loop

1.  **Action:** User performs a real-world activity (Squats, Reading, Drinking Water).
2.  **Validation:**
    - _Primary:_ **AI Snapshot** (Camera analyzes one frame via ML).
    - _Passive:_ Health Kit / Pedometer integration.
3.  **Feedback (Instant):**
    - Creature pulses with energy (Shader Effect).
    - Short AI comment: _"Kinetic energy absorbed. Efficiency +2%."_
4.  **Evolution (Long-term):**
    - XP bar fills up ? Creature mutates (New body part appears).

---

## 4. Visuals & "Spore" Engine (MVP)

### 4.1 "Rayman" Architecture (Floating Limbs)

To minimize asset production costs and rigging issues:

- The character consists of **floating parts** (Head, Hands, Feet) detached from the Torso.
- **Benefits:** No skinning required, easy scaling, parts from different sets (e.g., Gym Legs + Nerd Head) never clip.

### 4.2 The "Charge Up" Shader (Visual Progression)

Instead of creating 100 intermediate models, we use a **PBR Shader Graph**:

- **0% XP:** The creature is matte/dull.
- **50% XP:** Energy veins begin to glow on the surface.
- **99% XP:** The creature pulsates violently with emission, signaling readiness to evolve.

### 4.3 Environment

- **Background:** High-quality 2D Art (AI Generated via Midjourney/Stable Diffusion).
- **Progression:** Dirty Cryo-pod ? Clean Lab ? High-Tech Bridge ? Cosmic Throne.

---

## 5. RPG Mechanics (S.P.E.C.I.A.L.)

The body is divided into 3 modular zones based on habits:

| Attribute    | Input (Habits)           | Visual Output (Body Part)                    | Archetype |
| :----------- | :----------------------- | :------------------------------------------- | :-------- |
| **VITALITY** | Sports, Sleep, Nutrition | **Legs & Core.** (Thrusters, Armor, Muscles) | Titan     |
| **MIND**     | Reading, Study, Planning | **Head & Sensors.** (Halos, Optics, Runes)   | Psionic   |
| **SOUL**     | Hobbies, Art, Meditation | **Arms & Aura.** (Tools, Colors, Particles)  | Creator   |

---

## 6. Technical Architecture

**Stack:** Hybrid Mobile App (Flutter Shell + Unity Core).

### 6.1 Client Side

- **App UI:** **Flutter (Dart)**. Handles Lists, Chat, Settings, Navigation.
- **3D Renderer:** **Unity** (via `flutter_unity_widget`). Renders the Creature and Room.
- **Vision AI:** **Google ML Kit** (On-device).
  - _Pose Detection:_ For counting squats/exercises.
  - _Image Labeling:_ For identifying objects (Book, Fruit).

### 6.2 Backend & Logic

- **BaaS:** **Supabase**.
  - _Auth:_ User login.
  - _Database (PostgreSQL):_ User stats, Creature DNA string (`legs_tier: 2`).
  - _Edge Functions (JS/TS):_ Server-side logic for AI communication.
- **AI Brain:** **OpenAI API** (GPT-4o-mini).

---

## 7. Economy & Rate Limiting (Cost Control)

To prevent bankruptcy from API costs, we introduce **"Communication Energy"**.

- **Lore:** "My translation systems overheat easily. I need to cool down."
- **Mechanic:** The user gets **5 free AI interactions per day**.
- **Implementation:** Supabase Edge Function checks `daily_message_count` before calling OpenAI.
- **Monetization (Future):** Premium subscription removes the limit.

---

## 8. MVP Roadmap (Week 1 Sprint)

### Day 1-2: The Bridge

- [ ] Initialize Flutter Project.
- [ ] Initialize Unity Project.
- [ ] Setup `flutter_unity_widget` to show a spinning cube inside the Flutter app.

### Day 3: Visuals

- [ ] Create "Rayman" Rig in Unity (Core + 4 Anchor points).
- [ ] Implement **"Charge Up" Shader** (Glow varies by float parameter).
- [ ] Import 2D Background (Generated).

### Day 4: Logic & Backend

- [ ] Setup Supabase Project (Tables: `users`, `creature_state`).
- [ ] Write Edge Function for OpenAI chat with **Rate Limiting** logic.

### Day 5: Integration

- [ ] Connect Flutter Button ("Train") ? Unity Animation ("Happy") ? Shader Update ("Glow").

---

## 9. Risk Management

| Risk                         | Mitigation                                                                                 |
| :--------------------------- | :----------------------------------------------------------------------------------------- |
| **Friction (User Laziness)** | Allow "Passive Tracking" (HealthKit) or "Manual Log" (Lower XP) if camera is inconvenient. |
| **Battery Drain**            | Unload/Pause Unity widget when not on the Home Screen.                                     |
| **Asset Creep**              | Use primitive shapes + VFX for Tiers 0-1. Do not model complex bodies until Tier 2.        |
