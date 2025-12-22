# Project Spec: XenoMirror

## 1. Product Requirements (The "What" & "Why")

### 1.1 Project Goal

Build an MVP of a gamified habit tracker where the user nurtures an AI companion ("The Mimic") that physically evolves based on the user's real-life actions. The goal is to validate if "visual mirror evolution" provides better retention than standard checkboxes.

### 1.2 Target Audience

- **Who:** People struggling with self-improvement discipline, gamers who enjoy RPG progression (Spore, Tamagotchi), and tech enthusiasts interested in AI/Sci-Fi.
- **Problem:** Traditional habit trackers are boring and lack immediate emotional reward. Motivation relies solely on willpower.
- **Solution:** Externalize self-care. Caring for the AI companion reflects caring for oneself. The "visual proof" of progress (evolution) is more satisfying than a graph.

### 1.3 Core User Flows (What the product should do)

1.  **Habit Logging (The Input):**
    - User opens the app and selects an activity (e.g., "Squats").
    - User points the camera at themselves.
    - **AI Vision** instantly validates the action (e.g., counts 5 squats).
    - _Fallback:_ If camera is inconvenient, User can log manually (Passive/Manual mode).
2.  **Instant Feedback (The Loop):**
    - Upon validation, the 3D Creature in the center of the screen pulsates (Shader Effect).
    - A text bubble appears with a context-aware comment from the AI (e.g., "Leg servos strengthened.").
3.  **Evolution (The Reward):**
    - When XP threshold is reached, a "Mutation" event triggers.
    - The creature gains a new body part (e.g., primitive legs grow into cyber-legs) corresponding to the habit type (Vitality/Mind/Soul).

### 1.4 Milestones

**Version 1 (MVP) - CONFIRMED SCOPE (2024-12-22):**

- **3D Scene:** Floating "Rayman-style" character (Core + Head/Hands/Feet anchors) inside a 2D background.
- **Habits:** 3 types only (Squats [Vitality], Reading [Mind], Meditation/Object [Soul]).
- **Logging Methods:**
  - ✅ Manual logging (buttons for quick input)
  - ✅ AI Vision (Google ML Kit for Pose Detection and Image Labeling)
- **Logic:** Basic XP system and "Charge Up" shader effect.
- **Data Storage:** Local-only (SharedPreferences + SQLite/Hive) - no cloud backend in MVP
- **AI Chat:** ❌ NOT in MVP (no OpenAI integration yet, use hardcoded flavor text instead)
- **Authentication:** ❌ NOT in MVP (single-user, local device only)

**Version 2 (Future):**

- Cloud backend migration (Supabase)
- AI chat with creature (OpenAI GPT-4o-mini, 5 messages/day limit)
- User authentication
- Full 3D Room customization
- Social features (visiting friends)
- Paid subscription (removing chat limits)

---

## 2. Engineering Requirements (The "How")

### 2.1 Tech Stack

- **Mobile Framework (Shell):** Flutter (Dart). Handles navigation, UI, and business logic.
- **3D Rendering:** Unity 2022+ (C#) exported as a library via `flutter_unity_widget`.
- **Backend & DB:** Supabase.
  - **Auth:** Supabase Auth (Email/Password).
  - **Database:** PostgreSQL.
  - **API Logic:** Supabase Edge Functions (Deno/TypeScript).
- **AI Services:**
  - **LLM:** OpenAI API (`gpt-4o-mini`) accessed via Edge Functions.
  - **Vision:** Google ML Kit (On-device Flutter package).
- **DevOps:** Docker (Dev Container) for isolated backend environment.

### 2.2 Technical Architecture

- **Hybrid Bridge:**
  - Flutter sends JSON messages to Unity (`{"action": "set_glow", "value": 0.8}`).
  - Unity listens via `UnityMessageManager` and updates the Scene graph.
- **Data Schema (Supabase):**
  - `users`: `id`, `email`, `created_at`.
  - `creature_state`: `user_id`, `xp_vitality`, `xp_mind`, `xp_soul`, `legs_tier`, `head_tier`, `arms_tier`.
  - `daily_usage`: `user_id`, `date`, `message_count` (for rate limiting).
- **Security Policies:**
  - Use Row Level Security (RLS) in Supabase so users can only read/edit their own creature data.
  - **Never** store OpenAI API keys in the app. Only call them from Edge Functions.

### 2.3 Directory Structure & Constraints

- **Root:**
  - `/lib` (Flutter Code)
  - `/unity` (Unity Project)
  - `/supabase` (Edge Functions & Migrations)
- **Rules:**
  - All business logic (XP calculation, Level Up) resides in Flutter BLoC or Supabase, NOT in Unity. Unity is strictly a "dumb" renderer.
  - Use `flutter_test` for logic verification.
  - Keep Unity assets minimal (Low Poly) to maintain small APK size.
