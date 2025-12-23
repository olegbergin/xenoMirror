# Project Spec: XenoMirror

**Version**: 1.0 MVP
**Last Updated**: 2025-12-23
**Current Phase**: Phase 1 Complete (Data Layer) ✅

---

## 1. Product Requirements (The "What" & "Why")

### 1.1 Project Goal

Build an MVP of a gamified habit tracker where the user nurtures an AI companion ("The Mimic") that physically evolves based on the user's real-life actions. The goal is to validate if "visual mirror evolution" provides better retention than standard checkboxes.

### 1.2 Target Audience

- **Who:** People struggling with self-improvement discipline, gamers who enjoy RPG progression (Spore, Tamagotchi), and tech enthusiasts interested in AI/Sci-Fi.
- **Problem:** Traditional habit trackers are boring and lack immediate emotional reward. Motivation relies solely on willpower.
- **Solution:** Externalize self-care. Caring for the AI companion reflects caring for oneself. The "visual proof" of progress (evolution) is more satisfying than a graph.

### 1.3 Core User Flows (What the product should do)

1. **Habit Logging (The Input):**
   - User opens the app and selects an activity (e.g., "Squats").
   - **Option A (AI Vision):** User points the camera at themselves. AI instantly validates the action (e.g., counts 5 squats).
   - **Option B (Manual):** User logs manually via button tap (Passive/Manual mode).

2. **Instant Feedback (The Loop):**
   - Upon validation, the 3D Creature in the center of the screen pulsates (Shader Effect).
   - A text bubble appears with context-aware feedback (e.g., "Leg servos strengthened.").

3. **Evolution (The Reward):**
   - When XP threshold is reached, a "Mutation" event triggers.
   - The creature gains a new body part (e.g., primitive legs → cyber-legs) corresponding to the habit type (Vitality/Mind/Soul).

---

## 2. MVP Scope (Version 1.0)

### 2.1 Included Features ✅

**Phase 1 (COMPLETE):**
- ✅ **Data Layer:** Hive-based local storage with repository pattern
- ✅ **Domain Models:** CreatureState, HabitEntry with type-safe serialization
- ✅ **XP System:** Polynomial progression curve (100/400/1000 tier thresholds)
- ✅ **Clean Architecture:** Repository interfaces ready for future Supabase migration
- ✅ **Test Coverage:** 90%+ on core data layer and XP calculations

**Phase 2 (IN PROGRESS):**
- 🚧 **UI/UX Design:** Main app screens (home, habit logging, creature detail)
- 🚧 **Manual Habit Logging:** Buttons for 3 habit types (Vitality/Mind/Soul)

**Phase 3 (PLANNED):**
- 📋 **Unity Creature:** Floating "Rayman-style" character (Core + Head/Hands/Feet anchors)
- 📋 **Visual Evolution:** 3 body part tiers per attribute (9 total variations)
- 📋 **"Charge Up" Shader:** Emission glow that increases with XP percentage
- 📋 **AI Vision:** Google ML Kit for Pose Detection (squats) and Image Labeling (books, meditation objects)

**MVP Success Criteria:**
- User can log habits manually via buttons
- XP persists across app restarts (local storage only)
- 3D creature displays glow intensity based on current XP
- Creature swaps body part models when tier thresholds are crossed
- AI Vision validates at least 1 activity type (pose detection)
- No crashes on physical Android device
- 80%+ test coverage on business logic

### 2.2 Explicitly Excluded from MVP ❌

- ❌ **AI Chat with Creature:** No OpenAI integration (use hardcoded flavor text instead)
- ❌ **Cloud Backend:** No Supabase, no multi-device sync (local-only in MVP)
- ❌ **User Authentication:** Single-user, no login/signup flow
- ❌ **Social Features:** No visiting friends, no leaderboards
- ❌ **In-App Purchases:** No monetization in MVP
- ❌ **Room Customization:** Basic 2D background only

### 2.3 Milestones

**Version 1.0 (MVP) - Current Target:**
- Basic habit tracking with 3 types (Squats, Reading, Meditation)
- Local data persistence (Hive)
- 3D creature with tier-based evolution (9 body part variants)
- Manual + AI Vision logging (Google ML Kit)
- Hardcoded feedback messages (no LLM)

