# IRON ASCENT — AI Build Runbook

> **Document role:** Execution protocol for an AI coding agent building the IRON ASCENT MVP.
>
> **Purpose:** Define how the agent should read the project, make decisions, implement features, validate work, avoid scope creep, and report progress.
>
> **Primary rule:** Build the playable vertical slice before expanding anything.

---

# 1. Mandatory Reading Order

Before modifying code, read these documents in this order:

1. `01_IRON_ASCENT_Complete_Game_Plan.md`
2. `02_IRON_ASCENT_Flutter_Technical_Architecture.md`
3. `03_IRON_ASCENT_MVP_Spec.md`
4. `04_IRON_ASCENT_Game_Systems_and_Data.md`
5. `05_IRON_ASCENT_UI_UX_and_Art_Direction.md`
6. `06_IRON_ASCENT_AI_Build_Runbook.md`

Do not begin implementation after reading only one file.

---

# 2. Conflict Priority

If instructions conflict, use:

```text
03 MVP Spec
    ↓
02 Technical Architecture
    ↓
04 Game Systems & Data
    ↓
05 UI/UX & Art Direction
    ↓
01 Complete Game Plan
    ↓
06 Runbook execution guidance
```

The MVP Spec controls scope.

The Architecture controls code organization.

Game Systems controls rules/data.

UI/UX controls presentation.

The Complete Plan controls long-term intent.

---

# 3. Mission

Build:

> **One polished, cross-platform chest-day learning loop inside a low-poly 3D gym.**

The final MVP must allow the player to:

```text
launch
walk
interact
discover exercises
inspect exercise knowledge
build a chest session
perform a training set
gain fatigue
lose hydration
return to coach
recover
unlock Codex knowledge
save progress
reload progress
```

Anything that does not help this loop is lower priority.

---

# 4. Core Execution Rule

Always prefer:

> **working vertical slice > broad unfinished framework**

Do not build fifteen systems to 20%.

Build the required path end-to-end.

---

# 5. Do Not Expand Scope

Do not add:

- new districts
- live multiplayer
- real-time leaderboard
- combat
- inventory system
- crafting
- nutrition simulation
- body morphing
- procedural world
- complex NPC AI
- wearable APIs
- authentication
- cloud save
- cosmetic shop
- advanced avatar customization

unless the MVP explicitly requires them.

---

# 6. Inspect Before Editing

Before changing code:

1. inspect project structure
2. inspect existing dependencies
3. inspect current architecture
4. inspect relevant files
5. search for existing abstractions
6. reuse working code when appropriate
7. avoid duplicate systems

Do not create a new service if an equivalent one already exists.

---

# 7. Never Rewrite Working Code Without Reason

Do not refactor working systems merely because another pattern looks cleaner.

Refactor only if:

- current code blocks MVP implementation
- architecture violates project docs
- code is broken
- tests expose correctness issues
- duplication materially increases implementation risk

The goal is shipping the MVP.

---

# 8. Technology Direction

Use:

```text
Flutter
flutter_scene
Pure Dart domain logic
Data-driven content
Local persistence
RevenueCat abstraction
```

Do not introduce Flame unless the project intentionally changes from 3D to 2D.

Do not add another state-management library if one already exists and works.

---

# 9. Layer Rules

## Presentation

Owns:

```text
Flutter widgets
HUD
menus
panels
visual feedback
responsive layout
```

Must not own:

```text
fitness calculations
quest rules
save implementation details
```

## Game Runtime

Owns:

```text
movement
camera
collision
scene
animation
interaction target
frame state
```

Must not own:

```text
XP rules
exercise science
quest reward logic
```

## Domain

Owns:

```text
training rules
condition changes
quest evaluation
Codex progression
XP
validation
```

Must remain independent from Flutter rendering.

## Infrastructure

Owns:

```text
persistence
RevenueCat
platform services
analytics
audio adapters
```

---

# 10. Domain Purity

Do not import Flutter UI or renderer packages into the domain layer.

Avoid:

```text
flutter/material.dart
BuildContext
Widget
SceneView
RevenueCat SDK
database concrete classes
```

inside domain code.

---

# 11. State Rule

Do not push frame-by-frame movement state through Riverpod/Provider/BLoC or other application state systems.

Runtime owns:

```text
position
rotation
velocity
animation
camera
nearby interactables
```

Application/domain owns:

```text
XP
level
hydration
fatigue
quests
Codex
settings
entitlements
```

---

# 12. Data-Driven Rule

Do not hardcode every exercise and quest into Dart.

Use structured content.

Examples:

```text
assets/data/exercises/chest.json
assets/data/quests/build_first_chest_day.json
assets/data/districts/hypertrophy_gym.json
assets/data/npcs/hypertrophy_coach.json
assets/data/knowledge/chest_programming_1.json
```

---

# 13. Stable IDs

Use stable snake_case IDs.

Examples:

```text
incline_dumbbell_press
machine_chest_press
cable_fly
build_first_chest_day
hypertrophy_gym
hypertrophy_coach
chest_programming_1
```

Do not derive persistence IDs from display names.

---

# 14. Build Order

Implement in this order unless existing code already completes a phase.

---

# Phase 1 — Bootstrap

Goal:

> project builds and runs cleanly

Tasks:

- verify Flutter SDK compatibility
- verify dependencies
- establish routing
- establish folders
- create app bootstrap
- add theme foundation
- add structured error logging
- run analyzer
- run tests

Done when:

- app boots
- no fatal dependency conflict
- analyzer has no critical errors

---

# Phase 2 — Static Content

Goal:

> game content exists independently from code

Implement:

- Exercise model
- QuestDefinition
- DistrictDefinition
- NPCDefinition
- KnowledgeUnlock
- JSON loading
- content repositories
- content validation

Add required content:

```text
Incline Dumbbell Press
Machine Chest Press
Cable Fly
Build Your First Chest Day
Hypertrophy Gym
Hypertrophy Coach
Chest Programming I
```

Done when:

- content loads
- invalid content is reported safely
- unit tests pass

---

# Phase 3 — Domain Core

Goal:

> core gameplay rules work without 3D

Implement:

- PlayerProfile
- PlayerCondition
- XP
- level thresholds
- exercise discovery
- Codex unlock
- workout selection
- workout validation
- TrainingResult
- fatigue calculation
- hydration changes
- recovery
- quest progression
- domain events

Done when:

- domain unit tests prove full chest-day state progression

---

# Phase 4 — Persistence

Goal:

> meaningful progress survives restart

Implement:

- SaveGame
- schemaVersion
- SaveRepository
- local implementation
- new game
- continue
- reset
- save triggers

Done when:

- save/load tests pass
- discoveries persist
- quest persists
- XP persists
- condition persists

---

# Phase 5 — Game Host

Goal:

> Flutter can host the real-time 3D runtime

Implement:

- GameScreen
- SceneView
- game runtime entry
- scene loading state
- error fallback

Done when:

- gym scene renders inside Flutter
- HUD can overlay it

---

# Phase 6 — World Scene

Goal:

> player exists inside the gym

Implement:

- Hypertrophy Gym GLB
- spawn point
- player GLB
- coach GLB
- required stations
- water station
- recovery mat

Use placeholder low-poly assets if final assets do not exist.

Do not block code progress waiting for perfect art.

Done when:

- all required objects are visible

---

# Phase 7 — Input and Movement

Goal:

> player can navigate the gym

Implement:

- normalized InputState
- keyboard adapter
- touch adapter
- player motor
- rotation
- camera follow

Done when:

- WASD works
- mobile joystick works
- same PlayerController receives both

---

# Phase 8 — Collision

Goal:

> world behaves like a space

Implement:

- player collider
- wall blockers
- station blockers
- NPC blocker
- world boundary

Prefer simple collision primitives.

Done when:

- player cannot pass through critical geometry

---

# Phase 9 — Interaction

Goal:

> the environment creates gameplay

Implement:

- Interactable abstraction
- interaction radius
- nearest-target selection
- front-facing preference if useful
- contextual prompt
- inspect
- train
- NPC interaction
- water
- recovery

Done when:

- one clear interaction target appears
- prompt disappears correctly

---

# Phase 10 — Coach and Quest Start

Goal:

> chest-day loop begins naturally

Implement:

- coach dialogue
- start quest use case
- quest HUD
- objective progression

Done when:

- talking to coach activates quest
- HUD shows correct current objective

---

# Phase 11 — Exercise Discovery

