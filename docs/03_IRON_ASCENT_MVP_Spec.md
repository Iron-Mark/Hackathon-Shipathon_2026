# IRON ASCENT — MVP Specification

> **Document role:** Authoritative implementation contract for the first playable vertical slice.
>
> **MVP:** Build Your First Chest Day
>
> **Primary purpose:** Prove that IRON ASCENT works as an explorable fitness RPG where the player learns by interacting with the environment, training, accumulating fatigue, recovering, and unlocking knowledge.
>
> **Scope rule:** If a feature does not directly support the playable chest-day loop, it does not belong in the MVP.

---

# 1. Document Authority

This file defines **what must be built now**.

When the project documents disagree, use this priority:

1. `03_IRON_ASCENT_MVP_Spec.md`
2. `02_IRON_ASCENT_Flutter_Technical_Architecture.md`
3. `04_IRON_ASCENT_Game_Systems_and_Data.md`
4. `05_IRON_ASCENT_UI_UX_and_Art_Direction.md`
5. `01_IRON_ASCENT_Complete_Game_Plan.md`
6. `06_IRON_ASCENT_AI_Build_Runbook.md` for execution process

The Complete Game Plan describes the long-term product.

This document intentionally reduces that vision into one complete, testable vertical slice.

---

# 2. MVP Goal

The MVP must prove six things:

1. The player can control a character inside a low-poly 3D gym.
2. Gym objects can be approached and physically interacted with.
3. Interactions teach real fitness concepts.
4. Training changes the player's condition.
5. Quest and Codex progression react to gameplay.
6. Recovery matters after training.

The core test is:

> Can a new player walk into the gym, discover chest exercises, understand their roles, build a simple chest session, perform a training interaction, become fatigued, recover, and unlock fitness knowledge?

If yes, the MVP works.

If the build only contains menus, static exercise cards, or a workout tracker, the MVP has failed.

---

# 3. MVP Player Fantasy

The player begins as a novice athlete inside the Hypertrophy District.

A coach gives one instruction:

> **Don't collect exercises. Build a session.**

The player must explore the gym and learn that a useful chest session is built from movement roles rather than simply selecting every available chest exercise.

The player should finish the demo understanding:

- pressing and isolation are different exercise roles
- more exercises are not automatically better
- training creates fatigue
- recovery matters
- exercise knowledge can be discovered through exploration
- the game rewards understanding, not blind grinding

---

# 4. Definition of Done

The MVP is complete only when this entire flow works without developer intervention:

```text
Launch Game
   ↓
Enter Hypertrophy Gym
   ↓
Control Character
   ↓
Talk to Coach
   ↓
Receive Chest-Day Quest
   ↓
Explore Equipment
   ↓
Discover Exercises
   ↓
Inspect Exercise Information
   ↓
Select Session Movements
   ↓
Perform One Training Set
   ↓
Fatigue / Hydration Change
   ↓
Quest Evaluates Session
   ↓
Complete Quest
   ↓
Unlock Codex Knowledge
   ↓
Visit Recovery Corner
   ↓
Recover
   ↓
Save Progress
   ↓
Restart Game
   ↓
Progress Still Exists
```

---

# 5. Explicit MVP Scope

## Included

The MVP includes:

- Flutter application shell
- one playable low-poly 3D gym
- one compact recovery corner
- one controllable player character
- elevated isometric / third-person camera
- movement
- collision
- object proximity detection
- contextual interaction prompts
- one coach NPC
- three required training stations
- optional additional discoverable chest objects if already available
- exercise inspection
- exercise discovery
- one chest-programming quest
- one simplified training minigame
- hydration
- fatigue
- recovery
- XP
- basic progression
- Iron Codex
- local save/load
- minimal map / district preview
- minimal competition-board preview
- RevenueCat entitlement integration
- keyboard controls
- touch controls
- basic responsive HUD
- basic accessibility settings
- sound hooks / minimal audio if assets are available

---

# 6. Explicitly Out of Scope

Do not build these for the MVP:

- open world
- full Iron Map traversal
- real-time multiplayer
- multiplayer netcode
- matchmaking
- live PvP
- chat
- guilds / clubs
- full friend system
- seasonal backend
- production anti-cheat
- full Strength Yard
- full Cardio Run
- full Mobility Temple
- full Macro Market
- complete Home Base
- full avatar creator
- cosmetic store
- 100+ exercises
- wearable integration
- Apple Health
- Health Connect
- full real-world workout logging
- advanced nutrition simulation
- calorie tracking
- detailed injury simulation
- medical diagnosis
- realistic muscle deformation
- procedural generation
- dynamic weather
- day/night cycle
- combat
- weapons
- enemy AI
- crafting
- survival hunger system
- complex inventory
- fully simulated NPC schedules
- voice acting
- cinematic cutscenes
- photorealism

