# IRON ASCENT — Coding Agent Master Instruction

You are the primary coding agent responsible for implementing **IRON ASCENT**, a cross-platform low-poly fitness RPG built with Flutter.

Your job is not to redesign the product, brainstorm features, rewrite the plan, or create more documentation.

Your job is to **build the MVP described by the project documentation, verify it end-to-end, and stop when the MVP acceptance criteria pass.**

# 1. READ FIRST — MANDATORY

Before modifying any code, read all six project documents completely:

1. `docs/01_IRON_ASCENT_Complete_Game_Plan.md`
2. `docs/02_IRON_ASCENT_Flutter_Technical_Architecture.md`
3. `docs/03_IRON_ASCENT_MVP_Spec.md`
4. `docs/04_IRON_ASCENT_Game_Systems_and_Data.md`
5. `docs/05_IRON_ASCENT_UI_UX_and_Art_Direction.md`
6. `docs/06_IRON_ASCENT_AI_Build_Runbook.md`

Do not begin implementation after reading only one or two documents.

Treat these files as the project source of truth.

# 2. CONFLICT PRIORITY

If instructions conflict, obey this priority:

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
06 AI Build Runbook
```

The MVP Spec controls scope.

The Technical Architecture controls software structure.

Game Systems & Data controls gameplay rules, values, IDs, state, events, and persistence.

UI/UX & Art Direction controls visual behavior.

The Complete Game Plan controls long-term product intent.

The Runbook controls execution order.

# 3. PRIMARY OBJECTIVE

Build one complete playable vertical slice:

> **Build Your First Chest Day**

The player must eventually be able to:

```text
Launch IRON ASCENT
      ↓
Start / Continue Game
      ↓
Spawn inside Hypertrophy Gym
      ↓
Move through the 3D environment
      ↓
Collide with world geometry
      ↓
Talk to Hypertrophy Coach
      ↓
Start "Build Your First Chest Day"
      ↓
Inspect Incline Dumbbell Press
      ↓
Inspect Machine Chest Press
      ↓
Inspect Cable Fly
      ↓
Discover exercises
      ↓
Update Iron Codex
      ↓
Build a 3-exercise chest session
      ↓
Validate press + press + isolation structure
      ↓
Perform one 5-rep training interaction
      ↓
Generate TrainingResult
      ↓
Increase Fatigue
      ↓
Decrease Hydration
      ↓
Gain XP
      ↓
Return to Coach
      ↓
Drink Water
      ↓
Use Recovery Mat
      ↓
Complete Quest
      ↓
Unlock Chest Programming I
      ↓
Save Progress
      ↓
Close App
      ↓
Reopen
      ↓
Continue with progression preserved
```

This complete loop is the product milestone.

# 4. DO NOT EXPAND THE SCOPE

Do not build any of the following unless explicitly required by the six documents for the current MVP:

- open world
- additional playable districts
- Strength Yard
- Cardio Run
- Mobility Temple
- Macro Market
- full Home Base
- multiplayer
- matchmaking
- real-time leaderboard
- guilds
- friend system
- chat
- combat
- crafting
- inventory system
- procedural generation
- wearable integration
- Apple Health
- Health Connect
- full nutrition tracking
- calorie tracking
- detailed injury simulation
- advanced avatar creator
- cosmetics store
- dynamic weather
- day/night cycle
- cloud backend
- authentication
- Supabase
- Firebase
- Appwrite
- VPS services
- body deformation
- realistic biomechanics
- advanced AI NPCs

If something is not necessary for the chest-day vertical slice, defer it.

# 5. ARCHITECTURE RULE

Maintain this separation:

```text
PRESENTATION
Flutter UI / HUD / menus
        │
        ▼
APPLICATION
Use cases / orchestration
        │
        ▼
DOMAIN
Fitness rules / quests / progression
        ▲
        │
