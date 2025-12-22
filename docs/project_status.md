# XenoMirror Project Status

**Last Updated**: 2025-12-22 23:45 UTC
**Current Phase**: MVP Development
**Sprint Goal**: Build automated documentation system and plan data architecture

---

## 🎯 Current Focus (This Session)
- [x] Design automated documentation system structure
- [x] Create comprehensive architecture documentation
- [x] Seed changelog with git history
- [ ] Complete feature documentation templates
- [ ] Update CLAUDE.md with doc system instructions
- [ ] Decide: Hive vs SQLite for local storage

## ✅ Recently Completed (Last 2 Sessions)
- ✅ Flutter-Unity bridge proof-of-concept (color-changing cube demo)
- ✅ Build pipeline validated on physical Android device
- ✅ Root documentation created (README, CLAUDE, project_spec)
- ✅ MVP scope defined (local-first, no AI chat, includes vision AI)
- ✅ Development priorities roadmap (8-step plan)

## 🚧 In Progress
- **Documentation Infrastructure**: Core docs created, need CLAUDE.md integration
- **Data Layer Research**: Evaluating Hive (simple key-value) vs SQLite (complex queries)

## 🔜 Next Up (Priority Order)
1. **Complete Documentation System** (1 hour)
   - Finish feature templates and CLAUDE.md updates
   - Test `/update-docs` workflow manually

2. **Data Model Design** (1-2 hours)
   - Define creature state schema (xp_vitality, xp_mind, xp_soul, tier levels)
   - Choose persistence library (Hive or SQLite)
   - Create Dart model classes

3. **Habit Logging UI** (2-3 hours)
   - Design Flutter screen with 3 habit type buttons (Vitality/Mind/Soul)
   - Create input form (activity type, duration, notes)
   - Wire up to temporary in-memory state (before persistence layer)

4. **XP Calculation Logic** (1-2 hours)
   - Implement XP formula (activity type → XP amount)
   - Add tier threshold logic (when to trigger evolution)
   - Write unit tests for XP calculations

5. **Unity Creature v0.1** (3-4 hours)
   - Model basic sphere core + 4 floating attachment points
   - Import to Unity, set up scene hierarchy
   - Create placeholder Tier 1/2/3 body parts

6. **Charge Up Shader** (2-3 hours)
   - Create URP shader graph with emission parameter
   - Wire shader to receive XP percentage from Flutter
   - Test glow intensity changes

7. **AI Vision Integration** (4-6 hours)
   - Add Google ML Kit dependencies
   - Implement pose detection for squat counting
   - Implement image labeling for object recognition (books)

8. **Polish & Testing** (2-3 hours)
   - Smooth transitions between states
   - Particle effects on XP gain
   - End-to-end testing on physical device

---

## ⚠️ Blockers & Open Questions

### Open Questions
- **Q1**: Should XP thresholds be linear (100, 200, 300...) or exponential (100, 250, 500...)?
  - **Impact**: Affects game pacing and progression feel
  - **Decision needed by**: Before implementing XP logic
  - **Recommendation**: Start with linear for MVP, gather user feedback, iterate

- **Q2**: Hive vs SQLite for local storage?
  - **Hive pros**: Faster for simple key-value, no SQL boilerplate, smaller package size
  - **SQLite pros**: Complex queries, relational data, SQL familiarity
  - **Current MVP needs**: Simple CRUD on creature state + habit entries (Hive sufficient)
  - **Recommendation**: Start with Hive for MVP, migrate to SQLite if complex queries needed

- **Q3**: How to handle partial progress when app closes unexpectedly?
  - **Options**:
    - A) Save on every action (frequent I/O, battery drain)
    - B) Save every 30 seconds (risk losing progress)
    - C) Save on app pause/resume events (Flutter lifecycle)
  - **Recommendation**: Option C (lifecycle-based saves) - balance between data safety and performance

- **Q4**: What 3D modeling tool to use for creature parts?
  - **Options**: Blender (free, steep curve), Vectary (browser, easier), Sketchfab (asset library)
  - **Decision needed by**: Before Unity creature modeling session
  - **Recommendation**: Start with Sketchfab free assets for MVP, learn Blender for custom parts later

### Current Blockers
- ❌ None