Do not add any of these because they seem "cool."

They are scope failures during the MVP.

---

# 7. Supported Platforms

IRON ASCENT remains a Flutter-first cross-platform project.

For the MVP:

## Primary targets

- Android
- Web

## Architecture compatibility

The codebase must avoid unnecessary platform-specific assumptions so it can later support:

- iOS
- Windows
- macOS

Platform-specific behavior should be isolated behind adapters or services.

The gameplay rules must remain platform-independent.

---

# 8. Technology Constraints

Follow the technical architecture document.

## Required direction

```text
Flutter
+
flutter_scene
+
Pure Dart domain simulation
+
Data-driven content
+
Local persistence
```

## Do not

- introduce a second game engine without an explicit architecture change
- place fitness rules in widgets
- place quest rules inside renderer code
- run frame-by-frame player movement through application state management
- hardcode every exercise in Dart
- make backend calls part of normal single-player simulation
- tightly couple RevenueCat with UI widgets

---

# 9. MVP World

The playable world consists of one compact gym scene divided visually into two functional areas.

## Area A — Hypertrophy Gym

Purpose:

- exploration
- exercise discovery
- coach interaction
- chest-day quest
- training

Required objects:

- Incline Dumbbell Press station
- Machine Chest Press station
- Cable Fly station
- Coach NPC
- gym signage
- environmental props

Optional if assets already exist:

- Pec Deck
- Push-Up Zone
- dumbbell rack
- mirrors
- lockers
- plate rack

## Area B — Recovery Corner

Purpose:

- demonstrate that recovery is part of progression

Required objects:

- Water Station
- Recovery Mat

Optional:

- bench
- recovery signage
- lighting change
- ambient props

The Recovery Corner may exist inside the same loaded gym scene.

It does not need to be a separate level.

---

# 10. World Size

The MVP world should be small.

Target design:

- player can walk from one end to the other quickly
- every important object should be easy to locate
- no long empty hallways
- no large exterior area
- no unnecessary scene streaming

The player should spend time interacting, not commuting.

---

# 11. Player Character

## Required

The player must have:

- low-poly character model
- idle animation
- walking animation
- basic interaction state
- optional training pose / animation
- simple rotation toward movement direction

## Not required

- full character creator
- facial customization
- detailed body morph system
- clothing inventory
- hair selection
- gender customization system
- advanced IK
- procedural hand placement

A single polished player model is enough.

---

# 12. Player Movement

The player must be able to move freely through the gym.

## Desktop / Web controls

```text
W / Arrow Up       Move forward
S / Arrow Down     Move backward
A / Arrow Left     Move left
D / Arrow Right    Move right
E                  Interact
Escape             Pause / Close
```

## Mobile controls

Required:

- virtual movement joystick
- interact button
- contextual action button if needed

The underlying player controller must receive normalized gameplay input rather than directly checking keyboard or touch state.

---

# 13. Movement Behavior

Required behavior:

- movement relative to the chosen camera orientation
- smooth acceleration is optional
- character rotates toward movement
- player cannot walk through walls or major gym machines
- player remains constrained to the playable gym area
- player cannot fall through the floor
- interaction remains stable while near an object

The player does not need:

- jumping
- sprinting
- crouching
- climbing
- swimming

---

# 14. Camera

Use an elevated third-person / isometric-style camera.

Goals:

- keep the player readable
- show nearby equipment
- maintain the diorama feel
- avoid motion sickness
- work on mobile screens

The MVP camera should be mostly fixed in angle.

It may:

- smoothly follow the player
- apply slight positional damping

It does not need:

- fully free orbit
- cinematic camera controls
- first-person mode
- shoulder switching
- zoom system

---

# 15. Collision

Required collision categories:

```text
Player
World Boundary
Static Environment
Exercise Station
NPC
```

The player must not walk through:

- walls
- major machines
- coach NPC
- boundary blockers

Collision can remain simple.

Use boxes / capsules / simplified primitives.

Do not create complex mesh collision for every prop unless required.

---

# 16. Interaction System

The interaction system is one of the core MVP systems.

## Interaction flow

```text
Player enters interaction range
      ↓
Nearest valid interactable selected
      ↓
Interaction prompt appears
      ↓
Player activates Interact
      ↓
Object action executes
```

## Prompt example

```text
INCLINE DUMBBELL PRESS

[E] Inspect
[Hold E] Train
```

Mobile equivalent:

```text
INCLINE DUMBBELL PRESS

[Inspect]
[Train]
```

For the MVP, "Hold E" is optional.

A simple interaction menu is acceptable.

---

# 17. Interaction Priority

If several objects are nearby:

1. choose the closest valid interactable
2. prefer objects roughly in front of the player if distances are similar
3. show only one main interaction prompt
4. update target when the player moves away

