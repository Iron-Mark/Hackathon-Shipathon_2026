# IRON ASCENT — Game Systems & Data Specification

> **Document role:** Authoritative specification for gameplay rules, domain models, data schemas, state transitions, events, calculations, and persistence for the MVP.
>
> **Scope:** Build Your First Chest Day vertical slice.
>
> **Purpose:** Remove ambiguity from implementation so gameplay behavior is deterministic, testable, and data-driven.

---

# 1. Document Authority

This document defines **how the MVP behaves internally**.

Project document priority:

1. `03_IRON_ASCENT_MVP_Spec.md`
2. `02_IRON_ASCENT_Flutter_Technical_Architecture.md`
3. `04_IRON_ASCENT_Game_Systems_and_Data.md`
4. `05_IRON_ASCENT_UI_UX_and_Art_Direction.md`
5. `01_IRON_ASCENT_Complete_Game_Plan.md`
6. `06_IRON_ASCENT_AI_Build_Runbook.md`

If this file conflicts with the MVP Spec, the MVP Spec wins.

---

# 2. Core Domain Principle

IRON ASCENT must remain:

> **Data-driven, deterministic, event-oriented, and independent from the renderer.**

The world renderer should never decide fitness outcomes.

The UI should never directly mutate domain state.

The domain simulation should remain pure Dart wherever practical.

Required direction:

```text
Player Input
    ↓
Runtime Interaction
    ↓
Application Use Case
    ↓
Domain Logic
    ↓
Domain Event
    ↓
State Mutation
    ↓
Persistence
    ↓
UI Feedback
```

---

# 3. MVP Systems

The MVP requires these gameplay systems:

```text
Player Profile
Player Condition
Exercise Catalog
Exercise Discovery
Exercise Inspection
Workout Selection
Workout Validation
Training
Quest Progression
Codex
Recovery
XP / Level Progression
District Content
NPC Interaction
Save / Load
Monetization Entitlement State
Settings
```

Not all future systems belong here.

Do not add:

- full nutrition simulation
- injury simulation
- body composition model
- multiplayer ranking simulation
- advanced strength calculations
- wearable data
- detailed sleep simulation

until after the MVP.

---

# 4. Core State Domains

Separate state into four categories.

## 4.1 Runtime State

Transient and frame-sensitive.

```text
player position
player rotation
velocity
animation state
camera transform
active interaction target
nearby interactables
scene load state
input state
```

This should **not** be persisted every frame.

---

## 4.2 Domain Gameplay State

Persistent or meaningful gameplay state.

```text
player profile
XP
level
hydration
fatigue
quest state
exercise discoveries
Codex unlocks
knowledge unlocks
workout selection
```

---

## 4.3 Content State

Static or bundled content.

```text
exercise definitions
quest definitions
district definitions
NPC definitions
knowledge definitions
interaction definitions
```

Stored as JSON/YAML or equivalent structured content.

---

## 4.4 Infrastructure State

Implementation-specific state.

```text
save metadata
purchase entitlement cache
audio setting
reduced motion
graphics quality
schema version
```

---

# 5. Canonical MVP Data Models

Required core entities:

```text
PlayerProfile
PlayerCondition
Exercise
ExerciseStation
WorkoutSelection
WorkoutValidationResult
TrainingResult
QuestDefinition
QuestObjectiveDefinition
QuestProgress
CodexEntry
KnowledgeUnlock
DistrictDefinition
NPCDefinition
GameSettings
SaveGame
```

---

# 6. PlayerProfile

Represents persistent player progression.

Recommended Dart shape:

```dart
class PlayerProfile {
  final String playerId;
  final int level;
  final int xp;
  final PlayerCondition condition;
  final Set<String> discoveredExerciseIds;
  final Set<String> unlockedCodexIds;
  final Set<String> unlockedKnowledgeIds;
  final Map<String, QuestProgress> questProgress;
}
```

Canonical MVP data:

```yaml
playerId: local_player
level: 1
xp: 0
condition:
  hydration: 80
  fatigue: 10
discoveredExerciseIds: []
unlockedCodexIds: []
unlockedKnowledgeIds: []
questProgress: {}
```

---

# 7. PlayerCondition

The MVP only actively simulates:

```text
Hydration
Fatigue
```

Recommended model:

```dart
class PlayerCondition {
  final int hydration;
  final int fatigue;
}
```

Valid ranges:

```text
Hydration: 0–100
Fatigue:   0–100
```

Clamp all mutations.

```dart
hydration = hydration.clamp(0, 100);
fatigue = fatigue.clamp(0, 100);
```

---

# 8. Condition Semantics

## Hydration

```text
100 = fully hydrated
80  = starting state
50  = noticeably depleted
25  = strongly depleted
0   = minimum possible MVP value
```

The MVP does not model medical dehydration.

This stat is a gameplay abstraction.

---

## Fatigue

```text
0   = fully fresh
10  = starting state
30  = mildly fatigued
50  = clearly fatigued
75  = highly fatigued
100 = maximum MVP fatigue
```

