# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**XenoMirror** is a gamified habit tracker where users nurture a digital alien creature that evolves based on real-life habits. The app uses Flutter for the UI shell and Unity for 3D rendering of the creature, bridged via `flutter-unity-view-widget`.

**Core Concept:** "The Mirror Soul" - your habits feed the creature's evolution (workout → muscular legs, reading → third eye, neglect → glitchy appearance).

## 🎯 MVP CRITICAL DECISIONS (2024-12-22)

**These answers define the scope and priorities for MVP development:**

### Question 1: MVP Feature Set
**Included in MVP:**
- ✅ **Visual Evolution System** - 3D creature with shader effects that change based on XP
- ✅ **Manual Habit Logging** - User can log activities via buttons (no camera required)
- ✅ **AI Vision Integration** - Google ML Kit for camera-based activity validation (pose detection for exercises, image labeling for objects)

**NOT in MVP:**
- ❌ AI Chat with creature (no OpenAI integration)
- ❌ Cloud sync / Multi-device support (start local-only)
- ❌ Social features

### Question 2: Backend Infrastructure
**Current Status:** No backend infrastructure exists yet. Just completed basic app structure and build pipeline.

**MVP Approach:**
1. **Phase 1 (Immediate):** Use local storage (SharedPreferences for simple data, SQLite/Hive for creature state)
2. **Phase 2 (Future):** Migrate to Supabase when cloud features are needed

**Rationale:** Local-first approach allows faster MVP iteration without backend complexity.

### Question 3: AI Budget & Integration
**Decision:** No OpenAI API integration in MVP
- No chat functionality with creature
- Use hardcoded responses or pre-written flavor text for feedback
- Can add "Coming Soon" UI placeholder where chat would go

**Future:** When budget allows, integrate GPT-4o-mini with rate limiting (5 messages/day)

### MVP Development Priorities (In Order)
1. **Data Layer:** Create local storage system for creature state (XP, body part tiers)
2. **Habit Logging UI:** Simple buttons for 3 habit types (Vitality/Mind/Soul)
3. **XP System Logic:** Calculate and store XP in Flutter (NOT Unity)
4. **Unity Creature:** Build modular "Rayman-style" creature with tier system
5. **Shader System:** Implement "Charge Up" shader that reacts to XP percentage
6. **Flutter→Unity Bridge:** Send XP/tier data to Unity to trigger visual changes
7. **AI Vision:** Integrate Google ML Kit for pose detection (squats) and object recognition (books)
8. **Polish:** Smooth transitions, particle effects, satisfying feedback

## Technology Stack

- **Frontend Shell:** Flutter (Dart) - handles UI, navigation, and business logic
- **3D Rendering:** Unity 2022.3 LTS (URP) - renders creature and environment
- **Bridge:** `flutter-unity-view-widget` (master branch from GitHub)
- **Target Platform:** Android (ARM64/ARMv7) - requires physical device, emulators not supported
- **Data Storage (MVP):** Local storage (SharedPreferences + SQLite/Hive) - no cloud backend yet
- **Vision AI (MVP):** Google ML Kit (On-device) - for pose detection and image labeling
- **Future Backend:** Supabase (when cloud sync needed)
- **Future AI Chat:** OpenAI GPT-4o-mini (when budget allows)

## Project Structure

```
D:\xenoMirror\client_app\          # Flutter project root
├── docs/                           # Detailed technical documentation
│   ├── .metadata.json              # Last update timestamps for /update-docs
│   ├── architecture.md             # System design & technical decisions
│   ├── changelog.md                # Session-based change history
│   ├── project_status.md           # Current sprint status & next steps
│   └── features/                   # Feature-specific documentation
│       ├── _template.md            # Template for new feature docs
│       └── flutter-unity-bridge.md # Current POC documentation
├── lib/                            # Flutter Dart code
│   └── main.dart                   # Main entry point with Unity integration demo
├── unity/xeno_unity/               # Unity source project (scenes, C# scripts)
│   └── Assets/
│       ├── ColorChanger.cs         # Example Unity script for Flutter communication
│       └── FlutterUnityIntegration/ # Bridge plugin files
├── android/
│   ├── unityLibrary/               # [GENERATED] Unity export (DO NOT EDIT MANUALLY)
│   ├── build.gradle.kts            # Build config (NDK fixes here)
│   └── settings.gradle.kts         # Module config (includes :unityLibrary)
├── README.md                       # Project overview & setup guide
├── CLAUDE.md                       # AI assistant instructions (this file)
├── project_spec.md.md              # Product requirements document
└── pubspec.yaml                    # Flutter dependencies
```