The player should never see three overlapping interaction prompts.

---

# 18. Required Interactable Types

The MVP requires these reusable interaction types:

```text
ExerciseStation
NPC
WaterStation
RecoveryStation
Information / Preview Object
```

Each interaction type should be reusable.

Do not build each station as completely unique gameplay code.

---

# 19. Coach NPC

One coach NPC is required.

Working role:

> **Hypertrophy Coach**

The coach begins the MVP quest.

## First interaction

The coach should communicate:

> Don't collect exercises. Build a session.

Then introduce the quest:

> **Build Your First Chest Day**

The NPC does not need:

- pathfinding
- daily schedule
- combat
- voice
- procedural dialogue
- advanced animation tree

The coach may remain stationary.

---

# 20. Quest — Build Your First Chest Day

## Quest ID

```text
build_first_chest_day
```

## Quest title

```text
Build Your First Chest Day
```

## Quest purpose

Teach the player how to select complementary chest exercises instead of simply picking every chest movement.

---

# 21. Quest Objectives

Recommended objective structure:

```text
1. Talk to the Hypertrophy Coach.
2. Discover at least 3 chest exercises.
3. Inspect at least 1 pressing movement.
4. Inspect at least 1 isolation movement.
5. Build a 3-exercise chest session.
6. Complete 1 working set.
7. Return to the Coach.
8. Recover at the Recovery Corner.
```

The quest should progress automatically when possible.

Do not require the player to manually tick objectives.

---

# 22. Required Exercises

Three exercises are required for the MVP.

## 1. Incline Dumbbell Press

Role:

- pressing movement
- chest emphasis
- upper-chest emphasis
- triceps / anterior deltoids secondary

## 2. Machine Chest Press

Role:

- pressing movement
- stable setup
- similar role to other pressing movements

## 3. Cable Fly

Role:

- isolation movement
- demonstrates a different role from pressing

These three are enough to teach:

> Pressing + pressing + isolation

and to explain exercise overlap.

---

# 23. Optional Exercises

If assets and implementation time permit:

- Pec Deck
- Push-Up

They may appear as discoverable objects but are not required for the MVP to be complete.

The quest must not depend on optional exercises.

---

# 24. Exercise Inspection

When the player inspects a station, show a compact information panel.

Example:

```text
INCLINE DUMBBELL PRESS

Category:
Chest / Hypertrophy

Movement:
Press

Primary:
Chest

Emphasis:
Upper Chest

Secondary:
Triceps
Anterior Deltoids

ROLE
A pressing movement used to train the chest with greater emphasis on the upper chest.

TECHNIQUE
Use a controlled lowering phase.
Keep the bench at a moderate incline.
Avoid turning the movement into mostly shoulder work.
```

The MVP does not need encyclopedic text.

Information should be:

- concise
- readable
- educational
- actionable

---

# 25. Exercise Discovery

An exercise becomes discovered when the player inspects the station for the first time.

Required event:

```text
ExerciseDiscovered
```

Required feedback:

```text
NEW EXERCISE DISCOVERED

Incline Dumbbell Press

Codex Updated
```

Discovery must persist after restarting the app.

---

# 26. Iron Codex

The MVP Codex is a small exercise collection screen.

Required categories:

```text
CHEST
├── Pressing
│   ├── Incline Dumbbell Press
│   └── Machine Chest Press
│
└── Isolation
    └── Cable Fly
```

Undiscovered exercises may appear as:

```text
???
```

or hidden entries.

## Each unlocked entry includes

- name
- category
- movement role
- primary muscles
- secondary muscles
- short technique explanation
- discovery status

No search or advanced filtering is required.

---

# 27. Session Builder

The player must choose three discovered exercises for the chest session.

This can be a simple Flutter panel opened during the quest.

## Required behavior

The session builder:

- shows discovered chest exercises
- allows selection / deselection
- requires three exercises
- evaluates the selected combination
- explains obvious redundancy

---

# 28. Session Evaluation

The MVP evaluator does not need advanced exercise science.

It needs simple transparent rules.

## Minimum rules

A successful session must include:

- at least one pressing movement
- at least one isolation movement
- exactly three selected exercises for the MVP quest

Example valid session:

```text
Incline Dumbbell Press
Machine Chest Press
Cable Fly
```

## Redundancy feedback

If the user selects only pressing movements:

```text
Your session is heavily press-focused.

Try including a chest isolation movement so your session is not built entirely around the same movement role.
```

Do not frame the player as "wrong."

Explain why the selection could be improved.

---

# 29. Training Minigame

The MVP requires one simplified training interaction.

It does not need realistic biomechanics.

## Goal

Make training feel interactive enough that the player experiences:

- effort
- timing
- fatigue
- completion

---

# 30. Recommended Training Interaction

Use a timing / rhythm mechanic.

Example:

