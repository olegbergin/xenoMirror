# 🛸 XenoMirror - Gamified Habit Tracker

**Version:** 1.2 (Phase 1 Complete)
**Status:** MVP Development - Data Layer Complete ✅
**Target Platform:** Android (ARM64/ARMv7)
**Core Concept:** "The Mirror Soul" — Your habits shape an evolving AI companion

**Core Library:** [flutter-unity-view-widget](https://github.com/juicycleff/flutter-unity-view-widget)

---

## 📖 Overview

**XenoMirror** is a gamified self-improvement app where users nurture a digital alien creature found in a cryo-pod. Unlike traditional virtual pets, **you don't feed it virtual food—you feed it your real-life habits.**

The creature is a **mirror of your lifestyle**:

- **Work out** → The creature grows cybernetic/muscular legs
- **Read books** → The creature develops a "Third Eye" or Halo
- **Neglect yourself** → The creature's light fades and becomes glitchy

**The Hook:** "Don't just level up a character. Build a better version of yourself, and watch it come alive."

---

## 🎯 Current Status (Phase 1 Complete)

### ✅ Completed Features
- **Data Layer**: Hive-based local storage with repository pattern
- **Domain Models**: Creature state, habit tracking, XP system
- **XP Progression**: Polynomial curve (100/400/1000 tier thresholds)
- **Clean Architecture**: Repository interfaces ready for future Supabase migration
- **Flutter-Unity Bridge**: Proof-of-concept validated on physical device

### 🚧 In Development
- **UI/UX Design**: Main app screens and navigation
- **Habit Logging**: Manual input with AI vision support

### 📋 Planned (MVP)
- Unity creature with modular "Rayman-style" body parts
- "Charge Up" shader system for visual feedback
- Google ML Kit for pose detection and image labeling

---

## 🛠️ Technology Stack

### Current Implementation (MVP)
- **Mobile Framework**: Flutter (Dart) - handles UI, navigation, and business logic
- **3D Rendering**: Unity 2022.3 LTS (URP) - renders creature and environment
- **Bridge**: `flutter-unity-view-widget` (master branch)
- **Data Storage**: Hive (local NoSQL database)
- **Vision AI**: Google ML Kit (On-device, planned)
- **Architecture**: Clean Architecture + BLoC pattern

### Future Stack (Post-MVP)
- **Backend**: Supabase (PostgreSQL + Auth + Edge Functions)
- **AI Chat**: OpenAI GPT-4o-mini (5 messages/day limit)
- **Cloud Sync**: Multi-device support with RLS security

---

## 📁 Project Structure

```
D:\xenoMirror\client_app\          # Flutter project root
├── docs/                           # Technical documentation
│   ├── architecture.md             # System design & decisions
│   ├── changelog.md                # Session-based change history
│   ├── project_status.md           # Current sprint status
│   └── features/                   # Feature-specific docs
├── lib/                            # Flutter Dart code
│   ├── core/                       # Constants, utilities
│   ├── data/                       # Data sources, models, repositories
│   ├── domain/                     # Business logic, entities
│   ├── presentation/               # UI, BLoC, widgets
│   └── main.dart                   # App entry point
├── unity/xeno_unity/               # Unity source project
│   └── Assets/
│       ├── ColorChanger.cs         # Example Unity script
│       └── FlutterUnityIntegration/ # Bridge plugin
├── android/
│   ├── unityLibrary/               # [GENERATED] Unity export (DO NOT EDIT)
│   ├── build.gradle.kts            # Build config with NDK fixes
│   └── settings.gradle.kts         # Module configuration
├── test/                           # Unit and widget tests
├── README.md                       # This file
├── CLAUDE.md                       # AI assistant instructions
├── project_spec.md                 # Product requirements
└── pubspec.yaml                    # Flutter dependencies
```

---

## 🖥️ Development Environment Setup (Windows)

### Required Software

1. **Flutter SDK**: 3.x (Stable channel)
   ```powershell
   flutter --version  # Verify installation
   ```

2. **Visual Studio 2022**:
   - Workload: **"Desktop development with C++"** (Required for Windows compilation)

3. **Android Studio**:
   - **SDK Platform**: API 24+ (Android 7.0+)
   - **SDK Command-line Tools**: Latest version
   - **NDK (Critical)**: Install **two versions side-by-side**:
     - `23.1.7779620` (for Unity IL2CPP compilation)
     - `27.0.12077973` (for Flutter plugin compilation)

   > **How to install multiple NDKs**:
   > Android Studio → Settings → Appearance & Behavior → System Settings → Android SDK → SDK Tools tab → Check "Show Package Details" → Select both NDK versions

4. **Unity Hub + Unity 2022.3 LTS**:
   - Install via Unity Hub
   - Required modules: Android Build Support (with OpenJDK & SDK)

---

## 🚀 Build & Run Instructions

### 1️⃣ Initial Setup

```powershell
# Navigate to project root
cd D:\xenoMirror\client_app

# Install Flutter dependencies
flutter pub get
```

### 2️⃣ Export Unity Project (Required before first build)

1. Open `client_app/unity/xeno_unity` in Unity Hub (2022.3 LTS)
2. In Unity Editor: **Flutter → Export Android (debug)**
   - This generates/updates the `android/unityLibrary/` directory
   - **Note**: This directory is auto-generated. Never edit it manually.

### 3️⃣ Run on Physical Device

```powershell
# IMPORTANT: Connect Android device via USB with USB Debugging enabled
# x86_64 emulators are NOT supported by Unity

flutter run
```

> **Why no emulator support?**
> Unity's IL2CPP requires ARM architecture. Standard x86_64 emulators will fail with `dlopen failed: library not found`.

### 4️⃣ Build Release APK

```powershell
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🧪 Testing

### Run All Tests
```powershell
flutter test
```

### Generate Coverage Report
```powershell
# Run tests with coverage
flutter test --coverage

# View summary (requires lcov: choco install lcov)
lcov --summary coverage/lcov.info

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html
# Then open coverage/html/index.html in browser
```

### Check Coverage Threshold (80%)
```powershell
bash scripts/check_coverage.sh
```

### Current Coverage Status
- **Target**: 80% minimum
- **Core modules**: 90%+ (data layer, repositories, XP calculations)
- **UI widgets**: In progress

---

## 🎮 Game Mechanics (MVP Scope)

### RPG System: Three Attributes

| Attribute    | Input Activities         | Visual Output            | Archetype |
|--------------|--------------------------|--------------------------|-----------|
| **VITALITY** | Sports, Sleep, Nutrition | Legs & Core (Thrusters, Muscles) | Titan     |
| **MIND**     | Reading, Study, Planning | Head & Sensors (Halos, Third Eye) | Psionic   |
| **SOUL**     | Hobbies, Art, Meditation | Arms & Aura (Tools, Particles)   | Creator   |

### XP Progression System
- **Tier 1**: 0-100 XP (Basic body parts)
- **Tier 2**: 100-400 XP (Enhanced parts)
- **Tier 3**: 400-1000 XP (Advanced evolution)
- **Formula**: Polynomial curve for satisfying progression feel

### Visual Style
- **"Rayman Architecture"**: Floating body parts (no rigging complexity)
- **"Charge Up" Shader**: Emission glow increases with XP percentage
- **Low-poly aesthetic**: Small APK size, fast rendering

---

## 🔌 Flutter ↔ Unity Communication

### Flutter → Unity (Send Commands)
```dart
// In Flutter
unityWidgetController.postMessage(
  'GameObjectName',  // Target GameObject in Unity scene
  'MethodName',      // Public method name in C# script
  'messageData'      // String parameter
);

// Example: Change creature glow intensity
controller.postMessage('Creature', 'SetGlowIntensity', '0.8');
```

### Unity → Flutter (Receive Commands)
```csharp
// In Unity C# script (attached to GameObject)
public void SetGlowIntensity(string message)
{
    float intensity = float.Parse(message);
    material.SetFloat("_EmissionStrength", intensity);
}
```

### Architecture Rules
- **Business Logic**: Lives in Flutter (BLoC) or future backend, **NOT in Unity**
- **Unity's Role**: "Dumb renderer" - only handles 3D visualization and effects
- **Data Flow**: Flutter calculates XP → Flutter sends tier/glow data → Unity updates visuals

---

## ⚠️ Common Issues & Solutions

### `dlopen failed: library not found`
- **Cause**: Using x86_64 emulator instead of ARM device
- **Solution**: Always use a physical Android device via USB

### Unity export not found / build fails
- **Cause**: Forgot to export Unity project before Flutter build
- **Solution**: Re-export from Unity Editor (Flutter → Export Android)

### NDK version mismatch errors
- **Cause**: Only one NDK version installed
- **Solution**: Install both NDK versions (23.1.7779620 **and** 27.0.12077973) side-by-side in Android Studio SDK Manager

### Unity scene shows black screen
- **Cause**: `useAndroidViewSurface: false` in UnityWidget
- **Solution**: Set `useAndroidViewSurface: true` in Flutter code

---

## 📚 Documentation System

### Auto-Generated Docs (docs/ folder)
- **`architecture.md`**: Technical design and data flow
- **`changelog.md`**: Session summaries (human-readable, not raw git log)
- **`project_status.md`**: Current sprint goals and blockers
- **`features/`**: Individual feature documentation

### Update Documentation
```powershell
# User triggers manually when docs need refresh
/update-docs
```

This command:
1. Analyzes commits since last update
2. Asks for session summary
3. Updates relevant docs (changelog, status, architecture)
4. Preserves manual edits (section-aware merge)

---

## 🎯 MVP Completion Criteria

The MVP is considered complete when:
- ✅ User can log 3 habit types manually (Vitality/Mind/Soul)
- ✅ XP persists locally across app restarts
- ✅ 3D creature displays glow based on XP
- ✅ Creature evolves (swaps body parts) at tier thresholds
- ✅ AI Vision validates at least 1 activity (pose detection for squats)
- ✅ No crashes on physical Android device
- ✅ 80%+ test coverage on core logic

**NOT in MVP**:
- ❌ Cloud backend / multi-device sync
- ❌ AI chat with creature
- ❌ Social features
- ❌ User authentication

---

## 🤝 Contributing

Currently in private development. Follow conventional commit format:
- `feat:` New features
- `fix:` Bug fixes
- `docs:` Documentation changes
- `test:` Test additions/changes
- `refactor:` Code refactoring

---

## 📄 License

Proprietary - All rights reserved

---

## 🔗 Related Links

- **Repository**: https://github.com/olegbergin/xenoMirror
- **Flutter-Unity Widget**: https://github.com/juicycleff/flutter-unity-view-widget
- **Unity Hub**: https://unity.com/download
- **Flutter**: https://flutter.dev

---

**Last Updated**: 2025-12-23
**Phase**: MVP Development (Phase 1 Complete)