### Resolved Blockers (Recent)
- ✅ NDK version mismatch (resolved: installed both 23.1.7779620 and 27.0.12077973 side-by-side)
- ✅ Docker GPU driver issues (resolved: switched to native Windows development)
- ✅ MVP scope ambiguity (resolved: confirmed no AI chat, local storage only)

---

## 📊 MVP Progress Tracker
**Overall Completion**: ~20% (2 of 8 core features have working POCs)

| Feature | Status | Priority | Est. Time | Notes |
|---------|--------|----------|-----------|-------|
| **Flutter-Unity Bridge** | ✅ Done | P0 | - | Color demo working on device |
| **Documentation System** | 🚧 In Progress | P1 | 1h remaining | Core docs created, CLAUDE.md update pending |
| **Local Data Persistence** | 📋 Not Started | P0 | 2-3h | Hive vs SQLite decision pending |
| **Manual Habit Logging** | 📋 Not Started | P0 | 3-4h | After data layer exists |
| **XP Calculation Logic** | 📋 Not Started | P0 | 2-3h | BLoC pattern planned |
| **Unity Creature (Basic)** | 📋 Not Started | P0 | 4-6h | Rayman-style modular architecture |
| **Shader System (Glow)** | 📋 Not Started | P1 | 2-3h | After creature model exists |
| **AI Vision (ML Kit)** | 📋 Not Started | P2 | 4-6h | After manual logging works |

**Legend**:
- P0 = Critical for MVP (blocks other features)
- P1 = Important but not blocking
- P2 = Nice-to-have for MVP

---

## 🗓️ Session History

| Date | Duration | Focus | Outcome |
|------|----------|-------|---------|
| 2025-12-22 | 3h | Documentation system design + MVP planning | ✅ Docs infrastructure 80% complete |
| 2025-12-21 | 3h | Flutter-Unity bridge validation | ✅ POC working on physical device |
| 2025-12-20 | 1h | Initial project setup | ✅ Project scaffold created |

**Total time invested**: 7 hours
**Estimated time to MVP**: ~25-35 hours remaining

---

## 🎯 MVP Completion Criteria (Definition of Done)

The MVP is considered complete when:
1. ✅ User can log 3 types of habits manually (buttons for Squats/Reading/Meditation)
2. ✅ XP is calculated and persisted locally (survives app restart)
3. ✅ 3D creature in Unity displays glow intensity based on XP levels
4. ✅ Creature evolves (swaps body part models) when tier thresholds are crossed
5. ✅ AI Vision validates at least 1 activity type (e.g., squat counting with pose detection)
6. ✅ App builds and runs on physical Android device without crashes
7. ✅ Core documentation exists (architecture, features, build instructions)

**Out of scope for MVP**:
- ❌ Cloud backend / multi-device sync
- ❌ AI chat with creature (OpenAI integration)
- ❌ Social features (visiting friends)
- ❌ Authentication system
- ❌ Multiple creature types or customization

---

## 📈 Velocity Tracking

**Current Sprint Velocity**: ~2-3 hours per session, 1-2 sessions per week
**Burn-down rate**: Completing ~1-2 P0 features per week

**Projected MVP completion**: 3-4 weeks from now (mid-to-late January 2025)

---

## 💡 Ideas Parking Lot (Future Enhancements)

Ideas that came up during development but are deferred post-MVP:

1. **Multiple creature types**: Let user choose alien species (different evolution paths)
2. **Streak bonuses**: Extra XP for consecutive days of habits
3. **Achievements system**: Badges for milestones (100 squats, 7-day streak, etc.)
4. **Background animations**: Creature idles, reacts to user presence via camera
5. **Sound effects**: Audio feedback on XP gain, evolution animations
6. **Widget support**: Home screen widget showing creature state
7. **Dark mode**: Theme toggle (creature could change colors based on theme)
8. **Export data**: CSV export of habit history for external analysis

---

## 🔗 Related Documentation

- `docs/architecture.md` - Technical system design
- `docs/changelog.md` - Session history and change log
- `docs/features/` - Individual feature documentation
- `CLAUDE.md` - AI assistant instructions and build commands
- `README.md` - Project overview and setup instructions
- `project_spec.md.md` - Product requirements and user stories