```text
REP 1
[---| GREEN |---]
       ↑
Press inside control zone
```

Each rep cycles through:

- lowering
- controlled zone
- press timing

The player performs a short set.

Recommended:

```text
5 reps
```

This keeps the demo short.

---

# 31. Training Results

At the end of a set, generate a simple result.

Example:

```text
SET COMPLETE

Clean Reps: 4 / 5
Technique: GOOD
Fatigue: +12
Hydration: -3
XP: +20
```

The result should update domain state.

The result must not be purely cosmetic.

---

# 32. Training Failure

The MVP does not need complex failure simulation.

Possible result states:

```text
Excellent
Good
Rough
Failed
```

If the player performs poorly:

- reduce XP
- still allow quest progress if the set is completed
- explain technique briefly

Do not soft-lock the player.

---

# 33. Player Condition

The MVP condition model only requires:

```text
Hydration
Fatigue
```

Other long-term stats may exist in models but do not need active gameplay.

Do not build the entire health simulation now.

---

# 34. Starting Condition

Recommended default:

```yaml
hydration: 80
fatigue: 10
```

Displayed as 0–100 values.

Meaning:

```text
Hydration
100 = fully hydrated
0 = severely depleted

Fatigue
0 = fresh
100 = extremely fatigued
```

---

# 35. Training Condition Changes

For the MVP:

```text
Complete exercise set
→ Fatigue increases
→ Hydration decreases
```

Exact values should come from content data.

Example:

```yaml
incline_dumbbell_press:
  fatigueCost: 12
  hydrationCost: 3
```

Do not hardcode those values inside the UI.

---

# 36. Condition Feedback

HUD should immediately reflect changes.

Example:

```text
Hydration 80 → 77
Fatigue 10 → 22
```

Optional small notification:

```text
Fatigue +12
```

The goal is to make cause and effect visible.

---

# 37. Water Station

The Recovery Corner includes a Water Station.

Interaction:

```text
WATER STATION

[Drink]
```

Effect:

- increase hydration
- cap at 100

Example:

```text
Hydration +15
```

The water station should not reduce fatigue.

This teaches that hydration and recovery are related but not identical systems.

---

# 38. Recovery Mat

The Recovery Mat demonstrates active recovery.

Interaction:

```text
RECOVERY MAT

[Recover]
```

Effect:

- reduce fatigue
- optional small time transition / short animation

Example:

```text
Fatigue -15
```

The player should visibly return toward a better condition.

---

# 39. Recovery Quest Step

After completing the training set, the quest should explicitly direct the player to recover.

Example:

```text
NEW OBJECTIVE

Visit the Recovery Corner.
```

Then:

```text
Use the Recovery Mat.
```

This is critical.

The demo should not end immediately after lifting.

The recovery step proves the health-first philosophy.

---

# 40. XP and Progression

The MVP only needs lightweight progression.

Required:

```text
Player Level
XP
```

Starting state:

```yaml
level: 1
xp: 0
```

Possible rewards:

```text
Exercise discovery: +5 XP
Working set: +20 XP
Quest completion: +100 XP
```

Exact balance is not important yet.

Consistency is.

---

# 41. Quest Reward

Completing the quest should award:

```text
+100 XP
Chest Programming I
Codex Progress
```

Required knowledge unlock:

```text
Chest Programming I
```

Description:

> Understand the basic role of combining pressing and isolation movements when building a chest session.

---

# 42. Quest Completion Feedback

Required completion feedback:

```text
QUEST COMPLETE

BUILD YOUR FIRST CHEST DAY

Chest Programming I unlocked
+100 XP
```

This should feel meaningful.

Use:

- animation
- sound
- visual emphasis

but keep it short.

---

# 43. HUD

The world must remain visually dominant.

Required HUD:

## Top-left

```text
Active Quest
Current Objective
```

## Top-right

```text
Hydration
Fatigue
```

## Bottom-center

```text
Contextual Interaction Prompt
```

## Mobile only

```text
Bottom-left: Joystick
Bottom-right: Interact / Action
```

Do not cover the screen with RPG bars.

---

# 44. Required Screens

The MVP needs only these screens.

## 1. Launch / Start

Minimal:

```text
IRON ASCENT
[Continue]
[New Game]
[Settings]
```

## 2. Gameplay Screen

Contains:

- 3D world
- HUD
- prompts

## 3. Codex

Shows discovered exercises.

## 4. Quest Log

Shows the active chest-day quest.

## 5. Session Builder

Allows three exercise selections.

## 6. Map Preview

Shows:

```text
Hypertrophy District — AVAILABLE

Strength Yard — LOCKED
Cardio Run — LOCKED
Mobility Temple — LOCKED
Recovery House — FUTURE
Macro Market — FUTURE
Arena — FUTURE
```

The map does not need actual travel.