The MVP does not simulate injury.

Fatigue only affects:

- training result modifiers
- educational feedback
- recovery need

---

# 9. Exercise Model

Canonical model:

```dart
class Exercise {
  final String id;
  final String name;
  final String category;
  final String movementRole;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final List<String> emphasis;
  final List<String> equipment;
  final int fatigueCost;
  final int hydrationCost;
  final int xpReward;
  final int techniqueDifficulty;
  final bool codexUnlock;
  final String summary;
  final List<String> techniqueNotes;
}
```

---

# 10. Exercise Schema

Required content fields:

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

# 11. Canonical MVP Exercises

## 11.1 Incline Dumbbell Press

```yaml
id: incline_dumbbell_press
name: Incline Dumbbell Press
category: hypertrophy
movementRole: press
primaryMuscles:
  - chest
secondaryMuscles:
  - triceps
  - anterior_deltoids
emphasis:
  - upper_chest
equipment:
  - incline_bench
  - dumbbells
fatigueCost: 12
hydrationCost: 3
xpReward: 20
techniqueDifficulty: 2
codexUnlock: true
summary: A chest pressing movement with greater emphasis on the upper chest.
techniqueNotes:
  - Use a moderate incline.
  - Control the lowering phase.
  - Avoid turning the movement into mostly shoulder work.
```

---

## 11.2 Machine Chest Press

```yaml
id: machine_chest_press
name: Machine Chest Press
category: hypertrophy
movementRole: press
primaryMuscles:
  - chest
secondaryMuscles:
  - triceps
  - anterior_deltoids
emphasis:
  - general_chest
equipment:
  - chest_press_machine
fatigueCost: 10
hydrationCost: 2
xpReward: 18
techniqueDifficulty: 1
codexUnlock: true
summary: A stable chest press variation with reduced stabilization demand.
techniqueNotes:
  - Keep the torso supported.
  - Use a comfortable pressing path.
  - Control both directions of the movement.
```

---

## 11.3 Cable Fly

```yaml
id: cable_fly
name: Cable Fly
category: hypertrophy
movementRole: isolation
primaryMuscles:
  - chest
secondaryMuscles: []
emphasis:
  - chest_adduction
equipment:
  - cable_station
fatigueCost: 8
hydrationCost: 2
xpReward: 16
techniqueDifficulty: 2
codexUnlock: true
summary: An isolation-style chest movement used to complement pressing movements.
techniqueNotes:
  - Keep the movement controlled.
  - Maintain a slight bend in the elbows.
  - Avoid using momentum.
```

---

# 12. Optional MVP Exercise Definitions

Optional only if assets already exist.

## Pec Deck

```yaml
id: pec_deck
movementRole: isolation
```

## Push-Up

```yaml
id: push_up
movementRole: press
```

The quest must never depend on optional exercises.

---

# 13. ExerciseStation

Represents an interactable world object tied to exercise content.

Recommended model:

```dart
class ExerciseStation {
  final String id;
  final String exerciseId;
  final String districtId;
  final double interactionRadius;
  final bool trainingEnabled;
}
```

Example:

```yaml
id: incline_station_01
exerciseId: incline_dumbbell_press
districtId: hypertrophy_gym
interactionRadius: 1.8
trainingEnabled: true
```

---

# 14. Exercise Discovery System

An exercise becomes discovered when the player successfully inspects the station for the first time.

Pseudo logic:

```dart
if (!profile.discoveredExerciseIds.contains(exercise.id)) {
  discoverExercise(exercise.id);
}
```

Discovery must:

1. add exercise ID to discovery set
2. unlock Codex entry if allowed
3. grant discovery XP once
4. emit domain events
5. request save

---

# 15. Discovery Reward

Each first-time discovery grants:

```text
+5 XP
```

This reward is separate from exercise training XP.

Do not grant discovery XP repeatedly.

---

# 16. Discovery Events

Required sequence:

```text
InspectExercise
      ↓
Exercise not discovered
      ↓
ExerciseDiscovered
      ↓
CodexUnlocked
      ↓
XPGranted
      ↓
Quest evaluator
      ↓
SaveRequested
```

---

# 17. Exercise Inspection

Inspection does not change fatigue or hydration.

Inspection may trigger:

```text
ExerciseDiscovered
ExerciseInspected
QuestObjectiveCompleted
```

Inspection should be safe and repeatable.

---

# 18. WorkoutSelection

Represents the three exercises chosen for the MVP quest.

Recommended model:

```dart
class WorkoutSelection {
  final List<String> exerciseIds;
}
```

MVP limit:

```text
Minimum: 0
Maximum: 3
Required for validation: exactly 3
```

Only discovered exercises may be selected.

---

# 19. Workout Validation

The MVP validator uses simple rule-based logic.

Required success conditions:

```text
Exactly 3 exercises selected
At least 1 press
At least 1 isolation
All exercises discovered
No duplicate exercise IDs
```

