# XenoMirror System Architecture

**Last Updated**: 2025-12-22
**Version**: 0.1.0 (MVP Phase)

---

## 1. High-Level Overview

XenoMirror is a hybrid Flutter + Unity application where:
- **Flutter** provides the UI shell, business logic, and handles data persistence
- **Unity** acts as a "dumb renderer" for 3D creature visualization
- Communication happens via `flutter-unity-view-widget` bridge

```
┌─────────────────────────────────────┐
│         Flutter Layer (Dart)        │
│  - UI Components (Habit buttons)    │
│  - BLoC State Management            │
│  - Local Storage (Hive/SQLite)      │
│  - ML Kit Integration               │
└─────────────┬───────────────────────┘
              │ JSON Messages
              │ (postMessage API)
┌─────────────▼───────────────────────┐
│        Unity Layer (C#/URP)         │
│  - 3D Creature Rendering            │
│  - Shader Effects (Glow)            │
│  - Particle Systems                 │
└─────────────────────────────────────┘
```

### Technology Stack
- **Flutter**: 3.x (Dart SDK ^3.10.4)
- **Unity**: 2022.3 LTS (URP)
- **Bridge**: `flutter-unity-view-widget` (master branch from GitHub)
- **Target Platform**: Android ARM64/ARMv7 (physical devices only, no emulators)
- **Data Storage (MVP)**: Local storage (SharedPreferences + SQLite/Hive)
- **Vision AI (MVP)**: Google ML Kit (On-device)
- **Future Backend**: Supabase (PostgreSQL + Edge Functions)
- **Future AI Chat**: OpenAI GPT-4o-mini

---

## 2. Flutter Layer Architecture

### Current Implementation (v0.1.0)
```
XenoApp (MaterialApp)
└── UnityControlScreen (StatefulWidget)
    ├── UnityWidget (Bridge to Unity)
    └── FloatingActionButtons (Demo: Red/Blue color commands)
```

**Key files**:
- `lib/main.dart` - Main entry point, contains UnityControlScreen demo

**State management** (current): StatefulWidget with local state
**State management** (planned): BLoC pattern for XP system, creature state

### Planned Architecture (MVP)
```
XenoApp (MaterialApp)
├── HomePage
│   ├── UnityWidget (3D Creature display)
│   └── HabitLogBar (Bottom navigation with 3 habit type buttons)
├── HabitLogScreen
│   ├── ManualInput (Quick log via buttons)
│   └── CameraInput (ML Kit pose detection/image labeling)
└── CreatureDetailScreen
    ├── StatsDisplay (XP levels per attribute)
    └── EvolutionHistory (Timeline of mutations)
```

---

## 3. Unity Layer Architecture

### Current Scene Hierarchy
```
SampleScene
└── Cube (GameObject)
    └── ColorChanger (MonoBehaviour script)
```

**Key files**:
- `unity/xeno_unity/Assets/ColorChanger.cs` - Receives color commands from Flutter
- `unity/xeno_unity/Assets/Scenes/SampleScene.unity` - Main scene

### Planned Architecture: Modular "Rayman-style" Creature
```
CreatureRoot (Empty GameObject)
├── Core (Sphere - main body with Charge Up shader)
├── HeadAnchor (Empty) → Head_Tier1/2/3 (swappable prefabs)
├── LeftArmAnchor (Empty) → Arm_Tier1/2/3
├── RightArmAnchor (Empty) → Arm_Tier1/2/3
└── LegsAnchor (Empty) → Legs_Tier1/2/3
```

**Why "Rayman-style" floating parts:**
- No skeletal rigging required (faster asset production)
- Easy scaling and swapping (tier evolution)
- Parts from different tiers never clip (no skinning issues)

---

## 4. Flutter ↔ Unity Bridge

### Communication Protocol
**Direction**: Flutter → Unity (one-way currently, callbacks planned for future)

**API**:
```dart
// Flutter side
_unityWidgetController.postMessage(
  'GameObjectName',  // Unity GameObject in scene hierarchy
  'MethodName',      // Public method in attached C# script
  'message'          // String argument (can be JSON)
);
```

**Unity side**:
```csharp
// Attached to GameObject
public class ColorChanger : MonoBehaviour {
    public void SetColor(string message) {
        // Handle message from Flutter
        if (message == "red") {
            GetComponent<Renderer>().material.color = Color.red;
        }
    }
}
```

### Current Message Examples
```dart
// Change cube color to red
controller.postMessage('Cube', 'SetColor', 'red');
```

### Planned Messages (Future)
```dart
// Update creature glow based on XP
controller.postMessage('CreatureRoot', 'UpdateGlow', jsonEncode({
  'vitality': 0.8,  // 0.0 - 1.0 (XP percentage)
  'mind': 0.5,
  'soul': 0.3
}));

// Trigger evolution animation
controller.postMessage('CreatureRoot', 'TriggerEvolution', jsonEncode({
  'bodyPart': 'legs',
  'newTier': 2
}));
```

---

## 5. Data Flow (Planned MVP)

```
User Action (Squats)
  → Flutter: Capture via Camera/Manual Input
  → Flutter: ML Kit Pose Detection (validate)
  → Flutter BLoC: Calculate XP (xpVitality += 10)
  → Flutter Storage: Save to Hive/SQLite
  → Flutter: Check if tier threshold crossed
  → Unity: Send UpdateGlow message
  → Unity: Update shader emission value
  → Unity: If tier up, trigger evolution animation
```

