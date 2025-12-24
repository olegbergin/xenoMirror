# Feature: Phase 2 UI/UX - Home Screen (XenoMirror OS HUD)

**Status**: Implementation Complete (Needs Bug Fixes)
**Owner**: Project Team
**Design Spec Version**: reference_design_document.md v1.0.0
**Related Files**:
- `lib/core/theme/app_colors.dart` (new)
- `lib/core/theme/app_text_styles.dart` (new)
- `lib/core/theme/app_theme.dart` (new)
- `lib/presentation/pages/home_page.dart` (new)
- `lib/presentation/widgets/neon_button.dart` (new)
- `lib/presentation/widgets/biometric_bar.dart` (new)
- `lib/presentation/widgets/vignette_overlay.dart` (new)
- `lib/presentation/widgets/injection_panel.dart` (new)
- `lib/presentation/blocs/creature/creature_bloc.dart` (new)
- `lib/presentation/blocs/habit/habit_bloc.dart` (new)
- `lib/presentation/services/unity_bridge_service.dart` (new)
- `lib/main.dart` (modify)
- `pubspec.yaml` (modify)
- `unity/xeno_unity/Assets/Scripts/CreatureController.cs` (new)

---

## 1. Overview

Transform the current POC (basic Material UI with red/blue buttons) into the production-ready "XenoMirror OS" interface - a cyberpunk HUD that simulates a sci-fi containment device for the alien creature.

**User Story**: "As a user, I want a visually stunning interface that makes me feel like I'm interacting with an advanced xenobiology scanner, so that logging habits feels immersive and rewarding."

**Design Philosophy**: "The Containment Unit" - Unity renders the organic creature, Flutter overlays sharp neon UI elements that represent the "glass" of the containment chamber.

**Scope**: Home screen only. Stats/History screens deferred to Phase 3.

---

## 2. Technical Design

### 2.1 Architecture

**Layer Structure**:
- **Flutter UI (Presentation Layer)**: Custom widgets matching Cipher_01 design spec (no standard Material components)
- **Flutter BLoC (State Management)**: CreatureBloc + HabitBloc for reactive state updates
- **Data Layer (Phase 1)**: Already complete - Hive-backed repositories
- **Unity (3D Renderer)**: Receives messages from Flutter to trigger visual feedback

**Stack Layout** (main screen):
```
Stack
├── Layer 0: UnityWidget (full screen, z-index lowest)
├── Layer 1: VignetteOverlay (RadialGradient darkening edges)
└── Layer 2: HUD
    ├── Top Bar (stats + biometric bars)
    ├── Center EMPTY (creature viewport)
    └── Bottom Deck (3 protocol buttons)
```

### 2.2 Data Model

**Consumed Models** (from Phase 1):
```dart
// lib/data/models/creature_state.dart
class CreatureState {
  int xpVitality, xpMind, xpSoul;
  int legsTier, headTier, armsTier; // 0-3
  double vitalityProgress, mindProgress, soulProgress; // 0.0-1.0
  int get totalXP;
  String creatureName;
}

// lib/data/models/habit_entry.dart
enum HabitType { vitality, mind, soul }
enum ValidationMethod { manual, camera }

class HabitEntry {
  String id;
  HabitType habitType;
  String activity; // 'squats', 'reading', etc.
  int xpEarned;
  DateTime timestamp;
  ValidationMethod validationMethod;
  Map<String, dynamic>? metadata;
}
```

**BLoC States**:
```dart
// Creature States
sealed class CreatureState {}
class CreatureLoaded extends CreatureState {
  final CreatureState creature;
}
class CreatureEvolved extends CreatureState {
  final CreatureState creature;
  final String evolvedBodyPart; // 'legs', 'head', 'arms'
  final int newTier; // 1-3
}

// Habit States
sealed class HabitState {}
class HabitLoaded extends HabitState {
  final List<HabitEntry> todayEntries;
  final int todayTotalXP;
  final int currentStreak;
}
class HabitLogged extends HabitState {
  final HabitEntry entry;
  // ... (transient state after successful log)
}
```

### 2.3 API / Interfaces

