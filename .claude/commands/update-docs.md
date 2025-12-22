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

### Step 4: Update Documentation Files

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

### Step 5: Update Metadata
1. Write current timestamp to `docs/.metadata.json`:
   ```json
   {
     "last_updated": "YYYY-MM-DDTHH:mm:ssZ",
     "last_commit": "commit_hash"
   }
   ```

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

## Merge Strategy (Important!)

**Always preserve manual edits:**
- `changelog.md`: Safe to prepend (never overwrites)
- `project_status.md`: Only replace "Current Focus" and "Recently Completed"
- `architecture.md`: Ask before overwriting if manually edited
- Feature docs: Only touch "Status" and "Implementation Checklist"

## Example Session

```
User runs: /update-docs