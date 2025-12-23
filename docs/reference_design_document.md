# XenoMirror UI/UX Specification

**Version**: 1.0.0 (Initial Design)
**Last Updated**: 2025-12-23
**Status**: Active (Phase 2 Implementation)
**Compatibility**: XenoMirror MVP (architecture.md v0.3.0)

---

## Version History

| Version | Date | Changes | Updated By |
|---------|------|---------|------------|
| 1.0.0 | 2025-12-23 | Initial design spec - Cyberpunk/Neon theme, HUD architecture | Project Team |

---

## Document Purpose

This document defines the **strict UI/UX requirements** for Phase 2 (Presentation Layer) implementation.

**Target Audience**: Claude Code, Flutter developers
**Constraint**: The UI must NOT look like a standard Material/Cupertino app. It must look like a Sci-Fi HUD (Heads-Up Display).

**Context**: We are entering Phase 2 (UI/UX Implementation). You are responsible for the Flutter Presentation Layer. Visual Concept: "XenoMirror OS" — A high-tech containment interface overlaying a biological specimen.

---

## 1. Visual Philosophy: "The Containment Unit"
   The app simulates a handheld scanner or containment device.

The "Subject" (Unity Layer): Occupies the entire background/center depth. It is organic, soft, and cute.

The "Interface" (Flutter Layer): Floats above the subject. It is sharp, digital, neon, and semi-transparent. It represents the "glass" of the containment unit.

2. Color Palette (Cyberpunk/Neon)
   Do not use standard material colors. Use these specific hex codes to achieve the "Cipher_01" look.

Backgrounds:

Void Black: #050505 (Main background for non-Unity screens)

Deep Space: #0B0E14 (Cards/Panels background)

Glass Overlay: #0B0E14 with 0.8 opacity and BackdropFilter (Blur).

Primary Accents (The 3 Attributes):

💚 Vitality (Green): #00FF41 (Reference: Matrix/Terminal green)

🩵 Mind (Cyan): #00F3FF (Reference: Sci-fi Hologram)

💜 Soul (Magenta): #BC13FE (Reference: Synthwave Neon)

Functional Colors:

Text Primary: #E0E0E0 (Off-white, not harsh white)

Text Secondary: #556870 (Muted slate blue)

Alert/Error: #FF2A2A (Red neon)

