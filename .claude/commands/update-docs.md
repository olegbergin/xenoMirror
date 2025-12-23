---
description: Analyze recent commits and update project documentation
allowed-tools: Bash(git log:*), Bash(git status:*), Read, Write, Edit, Glob
---

# Update Documentation

Analyze recent git commits and update the XenoMirror project documentation.

## Instructions

Follow these steps carefully:

### Step 1: Get Last Update Timestamp
1. Try to read `docs/.metadata.json` to find the last update timestamp
2. If file doesn't exist, create it and use 7 days ago as default
3. Store the current timestamp for later update

### Step 2: Analyze Recent Commits
1. Run: `git log --since=<timestamp> --oneline --name-status`
2. Categorize changes by file type:
   - New files in `lib/` → Potential new features
   - Changes to `main.dart`, Unity scripts, or `pubspec.yaml` → Architecture changes
   - Commit messages with `feat:`, `fix:`, `docs:` → Categorize appropriately

### Step 3: Ask User for Session Summary
1. Ask: "What did you accomplish this session? (Be concise, 1-2 sentences)"
2. Use their answer to write the changelog entry

### Step 4: Generate Validation Health Report

**NEW (Phase 1 - Agent-Ready Infrastructure)**

Run automated validation checks and capture results:

1. **Linting Status**:
   ```bash
   flutter analyze 2>&1
   ```
   - Capture: Pass/Fail + warning/error count

2. **Test Coverage** (if coverage/lcov.info exists):
   ```bash
   flutter test --coverage 2>&1
   lcov --summary coverage/lcov.info 2>&1 | grep "lines"
   ```
   - Extract coverage percentage from output

3. **Build Status**:
   ```bash
   flutter build apk --debug --no-tree-shake-icons 2>&1
   ```
   - Capture: Pass/Fail (check exit code)

4. **Calculate Agent-Ready Score**:
   - agents.md exists: +25 points
   - Linting passing (zero warnings): +25 points
   - Coverage ≥80%: +25 points
   - Build succeeds: +25 points
   - **Total**: 0-100 points

5. **Format timestamp**: Get current UTC timestamp for "Last checked"

### Step 4.5: Design Validation (Phase 2 - UI/UX Implementation)

**ONLY run if Flutter UI files changed** (detect changes in `lib/presentation/`, `lib/widgets/`, or files with `Widget` suffix)

Run automated design compliance checks:

1. **Color Palette Validation** (0-20 points):
   ```bash
   # Search for Material color usage
   rg --type dart 'Colors\.' lib/presentation lib/widgets 2>&1 | grep -v 'Colors.transparent'
   # Search for inline color definitions
   rg --type dart 'Color\(0x' lib/presentation lib/widgets 2>&1
   ```
   - Flag any Material colors (Colors.blue, Colors.red) that aren't custom constants
   - Check if colors defined in `lib/core/theme/app_colors.dart` match design spec hex codes
   - Scoring: 20 points baseline, -2 per violation
   - Extract: Count of non-compliant color references

2. **Component Type Validation** (0-20 points):
   ```bash
   # Search for prohibited Material widgets
   rg --type dart '(FloatingActionButton|ElevatedButton|OutlinedButton|LinearProgressIndicator|AppBar)' lib/presentation lib/widgets 2>&1
   ```
   - Flag usage of standard Material buttons (should be custom Protocol Buttons)
   - Flag standard progress indicators (should be Bio-Meters)
   - Scoring: 20 points baseline, -5 per prohibited widget
   - Extract: Count of prohibited widget types

3. **Stack Layer Validation** (0-20 points):
   ```bash
   # Find HomePage/MainScreen and check Stack structure
   rg --type dart 'Stack\(' lib/presentation/home 2>&1
   ```
   - Verify UnityWidget is first child (bottom layer)
   - Check for vignette overlay (RadialGradient or similar)
   - Scoring: 20 if correct structure found, 0 if wrong
   - Extract: Pass/Fail on correct z-order

