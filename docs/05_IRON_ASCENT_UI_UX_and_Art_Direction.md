# IRON ASCENT — UI/UX & Art Direction Specification

> **Document role:** Authoritative visual, interaction, presentation, and player-experience specification for the MVP.
>
> **Scope:** Build Your First Chest Day vertical slice.
>
> **Purpose:** Remove visual and UX ambiguity so the implementation feels like one intentional game rather than disconnected Flutter screens placed over a 3D scene.

---

# 1. Document Authority

Project document priority:

1. `03_IRON_ASCENT_MVP_Spec.md`
2. `02_IRON_ASCENT_Flutter_Technical_Architecture.md`
3. `04_IRON_ASCENT_Game_Systems_and_Data.md`
4. `05_IRON_ASCENT_UI_UX_and_Art_Direction.md`
5. `01_IRON_ASCENT_Complete_Game_Plan.md`
6. `06_IRON_ASCENT_AI_Build_Runbook.md`

This document defines:

- visual direction
- camera presentation
- HUD
- menus
- interaction feedback
- responsive behavior
- animation and motion
- accessibility presentation
- scene composition
- asset styling

It does not redefine gameplay rules.

---

# 2. Experience Goal

IRON ASCENT should feel like:

> **A compact, low-poly fitness RPG world that is gritty, readable, tactile, and hopeful.**

The player should immediately understand:

- this is a real explorable space
- objects matter
- the gym is interactive
- training has consequences
- education is part of gameplay
- the interface supports the world instead of replacing it

The player should never feel like they are using:

> a workout tracker with a 3D background.

---

# 3. Core Visual Direction

Primary direction:

> **Industrial grit + hopeful rebuilding**

Visual qualities:

- low-poly
- stylized
- grounded
- worn
- functional
- warm in key areas
- readable
- slightly rugged
- not bleak
- not hyper-futuristic

The environment should suggest:

> people reclaimed an old industrial training space and turned it into a place for rebuilding themselves.

---

# 4. What to Avoid

Do not drift into:

- glossy commercial gym aesthetic
- cyberpunk neon overload
- zombie-horror despair
- photorealistic anatomy
- medieval RPG fantasy
- military tactical UI
- sterile hospital UI
- generic fitness-app gradients
- overly rounded playful mobile UI
- giant HUD bars
- visually noisy dashboards
- direct imitation of Project Zomboid UI or assets

Project Zomboid may inspire atmosphere, density, and grit, but not direct visual copying.

---

# 5. Visual Vocabulary

## Materials

Use:

- concrete
- steel
- black rubber flooring
- painted metal
- worn leather
- reclaimed wood
- old-school iron plates
- chalk residue
- chain-link barriers
- faded signage
- industrial lamps
- practical wiring
- patched surfaces

## Surface Treatment

Prefer:

- slightly worn edges
- subtle dirt
- low-detail texture variation
- matte materials
- selective highlights

Avoid:

- high-gloss plastic everywhere
- perfectly clean showroom equipment
- unnecessary texture complexity

---

# 6. Lighting Direction

Lighting should communicate function and mood.

## Main Gym

Use:

- directional daylight
- dusty window light
- warm practical overhead lights
- strong readable contrast around interactable stations

## Recovery Corner

Use:

- slightly warmer
- calmer
- softer contrast
- more comfortable visual tone

## Important Rule

Do not use darkness to create difficulty.

Interactable equipment must remain easy to identify.

---

# 7. Color Strategy

Do not overbuild a massive brand color system for the MVP.

Use three layers:

## Environment

Mostly neutral:

- dark gray
- charcoal
- muted concrete
- worn steel
- desaturated earth tones

## Functional Accent

Use one main accent family for:

- interaction
- selection
- progress
- important actionable UI

## Status Colors

Status must never rely on color alone.

Use icon + label + value.

Examples:

```text
Hydration   77
Fatigue     22
```

Avoid showing only colored bars with no labels.