### Data Models (Planned)

**Creature State** (persisted locally):
```dart
class CreatureState {
  int xpVitality;    // 0-1000+ (Legs & Core)
  int xpMind;        // 0-1000+ (Head & Sensors)
  int xpSoul;        // 0-1000+ (Arms & Aura)
  int legsTier;      // 0-3 (visual tier)
  int headTier;      // 0-3
  int armsTier;      // 0-3
  DateTime lastUpdated;
}
```

**Habit Entry** (persisted locally):
```dart
class HabitEntry {
  String habitType;      // 'vitality', 'mind', 'soul'
  String activity;       // 'squats', 'reading', 'meditation'
  int xpEarned;
  DateTime timestamp;
  String validationMethod; // 'manual', 'camera'
}
```

---

## 6. AI Integration Points

### Google ML Kit (On-Device)
**Use cases**:
- **Pose Detection**: Count squats, push-ups (validate Vitality activities)
- **Image Labeling**: Recognize books, art supplies (validate Mind/Soul activities)

**Architecture**:
```
Flutter Camera Widget
  → ML Kit Pose Detector / Image Labeler
  → Confidence Score (> 0.8 = valid)
  → Award XP
```

### OpenAI GPT-4o-mini (Future - Not in MVP)
**Use case**: AI chat with creature (personalized responses)

**Architecture** (when implemented):
```
Flutter Chat UI
  → Supabase Edge Function
  → Rate Limiter (5 messages/day)
  → OpenAI API
  → Store conversation history
  → Return to Flutter
```

---

## 7. Build Pipeline

### Prerequisites
- Flutter SDK 3.x
- Visual Studio 2022 (Desktop development with C++)
- Android Studio with:
  - NDK 23.1.7779620 (Unity IL2CPP)
  - NDK 27.0.12077973 (Flutter plugins)
- Unity Hub 2022.3 LTS

### Build Steps
1. **Unity export**: Open `unity/xeno_unity` in Unity, use plugin's "Export Android (debug)"
   - Generates `android/unityLibrary/` (DO NOT edit manually)
2. **Flutter build**:
   ```powershell
   flutter pub get
   flutter run  # Physical device only!
   ```

### Known Constraints
- ❌ x86_64 emulators not supported (Unity ARM-only)
- ⚠️ Two NDK versions required (Unity + Flutter have different dependencies)
- ⚠️ Docker abandoned for Windows native dev (IL2CPP GPU driver issues)

---

## 8. Architectural Principles

### "Unity is a Dumb Renderer"
**Rule**: All business logic (XP calculation, level-up logic, game mechanics) belongs in Flutter or Supabase, **NOT in Unity**.

**Why**:
- Easier to test (Dart unit tests vs Unity integration tests)
- Faster iteration (no Unity re-export for logic changes)
- Better separation of concerns

**What Unity DOES**:
- Render 3D creature
- Play animations
- Update shader parameters
- Emit particles

**What Unity DOES NOT DO**:
- Calculate XP
- Decide when to evolve
- Persist data

### Local-First Data Architecture
**MVP approach**: All data stays on device (no cloud dependency)

**Benefits**:
- Faster MVP iteration (no backend setup)
- Works offline
- No API costs during development

**Migration path** (future):
- Export local data → Import to Supabase on first cloud sync
- Use Supabase RLS for user data isolation

---

## 9. Technical Debt & Current Limitations

### Current Status: Proof-of-Concept Only
- Only 1 Flutter file (`lib/main.dart`) and 1 Unity script (`ColorChanger.cs`)
- No data persistence yet
- No XP system yet
- No modular creature - just a cube demo

### Architectural Decisions Pending
- [ ] **Hive vs SQLite** for local storage
  - Hive: Simple key-value, faster for simple queries
  - SQLite: Complex queries, better for relational data
  - **Decision needed by**: Before implementing data layer

- [ ] **BLoC library choice** (flutter_bloc vs provider vs riverpod)
  - Leaning toward flutter_bloc (standard for complex state)

- [ ] **3D modeling tool** (Blender? Other free options?)
  - Blender: Free, powerful, steep learning curve
  - Vectary: Browser-based, easier learning curve

### Known Limitations
- Unity is constrained to "dumb renderer" role (no business logic allowed in C#)
- Bridge is one-way (Unity → Flutter callbacks not implemented yet)
- Physical Android device required (no emulator support)

---

## 10. Security Considerations

### Data Privacy (Local-First MVP)
- No cloud backend = no data transmission
- All sensitive data (XP, habits) stays on device
- No authentication required

### Future Security (When Backend Added)
- Supabase Row Level Security (RLS) for user data isolation
- OpenAI API keys NEVER in client app (only in Edge Functions)
- Rate limiting on AI chat (prevent abuse)

---

## 11. Performance Considerations

### Flutter Performance
- Use `const` constructors for widgets
- Avoid rebuilding UnityWidget (expensive)
- Debounce XP updates to Unity (batch messages)

### Unity Performance
- Keep poly count low (< 5000 triangles per creature)
- Use URP optimized shaders
- Unload/Pause Unity when app backgrounded (battery saving)

---

## 12. References

- [flutter-unity-view-widget GitHub](https://github.com/juicycleff/flutter-unity-view-widget)
- [Google ML Kit Documentation](https://developers.google.com/ml-kit)
- Internal: `CLAUDE.md` - Build commands and development patterns
- Internal: `project_spec.md.md` - Product requirements and user stories
