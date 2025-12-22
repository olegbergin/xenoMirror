# Feature: [Feature Name]

**Status**: [Not Started | In Progress | Completed | Deprecated]
**Owner**: [Developer name / "Community"]
**Related Files**:
- `lib/path/to/file.dart`
- `unity/xeno_unity/Assets/Scripts/Feature.cs`

---

## 1. Overview

Brief description of what this feature does and why it exists.

**User Story**: "As a [user type], I want [goal] so that [benefit]."

---

## 2. Technical Design

### 2.1 Architecture

How does this fit into the overall system? Which layers are involved?

- **Flutter UI**: [Description of UI components]
- **Flutter BLoC**: [State management approach]
- **Unity**: [3D visualization, if applicable]
- **Backend**: [API calls, if applicable]

### 2.2 Data Model

```dart
// Example: Data structures used by this feature
class FeatureData {
  String id;
  int value;
  DateTime timestamp;
}
```

### 2.3 API / Interfaces

**Flutter → Unity Messages** (if applicable):
```json
{
  "action": "feature_action",
  "parameter": "value"
}
```

**Unity → Flutter Callbacks** (if applicable):
```json
{
  "event": "feature_event",
  "data": {}
}
```

**Backend API Endpoints** (if applicable):
```
POST /api/feature
GET /api/feature/:id
```

### 2.4 Dependencies

- What other features must be completed first?
- What external packages are used?
- Are there any version constraints?

---

## 3. Implementation Checklist

- [ ] Define data model
- [ ] Create Flutter UI components
- [ ] Implement business logic (BLoC/Provider)
- [ ] Create Unity scripts (if applicable)
- [ ] Wire up bridge messages (if applicable)
- [ ] Implement backend API (if applicable)
- [ ] Write unit tests
- [ ] Write integration tests (if applicable)
- [ ] Test on physical device
- [ ] Update `architecture.md` with any architectural changes
- [ ] Add user documentation (if user-facing feature)

---

## 4. Testing Strategy

### Unit Tests
- [Describe what to test]
- [List test cases]

### Integration Tests
- [Describe integration scenarios]
- [List test scenarios]

### Manual Testing
1. [Step-by-step manual test procedure]
2. [Expected results]

---

## 5. Known Issues & Future Improvements

### Known Issues
- **Issue #1**: [Description]
  - **Impact**: [How it affects users]
  - **Workaround**: [Temporary solution]
  - **Planned fix**: [Future resolution]

### Future Improvements
- **Enhancement #1**: [Description of planned improvement]
- **Enhancement #2**: [Description of planned improvement]

---

## 6. References

- [Design mockups / Figma links]
- [External documentation]
- [Related GitHub issues]
- [API documentation]
- [Research notes]