---

# 20. WorkoutValidationResult

Recommended model:

```dart
class WorkoutValidationResult {
  final bool isValid;
  final List<String> passedRules;
  final List<String> warnings;
  final List<String> errors;
}
```

Example valid result:

```yaml
isValid: true
passedRules:
  - contains_press
  - contains_isolation
  - exactly_three
warnings: []
errors: []
```

---

# 21. Workout Validation Rules

## Rule A — Exactly Three

```text
selectedExercises.length == 3
```

Failure message:

> Select exactly three exercises for this chest-day session.

---

## Rule B — Press Required

At least one:

```text
movementRole == press
```

Failure message:

> Add at least one chest pressing movement.

---

## Rule C — Isolation Required

At least one:

```text
movementRole == isolation
```

Failure message:

> Include a chest isolation movement so the session is not built entirely around pressing.

---

## Rule D — No Duplicates

Exercise IDs must be unique.

Failure message:

> Choose three different exercises.

---

# 22. Redundancy Feedback

If all selected exercises share the same role:

```text
press + press + press
```

return:

```yaml
isValid: false
warning:
  Your session is heavily press-focused.
```

Educational message:

> Try including a chest isolation movement so the session is not built entirely around the same movement role.

Do not label the player as wrong or stupid.

---

# 23. Canonical Valid MVP Session

The intended primary valid solution is:

```text
Incline Dumbbell Press
Machine Chest Press
Cable Fly
```

This is not the only possible future solution.

For the MVP, this is the canonical example.

---

# 24. Training System

The MVP training system processes a single simplified working set.

Training input:

```text
exercise
player condition
rep performance
```

Training output:

```text
TrainingResult
```

---

# 25. TrainingResult

Recommended model:

```dart
class TrainingResult {
  final String exerciseId;
  final int totalReps;
  final int cleanReps;
  final TrainingGrade grade;
  final int fatigueAdded;
  final int hydrationLost;
  final int xpGranted;
}
```

---

# 26. Training Grades

Allowed values:

```text
excellent
good
rough
failed
```

Suggested mapping for 5 reps:

```text
5 clean reps → excellent
4 clean reps → good
2–3 clean reps → rough
0–1 clean reps → failed
```

The exact minigame implementation can vary, but its output must map to these grades.

---

# 27. Training XP Formula

Base XP comes from the exercise definition.

Recommended modifier:

```text
Excellent = 1.25x
Good      = 1.00x
Rough     = 0.75x
Failed    = 0.50x
```

Formula:

```text
xpGranted = round(exercise.xpReward * gradeMultiplier)
```

Example:

Incline Dumbbell Press base:

```text
20 XP
```

Results:

```text
Excellent → 25
Good      → 20
Rough     → 15
Failed    → 10
```

---

# 28. Fatigue Formula

Base fatigue comes from the exercise content.

Recommended grade modifiers:

```text
Excellent = 1.00x
Good      = 1.00x
Rough     = 1.10x
Failed    = 1.20x
```

Then apply current-fatigue modifier:

```text
fatigueStateMultiplier =
  1.00 if current fatigue < 50
  1.10 if current fatigue >= 50 and < 75
  1.20 if current fatigue >= 75
```

Formula:

```text
fatigueAdded =
round(
  baseFatigueCost
  * gradeFatigueMultiplier
  * fatigueStateMultiplier
)
```

Clamp final fatigue to 100.

---

# 29. Hydration Cost Formula

For MVP:

```text
hydrationLost = exercise.hydrationCost
```

No additional complexity is required.

Clamp hydration to 0.

---

# 30. Condition Effect on Training

Condition should matter slightly, but must not soft-lock the demo.

## Hydration modifier

```text
Hydration >= 50 → no penalty
Hydration 25–49 → -5% timing window
Hydration < 25 → -10% timing window
```

## Fatigue modifier

```text
Fatigue < 50 → no penalty
Fatigue 50–74 → -5% timing window
Fatigue >= 75 → -10% timing window
```

These modifiers should be small.

The player must still be able to complete the quest.

---

# 31. Training Process

Canonical flow:

```text
Player selects Train
      ↓
ExerciseStarted
      ↓
Training minigame opens
      ↓
5 reps completed
      ↓
Performance scored
      ↓
TrainingResult generated
      ↓
HydrationChanged
      ↓
FatigueChanged
      ↓
XPGranted
      ↓
ExerciseCompleted
      ↓
Quest evaluated
      ↓
SaveRequested
```

---

# 32. Working Set Requirement

The MVP quest only requires:

```text
1 completed working set
```

It does not require:

- multiple sets
- load progression
- warm-ups
- rest timers
- RPE
- RIR
- advanced volume calculation

Those belong later.

---

# 33. Training Failure Behavior

A failed set must not break the MVP flow.

If:

```text
grade == failed
```

then:

- XP reward is reduced
- fatigue still applies
- hydration still decreases
- quest training objective counts as attempted/completed if the set reaches the result screen