**Flutter → Unity Messages**:
```dart
// OnReaction - Visual feedback when XP added
controller.postMessage('CreatureController', 'OnReaction', 'vitality');
// Parameters: 'vitality' | 'mind' | 'soul'

// OnEvolution - Tier-up animation
controller.postMessage('CreatureController', 'OnEvolution', 'legs:2');
// Format: '<bodyPart>:<newTier>' (e.g., 'legs:2', 'head:3')

// OnStateUpdate - Sync XP progress for shader glow
controller.postMessage('CreatureController', 'OnStateUpdate', '0.5,0.8,0.3');
// Format: '<vitalityProgress>,<mindProgress>,<soulProgress>' (CSV)
```

**Unity C# Public Methods**:
```csharp
public void OnReaction(string attribute) { /* Trigger glow/particles */ }
public void OnEvolution(string data) { /* Swap tier materials */ }
public void OnStateUpdate(string data) { /* Update shader _GlowIntensity */ }
```

**BLoC Events/Actions**:
```dart
// CreatureBloc
creatureBloc.add(LoadCreature());
creatureBloc.add(AddXP(habitType: HabitType.vitality, xpAmount: 10));
creatureBloc.add(ResetCreature());

// HabitBloc
habitBloc.add(LoadTodayHabits());
habitBloc.add(LogHabit(
  habitType: HabitType.vitality,
  activity: 'squats',
  xpEarned: 10,
  validationMethod: ValidationMethod.manual,
));
```

### 2.4 Dependencies

**New Dependencies** (add to pubspec.yaml):
- `flutter_bloc: ^8.1.6` - State management
- `equatable: ^2.0.5` - Value equality for BLoC states

**Custom Fonts** (Google Fonts):
- Orbitron (Regular, Bold, Black) - Headers/labels
- Rajdhani (Regular, Medium, SemiBold, Bold) - Body text

**Phase 1 Dependencies** (already completed):
- Hive local storage
- CreatureRepository + HabitRepository implementations
- XP constants and tier thresholds

**External Assets**:
- Font files in `assets/fonts/` directory

---

## 3. Implementation Checklist

### 3.1 Setup & Dependencies
- [ ] Download Orbitron and Rajdhani fonts from Google Fonts
- [ ] Create `assets/fonts/` directory
- [ ] Add font files (.ttf) to directory
- [ ] Update `pubspec.yaml` with flutter_bloc, equatable
- [ ] Add fonts configuration to `pubspec.yaml`
- [ ] Run `flutter pub get`

### 3.2 Theme System
- [ ] Create `lib/core/theme/app_colors.dart` (Cipher_01 color constants)
- [ ] Create `lib/core/theme/app_text_styles.dart` (Orbitron/Rajdhani styles)
- [ ] Create `lib/core/theme/app_theme.dart` (ThemeData with custom theme)

### 3.3 BLoC State Management
- [ ] Create `lib/presentation/blocs/creature/creature_event.dart`
- [ ] Create `lib/presentation/blocs/creature/creature_state.dart`
- [ ] Create `lib/presentation/blocs/creature/creature_bloc.dart`
- [ ] Create `lib/presentation/blocs/habit/habit_event.dart`
- [ ] Create `lib/presentation/blocs/habit/habit_state.dart`
- [ ] Create `lib/presentation/blocs/habit/habit_bloc.dart`

### 3.4 Custom Widgets
- [ ] Create `lib/presentation/widgets/vignette_overlay.dart`
- [ ] Create `lib/presentation/widgets/neon_button.dart` (Protocol Button)
- [ ] Create `lib/presentation/widgets/biometric_bar.dart` (segmented progress)
- [ ] Create `lib/presentation/widgets/injection_panel.dart` (Bottom Sheet)

### 3.5 Unity Bridge
- [ ] Create `lib/presentation/services/unity_bridge_service.dart`
- [ ] Create `unity/xeno_unity/Assets/Scripts/CreatureController.cs`
- [ ] Attach CreatureController script to GameObject in Unity scene
- [ ] Configure body part Renderers in Unity inspector
- [ ] Create placeholder tier materials (Tier 0-3)
- [ ] Export Unity project (Android debug build)