## Development Environment Setup (Windows)

**Required Versions:**
- Flutter SDK 3.x (Stable)
- Visual Studio 2022 with "Desktop development with C++" workload
- Android Studio with:
  - SDK Platform (API 24+)
  - SDK Command-line Tools
  - **NDK (Critical):** Two side-by-side versions required:
    - `23.1.7779620` (for Unity IL2CPP)
    - `27.0.12077973` (for Flutter plugins)
- Unity Hub with Unity 2022.3 LTS

**Note:** Docker was abandoned for native Windows development to avoid `il2cpp.exe` and GPU driver issues.

## Build Commands

### Initial Setup
```powershell
# In client_app/ directory
flutter pub get
```

### Unity Export (Required before Flutter build)
1. Open `client_app/unity/xeno_unity` in Unity Hub (2022.3 LTS)
2. Use the plugin's "Export Android (debug)" option from Unity editor
   - This generates/updates `android/unityLibrary/` directory

### Running the App
```powershell
# IMPORTANT: Connect a physical Android device via USB (Debug mode enabled)
# x86_64 emulators are NOT supported by Unity
flutter run
```

### Testing
```powershell
flutter test
```

### Build APK
```powershell
flutter build apk --release
```

### Documentation Updates
```powershell
# User triggers manually when docs need refresh
# This analyzes recent commits and updates docs/ accordingly
/update-docs
```

## Architecture Principles

### Flutter ↔ Unity Communication
- **Flutter → Unity:** Use `UnityWidgetController.postMessage(gameObjectName, methodName, message)`
  - Example: `controller.postMessage('Cube', 'SetColor', 'red')`
- **Unity → Flutter:** Unity scripts receive messages via public methods
  - Example: `public void SetColor(string message)` in C# script attached to GameObject

### Code Organization Rules
- **Business Logic Location:** All XP calculation, level-up logic, and game mechanics belong in Flutter (BLoC) or Supabase, **NOT in Unity**
- **Unity's Role:** Unity is a "dumb renderer" - it only handles 3D visualization and visual effects
- **Asset Management:** Keep Unity assets minimal (low poly) to maintain small APK size

### Current Implementation Status
The codebase currently contains a **proof-of-concept** demo:
- `lib/main.dart` - Basic Flutter UI with two buttons that send color commands to Unity
- `unity/xeno_unity/Assets/ColorChanger.cs` - Unity script that receives color commands and changes a cube's material
- The full RPG system, habit tracking, AI vision, and backend are **not yet implemented**

## Key Development Patterns

### Flutter Side (lib/main.dart)
- Store `UnityWidgetController` reference in `_onUnityCreated` callback
- Use `UnityWidget` with `useAndroidViewSurface: true` for proper Android rendering
- Check controller is not null before sending messages

### Unity Side (Assets/*.cs)
- Attach scripts to GameObjects in Unity Editor
- Use public methods for Flutter-callable functions
- Access Unity components via `GetComponent<T>()`

## Common Issues & Solutions

### "dlopen failed: library not found" error
- Cause: Using x86_64 emulator instead of ARM device
- Solution: Always use a physical Android device connected via USB

### Unity export not found
- Cause: Forgot to export Unity project before Flutter build
- Solution: Re-export from Unity using plugin's Export Android option

### NDK version mismatch
- Cause: Only one NDK version installed
- Solution: Install both required NDK versions (23.1.7779620 and 27.0.12077973) side-by-side in Android Studio SDK Manager

## Planned Features (Not Yet Implemented)

### RPG System (S.P.E.C.I.A.L.)
Three attribute types will drive creature evolution:
- **VITALITY** (Sports, Sleep, Nutrition) → Legs & Core (Thrusters, Armor, Muscles)
- **MIND** (Reading, Study, Planning) → Head & Sensors (Halos, Optics, Runes)
- **SOUL** (Hobbies, Art, Meditation) → Arms & Aura (Tools, Colors, Particles)

### AI Vision Integration
- Google ML Kit for Pose Detection and Image Labeling
- Camera validation of user activities (e.g., counting squats)
- Manual logging fallback option

