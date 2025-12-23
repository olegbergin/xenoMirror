# XenoMirror Agent Development Guide

This file provides guidance to AI coding agents (Claude Code, Cursor, GitHub Copilot, etc.) when working with code in this repository.

## Quick Start for Agents

- **Architecture**: Clean Architecture (domain/data/presentation layers)
- **Testing**: Run `flutter test` before committing (80% coverage minimum)
- **Linting**: `flutter analyze` must pass with zero warnings
- **Build**: `flutter build apk --debug` must succeed
- **Code Generation**: Run `flutter pub run build_runner build` after model changes

## Critical Constraints

1. **Unity is a "dumb renderer"** - ALL business logic stays in Flutter (Dart), NOT Unity (C#)
   - XP calculations, level-up logic, game mechanics belong in Flutter repositories
   - Unity only handles 3D visualization and visual effects
   - See `lib/data/repositories/` for proper business logic patterns

2. **Physical Android device required** - No emulator support
   - Unity ARM binaries don't work on x86_64 emulators
   - Always test on physical device connected via USB

3. **Two build systems**: Flutter AND Unity export required
   - Unity must be exported BEFORE Flutter build
   - Use "Export Android (debug)" in Unity Editor
   - This generates `android/unityLibrary/` directory

4. **Hive models require code generation** before testing
   - Run `flutter pub run build_runner build --delete-conflicting-outputs`
   - After modifying `@HiveType` or `@HiveField` annotations
   - Generates `.g.dart` files (version controlled)

5. **Repository pattern enforced** - Never access Hive boxes directly
   - Always use `ICreatureRepository` or `IHabitRepository` interfaces
   - Repositories handle all data access logic
   - See `lib/domain/repositories/` for interfaces

6. **Manual Unity validation** - Document changes in commit message
   - Unity export can't be automated in CI
   - When modifying Unity scripts, note in commit message: "Unity changes: [description]"
   - Test Unity integration on physical device before pushing

## Testing Philosophy

### Coverage Targets
- **Unit tests**: All repositories, constants, and business logic (100% coverage)
- **Widget tests**: All screens with mocked repositories (60%+ coverage)
- **Integration tests**: End-to-end flows (future phase)
- **NO Unity tests in Flutter CI** - Unity has separate manual validation

### What to Test
- ✅ Pure functions (XP calculations, tier thresholds)
- ✅ Repository methods (data layer business logic)
- ✅ Model equality and copyWith() methods
- ✅ Boundary conditions (tier transitions, XP clamping)
- ✅ Error handling (invalid inputs, null safety)
- ❌ Generated code (`.g.dart` files)
- ❌ Unity C# scripts (tested manually)

### Test File Organization
```
test/
├── unit/
│   ├── data/
│   │   ├── repositories/    # Repository business logic tests
│   │   └── models/          # Model tests (equality, copyWith, etc.)
│   └── core/
│       └── constants/       # Pure function tests (highest priority)
├── widget/                   # Future: UI tests
├── helpers/
│   └── test_data.dart       # Shared test fixtures
└── widget_test.dart         # Existing smoke test
```

## Validation Checklist (Must Pass Before Commit)

Run these commands locally before committing:

- [ ] `flutter analyze` - Zero warnings/errors
- [ ] `flutter test` - All tests pass, coverage ≥80%
- [ ] `dart format .` - Code is formatted
- [ ] `flutter pub run build_runner build` - Generated code is up to date (if models changed)
- [ ] No new TODOs without GitHub issue references (e.g., `TODO(#123): Fix this`)

**Pre-commit hook will enforce these automatically.**

## Code Quality Standards

### Dart Style Guide
- Prefer `const` constructors wherever possible
  ```dart
  // Good
  const XpThresholds(currentTierXp: 0, nextTierXp: 100, tier: 0);

  // Avoid
  XpThresholds(currentTierXp: 0, nextTierXp: 100, tier: 0);
  ```

- Always declare return types explicitly
  ```dart
  // Good
  int getTierForXP(int xp) { ... }

  // Avoid
  getTierForXP(xp) { ... }
  ```

- Use `final` for variables that don't change
  ```dart
  // Good
  final int tier = getTierForXP(xp);

  // Avoid
  int tier = getTierForXP(xp);
  ```

- Never use `print()` - use proper logging (future: logger package)
  ```dart
  // Avoid
  print('XP updated to $xp');

  // Good (for now)
  // Log: XP updated to $xp
  debugPrint('XP updated to $xp');
  ```

- Document all public APIs with dartdoc comments
  ```dart
  /// Calculate XP progress percentage within current tier (0.0 - 1.0)
  ///
  /// Returns 1.0 if XP exceeds the next tier threshold.
  /// Returns 0.0 if XP is below the current tier start.
  static double calculateProgress(int currentXP, int currentTier) { ... }
  ```

- Follow existing patterns in `data/repositories/` for consistency
  - Constructor-based dependency injection
  - Async methods return `Future<T>`
  - Methods are small and focused (single responsibility)

### Architecture Patterns

**Clean Architecture Layers**:
```
lib/
├── core/                   # Shared utilities, constants
│   ├── constants/          # XP thresholds, game constants
│   └── config/             # App configuration
├── domain/                 # Business logic interfaces
│   └── repositories/       # Abstract repository interfaces
├── data/                   # Data layer implementation
│   ├── models/             # Hive models, data classes
│   ├── repositories/       # Concrete repository implementations
│   └── datasources/        # Hive, Supabase, API clients
└── presentation/           # UI layer (future)
    ├── screens/
    ├── widgets/
    └── blocs/
```

**Dependency Flow**: Presentation → Domain ← Data
- Presentation depends on Domain interfaces
- Data implements Domain interfaces
- Domain has no dependencies (pure business logic)

## XP Calculation Examples (Learn from existing code)

See `lib/core/constants/xp_constants.dart` for reference patterns:

### Pure Functions
```dart
/// Pure function - no side effects, deterministic output
static int getTierForXP(int xp) {
  if (xp >= tier3Threshold) return 3;
  if (xp >= tier2Threshold) return 2;
  if (xp >= tier1Threshold) return 1;
  return 0;
}
```

**Why this pattern matters**:
- Testable: Same input always produces same output
- No state mutations: Doesn't modify global variables
- No I/O operations: Doesn't access files, network, or database

### Explicit Parameter Types
```dart
// Good - Types are explicit
static int calculateFinalXP(
  int baseXP, {
  bool cameraValidated = false,
  bool hasStreak = false,
}) { ... }

// Avoid - Type inference can be ambiguous
static calculateFinalXP(baseXP, {cameraValidated = false, hasStreak = false}) { ... }
```

### Comprehensive Inline Documentation
```dart
/// Calculate final XP with multipliers applied.
///
/// Applies bonuses in this order:
/// 1. Camera validation bonus (1.5x if cameraValidated is true)
/// 2. Streak bonus (1.2x if hasStreak is true)
///
/// Example:
/// ```dart
/// final xp = XpConstants.calculateFinalXP(
///   10,
///   cameraValidated: true,
///   hasStreak: true,
/// );
/// // Returns: 18 (10 * 1.5 * 1.2)
/// ```
static int calculateFinalXP(int baseXP, { ... }) { ... }
```

### Factory Patterns for Configuration
```dart
class XpThresholds {
  final int currentTierXp;
  final int nextTierXp;
  final int tier;

  const XpThresholds({
    required this.currentTierXp,
    required this.nextTierXp,
    required this.tier,
  });

  /// Factory constructor to get thresholds for a given tier
  factory XpThresholds.forTier(int tier) {
    switch (tier) {
      case 0:
        return const XpThresholds(
          currentTierXp: 0,
          nextTierXp: XpConstants.tier1Threshold,
          tier: 0,
        );
      // ... more cases
    }
  }
}
```

## Repository Pattern Examples

See `lib/data/repositories/creature_repository.dart` for reference patterns:

### Constructor-Based Dependency Injection
```dart
class CreatureRepository implements ICreatureRepository {
  final LocalDataSource _localDataSource;

  CreatureRepository({required LocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  // ... methods
}
```

**Why this pattern matters**:
- Testable: Can inject mock `LocalDataSource` in tests
- Explicit dependencies: Clear what the repository needs
- Immutable: Dependencies are final, can't be changed after construction

### Interface Implementation
```dart
// Domain layer: Abstract interface
abstract class ICreatureRepository {
  Future<CreatureState> getCreatureState();
  Future<void> updateXP({int? vitalityDelta, int? mindDelta, int? soulDelta});
  Future<void> resetCreature();
}

// Data layer: Concrete implementation
class CreatureRepository implements ICreatureRepository {
  @override
  Future<CreatureState> getCreatureState() async { ... }

  @override
  Future<void> updateXP({...}) async { ... }

  @override
  Future<void> resetCreature() async { ... }
}
```

**Why this pattern matters**:
- Testable: Presentation layer can mock `ICreatureRepository`
- Flexible: Can swap implementations (Hive → Supabase) without changing domain layer
- Clear contract: Interface defines all required methods

### Business Logic in Repository Methods
```dart
@override
Future<void> updateXP({
  int? vitalityDelta,
  int? mindDelta,
  int? soulDelta,
}) async {
  // 1. Get current state
  final current = await getCreatureState();

  // 2. Calculate new XP values (with clamping)
  final newVitalityXP = (current.xpVitality + (vitalityDelta ?? 0))
      .clamp(0, XpConstants.maxXP);

  // 3. Calculate new tiers based on XP
  final newLegsTier = XpConstants.getTierForXP(newVitalityXP);

  // 4. Create updated state
  final updated = current.copyWith(
    xpVitality: newVitalityXP,
    legsTier: newLegsTier,
    lastUpdated: DateTime.now(),
  );

  // 5. Save to storage
  await _localDataSource.saveCreatureState(updated);
}
```

**Why this pattern matters**:
- Business logic is in Flutter: Not in Unity, not in UI widgets
- Single source of truth: All XP updates go through this method
- Testable: Can verify tier evolution logic with unit tests

### Proper Error Handling Patterns
```dart
@override
Future<double> getProgressForAttribute(String attribute) async {
  final creature = await getCreatureState();

  switch (attribute.toLowerCase()) {
    case 'vitality':
      return creature.vitalityProgress;
    case 'mind':
      return creature.mindProgress;
    case 'soul':
      return creature.soulProgress;
    default:
      throw ArgumentError('Invalid attribute: $attribute');
  }
}
```

**Why this pattern matters**:
- Fail fast: Invalid inputs cause immediate errors
- Clear error messages: Developer knows exactly what went wrong
- Type-safe: Better than returning null or default value

## Model Patterns

See `lib/data/models/creature_state.dart` for reference patterns:

### Immutable Models with copyWith()
```dart
@HiveType(typeId: 0)
class CreatureState {
  @HiveField(0)
  final int xpVitality;

  @HiveField(1)
  final int xpMind;

  // ... more fields

  const CreatureState({
    required this.xpVitality,
    required this.xpMind,
    // ... more parameters
  });

  /// Create a copy with updated fields
  CreatureState copyWith({
    int? xpVitality,
    int? xpMind,
    // ... more parameters
  }) {
    return CreatureState(
      xpVitality: xpVitality ?? this.xpVitality,
      xpMind: xpMind ?? this.xpMind,
      // ... more fields
    );
  }
}
```

**Why this pattern matters**:
- Immutable: State can't be accidentally modified
- Type-safe: Dart compiler catches typos in field names
- Testable: Easy to create test fixtures with specific values

### Equality and HashCode
```dart
@override
bool operator ==(Object other) {
  if (identical(this, other)) return true;

  return other is CreatureState &&
      other.xpVitality == xpVitality &&
      other.xpMind == xpMind &&
      other.xpSoul == xpSoul &&
      // ... more fields
}

@override
int get hashCode {
  return xpVitality.hashCode ^
      xpMind.hashCode ^
      xpSoul.hashCode ^
      // ... more fields
}
```

**Why this pattern matters**:
- Testable: Can use `expect(state1, equals(state2))` in tests
- Value semantics: Two states with same values are considered equal
- Required for Hive: Enables proper state comparison

## Flutter ↔ Unity Communication (Advanced)

**Current POC**: `main.dart` contains basic color-changing demo

**Message Format** (Flutter → Unity):
```dart
_unityWidgetController?.postMessage(
  'GameObjectName',    // Unity GameObject name
  'MethodName',        // Public method on attached C# script
  'message_data'       // String parameter
);
```

**Example** (Send XP update to Unity):
```dart
// In Flutter repository or BLoC
void _notifyUnityOfXPChange(int vitalityXP, int tier) {
  final message = json.encode({
    'attribute': 'vitality',
    'xp': vitalityXP,
    'tier': tier,
    'progress': XpConstants.calculateProgress(vitalityXP, tier),
  });

  _unityWidgetController?.postMessage(
    'CreatureManager',  // Unity GameObject
    'UpdateAttribute',  // C# method: public void UpdateAttribute(string json)
    message
  );
}
```

**Unity C# Script** (Receives message):
```csharp
// Attach to GameObject named "CreatureManager"
public class CreatureManager : MonoBehaviour
{
    public void UpdateAttribute(string jsonMessage)
    {
        // Parse JSON
        var data = JsonUtility.FromJson<AttributeUpdate>(jsonMessage);

        // Update shader/visual based on tier and progress
        UpdateCreatureVisuals(data.tier, data.progress);
    }
}
```

**Critical Rules**:
- Unity scripts only handle visualization (shaders, particles, animations)
- Business logic stays in Flutter (calculating XP, determining tiers)
- Message format should be JSON for complex data
- Unity methods must be public to receive messages

## Common Pitfalls to Avoid

### ❌ Putting Business Logic in Unity
```csharp
// BAD - XP calculation in Unity
public void LogSquats(int count)
{
    int xp = count * 10;  // Business logic in Unity!
    currentXP += xp;
    UpdateTier();
}
```

```dart
// GOOD - XP calculation in Flutter
void logSquats(int count) {
  final xp = XpConstants.getActivityXP('squats') * (count ~/ 10);
  creatureRepository.updateXP(vitalityDelta: xp);
  // Unity receives result via message
}
```

### ❌ Accessing Hive Directly
```dart
// BAD - Direct Hive access
final box = Hive.box('creature');
final xp = box.get('xp_vitality', defaultValue: 0);
box.put('xp_vitality', xp + 10);
```

```dart
// GOOD - Repository pattern
final repository = CreatureRepository(localDataSource: LocalDataSource());
await repository.updateXP(vitalityDelta: 10);
```

### ❌ Skipping Tests for "Simple" Functions
```dart
// BAD - No tests written
static int getTierForXP(int xp) {
  if (xp >= tier3Threshold) return 3;
  if (xp >= tier2Threshold) return 2;
  if (xp >= tier1Threshold) return 1;
  return 0;
}
```

```dart
// GOOD - Comprehensive tests
test('getTierForXP handles boundary conditions correctly', () {
  expect(XpConstants.getTierForXP(99), 0);   // Just below tier 1
  expect(XpConstants.getTierForXP(100), 1);  // Exactly tier 1
  expect(XpConstants.getTierForXP(399), 1);  // Just below tier 2
  expect(XpConstants.getTierForXP(400), 2);  // Exactly tier 2
});
```

### ❌ Using `print()` for Debugging
```dart
// BAD - Print statements left in code
void updateXP(int delta) {
  print('Updating XP with delta: $delta');  // Avoid!
  // ... logic
}
```

```dart
// GOOD - Use debugPrint (or future: logger package)
void updateXP(int delta) {
  debugPrint('Updating XP with delta: $delta');
  // ... logic
}
```

## Testing Examples

### Pure Function Tests (XpConstants)
See `test/unit/core/constants/xp_constants_test.dart` for full examples:

```dart
test('calculateProgress returns 0.5 at midpoint of tier', () {
  // Tier 0: 0-100 XP, midpoint = 50
  expect(XpConstants.calculateProgress(50, 0), 0.5);

  // Tier 1: 100-400 XP (300 range), midpoint = 250
  expect(XpConstants.calculateProgress(250, 1), closeTo(0.5, 0.01));
});

test('stacks multiple bonuses multiplicatively', () {
  expect(
    XpConstants.calculateFinalXP(
      10,
      cameraValidated: true,
      hasStreak: true,
    ),
    18,  // 10 * 1.5 * 1.2 = 18
  );
});
```

### Repository Tests with Mocks
See `test/unit/data/repositories/creature_repository_test.dart` for full examples:

```dart
test('updateXP increases vitality XP and updates tier', () async {
  // Given: Initial state (tier 0)
  final repository = CreatureRepository(
    localDataSource: MockLocalDataSource(),
  );

  // When: Add 100 XP
  await repository.updateXP(vitalityDelta: 100);

  // Then: State should be tier 1
  final state = await repository.getCreatureState();
  expect(state.xpVitality, 100);
  expect(state.legsTier, 1);  // Should evolve!
});
```

### Model Tests
See `test/unit/data/models/creature_state_test.dart` for full examples:

```dart
test('copyWith creates new instance with updated values', () {
  final original = CreatureState.initial();
  final updated = original.copyWith(
    xpVitality: 100,
    legsTier: 1,
  );

  expect(updated.xpVitality, 100);
  expect(updated.legsTier, 1);
  expect(updated.xpMind, 0);  // Unchanged
});
```

## Commit Message Guidelines

Follow Conventional Commits format:

```
<type>(<scope>): <subject>

<optional body>

<optional footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `refactor`: Code refactoring (no feature change)
- `chore`: Build/tooling changes

**Examples**:
```
feat(xp): Add streak bonus multiplier to XP calculation

Implements 1.2x bonus for users with 3+ day streaks.
Updates XpConstants.calculateFinalXP() to accept hasStreak parameter.

Closes #42
```

```
test(creature): Add repository tests for tier evolution

Covers boundary conditions for tier transitions (99 → 100 XP, etc.)
Adds MockLocalDataSource for testing without Hive initialization.
```

```
fix(unity): Prevent crash when Unity widget not initialized

Added null check for _unityWidgetController before postMessage() calls.
Unity changes: None (Flutter-only fix)
```

**Unity-related commits**:
Always mention Unity changes in commit body:
```
feat(creature): Implement glowing shader based on XP progress

Unity changes:
- Created ChargeUpShader.shader with emission control
- Added ProgressGlow.cs script to CreatureManager GameObject
- Updated creature prefab with new shader material
```

## Build & Run Commands

### Development Workflow
```powershell
# Install dependencies
flutter pub get

# Run code generation (after model changes)
flutter pub run build_runner build --delete-conflicting-outputs

# Check linting
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Build debug APK (requires Unity export first)
flutter build apk --debug

# Run on device
flutter run
```

### Unity Export (Manual)
1. Open `D:\xenoMirror\client_app\unity\xeno_unity` in Unity Hub (2022.3 LTS)
2. In Unity: File → Build Settings → Player Settings
3. Verify:
   - Target Platform: Android
   - Scripting Backend: IL2CPP
   - Target Architectures: ARM64 + ARMv7
4. Use `flutter-unity-widget` plugin's "Export Android (debug)" option
5. Exported to: `D:\xenoMirror\client_app\android\unityLibrary\`

### Coverage Reporting (Requires lcov)
```powershell
# Install lcov on Windows: choco install lcov

# Generate coverage report
flutter test --coverage

# View summary
lcov --summary coverage/lcov.info

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open in browser
start coverage/html/index.html
```

## Useful Resources

- **Project Documentation**: See `docs/` directory
  - `docs/architecture.md` - System design and technical decisions
  - `docs/project_status.md` - Current sprint status and next steps
  - `docs/changelog.md` - Session-based change history
  - `docs/features/flutter-unity-bridge.md` - Unity integration details

- **Codebase Conventions**: See `CLAUDE.md`
  - MVP decisions and scope
  - Technology stack details
  - Development environment setup
  - Common issues & solutions

- **Product Requirements**: See `project_spec.md.md`
  - User stories
  - Feature priorities
  - MVP definition

## Questions or Issues?

If you encounter ambiguity or need clarification:
1. Read existing code in `lib/data/repositories/` for patterns
2. Check test files in `test/` for examples
3. Review `docs/architecture.md` for architectural decisions
4. Ask the user for clarification if requirements are unclear

**Remember**: It's better to ask than to make incorrect assumptions about business logic or architecture.

---

**Last Updated**: 2025-12-23
**Agent-Ready Score**: 75/100 (After Phase 1 completion: 95/100)
**Coverage Target**: 80% minimum