### 3.6 Home Screen
- [ ] Create `lib/presentation/pages/home_page.dart`
- [ ] Implement Stack layout (Unity → Vignette → HUD)
- [ ] Build Top Bar with biometric bars
- [ ] Build Bottom Deck with 3 protocol buttons
- [ ] Wire Injection Panel flow
- [ ] Add BLoC listeners for evolution events
- [ ] Implement toast/SnackBar system logs

### 3.7 Integration
- [ ] Modify `lib/main.dart` - add MultiBlocProvider
- [ ] Update MaterialApp theme to AppTheme.darkTheme
- [ ] Route to HomePage instead of UnityControlScreen
- [ ] Delete obsolete UnityControlScreen code

### 3.8 Testing
- [ ] Verify colors match design spec (ColorZilla check)
- [ ] Verify fonts render correctly
- [ ] Test haptic feedback on all buttons
- [ ] Test Injection Panel blur effect
- [ ] Test XP updates persist in Hive
- [ ] Test Unity message reception (adb logcat)
- [ ] Test evolution triggers correctly
- [ ] Test on physical Android device

### 3.9 Documentation
- [ ] Update `docs/architecture.md` with BLoC architecture
- [ ] Update `docs/project_status.md` (mark Phase 2 complete)
- [ ] Update `docs/changelog.md` with Phase 2 session notes

---

## 4. Testing Strategy

### Unit Tests

**BLoC Tests** (`test/presentation/blocs/`):
```dart
// creature_bloc_test.dart
- Test LoadCreature event emits CreatureLoaded
- Test AddXP event without evolution
- Test AddXP event with evolution (tier 0→1)
- Test ResetCreature event

// habit_bloc_test.dart
- Test LoadTodayHabits event
- Test LogHabit event emits HabitLogged → HabitLoaded
- Test LogHabit with metadata
```

**Widget Tests** (`test/presentation/widgets/`):
```dart
// neon_button_test.dart
- Test color matches attribute (vitality = #00FF41)
- Test haptic feedback trigger
- Test idle → pressed state transition
- Test ALL CAPS transformation

// biometric_bar_test.dart
- Test segment calculation (20 segments)
- Test progress rendering (0.0, 0.5, 1.0)
- Test color matching attribute
```

### Integration Tests

**File**: `integration_test/home_page_test.dart`

**Scenarios**:
1. **Habit Logging Flow**:
   - Tap VITALITY button
   - Verify Injection Panel opens
   - Select "Squats (+10 XP)"
   - Verify XP increases by 10
   - Verify BiometricBar updates
   - Verify toast appears
   - Restart app → verify XP persisted

2. **Evolution Trigger**:
   - Add XP until tier threshold (100 XP)
   - Verify CreatureEvolved state emitted
   - Verify Unity OnEvolution message sent (mock controller)
   - Verify tier changes from 0 → 1

3. **Multi-Attribute Logging**:
   - Log Vitality, Mind, Soul activities
   - Verify all 3 BiometricBars update independently
   - Verify totalXP = sum of all 3

### Manual Testing

**Device Requirements**: Physical Android device (ARM64 or ARMv7), emulators NOT supported

**Test Procedure**:
1. **Visual Compliance**:
   - Screenshot home screen → compare colors with design spec using ColorZilla
   - Verify all text uses Orbitron (labels) or Rajdhani (body)
   - Verify ALL CAPS on buttons and labels
   - Verify no standard Material buttons visible
   - Verify vignette darkens edges

2. **Interaction Testing**:
   - Tap each Protocol Button → feel haptic feedback
   - Open Injection Panel → verify blur effect
   - Select activity → verify toast appears
   - Monitor Unity logs (adb logcat) → verify messages received

3. **Data Persistence**:
   - Log 5 different activities
   - Close app completely (swipe away)
   - Reopen app → verify XP values unchanged
   - Verify BiometricBars show correct progress

4. **Evolution Testing**:
   - Log activities until 100 XP reached
   - Verify toast: "EVOLUTION DETECTED: LEGS → TIER 1"
   - Check Unity logs for OnEvolution message
   - Verify legsTier = 1 in UI

