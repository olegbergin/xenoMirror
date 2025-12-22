# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**XenoMirror** is a gamified habit tracker where users nurture a digital alien creature that evolves based on real-life habits. The app uses Flutter for the UI shell and Unity for 3D rendering of the creature, bridged via `flutter-unity-view-widget`.

**Core Concept:** "The Mirror Soul" - your habits feed the creature's evolution (workout → muscular legs, reading → third eye, neglect → glitchy appearance).

## Technology Stack

- **Frontend Shell:** Flutter (Dart) - handles UI, navigation, and business logic
- **3D Rendering:** Unity 2022.3 LTS (URP) - renders creature and environment
- **Bridge:** `flutter-unity-view-widget` (master branch from GitHub)
- **Target Platform:** Android (ARM64/ARMv7) - requires physical device, emulators not supported
- **Planned Backend:** Supabase + OpenAI (GPT-4o-mini) - not yet implemented
- **Planned Vision AI:** Google ML Kit (On-device) - not yet implemented

## Project Structure

```
D:\xenoMirror\client_app\          # Flutter project root
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

### Backend Integration
- Supabase Auth (Email/Password)
- PostgreSQL schema: `users`, `creature_state`, `daily_usage`
- Row Level Security (RLS) for user data isolation
- Supabase Edge Functions for OpenAI API calls (rate limited to 5 messages/day in MVP)

### Visual Style
- "Rayman Architecture" - floating body parts to avoid rigging complexity
- "Charge Up" Shader - PBR Shader Graph with emission glow that increases with XP

## Git Workflow Notes

Current branch: `master`
- Initial commit establishes project structure
- Staged changes include Unity scene modifications and new ColorChanger script