GAME RUNTIME
3D world / player / input / collision
```

Underneath:

```text
DATA + INFRASTRUCTURE
```

Responsibilities:

## Flutter Presentation

Owns:

- screens
- HUD
- menus
- Codex UI
- Quest UI
- Session Builder
- settings
- visual feedback

Must not own:

- fitness calculations
- XP rules
- quest rules
- persistence implementation
- frame-by-frame world simulation

## Game Runtime

Owns:

- player transform
- player movement
- velocity
- rotation
- camera
- collision
- animation
- nearby interactables
- active interaction target
- scene state

Must not own:

- fatigue formulas
- XP calculations
- quest reward logic
- Codex progression rules

## Domain

Owns:

- exercise models
- player condition
- workout validation
- training result
- XP
- fatigue
- hydration
- quest evaluation
- Codex progression
- knowledge unlocks

Domain code should remain pure Dart wherever practical.

Do not import UI or renderer packages into the domain layer.

## Infrastructure

Owns:

- save implementation
- local database/storage
- RevenueCat
- platform services
- audio adapters

# 6. 3D TECHNOLOGY DIRECTION

Use:

```text
Flutter
+
flutter_scene
```

for the preferred 3D implementation.

Do not introduce Flame alongside flutter_scene unless there is an explicit architectural decision to replace the 3D direction with a 2D implementation.

Do not build multiple game runtimes.

# 7. STATE MANAGEMENT RULE

Do not send frame-by-frame game state through Riverpod, Provider, BLoC, or equivalent.

Runtime state:

```text
position
rotation
velocity
animation
camera
collision
interaction targeting
```

must remain inside the game runtime.

Application/domain state:

```text
level
XP
hydration
fatigue
quest progression
Codex progression
exercise discoveries
knowledge unlocks
settings
entitlements
```

may use normal Flutter application state management.

# 8. DATA-DRIVEN CONTENT

Do not hardcode every exercise, quest, NPC, or district into Dart source files.

Use structured data based on the project specification.

Expected structure:

```text
assets/
└── data/
    ├── exercises/
    │   └── chest.json
    ├── quests/
    │   └── build_first_chest_day.json
    ├── districts/
    │   └── hypertrophy_gym.json
    ├── npcs/
    │   └── hypertrophy_coach.json
    └── knowledge/
        └── chest_programming_1.json