Reason:

The MVP should teach, not punish the player into repeating the demo indefinitely.

---

# 34. Recovery System

The MVP recovery system contains two actions:

```text
Drink Water
Recover on Mat
```

---

# 35. Water Station Rules

Canonical effect:

```text
hydration +15
```

Formula:

```text
newHydration = min(100, hydration + 15)
```

Water Station does **not** reduce fatigue.

Event flow:

```text
WaterConsumed
      ↓
HydrationChanged
      ↓
SaveRequested
```

---

# 36. Recovery Mat Rules

Canonical effect:

```text
fatigue -15
```

Formula:

```text
newFatigue = max(0, fatigue - 15)
```

Recovery Mat does not increase hydration.

Event flow:

```text
RecoveryPerformed
      ↓
FatigueChanged
      ↓
Quest evaluator
      ↓
SaveRequested
```

---

# 37. Quest System

The MVP uses one quest.

Quest ID:

```text
build_first_chest_day
```

Quest states:

```text
locked
available
active
completed
```

For MVP:

```text
new game → available
talk to coach → active
all objectives → completed
```

---

# 38. QuestDefinition

Recommended model:

```dart
class QuestDefinition {
  final String id;
  final String title;
  final String districtId;
  final List<QuestObjectiveDefinition> objectives;
  final QuestReward reward;
}
```

---

# 39. Quest Objective Definition

Recommended model:

```dart
class QuestObjectiveDefinition {
  final String id;
  final String type;
  final int targetCount;
  final Map<String, dynamic> conditions;
}
```

---

# 40. Canonical Quest Data

```yaml
id: build_first_chest_day
title: Build Your First Chest Day
districtId: hypertrophy_gym

objectives:
  - id: talk_to_coach
    type: npc_interaction
    targetCount: 1
    conditions:
      npcId: hypertrophy_coach

  - id: discover_three_chest_exercises
    type: exercise_discovery
    targetCount: 3
    conditions:
      category: hypertrophy
      primaryMuscle: chest

  - id: inspect_press
    type: exercise_inspection
    targetCount: 1
    conditions:
      movementRole: press

  - id: inspect_isolation
    type: exercise_inspection
    targetCount: 1
    conditions:
      movementRole: isolation

  - id: build_three_exercise_session
    type: workout_validation
    targetCount: 1
    conditions:
      validator: chest_day_mvp

  - id: complete_working_set
    type: training_completion
    targetCount: 1
    conditions:
      primaryMuscle: chest

  - id: return_to_coach
    type: npc_interaction_after_training
    targetCount: 1
    conditions:
      npcId: hypertrophy_coach

  - id: recover
    type: recovery_action
    targetCount: 1
    conditions:
      stationType: recovery_mat

reward:
  xp: 100
  knowledgeIds:
    - chest_programming_1
```

---

# 41. QuestProgress

Recommended model:

```dart
class QuestProgress {
  final String questId;
  final QuestState state;
  final Map<String, int> objectiveProgress;
  final bool rewardClaimed;
}
```

Example:

```yaml
questId: build_first_chest_day
state: active
objectiveProgress:
  talk_to_coach: 1
  discover_three_chest_exercises: 2
  inspect_press: 1
  inspect_isolation: 0
  build_three_exercise_session: 0
  complete_working_set: 0
  return_to_coach: 0
  recover: 0
rewardClaimed: false
```

---

# 42. Quest Progression Rules

Objectives should update from events.

Do not manually mutate quest progress from widgets.

Example:

```text
ExerciseDiscovered
      ↓
QuestSystem.handle(event)
      ↓
Check objective definitions
      ↓
Increment matching objective
```

---

# 43. Quest Reward Rules

Quest reward:

```text
+100 XP
unlock chest_programming_1
```

Reward must only be granted once.

Guard:

```dart
if (!progress.rewardClaimed) {
  grantReward();
}
```

Then:

```text
rewardClaimed = true
```

---

# 44. Knowledge System

The MVP includes one explicit knowledge unlock.

## Chest Programming I

```yaml
id: chest_programming_1
name: Chest Programming I
category: hypertrophy
summary: Understand the basic role of combining pressing and isolation movements when building a chest session.
```

Unlock source:

```text
build_first_chest_day completion
```

---

# 45. Codex System

The Codex tracks discovered exercise knowledge.

Canonical relation:

```text
Exercise discovered
      ↓
Codex entry unlocked
```

Required Codex state:

```text
locked
unlocked
```

---

# 46. CodexEntry

Recommended model:

```dart
class CodexEntry {
  final String id;
  final String exerciseId;
  final bool unlocked;
}
```

No separate duplicated exercise text should be stored in save data.

Save only unlock state.

Load full content from exercise data.

---

# 47. Codex Unlock Rule

For MVP:

```text
exercise.codexUnlock == true
AND
exercise discovered
```

Then unlock:

```text
codex:{exerciseId}
```

Example:

```text
codex:incline_dumbbell_press
```