Goal:

> exploration produces knowledge

Implement:

- inspect station
- exercise information panel
- first-time discovery
- +5 XP
- Codex unlock
- discovery notification
- quest reaction
- save

Done when:

- all three required stations work
- duplicate discovery does not reward twice

---

# Phase 12 — Codex

Goal:

> discovered knowledge is visible

Implement:

- chest categories
- pressing
- isolation
- locked/unlocked state
- exercise detail
- Chest Programming I area if appropriate

Done when:

- discovery immediately appears in Codex

---

# Phase 13 — Session Builder

Goal:

> player learns exercise roles

Implement:

- show discovered exercises
- select exactly three
- validate
- explain missing press
- explain missing isolation
- prevent duplicates
- emit WorkoutValidated

Done when:

```text
press + press + isolation
```

passes.

---

# Phase 14 — Training Minigame

Goal:

> training becomes an action, not a button

Implement:

- 5-rep timing interaction
- clean rep count
- TrainingGrade
- TrainingResult
- XP calculation
- fatigue change
- hydration change
- result screen
- quest progress
- save

Done when:

- training produces deterministic domain result

---

# Phase 15 — Coach Return

Goal:

> quest pacing has acknowledgment

Implement:

- post-training coach dialogue
- objective gate
- next objective points to Recovery Corner

Done when:

- return objective only completes after training

---

# Phase 16 — Recovery

Goal:

> health-first loop closes

Implement:

Water:

```text
Hydration +15
```

Mat:

```text
Fatigue -15
```

Implement:

- feedback
- quest update
- save

Done when:

- recovery completes final quest objective

---

# Phase 17 — Quest Completion

Goal:

> player receives meaningful progression

Implement:

- +100 XP
- Chest Programming I
- completion state
- reward guard
- completion UI
- save

Done when:

- reward cannot be claimed twice

---

# Phase 18 — Product Screens

Implement only required surfaces:

- Main Menu
- Quest Log
- Codex
- Map Preview
- Competition Preview
- Settings

Keep them lightweight.

---

# Phase 19 — RevenueCat

Implement behind:

```text
MonetizationService
```

Required:

- initialize
- entitlement query
- offering/support screen
- purchase action where supported
- restore where supported
- failure-safe behavior

Core game must work when store initialization fails.

---

# Phase 20 — Accessibility

Implement:

- scalable UI
- reduced motion
- touch controls
- keyboard controls
- visible focus
- color-independent status labels

---

# Phase 21 — Polish

Only after the complete loop works.

Polish:

- animation transitions
- audio
- lighting
- feedback timing
- responsive layout
- scene composition
- loading presentation
- minor performance tuning

Do not polish one menu for hours while core gameplay is broken.

---

# 15. Placeholder Policy

If an asset is missing:

> use a temporary placeholder and continue.

Allowed placeholders:

- primitive mesh
- colored low-poly box
- simple character
- temporary icon
- text label

Do not halt core development for:

- final player model
- perfect coach
- perfect gym machine
- final sound
- logo polish

---

# 16. Asset Replacement Rule

Keep asset references centralized.

Do not spread raw asset paths through many widgets/classes.

Use:

```text
AssetCatalog
DistrictDefinition
ExerciseStation definition
```

so placeholders can be replaced cleanly.

---

# 17. Testing Discipline

After meaningful changes:

1. format code
2. run analyzer
3. run relevant unit tests
4. run widget tests if UI changed
5. launch target platform if runtime changed
6. fix failures before moving forward

Do not accumulate dozens of known errors.

---

# 18. Minimum Unit Test Coverage

Must test:

```text
new game defaults
exercise parsing
content validation
discovery reward once
Codex unlock once
workout validation
training XP
fatigue
hydration
recovery
quest progression
quest reward once
level thresholds
save/load
reset
```

---

# 19. Minimum Widget Tests

Must test:

```text
HUD state
Quest Log
Codex lock/unlock
Session Builder
Settings basics
```

---

# 20. Manual Gameplay Pass

Before declaring MVP complete, manually verify:

```text
launch
new game
walk
collision
coach
discovery
inspect
Codex
session builder
train
result
condition
coach return
water
recovery mat
quest completion
save
close
relaunch
continue
```

---

# 21. Build Health Rule

Never proceed for long with:

- compile errors
- analyzer errors
- broken tests
- failing imports
- missing generated files
- dependency conflict

Fix the foundation first.

---

# 22. No Fake Completion

Do not mark a feature complete because:

- UI exists but action is mocked
- button exists but does nothing
- data is hardcoded in widget
- persistence is in-memory only
- quest only visually updates
- training result does not affect domain state

A feature is complete when its acceptance criteria are satisfied end-to-end.

---

# 23. No Silent Stubs

If a feature is intentionally deferred:

use an explicit TODO or "Coming Soon" state.

Do not create fake implementations that look production-ready but do nothing.

---

# 24. TODO Rules

TODOs are allowed only for:

- explicitly out-of-scope feature
- optional polish
- known future integration
- placeholder asset replacement

Do not leave TODO for:

- save correctness
- quest reward
- collision
- interaction
- training state

Those are MVP-critical.

---

# 25. Error Handling

Core game must survive:

- missing optional asset
- RevenueCat unavailable
- no existing save
- invalid optional content
- store failure
- audio failure

Core gameplay should fail only when a required game asset/content dependency is impossible to recover from.

---

# 26. Logging

Log meaningful lifecycle events:

```text
app bootstrap
scene load
content validation
save load/write
exercise discovery
training result
quest objective completion
quest completion
RevenueCat init
critical errors
```

Do not log every frame.

---

# 27. Performance Rules

Do not:

- rebuild the whole UI every frame
- parse JSON repeatedly
- serialize save every frame
- create unnecessary objects in hot loops
- use highly detailed collision meshes for everything

Do:

- cache static content
- keep runtime state local
- use simple colliders
- keep scenes compact
- keep materials limited

---

# 28. Responsive Rule

Every required Flutter screen must be checked in:

```text
compact
expanded
```

at minimum.

Do not finish desktop and assume mobile will work automatically.

---

# 29. Git / Commit Discipline

If version control is available, prefer small coherent commits.

Examples:

```text
feat(domain): add exercise discovery
feat(game): add player movement
feat(quest): implement chest day objectives
fix(save): persist codex unlocks
```

Do not put the entire MVP into one giant commit if avoidable.

---

# 30. Documentation Discipline

Do not create new planning documents unless necessary.

The six project docs are enough.

Update existing source-of-truth docs only if implementation reveals a real inconsistency.

Do not spend development time generating:

- architecture essays
- new roadmaps
- duplicate PRDs
- extra design-system docs

---

# 31. Progress Tracking

Maintain one compact progress section in the README or build log.

Recommended:

```text
## MVP Progress

[x] Bootstrap
[x] Content
[x] Domain
[x] Save
[x] Scene
[x] Movement
[ ] Interaction
[ ] Quest
[ ] Training
[ ] Recovery
[ ] Polish
```

Keep it factual.

---

# 32. Decision Rule

When an implementation decision is not specified:

1. preserve MVP scope
2. preserve architecture boundaries
3. choose simplest working solution
4. keep future replacement possible
5. avoid new dependencies
6. document only meaningful deviations

---

# 33. Dependency Rule

Before adding a package:

Ask:

```text
Can Flutter/Dart/current dependencies already do this?
```

Add a dependency only if it materially reduces risk or implementation effort.

Avoid package sprawl.

---

# 34. Package Evaluation

For any new package, check:

- actively maintained
- compatible with current Flutter
- target platform support
- license
- dependency health
- web/mobile limitations
- whether project really needs it

---

# 35. Security Rule

Do not hardcode:

- API keys
- private keys
- secrets
- RevenueCat secrets
- backend credentials

Use environment/config mechanisms appropriate for Flutter.

Public client SDK identifiers may be handled according to their platform guidance.

---

# 36. Health Content Rule

Do not invent medical guidance.

Use only the educational content defined in project files for MVP.

Do not add:

- medical diagnosis
- injury treatment
- extreme diet advice
- supplement claims
- dehydration mechanics presented as healthy strategy

---

# 37. Fitness Education Tone

The game should explain, not shame.

Use:

```text
Your session is heavily press-focused.
Try including an isolation movement.
```

Avoid:

```text
Bad workout.
Wrong answer.
You failed.
```

---

# 38. UI Rule

The world remains primary.

Avoid solving every UX problem with another modal.