**Expected Results**:
- No standard Material UI visible
- Creature visible in center viewport
- All interactions have haptic feedback
- XP updates in real-time
- Data persists across app restarts

---

## 5. Known Issues & Future Improvements

### Known Issues

**Issue #1**: BackdropFilter may not work on Android emulators
- **Impact**: InjectionPanel won't show blur effect during development
- **Workaround**: Test on physical device only
- **Planned fix**: None (emulator limitation)

**Issue #2**: Font loading requires hot restart (not hot reload)
- **Impact**: During development, font changes won't appear until full restart
- **Workaround**: Use `flutter run` instead of hot reload after font changes
- **Planned fix**: None (Flutter framework limitation)

**Issue #3**: Unity messages may fail silently if GameObject name mismatches
- **Impact**: Flutter sends messages but Unity doesn't respond
- **Workaround**: Use exact name "CreatureController" in Unity scene
- **Planned fix**: Add debug mode to log all Unity messages in development

### Future Improvements

**Enhancement #1**: Animated tier transitions
- Description: Instead of instant material swap, animate body part transformation over 1-2 seconds
- Requires: Unity Animator setup, additional animation clips

**Enhancement #2**: Particle effects on XP gain
- Description: Colored particles burst from creature when habit logged
- Requires: Unity Particle System, trigger via OnReaction message

**Enhancement #3**: Stat tooltips
- Description: Long-press on BiometricBar → show detailed tier info
- Requires: GestureDetector with onLongPress, custom tooltip widget

**Enhancement #4**: Swipe gestures for navigation
- Description: Swipe up on Bottom Deck → Stats screen, swipe down → History
- Requires: GestureDetector, navigation routing (Phase 3)

**Enhancement #5**: Dynamic color themes
- Description: Allow user to customize accent colors
- Requires: Settings screen (Phase 3), theme persistence in Hive

---

## 6. References

**Design Documentation**:
- `docs/reference_design_document.md` (v1.0.0) - Complete UI/UX specification
- `docs/architecture.md` (v0.3.0) - System architecture overview
- `CLAUDE.md` - Development guidelines and constraints

**External Resources**:
- [Google Fonts - Orbitron](https://fonts.google.com/specimen/Orbitron)
- [Google Fonts - Rajdhani](https://fonts.google.com/specimen/Rajdhani)
- [flutter_bloc Documentation](https://bloclibrary.dev/)
- [flutter-unity-view-widget GitHub](https://github.com/juicycleff/flutter-unity-view-widget)

**Related GitHub Issues**:
- N/A (MVP development, no issues filed yet)

**Color Palette Reference** (Cipher_01):
```dart
voidBlack:    #050505  // Main background
deepSpace:    #0B0E14  // Cards/panels
vitality:     #00FF41  // Matrix green
mind:         #00F3FF  // Hologram cyan
soul:         #BC13FE  // Synthwave magenta
textPrimary:  #E0E0E0  // Off-white
textSecondary: #556870 // Muted slate
alert:        #FF2A2A  // Red neon
glassOverlay: #CC0B0E14 // 0.8 opacity
```

---

## 7. Implementation Steps (Quick Reference)

1. **Setup**: Download fonts → Update pubspec.yaml → Run `flutter pub get`
2. **Theme**: Create app_colors.dart, app_text_styles.dart, app_theme.dart
3. **BLoC**: Create creature_bloc (3 files), habit_bloc (3 files)
4. **Widgets**: Create vignette_overlay, neon_button, biometric_bar, injection_panel
5. **Unity Bridge**: Create unity_bridge_service.dart + CreatureController.cs
6. **HomePage**: Create home_page.dart with Stack layout
7. **Integration**: Modify main.dart (BLoC providers + theme)
8. **Unity**: Attach script, configure inspector, export Android build
9. **Test**: Verify colors, fonts, haptics, persistence, Unity messages

**Total Files**: 18 new + 2 modified = 20 files
**Estimated Time**: 3-4 hours for full implementation
**Phase 2 Completion**: Home screen fully functional per design spec v1.0.0
