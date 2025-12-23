# XenoMirror Changelog

All notable changes to the XenoMirror project are documented here.
Format: Session-based entries (not individual commits).

---

## Session: 2024-12-22 - Local Supabase Backend Integration
**Duration**: ~2 hours
**Focus**: Set up local Supabase backend with environment-based configuration

### Added
- Local Supabase instance running in Docker (PostgreSQL + PostgREST + GoTrue + Storage + Studio)
- `supabase_flutter` package for database client integration
- `flutter_dotenv` package for secure environment variable management
- `lib/config/supabase_config.dart` - Configuration class reading from .env
- `lib/core/supabase_client.dart` - Global Supabase client helper
- `.env.example` - Template for developers to set up local credentials
- `/update-docs` slash command for automated documentation updates

### Changed
- `.gitignore` - Added environment file exclusions (.env, .env.local, .env.*.local)
- `lib/main.dart` - Added Supabase initialization before app start
- `pubspec.yaml` - Added supabase_flutter and flutter_dotenv dependencies
- `test/widget_test.dart` - Fixed test to work with new app structure (XenoApp)

### Architecture Changes
- **Backend separation**: Supabase initialized in project root (`D:\xenoMirror\supabase/`) separate from Flutter client
- **Environment-based config**: Credentials loaded from .env file (not hardcoded)
- **Local-first approach**: Development uses local Supabase (http://127.0.0.1:54321), production will use cloud instance
- **Security**: .env files excluded from git to prevent credential leaks

### Technical Notes
- Supabase CLI v2.67.1 installed via Scoop
- Local Supabase services accessible at:
  - Studio UI: http://127.0.0.1:54323
  - REST API: http://127.0.0.1:54321/rest/v1
  - GraphQL: http://127.0.0.1:54321/graphql/v1
- Database schema design is next step (creature_state, habit_logs tables)

### Next Session Prep
- Design PostgreSQL schema for creature state and habit entries
- Create initial Supabase migrations
- Implement data repository layer in Flutter

---

## Session: 2025-12-22 - MVP Architecture Planning & Documentation System
**Duration**: ~3 hours
**Focus**: Defining MVP scope and creating automated documentation infrastructure

### Added
- Designed automated documentation system (`docs/` folder structure)
- Created comprehensive system architecture documentation
- Defined MVP critical decisions (local-first, no AI chat, Google ML Kit vision)
- Established development priorities (8-step roadmap)

### Changed
- Updated `CLAUDE.md` with MVP scope and technology stack details
- Updated `project_spec.md.md` with confirmed MVP feature set
- Updated `README.md` with corrected library references and build instructions

### Technical Decisions
- **Backend approach**: Start with local storage (SharedPreferences + SQLite/Hive), migrate to Supabase later
- **AI integration**: No OpenAI chat in MVP (cost control), use hardcoded flavor text
- **Vision AI**: Include Google ML Kit for pose detection and image labeling in MVP
- **Documentation trigger**: Manual `/update-docs` command (user-controlled, not automatic)
- **Language**: All new documentation in English (open-source standard)

### Next Session Prep
- Implement data layer (choose between Hive vs SQLite)
- Create habit logging UI (3 habit type buttons)
- Design XP calculation logic in Flutter BLoC

---

## Session: 2025-12-21 - Flutter-Unity Bridge Proof-of-Concept
**Duration**: ~3 hours
**Focus**: Validating Flutter ↔ Unity communication works on physical Android device

### Added
- `lib/main.dart`: UnityControlScreen with color control demo (2 FloatingActionButtons)
- `unity/xeno_unity/Assets/ColorChanger.cs`: Unity script receiving Flutter messages via postMessage
- Updated Unity scene with Cube GameObject + ColorChanger component attached

### Changed
- `README.md`: Added detailed build pipeline documentation (Unity export → Flutter run)
- `CLAUDE.md`: Documented architecture principles, technology stack, common issues

### Technical Notes
- **Confirmed working**: `postMessage('Cube', 'SetColor', 'red')` successfully changes cube color
- **Tested on**: Physical Android device (ARM architecture)
- **Confirmed limitation**: x86_64 emulator fails as expected (Unity ARM-only)
- **Bridge protocol**: Currently plain string messages, will migrate to JSON for structured data

### Blockers Resolved
- **NDK version mismatch**: Installed both 23.1.7779620 (Unity IL2CPP) and 27.0.12077973 (Flutter plugins) side-by-side in Android Studio SDK Manager
- **Docker GPU issues**: Abandoned Docker approach, switched to native Windows development to avoid `il2cpp.exe` and GPU driver problems

### Known Issues Documented
- Controller can be null if Unity fails to initialize (workaround: null check before postMessage)
- No type safety for message format (typos in gameObjectName or methodName fail silently)

---

## Session: 2025-12-20 - Initial Project Setup
**Duration**: ~1 hour
**Focus**: Scaffolding project structure and configuring development environment

### Added
- Flutter project initialization (`flutter create client_app`)
- Unity 2022.3 LTS project setup (`unity/xeno_unity`)
- Added `flutter-unity-view-widget` dependency (master branch from GitHub)
- Created root documentation:
  - `README.md`: Project overview, high concept, technical architecture
  - `CLAUDE.md`: AI assistant instructions, build commands, architecture patterns
  - `project_spec.md.md`: Product requirements document

### Technical Notes
- **Initial commit**: `3daf2f1` - Project structure setup
- **Folder structure**: Designed to match `flutter-unity-view-widget` plugin expectations
- **Build artifacts**: `android/unityLibrary/` marked as [GENERATED] in .gitignore (Unity export output)
- **Platform support**: Targeting Android ARM64/ARMv7 only (iOS/Windows platforms scaffolded but not prioritized)

### Environment Setup
- Installed Flutter SDK 3.x
- Configured Android Studio with required NDK versions
- Set up Unity Hub with 2022.3 LTS
- Configured Visual Studio 2022 with C++ workload (for Windows native dev)

---

## Pre-Project: Concept & Planning
**Date**: Before 2025-12-20

### Concept Validation
- Defined "Mirror Soul" concept: Alien creature that evolves based on user's real-life habits
- Chose Flutter + Unity hybrid approach (vs pure Flutter 3D or pure Unity)
- Researched gamification mechanics:
  - S.P.E.C.I.A.L. system (3 attributes: Vitality/Mind/Soul)
  - "Rayman-style" modular creature (floating body parts, no skeletal rigging)
  - "Charge Up" shader (PBR emission glow increases with XP)

### Technical Research
- Evaluated `flutter-unity-view-widget` as bridge solution (chosen for community support)
- Decided on Google ML Kit for on-device AI vision (vs cloud-based alternatives for privacy/cost)
- Planned Supabase for future backend (PostgreSQL + Edge Functions for OpenAI integration)
- Analyzed habit tracker competitors (Habitica, Finch) for feature gaps

### Target Audience Research
- Primary: People struggling with self-improvement discipline
- Secondary: Gamers who enjoy RPG progression (Spore, Tamagotchi fans)
- Tertiary: Tech enthusiasts interested in AI/Sci-Fi