**Version 2.0 (Future) - Post-MVP:**
- Cloud backend migration (Supabase PostgreSQL)
- User authentication (Supabase Auth)
- AI chat with creature (OpenAI GPT-4o-mini, 5 messages/day limit)
- Multi-device sync
- Social features (visiting friends' creatures)
- Paid subscription (removes chat rate limits)

---

## 3. Current Implementation (MVP Tech Stack)

### 3.1 Technologies in Use

| Component | Technology | Status | Purpose |
|-----------|------------|--------|---------|
| **Mobile Framework** | Flutter (Dart) | ✅ Active | UI shell, navigation, business logic |
| **3D Rendering** | Unity 2022.3 LTS (URP) | ✅ Active | Creature visualization, shaders |
| **Bridge** | flutter-unity-view-widget | ✅ Active | Flutter ↔ Unity communication |
| **Data Storage** | Hive (NoSQL) | ✅ Implemented | Local creature state & habit history |
| **Architecture** | Clean Architecture + BLoC | ✅ Implemented | Separation of concerns, testability |
| **Vision AI** | Google ML Kit | 📋 Planned | On-device pose detection & image labeling |
| **Testing** | flutter_test + mockito | ✅ Active | Unit & widget tests, 80%+ coverage |

### 3.2 Current Data Model (Phase 1 Complete)

**CreatureState** (Hive TypeAdapter):
```dart
{
  xpVitality: int,    // Sports, sleep, nutrition XP
  xpMind: int,        // Reading, study, planning XP
  xpSoul: int,        // Hobbies, art, meditation XP
  lastUpdated: DateTime
}
```

**HabitEntry** (Hive TypeAdapter):
```dart
{
  id: String,
  habitType: HabitType (vitality | mind | soul),
  xpGained: int,
  timestamp: DateTime,
  notes: String?
}
```

**XP Progression Formula:**
- Tier 1: 0-100 XP (Basic body parts)
- Tier 2: 100-400 XP (Enhanced parts, +300 XP gap)
- Tier 3: 400-1000 XP (Advanced evolution, +600 XP gap)
- Formula: Polynomial curve for satisfying progression feel

### 3.3 Architecture Principles

**Data Flow (Clean Architecture):**
```
Presentation Layer (BLoC)
    ↓ Commands
Domain Layer (Use Cases, Entities)
    ↓ Interfaces
Data Layer (Repositories, Data Sources)
    ↓ Storage
Hive Local Database
```

**Flutter ↔ Unity Communication:**
- **Flutter → Unity:** JSON messages via `UnityWidgetController.postMessage()`
  - Example: `{"action": "set_glow", "value": 0.8}`
- **Unity → Flutter:** Public C# methods receive string messages
  - Unity is a "dumb renderer" - no business logic, only visualization
- **Business Logic Location:** All XP calculation, tier logic, and game rules live in Flutter (BLoC), **NOT in Unity**

### 3.4 Directory Structure

```
client_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── xp_constants.dart       # Tier thresholds, progression formulas
│   │   └── utils/
│   ├── data/
│   │   ├── datasources/
│   │   │   └── local_data_source.dart  # Hive box operations
│   │   ├── models/
│   │   │   ├── creature_state.dart     # Hive model with TypeAdapter
│   │   │   └── habit_entry.dart        # Hive model with TypeAdapter
│   │   └── repositories/
│   │       ├── creature_repository.dart     # Concrete implementation
│   │       └── habit_repository.dart        # Concrete implementation
│   ├── domain/
│   │   ├── entities/                   # Business objects (pure Dart)
│   │   └── repositories/
│   │       ├── i_creature_repository.dart   # Interface for migration
│   │       └── i_habit_repository.dart      # Interface for migration
│   ├── presentation/
│   │   ├── bloc/                       # State management (planned)
│   │   ├── pages/                      # Screens (planned)
│   │   └── widgets/                    # Reusable UI components
│   └── main.dart
├── test/
│   ├── unit/                           # Business logic tests (90%+ coverage)
│   ├── widget/                         # UI component tests
│   └── helpers/
│       └── test_data.dart              # Mock data generators
└── unity/xeno_unity/
    └── Assets/
        ├── Creature/                   # 3D models, shaders (planned)
        └── FlutterUnityIntegration/    # Bridge plugin
```

---

## 4. Future Architecture (Version 2.0+)

### 4.1 Planned Backend Stack (Post-MVP)

**When cloud features are needed:**

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Backend** | Supabase | PostgreSQL database + Auth + Edge Functions |
| **Database** | PostgreSQL | Relational data with Row Level Security (RLS) |
| **Authentication** | Supabase Auth | Email/password login |
| **API Logic** | Supabase Edge Functions | Deno/TypeScript serverless functions |
| **AI Chat** | OpenAI GPT-4o-mini | Creature personality (rate-limited to 5 msg/day) |
| **Real-time Sync** | Supabase Realtime | Live updates across devices |

### 4.2 Future Data Schema (Supabase PostgreSQL)

**Tables:**
```sql
-- Users table (Supabase Auth manages this)
users (
  id uuid PRIMARY KEY,
  email text,
  created_at timestamp
)

-- Creature state (one per user)
creature_state (
  user_id uuid PRIMARY KEY REFERENCES users(id),
  xp_vitality int DEFAULT 0,
  xp_mind int DEFAULT 0,
  xp_soul int DEFAULT 0,
  legs_tier int DEFAULT 1,
  head_tier int DEFAULT 1,
  arms_tier int DEFAULT 1,
  last_updated timestamp
)

-- Habit history (many per user)
habit_entries (
  id uuid PRIMARY KEY,
  user_id uuid REFERENCES users(id),
  habit_type text CHECK (habit_type IN ('vitality', 'mind', 'soul')),
  xp_gained int,
  timestamp timestamp,
  notes text
)

-- AI chat rate limiting
daily_usage (
  user_id uuid PRIMARY KEY REFERENCES users(id),
  date date,
  message_count int DEFAULT 0,
  CONSTRAINT max_messages CHECK (message_count <= 5)
)
```

**Row Level Security (RLS) Policies:**
- Users can only read/write their own `creature_state`
- Users can only insert/read their own `habit_entries`
- Edge Functions bypass RLS for admin operations

### 4.3 Migration Strategy (Hive → Supabase)

**When user first signs up for cloud sync:**

1. User creates account (Supabase Auth)
2. App exports local Hive data to JSON
3. Edge Function imports data into PostgreSQL
4. App switches repository implementation:
   - `LocalCreatureRepository` → `SupabaseCreatureRepository`
   - Same interface (`ICreatureRepository`), no BLoC changes needed
5. Local Hive data is kept as offline cache

**Benefits of Repository Pattern:**
- No changes to business logic (BLoC) when switching backends
- Can test with mock repositories
- Easy rollback if cloud migration fails

### 4.4 AI Chat Implementation (Future)

**Architecture:**
```
Flutter UI
    ↓ User message
Edge Function (Deno)
    ↓ Check rate limit (daily_usage table)
    ↓ Build context prompt (creature state + recent habits)
OpenAI API (GPT-4o-mini)
    ↓ AI response
Edge Function
    ↓ Increment message_count
Flutter UI (display response)
```

**Security:**
- OpenAI API key stored in Supabase Edge Function secrets (never in app)
- Rate limiting enforced server-side (5 messages/day free, unlimited for paid)
- User cannot bypass limit by modifying app code

**Prompt Template:**
```
You are an alien creature learning about Earth by observing the user.
Your current state:
- Vitality XP: {xp_vitality} (Tier {legs_tier})
- Mind XP: {xp_mind} (Tier {head_tier})
- Soul XP: {xp_soul} (Tier {arms_tier})

Recent activities:
{habit_history_last_7_days}

User says: "{user_message}"

Respond as the creature (curious, analytical, occasionally misunderstanding human concepts).
```

---

## 5. Engineering Constraints & Rules

### 5.1 Development Rules

- **Business Logic Location:** All XP calculation, tier thresholds, and game rules belong in Flutter (BLoC) or future backend, **NEVER in Unity**
- **Unity's Role:** Strictly a "dumb renderer" - only handles 3D visualization and shader effects
- **Asset Optimization:** Keep Unity assets low-poly to maintain APK size under 50MB
- **Test Coverage:** Maintain 80%+ coverage on all business logic (data layer, use cases, BLoC)
- **No Hardcoded Secrets:** API keys must go in environment variables or Supabase secrets

### 5.2 Performance Targets

- **App Launch:** Under 3 seconds on mid-range Android device (2020+)
- **Habit Logging:** Under 500ms from button tap to visual feedback
- **XP Animation:** Smooth 60fps during "Charge Up" shader transitions
- **APK Size:** Under 50MB for initial download (Unity compression critical)
- **Battery Drain:** Under 5% per hour of active use

### 5.3 Design Constraints

**Visual Style:**
- **"Rayman Architecture":** Floating body parts (avoids rigging complexity)
- **Low-Poly Aesthetic:** Small file size, fast rendering, stylized look
- **Shader-Based Effects:** Use URP Shader Graph for glow, not additional geometry

**UX Principles:**
- **Instant Feedback:** Every action should trigger immediate visual response
- **No Friction:** Logging a habit should take max 3 taps
- **Forgiving:** Manual logging always available if AI vision fails
- **Transparent:** XP gains should be visible (no hidden mechanics)

---

## 6. Success Metrics (How we measure MVP success)

### 6.1 MVP Validation Criteria

**Product Metrics:**
- **Retention:** 40%+ Day 7 retention (vs ~10% for standard habit trackers)
- **Engagement:** Average 3+ habit logs per day per user
- **Completion:** 60%+ of users reach Tier 2 in at least one attribute
- **Session Length:** Average 2-5 minutes per session (quick check-ins)

**Technical Metrics:**
- **Crash Rate:** Under 1% of sessions
- **Test Coverage:** 80%+ on business logic
- **Build Success:** 95%+ CI/CD pass rate
- **Performance:** 60fps during all animations

### 6.2 User Feedback Questions

After 2 weeks of MVP testing:
1. "Did you feel more motivated to do habits because of the creature?" (Yes/No)
2. "Which feature was most satisfying?" (Evolution animation / XP glow / Flavor text)
3. "Would you pay $3/month for AI chat with the creature?" (Yes/No/Maybe)
4. "What habit type did you log most often?" (Vitality/Mind/Soul)

---

## 7. Risk Assessment

### 7.1 Technical Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Flutter-Unity bridge crashes** | Medium | High | Extensive testing on multiple devices, fallback 2D mode |
| **AI Vision accuracy too low** | High | Medium | Manual logging always available as fallback |
| **APK size exceeds 50MB** | Medium | Medium | Unity asset compression, low-poly models |
| **Hive data corruption** | Low | High | Daily backups, export/import functionality |

### 7.2 Product Risks

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| **Users prefer standard checkbox UI** | Medium | High | A/B test with control group (traditional tracker) |
| **3D creature is "creepy" not "cute"** | Medium | High | User testing on art style before full implementation |
| **Progression feels too slow/fast** | High | Medium | Make XP thresholds configurable, gather feedback |
| **AI chat is too expensive** | Low | Medium | Rate limiting (5 msg/day), use GPT-4o-mini (cheap) |

---

## 8. Open Questions

### 8.1 Design Questions (Need User Testing)

- **Q1:** Should the creature have a "hunger" mechanic if user doesn't log habits for 3+ days?
  - **Pro:** Adds urgency, emotional connection
  - **Con:** Could feel punishing, cause guilt
  - **Decision:** Test with opt-in "Challenge Mode" (default: no decay)

- **Q2:** Should evolution be reversible if user stops logging habits?
  - **Pro:** Reinforces "mirror" concept (realistic)
  - **Con:** Demotivating to lose progress
  - **Decision:** No tier regression in MVP, revisit based on feedback

### 8.2 Technical Questions (Need Prototyping)

- **Q3:** How to handle partial habit completion (e.g., user quits mid-workout)?
  - **Option A:** Only award XP when full activity is validated
  - **Option B:** Award partial XP based on detected reps/time
  - **Decision:** Option A for MVP (simpler), Option B if users complain

- **Q4:** Should XP formulas be server-authoritative or client-calculated?
  - **MVP:** Client-calculated (local-only, no server)
  - **v2.0:** Server-authoritative (prevents cheating, consistent across devices)

---

## 9. Related Documentation

- **`README.md`**: Setup instructions, build pipeline
- **`CLAUDE.md`**: AI assistant guidelines, development patterns
- **`docs/architecture.md`**: Technical deep-dive on data flow
- **`docs/project_status.md`**: Current sprint status, blockers
- **`docs/changelog.md`**: Session summaries, decision history

---

**Document Version**: 1.0
**Last Reviewed**: 2025-12-23
**Next Review**: After MVP completion (estimated mid-January 2025)