4. **Haptics Validation** (0-20 points):
   ```bash
   # Count interactions with haptics
   total_interactions=$(rg --type dart 'on(Pressed|Tap|LongPress):' lib/presentation lib/widgets -c 2>&1 | awk '{s+=$1} END {print s}')
   haptic_count=$(rg --type dart 'on(Pressed|Tap|LongPress):' lib/presentation lib/widgets -A 3 2>&1 | grep -c 'HapticFeedback')
   ```
   - Count interactions with haptics vs total interactions
   - Scoring: (haptic_count / total_interactions) * 20
   - Extract: Haptics coverage percentage

5. **Typography Validation** (0-20 points):
   ```bash
   # Check for text style definitions
   rg --type dart 'TextStyle|fontFamily' lib/core/theme 2>&1
   ```
   - Verify monospace font defined for headers
   - Check for ALL CAPS transformation on labels
   - Scoring: 20 if fonts defined correctly, 0 if missing
   - Extract: Pass/Fail on font definitions

6. **Calculate Design Compliance Score**:
   - Sum of all 5 checks (0-100 total)
   - Target: 80+ points for Phase 2 compliance

7. **Format timestamp**: Get current UTC timestamp for "Last design validation"

### Step 5: Update Documentation Files

#### `docs/changelog.md` (Always update)
- Add new session block at the **top** (reverse chronological order)
- Format:
  ```markdown
  ## Session YYYY-MM-DD
  **Summary:** [User's summary here]

  **Changes:**
  - [Key file changes from git log]

  **Commits:** [List of commit messages]
  ```

#### `docs/project_status.md` (Update if commits found)
- Move current "Current Focus" section → "Recently Completed"
- Ask user: "What's the new focus for next session?"
- **DO NOT** overwrite "Blockers & Open Questions" (user edits this manually)
- **NEW (Phase 1)**: Add/Update "🔍 Validation Health" section after "Current Focus":

  ```markdown
  ## 🔍 Validation Health

  Last checked: [TIMESTAMP from Step 4]

  | Metric | Status | Details |
  |--------|--------|---------|
  | **Linting** | ✅ Pass / ❌ Fail | `flutter analyze` - [X warnings/errors] |
  | **Test Coverage** | [XX%] | Target: 80% minimum |
  | **Build** | ✅ Pass / ❌ Fail | Debug APK builds successfully |
  | **Agent-Ready Score** | [XX/100] | [X/4 pillars complete] |

  **Agent-Ready Pillars**:
  - [x] agents.md documentation exists
  - [x] Opinionated linter configured (analysis_options.yaml)
  - [x/  ] Test coverage ≥80%
  - [ ] CI/CD pipeline (Future: Phase 2)
  ```

- **NEW (Phase 2)**: Add/Update "🎨 Design Compliance" section after "Validation Health":

  ```markdown
  ## 🎨 Design Compliance (Phase 2)

  Last validated: [TIMESTAMP from Step 4.5]

  | Metric | Score | Status | Issues |
  |--------|-------|--------|--------|
  | **Color Palette** | [X/20] | ✅ Pass / ⚠️ Warning / ❌ Fail | [N violations] - See details |
  | **Component Types** | [X/20] | ✅ Pass / ⚠️ Warning / ❌ Fail | Found: FloatingActionButton (use Protocol Button) |
  | **Stack Structure** | [X/20] | ✅ Pass / ❌ Fail | Unity layer must be first child |
  | **Haptics Coverage** | [X/20] | [XX%] | [N/M interactions] have haptic feedback |
  | **Typography** | [X/20] | ✅ Pass / ❌ Fail | Missing monospace font definition |
  | **Design Compliance Score** | [XX/100] | Target: 80+ for Phase 2 | |

  **Design Spec Version**: v1.0.0 (`docs/reference_design_document.md`)

  **Critical Issues**:
  - [ ] Issue 1: Non-compliant color usage in `lib/presentation/home/home_page.dart` (line 45)
  - [ ] Issue 2: Using Material FloatingActionButton instead of Protocol Button

  **Reference**: See `docs/reference_design_document.md` for full UI specification.
  ```