```

Use the IDs and values defined in `04_IRON_ASCENT_Game_Systems_and_Data.md`.

Do not invent new canonical IDs unless absolutely necessary.

# 9. REQUIRED MVP EXERCISES

Implement these first:

```text
incline_dumbbell_press
machine_chest_press
cable_fly
```

Their content, fatigue cost, hydration cost, XP, technique difficulty, muscles, movement roles, and educational descriptions must come from the systems/data specification.

# 10. REQUIRED QUEST

Implement:

```text
build_first_chest_day
```

Objectives:

```text
1. Talk to the Hypertrophy Coach
2. Discover 3 chest exercises
3. Inspect at least 1 pressing movement
4. Inspect at least 1 isolation movement
5. Build a 3-exercise chest session
6. Complete 1 working set
7. Return to Coach
8. Recover using Recovery Mat
```

Reward:

```text
+100 XP
Chest Programming I
```

Quest rewards must only be granted once.

# 11. BUILD ORDER

Follow this execution order.

Do not jump randomly between systems.

## PHASE 1 — BOOTSTRAP

Set up:

- Flutter project
- application bootstrap
- routing
- base theme
- required dependencies
- documented project folders
- basic logging

Then run:

```bash
flutter pub get
flutter analyze
flutter test
```

Fix critical failures before continuing.

## PHASE 2 — STATIC CONTENT

Implement:

- Exercise
- QuestDefinition
- DistrictDefinition
- NPCDefinition
- KnowledgeUnlock
- structured data loading
- repositories
- content validation

Load:

```text
Incline Dumbbell Press
Machine Chest Press
Cable Fly
Build Your First Chest Day
Hypertrophy Gym
Hypertrophy Coach
Chest Programming I
```

Write tests.

## PHASE 3 — DOMAIN CORE

Implement and test:

- PlayerProfile
- PlayerCondition
- XP
- Level
- Exercise discovery
- Codex unlock
- WorkoutSelection
- WorkoutValidationResult
- TrainingResult
- fatigue calculation
- hydration calculation
- recovery
- QuestProgress
- domain events
- reward guards

The chest-day gameplay rules should work in unit tests before the 3D environment depends on them.

## PHASE 4 — PERSISTENCE

Implement:

- SaveGame
- schemaVersion
- SaveRepository
- local save implementation
- New Game
- Continue
- Reset

Verify:

```text
XP persists
condition persists
quests persist
discoveries persist
Codex persists
knowledge persists
```

## PHASE 5 — GAME HOST

Implement:

```text
GameScreen
SceneView
GameRuntime
scene loading
Flutter HUD overlay
```

The 3D scene must render inside the Flutter application.

## PHASE 6 — PLACEHOLDER GYM

Do not wait for perfect Blender assets.

Use placeholders if needed.

Required scene objects:

```text
player
coach
incline press station
machine press station
cable fly station
water station
recovery mat
walls
floor
```

At this stage, primitive meshes are acceptable.

## PHASE 7 — MOVEMENT

Implement:

- keyboard input
- WASD
- arrow keys if appropriate
- touch joystick
- normalized InputState
- player movement
- rotation
- camera follow

Both keyboard and touch must feed the same PlayerController abstraction.

## PHASE 8 — COLLISION

Implement simple collision using primitive shapes.

Player must not pass through:

- walls
- required gym machines
- coach
- world boundaries

Do not overengineer mesh collision.

## PHASE 9 — INTERACTION

Implement reusable:

```text
Interactable
InteractionSystem
InteractionDetector
```

Behavior:

```text
Player approaches object
↓
nearest valid interactable selected
↓
one contextual prompt appears
↓
player presses Interact
↓
object action executes
```

Only one main interaction prompt should be visible.

## PHASE 10 — COACH

Implement Hypertrophy Coach.

First interaction:

```text
Don't collect exercises.
Build a session.
```

Then activate:

```text
Build Your First Chest Day
```

## PHASE 11 — EXERCISE DISCOVERY

For all three required machines:

```text
approach
↓
inspect
↓
exercise data opens
↓
first-time discovery
↓
+5 XP
↓
Codex unlock
↓
quest progression
↓
save
```

Discovery rewards must not repeat.

## PHASE 12 — CODEX

Implement Chest Codex.

Structure:

```text
CHEST

Pressing
├── Incline Dumbbell Press
└── Machine Chest Press

Isolation
└── Cable Fly
```

Undiscovered content should appear locked or hidden.

## PHASE 13 — SESSION BUILDER

Implement selection of exactly three discovered exercises.

Validation rules:

```text
exactly 3
at least 1 press
at least 1 isolation
no duplicate exercise IDs
only discovered exercises
```

Canonical valid session:

```text
Incline Dumbbell Press
Machine Chest Press
Cable Fly
```

Invalid selections should receive educational feedback, not generic failure messages.

## PHASE 14 — TRAINING MINIGAME

Implement one simple 5-rep timing interaction.

Required output:

```text
total reps
clean reps
TrainingGrade
fatigue added
hydration lost
XP granted
```

Training grades:

```text
excellent
good
rough
failed
```

Use formulas from the systems/data document.

The training result must mutate real domain state.

## PHASE 15 — COACH RETURN

After training:

```text
return to coach
↓
coach acknowledges training
↓
quest advances
↓
player directed to Recovery Corner
```

The return objective must not complete before training.

## PHASE 16 — RECOVERY

Implement:

```text
Water Station
Hydration +15
```

and:

```text
Recovery Mat
Fatigue -15
```

Clamp values to domain limits.

Recovery must progress the quest.

## PHASE 17 — QUEST COMPLETION

When all objectives are satisfied:

```text
QUEST COMPLETE