## 7. Competition Preview

A simple Arena / leaderboard preview.

This is not a functioning multiplayer system.

## 8. Settings

Minimal:

- audio volume
- reduced motion
- control hints
- reset save
- optional graphics quality

## 9. Premium / Support Screen

Minimal RevenueCat integration surface.

---

# 45. Map Preview Purpose

The map exists to communicate the future product vision without building it.

It should show the Iron Map concept and make the MVP feel like one district within a larger world.

Do not implement travel to locked districts.

---

# 46. Competition Preview Purpose

The competition preview exists only to demonstrate future async competition.

It may show mocked entries such as:

```text
STRENGTH TRIAL
Coming Soon
```

or:

```text
PHYSIQUE LEAGUE
Coming Soon
```

Do not build a production leaderboard backend for the MVP.

---

# 47. RevenueCat MVP Requirement

The MVP needs one real monetization integration point.

Required architecture:

```text
MonetizationService
        ↓
RevenueCat implementation
```

Minimum behavior:

- initialize purchase service
- fetch offering / entitlement state
- display premium/support screen
- allow purchase action where supported
- allow restore action where supported
- app must remain playable without purchase

No gameplay-critical health mechanic may require payment.

---

# 48. Premium MVP Positioning

Premium may be framed as future access or supporter access.

Example:

```text
IRON ASCENT SUPPORTER

Support development and unlock future premium content when available.
```

Do not lock:

- quest completion
- hydration
- recovery
- Codex basics
- core chest-day gameplay

behind payment.

---

# 49. Save System

The MVP must save locally.

Required persistent data:

```text
Player level
XP
Hydration
Fatigue
Quest state
Discovered exercises
Codex unlocks
Chest Programming I unlock
Settings
Premium entitlement cache if appropriate
```

---

# 50. Save Timing

Save after meaningful state changes:

- exercise discovery
- exercise set completion
- quest objective completion
- quest completion
- recovery action
- settings change

Do not write to storage every frame.

---

# 51. Continue Game

On launch:

```text
Continue
```

should restore the most recent save.

The player should return to a safe spawn location.

Exact world position persistence is optional.

Progress persistence is required.

---

# 52. New Game

New Game should:

- clear gameplay progression
- initialize starting stats
- reset quest
- reset Codex discoveries

It should not necessarily clear monetization entitlement.

---

# 53. Data Models Required

At minimum:

```text
PlayerProfile
PlayerCondition
Exercise
ExerciseStation
Quest
QuestObjective
QuestProgress
CodexEntry
WorkoutSelection
TrainingResult
District
NPC
SaveGame
```

---

# 54. Required Exercise Data

Each exercise should support:

```yaml
id:
name:
category:
movementRole:
primaryMuscles:
secondaryMuscles:
emphasis:
equipment:
fatigueCost:
hydrationCost:
xpReward:
techniqueDifficulty:
codexUnlock:
summary:
techniqueNotes:
```

---

# 55. Required Quest Data

Example:

```yaml
id: build_first_chest_day
title: Build Your First Chest Day
district: hypertrophy
objectives:
  - talk_to_coach
  - discover_three_chest_exercises
  - inspect_press
  - inspect_isolation
  - build_three_exercise_session
  - complete_working_set
  - return_to_coach
  - recover
reward:
  xp: 100
  knowledge:
    - chest_programming_1
```

---

# 56. Required Domain Events

Minimum event set:

```text
ExerciseDiscovered
ExerciseInspected
WorkoutSelectionChanged
WorkoutValidated
ExerciseStarted
ExerciseCompleted
HydrationChanged
FatigueChanged
QuestObjectiveCompleted
QuestCompleted
CodexUnlocked
RecoveryPerformed
SaveRequested
```

These events should decouple gameplay systems.

---

# 57. State Ownership

## Game Runtime Owns

```text
Player position
Player rotation
Velocity
Animation state
Camera
Collision
Nearby interactables
Active interaction target
```

## Application / Domain State Owns

```text
Player level
XP
Hydration
Fatigue
Quest progress
Codex discoveries
Workout selection
Knowledge unlocks
Settings
Entitlements
```

Do not run player transform updates through Riverpod or equivalent application state on every frame.

---

# 58. Audio

Audio is not core, but minimal feedback significantly improves the demo.

If assets are available, include:

- gym ambience
- footsteps
- UI confirm
- discovery sound
- quest completion sound
- training rep feedback

Audio must not block MVP completion.

Missing audio assets should never stop gameplay work.

---

# 59. Art Requirements

MVP visual direction:

> **Low-poly industrial grit + hopeful rebuilding**

Required feel:

- concrete
- steel
- rubber flooring
- reclaimed gym equipment
- worn materials
- daylight / warm practical lights
- readable silhouettes
- restrained accent lighting

Avoid:

- generic glossy mobile gym
- neon cyberpunk overload
- zombie-horror misery
- photorealism
- direct imitation of Project Zomboid assets or UI

---

# 60. Asset List

## Required 3D Assets

```text
Player character
Coach NPC
Gym room
Incline bench / dumbbell station
Machine chest press
Cable fly station
Water station
Recovery mat
Simple props
```

## Required Player Animations

```text
Idle
Walk
Interact
```

Optional:

```text
Training
Victory
Stretch
```

Animation quality may be simple during the MVP.

---

# 61. Asset Performance Rules

Use:

- GLB / glTF
- low polygon counts
- limited materials
- compressed textures
- shared textures where practical
- simple collision shapes
- lightweight animations

Avoid unnecessarily high-resolution textures.

The world should prioritize stable performance over graphical detail.

---

# 62. Accessibility

MVP accessibility requirements:

- scalable Flutter UI
- readable font sizes
- color-independent hydration/fatigue labels
- keyboard support
- touch support
- reduced-motion option
- non-timing-heavy fallback for training interaction if reduced motion / accessibility mode is enabled
- important feedback shown in text, not sound only

---

# 63. Reduced-Motion Training Alternative

If Reduced Motion is enabled, the training minigame may use:

```text
Press
Release
Press
Release
```

or a slower timing window.

The player must still be able to complete the quest.

---

# 64. Error Handling

The app must fail safely.

Examples:

## Missing exercise content

Show:

```text
Exercise data unavailable.
```

Do not crash.

## Missing optional asset

Use fallback placeholder or skip the prop.

## Save failure

Keep in-memory progress and notify the user.

## RevenueCat failure

Core game remains playable.

## Unsupported purchase platform behavior

Show a clear disabled state.

---

# 65. Loading States

Required:

- initial app loading state
- gym scene loading state
- save loading state
- purchase loading state

Never show a frozen blank screen during loading.

---

# 66. Performance Targets

The MVP should aim for:

- responsive input
- stable gameplay
- no obvious frame stalls during normal movement
- no major rebuild loop caused by Flutter state
- reasonable scene load time
- no memory leak from repeatedly opening panels

Exact FPS targets can vary by platform and device.

The architectural goal is stable real-time interaction.

---

# 67. Testing Requirements

## Unit Tests

At minimum test:

- exercise parsing
- fatigue calculation
- hydration calculation
- session validation
- quest objective progression
- Codex unlock
- XP reward
- save serialization

## Widget Tests

At minimum test:

- HUD renders current state
- Codex locked/unlocked state
- Quest objective display
- Session Builder selection

## Integration / Manual Tests

Verify:

- movement
- collision
- interaction targeting
- exercise discovery
- training completion
- recovery
- save / restart / continue
- mobile controls
- keyboard controls

---

# 68. Acceptance Criteria — Boot

The MVP passes boot acceptance when:

- [ ] App launches without crash.
- [ ] Main menu appears.
- [ ] New Game creates default save state.
- [ ] Continue loads existing progress.
- [ ] Hypertrophy Gym scene loads.
- [ ] Missing online services do not block core gameplay.

---

# 69. Acceptance Criteria — Player

- [ ] Character appears in correct spawn location.
- [ ] Character can move.
- [ ] Character rotates appropriately.
- [ ] Character cannot walk through major walls.
- [ ] Character cannot walk through required gym machines.
- [ ] Keyboard controls work.
- [ ] Touch controls work.
- [ ] Camera follows player correctly.

---

# 70. Acceptance Criteria — Interaction

- [ ] Prompt appears near interactable object.
- [ ] Only one primary interaction prompt is shown.
- [ ] Prompt disappears outside range.
- [ ] Correct object is selected when objects are near each other.
- [ ] Player can inspect each required exercise station.
- [ ] Coach can be interacted with.
- [ ] Water Station works.
- [ ] Recovery Mat works.

---

# 71. Acceptance Criteria — Exercise Discovery

- [ ] Inspecting an undiscovered station unlocks its exercise.
- [ ] Discovery notification appears.
- [ ] Codex updates immediately.
- [ ] Discovered state persists after restart.
- [ ] Re-inspecting does not grant duplicate discovery rewards.

---

# 72. Acceptance Criteria — Quest

- [ ] Coach starts the quest.
- [ ] Quest appears in HUD.
- [ ] Discovering exercises progresses objectives.
- [ ] Inspecting a press progresses the press objective.
- [ ] Inspecting isolation progresses the isolation objective.
- [ ] Session Builder becomes available when appropriate.
- [ ] Valid session passes.
- [ ] Invalid session gives educational feedback.
- [ ] Training set progresses quest.
- [ ] Coach return step works.
- [ ] Recovery step works.
- [ ] Quest completes.
- [ ] Quest cannot reward repeatedly.

---