---

# 48. XP System

XP can be gained from:

```text
Exercise discovery
Training
Quest completion
```

MVP values:

```text
First exercise discovery: +5
Training: exercise base XP × grade multiplier
Quest completion: +100
```

---

# 49. Level System

Keep leveling intentionally simple.

Recommended curve:

```text
Level 1 → 0 XP
Level 2 → 100 XP
Level 3 → 250 XP
Level 4 → 450 XP
Level 5 → 700 XP
```

Formula implementation may use a table for MVP.

Do not overengineer an exponential progression system yet.

---

# 50. Level-Up Logic

After any XP grant:

```text
add XP
↓
check threshold
↓
increase level if threshold reached
↓
emit PlayerLeveledUp
```

Allow multiple level-ups if necessary.

No level-up rewards are required for MVP.

---

# 51. DistrictDefinition

Represents static district content.

Recommended model:

```dart
class DistrictDefinition {
  final String id;
  final String name;
  final String sceneAsset;
  final SpawnPoint spawn;
  final List<String> stationIds;
  final List<String> npcIds;
}
```

Canonical MVP district:

```yaml
id: hypertrophy_gym
name: Hypertrophy Gym
sceneAsset: assets/scenes/hypertrophy_gym.glb
spawn:
  x: 2.5
  y: 0
  z: 8.0
stationIds:
  - incline_station_01
  - machine_press_station_01
  - cable_fly_station_01
  - water_station_01
  - recovery_mat_01
npcIds:
  - hypertrophy_coach
```

---

# 52. NPCDefinition

Recommended model:

```dart
class NPCDefinition {
  final String id;
  final String name;
  final String role;
  final List<String> dialogueIds;
}
```

Canonical coach:

```yaml
id: hypertrophy_coach
name: Hypertrophy Coach
role: coach
dialogueIds:
  - coach_intro
  - coach_after_discovery
  - coach_after_training
  - coach_completion
```

---

# 53. Dialogue State

Dialogue can remain simple.

No branching dialogue engine is required.

Recommended lookup:

```text
quest not active
→ coach_intro

quest active, training incomplete
→ coach_after_discovery

training complete, return incomplete
→ coach_after_training

quest completed
→ coach_completion
```

---

# 54. Domain Event Catalog

Required MVP events:

```text
GameStarted
NewGameCreated
SaveLoaded

NPCInteracted

ExerciseDiscovered
ExerciseInspected
ExerciseStarted
ExerciseCompleted

WorkoutSelectionChanged
WorkoutValidated

HydrationChanged
FatigueChanged

WaterConsumed
RecoveryPerformed

XPGranted
PlayerLeveledUp

QuestStarted
QuestObjectiveCompleted
QuestCompleted

CodexUnlocked
KnowledgeUnlocked

SaveRequested

EntitlementUpdated
SettingsChanged
```

---

# 55. Event Payload Guidance

Events should contain only what downstream systems need.

Example:

```dart
class ExerciseCompleted extends GameEvent {
  final String exerciseId;
  final TrainingResult result;
}
```

Avoid events containing entire app state snapshots.

---

# 56. Event Processing Order

For important actions, process state changes deterministically.

Example training completion:

```text
1. Generate TrainingResult
2. Apply hydration change
3. Apply fatigue change
4. Grant training XP
5. Emit ExerciseCompleted
6. Evaluate quest
7. Request save
8. Update presentation
```

---

# 57. Duplicate Event Protection

Systems must be idempotent where duplicate events would create rewards.

Protect:

```text
exercise discovery XP
Codex unlock
quest reward
knowledge unlock
```

Use sets / reward flags.

---

# 58. Application Use Cases

Recommended use cases:

```text
StartNewGame
ContinueGame
InspectExercise
StartExercise
CompleteExercise
SelectWorkoutExercise
ValidateWorkout
InteractWithNPC
DrinkWater
Recover
OpenCodex
CompleteQuest
SaveGame
ResetGame
```

Use cases coordinate repositories and domain logic.

---

# 59. Repository Interfaces

Recommended:

```dart
abstract interface class ExerciseRepository {
  Future<Exercise?> getById(String id);
  Future<List<Exercise>> getAll();
}

abstract interface class QuestRepository {
  Future<QuestDefinition?> getById(String id);
}

abstract interface class DistrictRepository {
  Future<DistrictDefinition?> getById(String id);
}

abstract interface class SaveRepository {
  Future<SaveGame?> load();
  Future<void> save(SaveGame save);
  Future<void> clear();
}
```

---

# 60. Content Repository Rules

Bundled content is authoritative for:

```text
exercise metadata
quest definitions
district definitions
NPC definitions
knowledge definitions
```

Player save data must not duplicate full static content.

Save IDs and progress only.

---

# 61. SaveGame Schema

Recommended:

```yaml
schemaVersion: 1

player:
  playerId: local_player
  level: 1
  xp: 0

condition:
  hydration: 80
  fatigue: 10

discoveries:
  exerciseIds: []

codex:
  unlockedEntryIds: []

knowledge:
  unlockedIds: []

quests:
  build_first_chest_day:
    state: available
    objectiveProgress: {}
    rewardClaimed: false

settings:
  reducedMotion: false
  audioVolume: 1.0
  graphicsQuality: medium
```

---

# 62. Save Versioning

All save files must include:

```text
schemaVersion
```

Initial:

```text
1
```

If future save structure changes:

- add migration logic
- never silently discard progress
- never assume old saves match new models

---

# 63. Save Timing

Request save after:

```text
New Game creation
Exercise discovery
Training completion
Quest objective completion
Quest completion
Water consumption
Recovery
Settings change
Knowledge unlock
```

Do not save every frame.

---

# 64. Save Failure Behavior

If persistence fails:

- keep current in-memory state
- show non-blocking error
- allow player to continue
- retry on next meaningful save opportunity

Do not crash.

---

# 65. New Game Initialization

Canonical starting state:

```yaml
level: 1
xp: 0

condition:
  hydration: 80
  fatigue: 10

discoveredExerciseIds: []
unlockedCodexIds: []
unlockedKnowledgeIds: []

quest:
  build_first_chest_day:
    state: available
    rewardClaimed: false
```

Spawn:

```text
hypertrophy_gym
```

---

# 66. Continue Game Rules

Continue should:

1. load save
2. validate schema
3. load static content
4. restore gameplay progression
5. spawn player at safe default gym spawn
6. restore active quest
7. restore condition
8. restore Codex unlocks

World transform persistence is optional.

---

# 67. Reset Game Rules

Reset game clears:

```text
level
XP
condition
quest progress
exercise discoveries
Codex progress
knowledge unlocks
```

Do not clear:

```text
RevenueCat entitlement
platform purchase history
```

---

# 68. Settings Model

Minimum:

```dart
class GameSettings {
  final double audioVolume;
  final bool reducedMotion;
  final String graphicsQuality;
}
```

Canonical defaults:

```yaml
audioVolume: 1.0
reducedMotion: false
graphicsQuality: medium
```

---

# 69. Reduced Motion Rule

Reduced Motion may modify:

```text
camera damping
notification animation
training minigame presentation
screen transitions
```

It must not:

- block quest completion
- reduce rewards
- change progression outcome unfairly

---

# 70. Monetization State

Monetization is infrastructure-level state.

Recommended abstraction:

```dart
class EntitlementState {
  final bool premium;
  final bool loading;
  final String? error;
}
```

Gameplay must not depend on premium.

Core MVP state is independent from RevenueCat availability.

---

# 71. Validation Rules

Validate all content when loaded.

## Exercise

Reject or report invalid if:

```text
missing id
missing name
unknown movementRole
negative fatigueCost
negative hydrationCost
negative XP
```

## Quest

Reject or report invalid if:

```text
missing id
duplicate objective IDs
missing reward definition
unknown objective type
```

## District

Reject or report invalid if:

```text
missing id
missing scene asset
references nonexistent station IDs
references nonexistent NPC IDs
```

---

# 72. Supported Movement Roles

MVP enum:

```text
press
isolation
```

Future roles may include:

```text
horizontal_pull
vertical_pull
knee_dominant
hip_dominant
knee_flexion
calf
carry
rotation
conditioning
mobility
```

Do not implement these future roles unless content requires them.

---

# 73. Supported Muscle IDs

MVP needs:

```text
chest
triceps
anterior_deltoids
```

Use normalized machine-friendly IDs.

Do not use free-form display strings internally.

---

# 74. ID Naming Convention

Use:

```text
snake_case
```

Examples:

```text
incline_dumbbell_press
machine_chest_press
cable_fly
build_first_chest_day
chest_programming_1
hypertrophy_gym
hypertrophy_coach
```

IDs must be stable after release.

Display names may change.

IDs should not.

---

# 75. Content File Layout

Recommended:

```text
assets/
└── data/
    ├── exercises/
    │   └── chest.json
    │
    ├── quests/
    │   └── build_first_chest_day.json
    │
    ├── districts/
    │   └── hypertrophy_gym.json
    │
    ├── npcs/
    │   └── hypertrophy_coach.json
    │
    └── knowledge/
        └── chest_programming_1.json
```

---

# 76. Example `chest.json`