---

# 8. Typography

The UI should feel strong and utilitarian.

Use:

- highly readable sans-serif
- condensed or bold style for headings if available
- clean regular body text
- clear numeric weight for stats

Hierarchy:

```text
Display / Title
Section Heading
Panel Heading
Body
Secondary Body
Caption
Status Label
```

Avoid:

- script fonts
- decorative distressed fonts for body text
- very thin weights
- all-caps paragraphs

All-caps is acceptable for short game-system labels.

---

# 9. Spacing System

Use a consistent spacing scale.

Recommended:

```text
4
8
12
16
24
32
48
```

Do not use arbitrary values everywhere.

Game UI should feel compact but not cramped.

---

# 10. Corner Radius

Keep UI moderately angular.

Recommended:

```text
Small controls: 6–8
Cards / panels: 8–12
Large modal: 12–16
```

Avoid highly rounded pill-heavy mobile-app styling.

The UI should feel more like equipment than social media.

---

# 11. Shadows and Depth

Use shadows sparingly.

Prefer:

- border
- contrast
- translucent panel
- subtle elevation

Avoid:

- large soft Material shadows everywhere
- floating card soup

Menus should feel embedded into the game presentation.

---

# 12. Camera

Camera direction:

> **Elevated third-person / isometric-style follow camera**

The camera should make the player and nearby gym equipment readable at the same time.

Required behavior:

- fixed general angle
- smooth follow
- no aggressive rotation
- no first-person mode
- no free orbit for MVP
- no cinematic swings during normal movement

---

# 13. Camera Composition

Target:

```text
Player:
near center or slightly below center

Forward visibility:
more world visible in movement direction if feasible

Vertical angle:
high enough to read room layout

Distance:
far enough to show nearby machines
close enough to read the player silhouette
```

The camera should communicate:

> small interactive diorama

rather than:

> third-person action shooter.

---

# 14. Camera Motion

Use:

- gentle positional smoothing
- optional minor look-ahead
- stable horizon

Avoid:

- head bob
- camera shake during walking
- sudden zooms
- excessive FOV changes

Training minigames may slightly reframe the camera, but the transition should be short and controlled.

---

# 15. Gameplay Screen Hierarchy

The world must occupy the majority of the screen.

Recommended priority:

```text
1. World
2. Interaction target
3. Active objective
4. Player condition
5. Secondary UI
```

Never allow the HUD to dominate the 3D scene.

---

# 16. Desktop / Web HUD Layout

Recommended:

```text
┌────────────────────────────────────────────┐
│ Quest                              Status  │
│                                            │
│                                            │
│               GAME WORLD                   │
│                                            │
│                                            │
│          Interaction Prompt                │
└────────────────────────────────────────────┘
```

## Top Left

Active quest.

Example:

```text
BUILD YOUR FIRST CHEST DAY
Discover 3 chest exercises
2 / 3
```

## Top Right

Condition.

Example:

```text
HYDRATION  77
FATIGUE    22
```

## Bottom Center

Contextual prompt.

Example:

```text
INCLINE DUMBBELL PRESS
[E] Inspect    [Hold E] Train
```

---

# 17. Mobile HUD Layout

Recommended:

```text
┌──────────────────────────────┐
│ Quest                Status │
│                              │
│         GAME WORLD           │
│                              │
│                              │
│        Interact Prompt       │
│                              │
│  Joystick            Action │
└──────────────────────────────┘
```

## Bottom Left

Virtual joystick.

## Bottom Right

Interact button.

Optional secondary action button appears only when context requires it.

Do not permanently display many buttons.

---

# 18. HUD Behavior

HUD elements should be:

- compact
- translucent
- readable over varied backgrounds
- responsive
- dismissible where appropriate

Avoid:

- giant progress bars
- persistent full-screen panels
- excessive labels
- duplicated information

---

# 19. Quest HUD

Quest HUD should show only:

```text
Quest title
Current objective
Progress
```

Example:

```text
BUILD YOUR FIRST CHEST DAY
Discover chest exercises
2 / 3
```

Do not show all eight quest objectives simultaneously during gameplay.

Full details belong in Quest Log.

---

# 20. Condition HUD

Hydration and Fatigue should use:

- icon
- label
- numeric value
- optional compact bar

Example:

```text
💧 HYDRATION   77
⚡ FATIGUE     22
```

Icons should be visually distinct even in grayscale.

---

# 21. Condition Change Feedback

When condition changes:

```text
Hydration -3
Fatigue +12
```

Show small temporary feedback near the status HUD.

Duration:

```text
~1.5–2.5 seconds
```

Do not interrupt gameplay with a modal.

---

# 22. Interaction Prompt

Interaction prompts are core gameplay UI.

Required states:

```text
No target
Target available
Target selected
Interaction active
Unavailable
```

Example:

```text
INCLINE DUMBBELL PRESS
[E] Inspect
[Hold E] Train
```

If unavailable:

```text
CABLE FLY
Training unavailable during current interaction.
```

---

# 23. Interaction Target Feedback

The selected object should have subtle world feedback.

Use one or more:

- soft outline
- ground marker
- icon above station
- slight emissive accent
- contextual label

Avoid glowing the entire machine like a loot chest.

---

# 24. Discovery Feedback

First-time exercise discovery should feel rewarding.

Example:

```text
NEW EXERCISE DISCOVERED

INCLINE DUMBBELL PRESS

Codex Updated
+5 XP
```

Presentation:

- short centered card
- optional icon
- quick entrance animation
- non-blocking or lightly blocking
- dismiss automatically or by input

Duration target:

```text
2–3 seconds
```

---

# 25. Quest Start Feedback

When the coach starts the quest:

```text
NEW QUEST

BUILD YOUR FIRST CHEST DAY

Don't collect exercises.
Build a session.
```

Then transition into the regular quest HUD.

Do not use long cutscenes.

---

# 26. Quest Objective Completion

Feedback should be lightweight.

Example:

```text
OBJECTIVE COMPLETE
Inspect an isolation movement
```

Then automatically update HUD to next objective.

---

# 27. Quest Completion

Quest completion should have stronger presentation.

Example:

```text
QUEST COMPLETE

BUILD YOUR FIRST CHEST DAY

CHEST PROGRAMMING I UNLOCKED
+100 XP
```

Use:

- stronger scale animation
- short audio cue
- background dim
- clear confirmation

Duration:

```text
3–5 seconds
```

Do not make it a 20-second cinematic.

---

# 28. Main Menu

Required:

```text
IRON ASCENT

[Continue]
[New Game]
[Settings]
```

Optional:

```text
[Support / Premium]
```

Visual direction:

- 3D gym background or atmospheric still
- minimal menu
- strong title
- no dashboard clutter

---

# 29. Gameplay Pause Menu

Recommended:

```text
RESUME
CODEX
QUESTS
MAP
SETTINGS
RETURN TO TITLE
```

No inventory tab is required for MVP.

---

# 30. Codex Screen

The Codex should feel like a field guide, not a spreadsheet.

Layout:

```text
CHEST

Pressing
[Incline Dumbbell Press]
[Machine Chest Press]

Isolation
[Cable Fly]
```

Locked entry:

```text
???
Undiscovered
```

---

# 31. Codex Entry Layout

Recommended:

```text
INCLINE DUMBBELL PRESS

PRESS
Upper Chest Emphasis

Primary
Chest

Secondary
Triceps
Anterior Deltoids

WHAT IT DOES
Short summary

TECHNIQUE
• cue
• cue
• cue
```

Avoid overly long educational articles in the MVP.

---

# 32. Quest Log

Quest Log should show:

```text
BUILD YOUR FIRST CHEST DAY

✓ Talk to the Coach
✓ Discover 3 chest exercises
✓ Inspect a pressing movement
✓ Inspect an isolation movement
○ Build a 3-exercise session
○ Complete a working set
○ Return to Coach
○ Recover
```

Use clear completion states.

---

# 33. Session Builder

This is a key educational screen.

Layout:

```text
BUILD YOUR CHEST SESSION

SELECT 3

[✓] Incline Dumbbell Press
[✓] Machine Chest Press
[✓] Cable Fly

SESSION STRUCTURE
Pressing        ✓
Isolation       ✓
Exercise Count  3 / 3

[VALIDATE SESSION]
```

---

# 34. Session Builder Invalid State

Example:

```text
SESSION NEEDS ADJUSTMENT

Your session is heavily press-focused.

Try including a chest isolation movement so the session is not built entirely around the same movement role.
```

Use educational language.

Avoid:

```text
WRONG
BAD BUILD
FAILED
```

---

# 35. Training Minigame UI

Keep it visually simple.

Example:

```text
INCLINE DUMBBELL PRESS

REP 3 / 5

[------ CONTROL ZONE ------]
             ▲

PRESS
```

Show:

- current rep
- timing zone
- action cue
- minimal condition info if necessary

Hide unrelated HUD during minigame.

---

# 36. Training Grade Feedback

Per rep:

```text
CLEAN
GOOD
ROUGH
MISS
```

Keep feedback quick.

Final screen:

```text
SET COMPLETE

Clean Reps   4 / 5
Technique    GOOD

Fatigue      +12
Hydration    -3
XP           +20
```

---

# 37. Recovery Corner UX

Recovery area should visually contrast with training area.

Use:

- calmer lighting
- less equipment clutter
- floor mat
- water station
- simple signage

Prompt examples:

```text
WATER STATION
[Drink]
```

```text
RECOVERY MAT
[Recover]
```

---

# 38. Recovery Feedback

Water:

```text
HYDRATION +15
```

Mat:

```text
FATIGUE -15
```

Keep feedback immediate.

---

# 39. Iron Map Preview

Purpose:

> communicate the larger world without building it.

Recommended layout:

```text
IRON MAP

● Hypertrophy District
  AVAILABLE

○ Strength Yard
  LOCKED

○ Cardio Run
  LOCKED

○ Mobility Temple
  LOCKED

○ Recovery House
  FUTURE

○ Macro Market
  FUTURE

○ Arena
  FUTURE
```

Do not implement actual travel to locked areas.

---

# 40. Map Visual Style

Use:

- stylized district diagram
- compact industrial map
- symbolic icons
- clear lock states

Avoid:

- giant realistic city map
- Google Maps aesthetic
- complex navigation

---

# 41. Competition Preview

Simple screen:

```text
ARENA

PHYSIQUE LEAGUE
Coming Soon

STRENGTH LEAGUE
Coming Soon

ENDURANCE LEAGUE
Coming Soon

HYBRID LEAGUE
Coming Soon
```

This screen exists to communicate future scale.

Do not fake a fully working multiplayer backend.

---

# 42. Premium / Support Screen

Keep this respectful and non-predatory.

Example:

```text
IRON ASCENT SUPPORTER

Support development and future expansion.

Core fitness education remains playable without purchase.

[View Supporter Option]
[Restore Purchase]
```

Do not use:

- countdown timers
- fake scarcity
- health penalties
- forced popups after every action

---

# 43. Settings Screen

Required:

```text
Audio Volume
Reduced Motion
Graphics Quality
Control Hints
Reset Save
```

Optional:

```text
Vibration
Text Scale
```

---

# 44. Responsive Breakpoints

Do not design only for one phone.

Use logical categories:

```text
Compact
Medium
Expanded
```

## Compact

Phones.

Use:

- stacked layouts
- bottom actions
- larger touch targets

## Medium

Large phones / tablets.

Use:

- split layouts where useful

## Expanded

Desktop / web.

