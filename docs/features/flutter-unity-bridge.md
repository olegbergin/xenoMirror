# Feature: Flutter-Unity Bridge

**Status**: ✅ Completed (POC)
**Owner**: Core team
**Related Files**:
- `lib/main.dart:28-47` (Flutter side - UnityWidgetController)
- `unity/xeno_unity/Assets/ColorChanger.cs` (Unity side - message receiver)
- `unity/xeno_unity/Assets/Scenes/SampleScene.unity` (Unity scene)

---

## 1. Overview

The Flutter-Unity Bridge enables communication between the Flutter UI shell and the Unity 3D rendering engine. Currently implemented as a one-way proof-of-concept (Flutter → Unity).

**User Story**: "As a developer, I want Flutter to send commands to Unity so that the UI can control 3D visualizations."

**Why this exists**: Flutter provides superior UI/UX development tools (hot reload, rich widget library), while Unity excels at 3D rendering and physics. The bridge allows us to use the best tool for each job without compromise.

---

## 2. Technical Design

### 2.1 Architecture

```
Flutter Widget Tree                  Unity Scene Hierarchy
┌────────────────────┐              ┌─────────────────┐
│ UnityControlScreen │              │  SampleScene    │
│   ├─ UnityWidget ◄─┼──postMessage─┼► Cube           │
│   └─ FABs (Buttons)│              │   └─ ColorChanger│
└────────────────────┘              └─────────────────┘
```

**Layers involved**:
- **Flutter UI**: Triggers commands via button presses
- **Bridge**: `flutter-unity-view-widget` package handles IPC (Inter-Process Communication)
- **Unity**: C# scripts receive and handle messages via public methods

**Key architectural constraint**: Unity is a "dumb renderer" - no business logic allowed in Unity scripts, only visualization.

### 2.2 Data Model

**Message format**: String (currently plain text, will migrate to JSON for structured data)

**Current implementation**:
```dart
// Flutter side (lib/main.dart:42)
_unityWidgetController?.postMessage(
  'Cube',        // GameObject name in Unity scene hierarchy
  'SetColor',    // Public method name in attached C# script
  'red'          // String argument (message payload)
);
```

```csharp
// Unity side (ColorChanger.cs:6-22)
public class ColorChanger : MonoBehaviour {
    public void SetColor(string message) {
        if (message == "red") {
            GetComponent<Renderer>().material.color = Color.red;
        } else if (message == "blue") {
            GetComponent<Renderer>().material.color = Color.blue;
        } else {
            // Fallback to green for unknown messages
            GetComponent<Renderer>().material.color = Color.green;
        }
    }
}
```

**Future format** (JSON for creature updates):
```dart
controller.postMessage('CreatureRoot', 'UpdateGlow', jsonEncode({
  'vitality': 0.8,  // XP percentage (0.0 - 1.0)
  'mind': 0.5,
  'soul': 0.3
}));
```

### 2.3 API / Interfaces

**Flutter → Unity API**:
```dart
class UnityWidgetController {
  /// Send a message to a Unity GameObject
  ///
  /// [gameObjectName]: Must match Unity GameObject name exactly (case-sensitive)
  /// [methodName]: Must match public method in C# script (case-sensitive)
  /// [message]: Arbitrary string (can be JSON for structured data)
  void postMessage(
    String gameObjectName,
    String methodName,
    String message
  );
}
```

**Unity → Flutter Callbacks**: ❌ Not yet implemented
*Future plan*: Use `UnityMessageManager.Instance.SendMessageToFlutter(string message)` for event notifications (e.g., animation finished, object clicked)

### 2.4 Dependencies