```json
[
  {
    "id": "incline_dumbbell_press",
    "name": "Incline Dumbbell Press",
    "category": "hypertrophy",
    "movementRole": "press",
    "primaryMuscles": ["chest"],
    "secondaryMuscles": ["triceps", "anterior_deltoids"],
    "emphasis": ["upper_chest"],
    "equipment": ["incline_bench", "dumbbells"],
    "fatigueCost": 12,
    "hydrationCost": 3,
    "xpReward": 20,
    "techniqueDifficulty": 2,
    "codexUnlock": true,
    "summary": "A chest pressing movement with greater emphasis on the upper chest.",
    "techniqueNotes": [
      "Use a moderate incline.",
      "Control the lowering phase.",
      "Avoid turning the movement into mostly shoulder work."
    ]
  },
  {
    "id": "machine_chest_press",
    "name": "Machine Chest Press",
    "category": "hypertrophy",
    "movementRole": "press",
    "primaryMuscles": ["chest"],
    "secondaryMuscles": ["triceps", "anterior_deltoids"],
    "emphasis": ["general_chest"],
    "equipment": ["chest_press_machine"],
    "fatigueCost": 10,
    "hydrationCost": 2,
    "xpReward": 18,
    "techniqueDifficulty": 1,
    "codexUnlock": true,
    "summary": "A stable chest press variation with reduced stabilization demand.",
    "techniqueNotes": [
      "Keep the torso supported.",
      "Use a comfortable pressing path.",
      "Control both directions of the movement."
    ]
  },
  {
    "id": "cable_fly",
    "name": "Cable Fly",
    "category": "hypertrophy",
    "movementRole": "isolation",
    "primaryMuscles": ["chest"],
    "secondaryMuscles": [],
    "emphasis": ["chest_adduction"],
    "equipment": ["cable_station"],
    "fatigueCost": 8,
    "hydrationCost": 2,
    "xpReward": 16,
    "techniqueDifficulty": 2,
    "codexUnlock": true,
    "summary": "An isolation-style chest movement used to complement pressing movements.",
    "techniqueNotes": [
      "Keep the movement controlled.",
      "Maintain a slight bend in the elbows.",
      "Avoid using momentum."
    ]
  }
]
```

---

# 77. Testing Rules — Domain

At minimum write unit tests for:

```text
new game defaults
condition clamping
exercise parsing
discovery only rewards once
Codex unlock only occurs once
workout validation
training XP calculation
fatigue calculation
hydration change
quest objective matching
quest reward only granted once
knowledge unlock
save serialization
save deserialization
level thresholds
```

---

# 78. Required Unit Test Cases

## Workout validation

```text
press + press + isolation → valid
press + press + press → invalid
isolation + isolation + isolation → invalid
2 exercises → invalid
4 exercises → invalid
duplicate exercise → invalid
undiscovered exercise → invalid
```

---

# 79. Required Condition Tests

```text
hydration cannot exceed 100
hydration cannot go below 0
fatigue cannot exceed 100
fatigue cannot go below 0
water changes hydration only
recovery mat changes fatigue only
```

---

# 80. Required Quest Tests

```text
coach starts quest
3 discoveries completes discovery objective
press inspection completes press objective
isolation inspection completes isolation objective
valid workout completes builder objective
training completes set objective
coach return only counts after training
recovery completes final objective
quest reward granted once
```

---

# 81. Required Persistence Tests

```text
save → load preserves XP
save → load preserves condition
save → load preserves quest
save → load preserves discoveries
save → load preserves Codex
save → load preserves knowledge
schemaVersion persists
reset clears gameplay progress
reset does not affect entitlement
```

---

# 82. Error Handling Contracts

## Invalid Exercise ID

Return controlled failure:

```text
Exercise not found.
```

Do not crash.

## Invalid Quest ID

Return controlled failure.

## Missing Save

Treat as:

```text
no existing game
```

## Corrupt Save

Attempt:

1. validate
2. migration if possible
3. safe reset prompt / fallback

Never silently overwrite corrupted data without reporting it.

---

# 83. Logging Guidance

During development, log:

```text
scene load
save load
save write
exercise discovery
training result
quest objective completion
quest completion
RevenueCat initialization
content validation errors
```

Do not spam logs every frame.

---

# 84. Performance Rules

Do not:

- serialize the whole save every frame
- rebuild the entire Flutter tree on movement
- repeatedly parse JSON during every interaction
- load the same static content from disk on every inspection

Do:

- parse static content once
- cache immutable definitions
- update only meaningful application state
- keep frame state inside runtime

---

# 85. Domain Purity Rules

The domain layer should not import:

```text
flutter/material.dart
flutter/widgets.dart
flutter_scene
RevenueCat SDK
database implementation
platform APIs
```

Domain may use:

```text
Dart core
immutable value objects
pure functions
repository abstractions where needed
```

---

# 86. No Hidden Gameplay Mutations

Every meaningful player progression change should originate from a named use case or domain event.

Bad:

```dart
player.xp += 20;
```

inside a widget.

Good:

```text
CompleteExercise
      ↓
TrainingResult
      ↓
XPGranted
      ↓
PlayerProfile updated
```

This keeps behavior testable.

---

# 87. Canonical MVP Gameplay State Example

After discovering all exercises and completing one good incline press set:

```yaml
player:
  level: 1
  xp: 35

condition:
  hydration: 77
  fatigue: 22

discoveredExerciseIds:
  - incline_dumbbell_press
  - machine_chest_press
  - cable_fly

unlockedCodexIds:
  - codex:incline_dumbbell_press
  - codex:machine_chest_press
  - codex:cable_fly

unlockedKnowledgeIds: []

quest:
  build_first_chest_day:
    state: active
    objectiveProgress:
      talk_to_coach: 1
      discover_three_chest_exercises: 3
      inspect_press: 1
      inspect_isolation: 1
      build_three_exercise_session: 1
      complete_working_set: 1
      return_to_coach: 0
      recover: 0
```

---

# 88. Canonical Completed Quest State

After returning to coach and recovering:

```yaml
player:
  level: 2
  xp: 135

condition:
  hydration: 92
  fatigue: 7

knowledge:
  unlockedIds:
    - chest_programming_1

quest:
  build_first_chest_day:
    state: completed
    rewardClaimed: true
```

Exact XP may vary depending on training grade.

The reward must still be deterministic from the configured values.

---

# 89. Future Extension Rules

Future systems should extend existing structures rather than rewrite them.

Examples:

```text
More exercises
→ add content definitions

More districts
→ add DistrictDefinition files

More quests
→ add QuestDefinition files

More condition stats
→ extend PlayerCondition carefully

Competition
→ separate competition domain

Cloud save
→ new SaveRepository implementation

Real workout logging
→ separate real-world training feature
```

The renderer should not need redesign when more fitness content is added.

---

# 90. Anti-Scope Rule

Do not introduce a new system during MVP unless one of these requires it:

```text
player movement
environment interaction
exercise education
chest-day quest
training
fatigue
hydration
recovery
Codex
save/load
RevenueCat integration
basic product UI
```

Everything else waits.

---

# 91. Technical Source of Truth Summary

## Static content owns:

```text
what an exercise is
what a quest requires
what a district contains
what an NPC says
what knowledge unlocks
```

## Runtime owns:

```text
where the player is
what the player is touching
what is happening frame to frame
```

## Domain owns:

```text
what actions mean
how state changes
whether conditions are satisfied
what rewards are granted
```

## Presentation owns:

```text
what the player sees
how feedback is displayed
how menus are arranged
```

## Infrastructure owns:

```text
how saves are stored
how purchases are queried
how platform services are accessed
```

---

# 92. Final System Contract

The most important rule for IRON ASCENT is:

> **World interactions create domain actions. Domain actions create measurable fitness consequences. Those consequences create progression and educational feedback.**

Canonical example:

```text
Player walks to Cable Fly
        ↓
Inspect
        ↓
Cable Fly discovered
        ↓
Codex updated
        ↓
Isolation objective progresses
        ↓
Player includes it in workout
        ↓
Workout validates
        ↓
Player trains
        ↓
Fatigue rises
        ↓
Hydration drops
        ↓
XP gained
        ↓
Quest advances
        ↓
Player recovers
        ↓
Chest Programming I unlocked
```

If a gameplay system cannot fit into this model cleanly, it is probably either:

1. misplaced architecturally, or
2. outside the MVP scope.

---

# 93. Final Data Contract Checklist

## Player

- [ ] PlayerProfile
- [ ] PlayerCondition
- [ ] XP
- [ ] Level

## Exercises

- [ ] Exercise model
- [ ] ExerciseStation model
- [ ] 3 required exercise definitions
- [ ] Discovery
- [ ] Inspection
- [ ] Training values

## Workout

- [ ] WorkoutSelection
- [ ] WorkoutValidationResult
- [ ] press rule
- [ ] isolation rule
- [ ] exactly 3 rule
- [ ] no duplicates rule

## Training

- [ ] TrainingResult
- [ ] grade enum
- [ ] XP modifier
- [ ] fatigue formula
- [ ] hydration formula
- [ ] condition modifier

## Recovery

- [ ] Water Station
- [ ] Recovery Mat
- [ ] clamping

## Quest

- [ ] QuestDefinition
- [ ] QuestObjectiveDefinition
- [ ] QuestProgress
- [ ] reward guard
- [ ] chest-day quest data

## Codex

- [ ] CodexEntry
- [ ] unlock rule
- [ ] persistent discovery

## Knowledge

- [ ] Chest Programming I
- [ ] unlock rule

## World

- [ ] DistrictDefinition
- [ ] NPCDefinition
- [ ] station definitions

## Events

- [ ] domain event catalog
- [ ] deterministic order
- [ ] duplicate protection

## Persistence

- [ ] SaveGame
- [ ] schema version
- [ ] save timing
- [ ] reset behavior
- [ ] migration-ready structure

## Infrastructure

- [ ] settings
- [ ] entitlement state
- [ ] controlled error handling

---

# 94. Stop Condition

This systems specification is sufficient for the MVP when the AI builder can implement all gameplay behavior without inventing:

- exercise values
- quest rules
- training outcomes
- XP logic
- fatigue logic
- hydration logic
- recovery rules
- save structure
- event names
- content IDs
- validation requirements

At that point, stop adding systems documentation.

The next document should define only:

> **How the game should look, feel, communicate, and respond visually.**