# 73. Acceptance Criteria — Training

- [ ] Player can start training from required station.
- [ ] Training minigame loads.
- [ ] Player can complete the set.
- [ ] Result screen appears.
- [ ] Fatigue changes.
- [ ] Hydration changes.
- [ ] XP changes.
- [ ] Domain event is emitted.
- [ ] Quest reacts to completion.
- [ ] State persists.

---

# 74. Acceptance Criteria — Recovery

- [ ] Water Station increases hydration.
- [ ] Hydration cannot exceed 100.
- [ ] Recovery Mat reduces fatigue.
- [ ] Fatigue cannot drop below 0.
- [ ] HUD updates immediately.
- [ ] Recovery progresses quest.
- [ ] Recovery state persists.

---

# 75. Acceptance Criteria — Codex

- [ ] Codex opens.
- [ ] Required chest exercises appear.
- [ ] Locked entries are visibly locked or hidden.
- [ ] Discovered entries show content.
- [ ] Chest Programming I unlock appears after quest.
- [ ] Codex state persists.

---

# 76. Acceptance Criteria — Persistence

After:

1. discovering exercises
2. completing a set
3. completing the quest
4. recovering

the user must be able to:

```text
Close App
↓
Reopen App
↓
Continue
```

and still retain:

- discoveries
- XP
- level
- quest completion
- knowledge unlock
- condition values

---

# 77. Acceptance Criteria — UI

- [ ] HUD does not block important world view.
- [ ] Quest objective is readable.
- [ ] Hydration is readable.
- [ ] Fatigue is readable.
- [ ] Interaction prompt is readable.
- [ ] UI scales to mobile screen.
- [ ] UI remains usable on web/desktop.
- [ ] Panels can be closed.
- [ ] No debug controls are visible in release/demo UI.

---

# 78. Acceptance Criteria — RevenueCat

- [ ] Purchase service initializes without breaking app startup.
- [ ] Entitlement state can be queried.
- [ ] Premium/support screen renders.
- [ ] Purchase flow is exposed where supported.
- [ ] Restore flow is exposed where supported.
- [ ] Purchase failure does not crash game.
- [ ] Core gameplay remains free and playable.

---

# 79. MVP Demo Script

Target demo:

> **60–90 seconds**

## Sequence

### 1. Spawn

Player appears inside Hypertrophy Gym.

### 2. Coach

Walk to coach.

Coach:

> Don't collect exercises. Build a session.

Quest begins.

### 3. Discover

Walk to Incline Dumbbell Press.

Inspect.

```text
NEW EXERCISE DISCOVERED
Incline Dumbbell Press
```

### 4. Explore

Inspect Machine Chest Press.

Inspect Cable Fly.

Quest updates.

### 5. Build Session

Open Session Builder.

Select:

```text
Incline Dumbbell Press
Machine Chest Press
Cable Fly
```

Game approves the structure.

### 6. Train

Return to Incline Dumbbell Press.

Perform simplified set.

Result:

```text
Fatigue +12
Hydration -3
XP +20
```

### 7. Coach

Return to coach.

Coach acknowledges session.

### 8. Recover

Walk to Recovery Corner.

Drink water.

Use Recovery Mat.

### 9. Complete

```text
QUEST COMPLETE
Chest Programming I Unlocked
```

### 10. Future Vision

Open Iron Map.

Show locked future districts.

Open competition preview.

### 11. Product line

> **Learn fitness by playing it.**

---

# 80. MVP Success Criteria

The MVP succeeds if a new player can understand, without developer explanation:

1. This is an explorable game world.
2. Gym equipment is interactable.
3. Exercise choice has meaning.
4. The game teaches training concepts.
5. Training creates fatigue.
6. Recovery matters.
7. Knowledge is progression.
8. More districts will exist.
9. Competition will exist later.
10. The game is not simply a workout tracker.

---

# 81. MVP Failure Conditions

The MVP should be considered unsuccessful if:

- the user mostly interacts through menus
- walking around has no gameplay purpose
- exercise stations are decorative
- exercise information is disconnected from gameplay
- fatigue is cosmetic only
- recovery can be ignored
- Codex progression does not react to exploration
- quest logic is hardcoded inside UI widgets
- save data is unreliable
- scene performance is unstable
- scope expansion prevents the chest-day loop from being finished

---

# 82. Build Priority

Use this order.

## Phase 1 — Bootstrap

- Flutter project
- routing
- base theme
- dependency setup
- project folders

## Phase 2 — World

- SceneView
- gym scene
- player model
- camera

## Phase 3 — Movement

- keyboard input
- touch input
- player motor
- collision

## Phase 4 — Interaction

- interactable abstraction
- proximity detection
- prompt
- object action routing

## Phase 5 — Content

- exercise JSON
- quest JSON
- district data
- repositories