#### `docs/architecture.md` (Only if architectural changes detected)
- Detect changes to: `main.dart`, `*.cs`, `pubspec.yaml`, new directories in `lib/`
- Check if file was manually edited (compare file mtime vs last metadata timestamp)
- If manually edited: Ask "Manual edits detected in architecture.md. Overwrite? (yes/no)"
- If yes or no manual edits: Update relevant sections

#### `docs/features/*.md` (Update if related files changed)
- Detect which feature files need updates based on changed files
- Only update these sections:
  - "Status" field (e.g., "In Progress" → "Completed")
  - "Implementation Checklist" (mark items as done)
- **DO NOT** change: "Known Issues", manual notes, references

### Step 6: Update Metadata
1. Write current timestamp to `docs/.metadata.json`:
   ```json
   {
     "last_updated": "YYYY-MM-DDTHH:mm:ssZ",
     "last_commit": "commit_hash",
     "validation_last_checked": "YYYY-MM-DDTHH:mm:ssZ",
     "agent_ready_score": 75,
     "design_spec_version": "1.0.0",
     "design_last_validated": "YYYY-MM-DDTHH:mm:ssZ",
     "design_compliance_score": 0
   }
   ```
   - `design_spec_version`: Current version from `reference_design_document.md` header
   - `design_last_validated`: Timestamp from Step 4.5 (only if design validation ran)
   - `design_compliance_score`: 0-100 score from Step 4.5 (only if design validation ran)

## Detection Logic

### New Feature Docs Needed
If new files created in `lib/`:
- Ask user: "I detected new files in lib/. Should I create a feature doc? (yes/no/which files)"
- If yes, copy `docs/features/_template.md` and fill it out

### Architecture Changes
Trigger if changed files include:
- `lib/main.dart`
- `unity/xeno_unity/Assets/*.cs`
- `pubspec.yaml` (dependencies)
- New directories in `lib/`

### Changelog Categories
Use commit message prefixes:
- `feat:` → Feature implementation
- `fix:` → Bug fixes
- `docs:` → Documentation only
- `refactor:` → Code refactoring
- `test:` → Testing
- `chore:` → Build/dependencies

### Design Validation Triggers

Run design validation (Step 4.5) if ANY of these conditions are true:

**File Path Triggers**:
- Changes detected in `lib/presentation/`
- Changes detected in `lib/widgets/`
- New files created with `*_page.dart`, `*_screen.dart`, or `*_widget.dart` suffix
- Changes to `lib/core/theme/` files

**Commit Message Triggers**:
- Commit contains `ui:`, `design:`, `style:`, or `theme:` prefix
- Commit message contains keywords: "button", "color", "widget", "screen", "page"

**Dependency Triggers**:
- Changes to `pubspec.yaml` that add UI packages (e.g., google_fonts, flutter_svg)

**Skip Conditions** (do NOT run design validation):
- Only changes in `lib/data/`, `lib/domain/`, or `unity/` directories
- Commit message contains `[skip-design]` flag
- Only documentation files changed (*.md)

## Merge Strategy (Important!)

**Always preserve manual edits:**
- `changelog.md`: Safe to prepend (never overwrites)
- `project_status.md`: Only replace "Current Focus", "Recently Completed", and "Design Compliance" sections
- `architecture.md`: Ask before overwriting if manually edited
- `reference_design_document.md`: **READ-ONLY for /update-docs** - only update metadata fields
  - Auto-update: "Last Updated" timestamp, "Compatibility" version reference
  - Preserve: All design content (user manually versions this document)
  - If manual edits detected: Show message "Design spec modified. Please update version number in header."
- Feature docs: Only touch "Status" and "Implementation Checklist"

## Example Session

```
User runs: /update-docs