3. Typography
   Headers / Data Values: Use a Monospace or "Tech" font (e.g., Orbitron, Rajdhani, or standard Courier Prime if custom fonts aren't loaded yet). ALL CAPS for labels.

Body / Feedback: Clean Sans-Serif (e.g., Roboto or Inter) for readability.

4. UI Architecture (The Z-Stack)
   The Main Screen (HomePage) must use a Stack widget structure:

Layer 0 (Bottom): UnityWidget. Full screen. Renders the creature.

Layer 1 (Vignette): A Container with a RadialGradient (Transparent center -> Dark borders). This makes the UI text at the edges readable while keeping the creature in the spotlight.

Layer 2 (The HUD):

Top Bar: "System Status". Small, technical text.

Center: EMPTY. This is the "Viewport". Do not place widgets here unless it's a transient alert.

Bottom Bar: "Control Deck". The habit logging buttons.

5. UI Components (Widget Guide)
   A. The "Protocol Button" (Main Action)
   Instead of round buttons, use Chamfered or Sharp rectangular buttons.

Shape: Rectangular with a thin neon border (1px).

State (Idle): Transparent fill, Colored Border (based on Attribute).

State (Pressed): Filled with Attribute Color (with Glow), Text turns Black.

Effect: Must have a BoxShadow with spreadRadius to simulate neon glow.

B. The "Bio-Meter" (Progress Bar)
Do not use a standard linear progress indicator.

Style: Segmented lines or a thin bar with a "glitch" effect.

Layout: Thin horizontal lines under the Top Bar.

Animation: Smooth tweening when XP is added.

C. The "Injection Panel" (Habit Logging Sheet)
When a user taps an Attribute button (e.g., Vitality):

Do NOT open a new full-screen page.

Show a Modal Bottom Sheet styled as a "Data Terminal".

Background: Dark, semi-transparent blur.

Content: Grid of actions (e.g., "Squats", "Run", "Sleep").

🔄 User Flows (UX)
Case 1: The "Injection" (Logging a Habit)
Goal: User logs 10 Squats (Vitality) quickly.

Idle State:

User sees the Creature (Unity) floating in the void.

HUD shows current levels: Vitality (Green), Mind (Cyan), Soul (Magenta).

Interaction:

User taps the [VITALITY] button on the Bottom Deck.

Selection:

A "Holo-Panel" (Bottom Sheet) slides up.

User selects "Squats (+10 XP)".

Feedback (The "Juice"):

Haptics: Trigger HapticFeedback.mediumImpact().

Visual: The UI flashes Green briefly.

Bridge: Send message to Unity: {"type": "reaction", "attribute": "vitality"}. (Creature plays animation).

Toast: A "System Log" appears near the creature: "Processing: Muscle Density Increased..."

Case 2: The "Bio-Scan" (Checking Stats)
Goal: User wants detailed stats.

Trigger:

User swipes UP on the Bottom Deck or taps a "Scan" button in the Top Bar.

Transition:

The Unity Layer blurs or darkens (via an opacity overlay).

The "Bio-Scan" screen slides in.

Layout (Reference: Medical Chart):

Display numeric stats: "Vitality: 78/100".

Display "Daily Protocols" (History list).

Visual: Use "wireframe" aesthetics for boxes and dividers.

🛠️ Implementation Priorities for You (Claude)
Theme Setup: Create AppTheme with the hex codes provided above.

HUD Layout: Build the HomePage with the Stack [Unity, Vignette, HUD] structure.

Custom Widgets: Create a NeonButton widget that accepts an AttributeType (Vitality/Mind/Soul) and styles itself accordingly (Green/Cyan/Magenta).

No Material 2.0: Avoid AppBar (unless styled invisible) and FloatingActionButton. Build custom containers.

---

## Appendix A: Design Validation Checklist

When `/update-docs` runs, the following checks are automated:

**Color Compliance**:
- [ ] No `Colors.*` Material constants (except Colors.transparent)
- [ ] All colors use constants from `lib/core/theme/app_colors.dart`
- [ ] Hex codes match exactly: #050505, #0B0E14, #00FF41, #00F3FF, #BC13FE, #E0E0E0, #556870, #FF2A2A

**Component Compliance**:
- [ ] No FloatingActionButton (use Protocol Button)
- [ ] No ElevatedButton/OutlinedButton (use Protocol Button)
- [ ] No standard LinearProgressIndicator (use Bio-Meter)
- [ ] No AppBar with default styling (use custom transparent overlay)

**Layout Compliance**:
- [ ] Main screen uses Stack widget
- [ ] UnityWidget is first child (z-index 0)
- [ ] Vignette overlay present (RadialGradient)
- [ ] Top Bar and Bottom Deck positioned correctly
- [ ] Center viewport empty (no obstructing widgets)

**Interaction Compliance**:
- [ ] All onPressed/onTap handlers include HapticFeedback.mediumImpact()
- [ ] Modal Bottom Sheets used for action selection (not full-screen routes)
- [ ] Blur effects applied to overlays (BackdropFilter)

**Typography Compliance**:
- [ ] Monospace/Tech font defined (Orbitron, Rajdhani, or Courier Prime)
- [ ] ALL CAPS transformation on labels (.toUpperCase())
- [ ] Sans-serif font for body text (Roboto or Inter)

---

## Appendix B: Design Spec Versioning Policy

**Semantic Versioning**: `MAJOR.MINOR.PATCH`

- **MAJOR**: Breaking changes to visual philosophy (e.g., switching from HUD to flat design)
- **MINOR**: New component types, color additions, layout variations
- **PATCH**: Clarifications, typo fixes, measurement adjustments

**Compatibility Notes**:
- Design spec version is tracked in `docs/.metadata.json`
- `/update-docs` compares file modification time to detect manual edits
- Manual edits require version bump + changelog entry

**Migration Strategy**:
- When design spec changes, update `architecture.md` "UI Layer" section
- Feature docs reference specific design spec version
- Breaking changes require updating existing UI components