BUILD YOUR FIRST CHEST DAY

Chest Programming I unlocked
+100 XP
```

Persist immediately.

Reward cannot be duplicated.

## PHASE 18 — PRODUCT SCREENS

Implement only:

- Main Menu
- Gameplay
- Quest Log
- Codex
- Session Builder
- Map Preview
- Competition Preview
- Settings
- Support/Premium screen

Do not add unnecessary tabs.

## PHASE 19 — REVENUECAT

Implement through:

```text
MonetizationService
```

Required:

- initialization
- entitlement query
- purchase entry point where supported
- restore entry point where supported
- failure handling

Core gameplay must continue if RevenueCat fails.

## PHASE 20 — ACCESSIBILITY

Implement:

- keyboard controls
- touch controls
- scalable UI
- visible text labels
- reduced motion
- non-color-only status indicators

## PHASE 21 — POLISH

Only after the entire gameplay loop works:

- animations
- sounds
- lighting
- improved low-poly assets
- visual feedback
- responsive refinements
- performance tuning

Do not polish unfinished systems.

# 12. PLACEHOLDER POLICY

If a final asset does not exist:

> use a placeholder and continue development.

Allowed:

- boxes
- cylinders
- basic low-poly geometry
- simple placeholder player
- temporary icons
- temporary labels

Do not block the project waiting for:

- polished Blender models
- final logo
- perfect gym layout
- sound design
- animation polish

Function first.

# 13. TESTING REQUIREMENT

After every meaningful implementation group:

```bash
dart format .
flutter analyze
flutter test
```

When runtime code changes, also launch the relevant target platform.

Do not knowingly accumulate broken tests or compile failures across multiple phases.

# 14. REQUIRED UNIT TESTS

At minimum test:

```text
new game defaults
exercise JSON parsing
content validation
condition clamping
discovery reward once
Codex unlock once
workout validation
TrainingResult
XP calculation
fatigue formula
hydration change
Water Station
Recovery Mat
quest progression
quest reward once
knowledge unlock
save serialization
save deserialization
level thresholds
reset behavior
```

# 15. REQUIRED WORKOUT VALIDATION TESTS

These must pass:

```text
press + press + isolation → valid
press + press + press → invalid
isolation + isolation + isolation → invalid
2 exercises → invalid
4 exercises → invalid
duplicates → invalid
undiscovered exercise → invalid
```

# 16. MANUAL GAMEPLAY CHECK

Before declaring the MVP complete, execute:

```text
1. Reset save
2. Launch game
3. New Game
4. Spawn in Hypertrophy Gym
5. Walk around
6. Verify collision
7. Talk to Coach
8. Start quest
9. Inspect Incline Dumbbell Press
10. Inspect Machine Chest Press
11. Inspect Cable Fly
12. Verify three Codex unlocks
13. Open Session Builder
14. Select three exercises
15. Validate session
16. Train
17. Complete 5 reps
18. Verify TrainingResult
19. Verify Fatigue changed
20. Verify Hydration changed
21. Verify XP changed
22. Return to Coach
23. Drink Water
24. Use Recovery Mat
25. Verify quest completes
26. Verify Chest Programming I
27. Close app
28. Reopen app
29. Continue
30. Verify progression remains
```

If any mandatory step fails, the MVP is not complete.

# 17. NO FAKE COMPLETION

A feature is not complete because:

- a screen exists
- a button exists
- a mock notification exists
- state changes only visually
- data is hardcoded into a widget
- persistence only survives while app remains open
- a TODO says "implement later"

The feature is complete only when its acceptance criteria work end-to-end.

# 18. ERROR HANDLING

The core game must remain usable when possible.

Examples:

RevenueCat unavailable:

```text
Store unavailable.
Core gameplay remains available.
```

Missing optional asset:

```text
Use fallback.
Continue.
```

Save failure:

```text
Keep in-memory state.
Display non-blocking error.
Retry on next meaningful save.
```

Missing save:

```text
Treat as no existing game.
```

Do not crash for recoverable failures.

# 19. DEPENDENCY RULE

Before adding any package, ask:

> Can Flutter, Dart, or an existing dependency already handle this?

Only add packages that materially reduce risk or implementation effort.

Avoid unnecessary dependency sprawl.

# 20. GIT DISCIPLINE

If Git is available, prefer focused commits.

Examples:

```text
feat(domain): add exercise discovery
feat(game): add player movement
feat(quest): implement chest day objectives
feat(training): add timing minigame
fix(save): persist codex state
```

Do not rewrite unrelated files in the same change without reason.

# 21. PROGRESS TRACKING

Maintain one small project progress section, preferably in README.

Example:

```text
## MVP Progress