### Data Persistence (MVP: Local-First)
**Current Approach (MVP):**
- Local storage using SharedPreferences (simple key-value data)
- SQLite or Hive for structured creature state data
- No authentication required for MVP
- All data stays on device

**Future Backend Migration:**
- Supabase Auth (Email/Password)
- PostgreSQL schema: `users`, `creature_state`, `daily_usage`
- Row Level Security (RLS) for user data isolation
- Supabase Edge Functions for OpenAI API calls (rate limited to 5 messages/day)
- Migration path: export local data → import to Supabase on first cloud sync

### Visual Style
- "Rayman Architecture" - floating body parts to avoid rigging complexity
- "Charge Up" Shader - PBR Shader Graph with emission glow that increases with XP

## Git Workflow Notes

Current branch: `master`
- Repository: https://github.com/olegbergin/xenoMirror
- Follow conventional commits format when possible (feat:, fix:, docs:, etc.)

## Documentation System

### Automated Docs Location
The project uses an automated documentation system in the `docs/` directory:

- **`docs/architecture.md`**: Deep dive into system design, data flow, and technical decisions. Update this when you make architectural changes (new components, bridge protocol changes, major refactors).

- **`docs/changelog.md`**: Human-readable session summaries. This is NOT just git history - it's a natural language changelog explaining what was accomplished each session, why decisions were made, and what blockers were encountered.

- **`docs/project_status.md`**: Critical for resuming work after breaks. Contains current sprint goals, recently completed tasks, blockers, and next steps. Update at start/end of each session.

- **`docs/features/`**: Individual feature documentation. Each major feature (habit logging, XP system, creature evolution, etc.) gets its own markdown file following the `_template.md` structure.

### When to Update Docs

**Manual trigger**: User will run `/update-docs` command when they want documentation refreshed. DO NOT auto-update without this command.

**What `/update-docs` does**:
1. Read `docs/.metadata.json` for last update timestamp
2. Analyze git commits since last update: `git log --since=<timestamp> --oneline --name-status`
3. Ask user for session summary ("What did you accomplish this session?")
4. Update relevant docs:
   - `changelog.md`: Add new session block (reverse chronological order)
   - `project_status.md`: Move "Current Focus" to "Recently Completed", ask for new focus
   - `architecture.md`: Only update if architectural changes detected (bridge protocol, new major components)
   - Feature docs: Update if related files were modified (update Status + Implementation Checklist)

**Detection logic**:
- New files in `lib/` → Ask: "Should I create a feature doc for this?"
- Changes to `main.dart` or Unity scripts → Update `architecture.md` (bridge changes likely)
- Changes to `pubspec.yaml` (dependencies) → Update `architecture.md` (new packages section)
- Commit messages with `feat:`, `fix:`, `docs:` → Categorize changes appropriately

### Merge Strategy (Preserving Manual Edits)

**Problem**: Docs may have manual edits that shouldn't be overwritten.

**Solution**: Section-aware updates

For `changelog.md`:
- Always safe - just prepend new session block (reverse chronological)

For `project_status.md`:
- **Replace**: "Current Focus", "Recently Completed", "Session History" (auto-generated sections)
- **Preserve**: "Blockers & Open Questions" (user may manually edit)

For `architecture.md`:
- Check if file modified after last auto-update (compare file mtime vs metadata timestamp)
- If manually edited: Show diff, ask "Manual edits detected. Overwrite? (yes/no)"
- If not: Safe to auto-update

For feature docs:
- Only update "Status" field and "Implementation Checklist" sections
- Preserve "Known Issues", "References", and manual notes

### Root Docs vs docs/ Directory

**Separation of concerns**:
- `README.md`: High-level project intro, setup instructions, "how to build" (stable, rarely changes)
- `CLAUDE.md`: Instructions for AI assistant (build commands, coding patterns, constraints)
- `project_spec.md.md`: Product requirements, user stories, MVP scope
- `docs/`: Detailed technical documentation that evolves with code

**When to update which**:
- Add new build step → Update `README.md` + `CLAUDE.md`
- Change MVP scope → Update `project_spec.md.md`
- Implement new feature → Update `docs/features/`, possibly `docs/architecture.md`
- Complete work session → Update `docs/changelog.md` + `docs/project_status.md`