Use:

- centered panels
- keyboard hints
- more horizontal room

---

# 45. Touch Targets

Minimum recommended:

```text
44–48 logical pixels
```

Interactive controls should be easy to hit.

Do not use tiny desktop-sized buttons on mobile.

---

# 46. Panel Widths

Avoid full-width panels on desktop.

Recommended:

```text
Small modal: 320–420
Medium panel: 480–640
Large information view: 720–960
```

On mobile:

```text
use most available width with safe margins
```

---

# 47. Motion

Motion should communicate state, not decorate everything.

Use motion for:

- discovery
- quest progression
- panel transitions
- button feedback
- condition updates
- world interaction
- training timing

Avoid constant idle UI movement.

---

# 48. Reduced Motion

Reduced Motion mode should:

- remove large scale animations
- reduce camera easing
- simplify panel transitions
- reduce flashy discovery effects
- slow/simplify training timing visual

It must preserve all information.

---

# 49. Audio Direction

If used:

## Environment

- low gym ambience
- distant metal sounds
- subtle ventilation
- footsteps

## UI

- soft interaction confirm
- discovery chime
- quest completion hit
- training timing feedback

Avoid:

- arcade casino sounds
- excessive UI beeps
- constant music overpowering ambience

---

# 50. Music Direction

Optional for MVP.

If included:

- low intensity
- industrial / ambient
- determined
- not horror
- not EDM gym montage

Music must not be necessary for comprehension.

---

# 51. NPC Presentation

NPC dialogue should use compact dialogue panels.

Example:

```text
HYPERTROPHY COACH

Don't collect exercises.
Build a session.
```

Use:

- NPC name
- portrait optional
- 1–3 short lines
- clear continue control

Avoid dialogue walls.

---

# 52. Coach Character Direction

Coach silhouette should communicate:

- experienced
- approachable
- physically trained
- grounded

Avoid caricature:

- giant steroid monster
- military drill sergeant
- meme gym bro

The coach represents credible guidance.

---

# 53. Player Character Direction

Player should be:

- readable from camera distance
- low-poly
- neutral starting physique
- clearly animated
- visually distinct from NPCs

The MVP does not need body progression morphs.

---

# 54. Exercise Station Readability

Each required station should have a distinct silhouette.

Incline Dumbbell Press:

- angled bench
- dumbbells nearby

Machine Chest Press:

- seated machine
- pressing handles

Cable Fly:

- upright cable structure

The player should identify them without opening a menu.

---

# 55. Environment Composition

Design the gym around visual landmarks.

Recommended:

```text
Entrance / Spawn
      ↓
Coach
      ↓
Incline Press
      ↓
Machine Press
      ↓
Cable Fly
      ↓
Recovery Corner
```

The exact layout can differ, but the room should naturally guide the player through the quest.

---

# 56. Environmental Signage

Use diegetic signage for wayfinding.

Examples:

```text
HYPERTROPHY
PRESSING
CABLES
RECOVERY
```

Keep text short.

Do not rely on arrows everywhere.

---

# 57. Object Density

Prefer:

> small + dense + meaningful

Avoid:

> huge + empty + decorative

Every major region of the MVP gym should contain either:

- interactable content
- navigation landmark
- atmosphere supporting the scene

---

# 58. Loading Screen

If needed:

```text
IRON ASCENT

Loading Hypertrophy Gym...
```

Optional rotating tip:

> More exercises do not automatically mean better training.

Keep tips short and sourced from actual game concepts.

---

# 59. Empty / Error States

Codex empty:

```text
No exercises discovered yet.

Explore the gym and inspect equipment.
```

Purchase error:

```text
Store unavailable right now.
Core gameplay is still available.
```

Save error:

```text
Progress could not be saved.
Your current session remains active.
```

Be clear and concise.

---

# 60. Accessibility Presentation

Required:

- readable text
- non-color-only status
- reduced motion
- captions/text for dialogue
- keyboard navigation for Flutter screens
- touch controls
- scalable UI
- visible focus states where appropriate

---

# 61. Contrast

Important HUD text should remain readable over the game scene.

Use:

- dark translucent backing
- subtle stroke
- high-contrast text

Do not rely on text placed directly over complex backgrounds.

---

# 62. Focus and Keyboard UX

Desktop/web menus should support:

- Tab focus
- Enter / Space activation
- Escape close
- visible focus state

Do not make keyboard users reach for the mouse for basic navigation.

---

# 63. Cursor Behavior

Desktop/web:

- pointer cursor on clickable Flutter controls
- default cursor over world unless interaction UI requires otherwise

Do not overcomplicate cursor states.

---

# 64. Visual Feedback Priority

Every player action should answer:

```text
Did the game receive my input?
What happened?
Why did it happen?
What should I do next?
```

Examples:

Inspect:

```text
Exercise discovered
Codex updated
Quest progressed
```

Train:

```text
Set completed
Condition changed
Quest progressed
```

Recover:

```text
Fatigue decreased
Quest completed
```

---

# 65. No Redundant UI

If the world already communicates something clearly, do not duplicate it unnecessarily.

Example:

Do not show:

```text
CABLE FLY
CABLE FLY MACHINE
YOU ARE NEAR CABLE FLY
PRESS E FOR CABLE FLY
```

One clear prompt is enough.

---

# 66. MVP Screen Flow

Canonical:

```text
Launch
  ↓
Main Menu
  ↓
Gameplay
  ├── Coach Dialogue
  ├── Exercise Inspect
  ├── Session Builder
  ├── Training Minigame
  ├── Recovery
  │
  ├── Codex
  ├── Quest Log
  ├── Map Preview
  ├── Competition Preview
  └── Settings
```

---

# 67. Visual QA Checklist

## World

- [ ] Player readable against floor
- [ ] Coach visually identifiable
- [ ] Three stations visually distinct
- [ ] Recovery corner visually different
- [ ] Interactables easy to identify
- [ ] No large empty spaces
- [ ] No broken lighting

## HUD

- [ ] Quest readable
- [ ] Hydration readable
- [ ] Fatigue readable
- [ ] Prompt readable
- [ ] Mobile controls not overlapping content

## Panels

- [ ] Codex readable
- [ ] Quest Log readable
- [ ] Session Builder understandable
- [ ] Settings usable
- [ ] Map preview understandable

## Feedback

- [ ] Discovery noticeable
- [ ] Quest progression noticeable
- [ ] Training result clear
- [ ] Recovery result clear
- [ ] Quest completion satisfying

---

# 68. UX QA Checklist

- [ ] Player knows where to go after spawning
- [ ] Coach interaction is obvious
- [ ] Player understands how to inspect equipment
- [ ] Player understands discovered vs undiscovered
- [ ] Player understands press vs isolation
- [ ] Session Builder explains invalid choice
- [ ] Player can complete training without tutorial confusion
- [ ] Fatigue and hydration change visibly
- [ ] Recovery is clearly prompted
- [ ] Quest completion is obvious
- [ ] Player can find Codex
- [ ] Player can return to gameplay easily
- [ ] No screen traps player
- [ ] No modal has unclear dismissal

---

# 69. Final Art Direction Contract

The MVP should visually communicate:

> **You are rebuilding yourself inside a rugged training world.**

Not:

> **You are browsing a fitness app.**

The environment should carry the emotional tone.

The UI should stay restrained.

The player should remember:

- the coach
- the gym
- the machines
- the discovery
- the training
- the recovery

not a pile of cards and menus.

---

# 70. Final UI/UX Rule

When choosing between:

```text
more UI
```

and:

```text
better environmental interaction
```

prefer the environment whenever the interaction remains understandable.

IRON ASCENT succeeds when:

> **the world teaches, the UI clarifies, and the player acts.**