Prefer:

```text
world interaction
→ contextual feedback
→ compact panel only when needed
```

---

# 39. Demo Priority

The following path must be polished first:

```text
Spawn
→ Coach
→ Discover
→ Build Session
→ Train
→ Fatigue
→ Recover
→ Quest Complete
```

Map preview, competition preview, and monetization come after this path works.

---

# 40. No Premature Backend

Do not introduce:

- Supabase
- Firebase
- Appwrite
- custom API
- VPS service

for the MVP unless a requirement absolutely demands it.

Local-first is the intended MVP architecture.

---

# 41. No Premature Authentication

The MVP can use:

```text
local_player
```

No sign-up flow is required.

---

# 42. No Premature Multiplayer

Competition preview is presentation only.

Do not build networking.

---

# 43. No Premature ECS

Do not introduce a complex entity-component-system framework unless the current simple entity architecture demonstrably fails.

The MVP is too small to justify architectural ceremony.

---

# 44. No Premature Optimization

Do not spend hours optimizing hypothetical future problems.

Optimize only when:

- profiler shows issue
- interaction feels bad
- scene is unstable
- memory leaks
- target platform struggles

---

# 45. Quality Bar

The MVP should feel:

- intentional
- coherent
- playable
- understandable
- responsive
- visually consistent

It does not need:

- huge content
- advanced simulation
- perfect art
- production multiplayer scale

---

# 46. Final Acceptance Gate

Do not call the MVP complete until all are true.

## Gameplay

- [ ] Player can move
- [ ] Collision works
- [ ] Coach works
- [ ] All 3 stations work
- [ ] Discovery works
- [ ] Session Builder works
- [ ] Training works
- [ ] Condition changes
- [ ] Recovery works
- [ ] Quest completes

## Progression

- [ ] XP works
- [ ] Codex works
- [ ] Chest Programming I works
- [ ] rewards cannot duplicate

## Persistence

- [ ] save works
- [ ] continue works
- [ ] reset works
- [ ] restart preserves progress

## UI

- [ ] HUD usable
- [ ] mobile usable
- [ ] desktop/web usable
- [ ] interaction feedback clear
- [ ] quest feedback clear

## Product

- [ ] map preview
- [ ] competition preview
- [ ] settings
- [ ] RevenueCat failure-safe integration

## Quality

- [ ] analyzer clean enough to ship demo
- [ ] critical tests pass
- [ ] no crash on normal demo path
- [ ] no critical save-loss issue
- [ ] no soft-lock on quest path

---

# 47. Demo Verification

Run this exact sequence:

```text
1. Delete/reset save.
2. Launch.
3. Start New Game.
4. Spawn in gym.
5. Walk to coach.
6. Start quest.
7. Inspect Incline Dumbbell Press.
8. Inspect Machine Chest Press.
9. Inspect Cable Fly.
10. Open Session Builder.
11. Select all three.
12. Validate.
13. Train Incline Dumbbell Press.
14. Finish 5-rep minigame.
15. Confirm fatigue/hydration changed.
16. Return to coach.
17. Drink water.
18. Use Recovery Mat.
19. Confirm quest completion.
20. Open Codex.
21. Confirm three exercises and knowledge unlock.
22. Close app.
23. Reopen.
24. Continue.
25. Confirm state persists.
```

If any required step fails, the vertical slice is not done.

---

# 48. What to Do After MVP

Only after the vertical slice is stable:

1. fix highest-impact UX issues
2. improve art
3. improve animation
4. add Strength Yard
5. expand exercises
6. add broader progression
7. add backend competition
8. add real-world workout bridge

Do not skip directly to step 4 while the MVP is fragile.

---

# 49. AI Behavior Rule

When uncertain:

> **Choose the smallest implementation that satisfies the written acceptance criteria and preserves future extensibility.**

Do not invent major product behavior.

Do not redesign the product.

Do not broaden the roadmap.

---

# 50. Final Execution Contract

The agent's job is not to "make a fitness RPG."

The job is:

> **Build the exact IRON ASCENT chest-day vertical slice described by the six project documents, verify it end-to-end, and stop when the MVP acceptance gate passes.**

The success metric is not lines of code.

It is:

> **A player can learn fitness by physically playing through one complete training-and-recovery loop.**