## Phase 6 — Domain

- player condition
- exercise models
- fatigue
- hydration
- XP
- events

## Phase 7 — Exercise Stations

- Incline Dumbbell Press
- Machine Chest Press
- Cable Fly

## Phase 8 — Quest

- coach
- objectives
- Session Builder
- evaluation

## Phase 9 — Training

- minigame
- TrainingResult
- condition updates

## Phase 10 — Codex

- discovery
- entries
- unlock feedback

## Phase 11 — Recovery

- Water Station
- Recovery Mat

## Phase 12 — Persistence

- save
- load
- continue
- reset

## Phase 13 — Product UI

- map preview
- competition preview
- settings

## Phase 14 — Monetization

- RevenueCat service
- offering / entitlement UI
- restore

## Phase 15 — Polish

- audio
- visual feedback
- responsiveness
- reduced motion
- testing
- performance

---

# 83. Hard Scope Gate

Before implementing any new feature, ask:

> Does this directly help complete or demonstrate the chest-day vertical slice?

If no:

> **Do not build it.**

Examples:

```text
New hairstyle system?
NO.

Strength district?
NO.

Live leaderboard?
NO.

Cardio system?
NO.

Better interaction feedback?
YES.

Quest bug?
YES.

Save reliability?
YES.

Training result feedback?
YES.
```

---

# 84. MVP Technical North Star

The entire playable loop should follow:

```text
PLAYER INPUT
     ↓
GAME RUNTIME
     ↓
WORLD INTERACTION
     ↓
APPLICATION USE CASE
     ↓
DOMAIN SIMULATION
     ↓
DOMAIN EVENT
     ↓
PERSISTENT STATE
     ↓
FLUTTER UI FEEDBACK
```

Example:

```text
Player presses Interact
        ↓
Incline Station
        ↓
InspectExercise
        ↓
ExerciseRepository
        ↓
ExerciseDiscovered
        ↓
Codex unlocks
        ↓
Quest progresses
        ↓
Save requested
        ↓
Flutter shows discovery notification
```

That is the architectural pattern the rest of IRON ASCENT should eventually follow.

---

# 85. Final MVP Statement

> **The IRON ASCENT MVP is one polished, cross-platform chest-day learning loop inside a low-poly 3D gym. The player explores the environment, discovers three chest exercises, learns their roles, builds a simple session, performs one interactive working set, experiences fatigue and hydration changes, recovers afterward, and permanently unlocks fitness knowledge through the Iron Codex.**

Anything beyond that is secondary until this loop works end to end.

---

# 86. Final Checklist

## Core World

- [ ] Hypertrophy Gym loads
- [ ] Recovery Corner exists
- [ ] Player character loads
- [ ] Coach loads
- [ ] Three exercise stations load

## Movement

- [ ] Keyboard
- [ ] Touch
- [ ] Camera
- [ ] Collision

## Interaction

- [ ] Detection
- [ ] Prompt
- [ ] Inspect
- [ ] Train
- [ ] NPC
- [ ] Water
- [ ] Recovery

## Fitness

- [ ] Exercise data
- [ ] Training result
- [ ] Fatigue
- [ ] Hydration
- [ ] XP

## Education

- [ ] Pressing concept
- [ ] Isolation concept
- [ ] Session Builder
- [ ] Redundancy feedback
- [ ] Chest Programming I

## Progression

- [ ] Quest
- [ ] Exercise discovery
- [ ] Codex
- [ ] XP
- [ ] Knowledge unlock

## Persistence

- [ ] Save
- [ ] Load
- [ ] Continue
- [ ] Reset

## Product

- [ ] Main menu
- [ ] Gameplay HUD
- [ ] Codex screen
- [ ] Quest screen
- [ ] Map preview
- [ ] Competition preview
- [ ] Settings
- [ ] Premium/support screen

## Monetization

- [ ] RevenueCat service
- [ ] Entitlement query
- [ ] Purchase entry point
- [ ] Restore entry point
- [ ] Failure-safe behavior

## Quality

- [ ] Unit tests
- [ ] Widget tests
- [ ] Manual gameplay pass
- [ ] Mobile layout pass
- [ ] Web/desktop layout pass
- [ ] Reduced motion
- [ ] No critical crashes
- [ ] No duplicate quest rewards
- [ ] No save-loss bug
- [ ] No scope creep

---

# 87. Stop Condition

The MVP is finished when the complete chest-day loop works reliably.

At that point:

> **Stop adding features.**

Demo it.

Test it.

Polish it.

Only after the vertical slice is stable should development move into:

- Strength Yard
- deeper progression
- additional exercises
- competition backend
- body development
- additional districts
- real-world workout bridge

The purpose of this MVP is not to prove the entire roadmap.

It is to prove that the **core idea is fun, understandable, technically viable, and worth expanding.**