**Flutter packages**:
- `flutter_unity_widget` (master branch from GitHub: https://github.com/juicycleff/flutter-unity-view-widget)
  - Version: Latest commit from master (no stable release)
  - Why master: Active development, bug fixes

**Unity packages**:
- FlutterUnityIntegration (bundled with `flutter_unity_widget`)
  - Location: `unity/xeno_unity/Assets/FlutterUnityIntegration/`
  - Includes: UnityMessageManager, NativeAPI, Demo scenes

**Prerequisites**:
- Unity 2022.3 LTS must export project to `android/unityLibrary/` before Flutter build
- Physical Android ARM device required (x86_64 emulators NOT supported)
- Two NDK versions: 23.1.7779620 (Unity IL2CPP) + 27.0.12077973 (Flutter plugins)

---

## 3. Implementation Checklist

- [x] Add `flutter_unity_widget` dependency to `pubspec.yaml`
- [x] Create Flutter UI with `UnityWidget` embedded
- [x] Store `UnityWidgetController` reference in `_onUnityCreated` callback
- [x] Create Unity scene with test GameObject (Cube)
- [x] Attach C# script with public method for receiving messages
- [x] Export Unity project to Android (`android/unityLibrary/`)
- [x] Test on physical device (color commands working)
- [ ] Implement JSON message parsing in Unity (for future creature updates)
- [ ] Add Unity → Flutter callbacks (for future event notifications)
- [ ] Add error handling for null controller (currently has null check, but no user feedback)
- [ ] Add message queue (batch messages to reduce bridge overhead)

---

## 4. Testing Strategy

### Manual Testing (Current)
1. Build and deploy to physical Android device via `flutter run`
2. Wait for Unity to initialize (~3-5 seconds)
3. Tap "Make RED" button → **Expected**: Cube turns red, console logs "Command sent: red"
4. Tap "Make BLUE" button → **Expected**: Cube turns blue, console logs "Command sent: blue"
5. Check Unity logs for any errors (should be clean)

### Unit Tests
❌ Not yet implemented

**Difficulty**: Hard to unit test Unity bridge without mocking the native platform channel. Would require:
- Mocking `UnityWidgetController`
- Mocking platform method channel
- Test harness on actual device (integration test, not unit test)

**Recommendation**: Skip unit tests for bridge, focus on integration tests instead.

### Integration Tests
❌ Not yet implemented

**Future approach**:
- Use Flutter integration test driver
- Create test Unity scene that echoes messages back to Flutter
- Verify round-trip communication (Flutter → Unity → Flutter)
- Requires device farm setup (not critical for MVP)

**Test coverage**: ~0% automated, 100% manual verification

---

## 5. Known Issues & Future Improvements

### Known Issues

**Issue #1**: Controller can be null if Unity fails to initialize
- **Impact**: App doesn't crash (null check in place), but buttons do nothing
- **Workaround**: Check `_unityWidgetController != null` before calling `postMessage` (currently implemented)
- **Planned fix**: Add visual indicator for Unity initialization status (loading spinner)

**Issue #2**: No type safety for message format
- **Impact**: Typos in `gameObjectName` or `methodName` fail silently (no error, no visual feedback)
- **Example**: `postMessage('Cubes', ...)` won't work (should be 'Cube')
- **Future fix**: Create Dart/C# message classes with code generation (`json_serializable`)

**Issue #3**: Bridge overhead for high-frequency messages
- **Impact**: Sending 60 messages/second (e.g., shader updates) could cause performance issues
- **Current status**: Not tested yet (POC only sends messages on button clicks)
- **Future fix**: Implement message batching (queue messages, send every 100ms)

**Issue #4**: One-way communication only
- **Impact**: Unity can't notify Flutter of events (e.g., animation finished, object clicked)
- **Future fix**: Implement `UnityMessageManager.SendMessageToFlutter()` callback

### Future Improvements

1. **JSON message protocol**
   - Replace plain strings with structured JSON
   - Use `json_serializable` for type-safe message classes
   - Example:
     ```dart
     class CreatureUpdateMessage {
       final double vitality;
       final double mind;
       final double soul;
     }
     ```

2. **Bi-directional communication**
   - Implement Unity → Flutter callbacks
   - Use cases:
     - Unity notifies Flutter when animation completes
     - Unity sends tap events (user taps creature → show detail screen)

3. **Error handling improvements**
   - Add try-catch in Unity methods
   - Return error codes to Flutter
   - Show user-friendly error messages (e.g., "Unity initialization failed")

4. **Performance optimization**
   - Message batching for high-frequency updates
   - Compression for large JSON payloads
   - Benchmark bridge latency (target: < 16ms for 60fps)

5. **Type-safe API**
   - Code generation for message classes (Dart + C#)
   - Compile-time checks for valid GameObject names
   - Auto-complete for method names in IDE

---

## 6. References

- [flutter-unity-view-widget GitHub](https://github.com/juicycleff/flutter-unity-view-widget)
- [Unity Native Plugins documentation](https://docs.unity3d.com/Manual/NativePlugins.html)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)
- Internal: `docs/architecture.md` section 4 "Flutter ↔ Unity Bridge"
- Internal: `CLAUDE.md` section "Flutter ↔ Unity Communication"

### Example Projects
- [flutter_unity_widget Demo](https://github.com/juicycleff/flutter-unity-view-widget/tree/master/example) - Official example
- Similar hybrid apps: AR Foundation + Flutter, Vuforia + Flutter

### Troubleshooting
- **"dlopen failed: library not found"**: Using x86_64 emulator instead of ARM device
- **Controller is null**: Unity export not found (re-export from Unity)
- **NDK version errors**: Install both required NDK versions side-by-side