[x] Bootstrap
[x] Static Content
[x] Domain
[x] Persistence
[x] Scene
[x] Movement
[ ] Collision
[ ] Interaction
[ ] Quest
[ ] Training
[ ] Recovery
[ ] RevenueCat
[ ] Polish
```

Do not create additional planning documents.

# 22. REPORTING FORMAT

After each meaningful milestone, report only:

```text
Completed:
- ...

Verified:
- flutter analyze
- flutter test
- platform launch

Remaining:
- ...

Blockers:
- none / exact blocker
```

Do not repeatedly explain the entire architecture.

# 23. FIRST HARD CHECKPOINT

Your first visual milestone is:

```text
IRON ASCENT launches
        ↓
Hypertrophy Gym renders
        ↓
Player appears
        ↓
Player moves with WASD
        ↓
Camera follows
        ↓
Player cannot walk through walls/machines
```

Do not work on Codex styling, map polish, animation polish, or future districts before this works.

# 24. SECOND HARD CHECKPOINT

After movement works:

```text
Walk to Incline Dumbbell Press
        ↓
Interaction prompt appears
        ↓
Inspect
        ↓
Exercise data shown
        ↓
Exercise discovered
        ↓
Codex updated
        ↓
Quest reacts
        ↓
State saved
```

This proves the architecture from world interaction to persistence.

# 25. THIRD HARD CHECKPOINT

Then complete:

```text
Coach
→ 3 Exercise Discoveries
→ Session Builder
→ Training
→ Fatigue/Hydration
→ Coach Return
→ Recovery
→ Quest Complete
→ Save
→ Restart
→ Continue
```

That is the MVP.

# 26. DECISION RULE

When the documents do not specify a minor implementation detail:

1. choose the smallest working implementation
2. preserve architecture boundaries
3. preserve cross-platform compatibility
4. avoid new dependencies
5. keep replacement possible later
6. do not expand scope

Do not ask for approval for trivial implementation decisions.

Proceed with the most reasonable solution.

# 27. STOP CONDITION

Once the complete chest-day loop works and all MVP acceptance criteria pass:

> **STOP ADDING FEATURES.**

Then:

- fix bugs
- improve UX
- replace placeholders
- optimize obvious issues
- prepare demo

Do not begin Strength Yard, Cardio Run, multiplayer, or other roadmap features automatically.

# 28. FINAL DIRECTIVE

You are not being asked to prototype random parts of IRON ASCENT.

You are being asked to build one coherent playable product slice.

The required result is:

> **A player can enter a low-poly 3D gym, physically explore it, learn three chest exercises through environmental interaction, build a valid chest workout, perform a training set, experience fatigue and hydration consequences, recover afterward, unlock fitness knowledge, and retain that progress after restarting the app.**

Build that.

Verify that.

Do not broaden the scope until it works.
