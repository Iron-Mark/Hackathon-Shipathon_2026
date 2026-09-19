# IRON ASCENT — Flutter Technical Architecture

## 1. Architecture Goal

IRON ASCENT should **not** be built like a normal CRUD Flutter app.

The recommended architecture is:

> **Flutter product shell + isolated real-time game runtime + pure Dart domain simulation + data/infrastructure layer**

This keeps the 3D world, fitness rules, progression, quests, UI, persistence, and future backend concerns separated.

The biggest rule:

> **Flutter UI does not own the game simulation, and the 3D renderer does not own the fitness rules.**

---

# 2. High-Level Architecture

```text
┌─────────────────────────────────────────────────┐
│                  FLUTTER APP                    │
│                                                 │
│  MaterialApp.router                             │
│  ├── Onboarding                                 │
│  ├── Profile                                    │
│  ├── Map                                        │
│  ├── Codex                                      │
│  ├── Quests                                     │
│  ├── Leaderboards                               │
│  ├── Store                                      │
│  └── GameScreen                                 │
│        │                                        │
│        ├──────── Flutter HUD ───────────────┐   │
│        │                                     │   │
│        └── SceneView                         │   │
│              │                               │   │
│              ▼                               │   │
│      ┌────────────────────┐                  │   │
│      │   GAME RUNTIME     │                  │   │
│      │                    │                  │   │
│      │ Input              │                  │   │
│      │ Player Motor       │                  │   │
│      │ Camera             │                  │   │
│      │ Physics            │                  │   │
│      │ Interactions       │                  │   │
│      │ Animation          │                  │   │
│      │ Scene Manager      │                  │   │
│      └─────────┬──────────┘                  │   │
│                │                             │   │
│                ▼                             │   │
│      ┌────────────────────┐                  │   │
│      │ GAME SIMULATION    │◄─────────────────┘   │
│      │                    │                      │
│      │ PlayerCondition    │                      │
│      │ ExerciseSystem     │                      │
│      │ FatigueSystem      │                      │
│      │ QuestSystem        │                      │
│      │ ProgressionSystem  │                      │
│      │ CodexSystem        │                      │
│      └─────────┬──────────┘                      │
│                │                                 │
│                ▼                                 │
│      ┌────────────────────┐                      │
│      │ DATA / REPOSITORY  │                      │
│      │                    │                      │
│      │ Exercise JSON      │                      │
│      │ Quest JSON         │                      │
│      │ District JSON      │                      │
│      │ Local Save DB      │                      │
│      │ Cloud later        │                      │
│      └────────────────────┘                      │
└─────────────────────────────────────────────────┘
```

---

# 3. Flutter as the Application Shell

Use standard Flutter for everything that does **not** need to run every frame.

```text
Flutter
├── routing
├── onboarding
├── profile
├── map
├── quest log
├── codex
├── body screen
├── settings
├── leaderboards
├── RevenueCat
└── HUD overlays
```

Recommended routing:

```dart
MaterialApp.router(
  routerConfig: router,
)
```

Possible gameplay route:

```text
/game/hypertrophy-gym
```

The gameplay screen can be structured like:

```dart
Stack(
  children: [
    IronAscentWorld(),
    GameHud(),
    InteractionPrompt(),
    QuestTracker(),
  ],
)
```

This gives IRON ASCENT the desired layout:

> **3D world underneath, Flutter UI on top.**

---

# 4. 3D Runtime

For the preferred 3D direction:

> **Flutter + flutter_scene**

Assets should be created in Blender and exported as GLB/glTF.

Example assets:

```text
player.glb
hypertrophy_gym.glb
incline_bench.glb
cable_machine.glb
coach.glb
```

Asset pipeline:

```text
Blender
   ↓
GLB / glTF
   ↓
flutter_scene
   ↓
Scene
   ↓
SceneView
   ↓
Flutter
```

Use low-poly, optimized assets.

Do not build an open-world scene.

Use:

- small rooms
- compact gyms
- connected districts
- diorama-style environments

---

# 5. Flame vs Flutter Scene

Do not run two game engines unless absolutely necessary.

Choose one direction.

```text
3D IRON ASCENT
Flutter + flutter_scene

OR

2D / Isometric IRON ASCENT
Flutter + Flame
```

For the current IRON ASCENT concept:

> **Commit to Flutter + flutter_scene.**

Keep Flame only as the fallback if 3D becomes too risky.

---

# 6. Game Runtime Layer

The runtime owns everything that happens continuously during gameplay.

Recommended structure:

```text
game/
├── runtime/
│   ├── game_runtime.dart
│   ├── game_session.dart
│   └── game_clock.dart
│
├── world/
│   ├── world_controller.dart
│   ├── district_controller.dart
│   └── scene_loader.dart
│
├── player/
│   ├── player_controller.dart
│   ├── player_motor.dart
│   └── player_animation.dart
│
├── camera/
│   └── isometric_camera.dart
│
├── physics/
│   ├── collision_world.dart
│   └── colliders.dart
│
├── input/
│   ├── input_controller.dart
│   ├── keyboard_input.dart
│   ├── touch_input.dart
│   └── controller_input.dart
│
└── interactions/
    ├── interaction_system.dart
    ├── interactable.dart
    └── interaction_detector.dart
```

The runtime handles:

```text
player position
velocity
rotation
animation
collisions
camera position
nearest interactable
button presses
scene transitions
```

The runtime should **not** decide:

```text
how much fatigue an exercise gives
whether a workout is well structured
how much XP the player gets
whether a Codex entry unlocks
whether a quest is complete
```

Those belong to the domain simulation.

---

# 7. Domain Simulation

The core fitness simulation should be written in **pure Dart**.

No:

- Flutter widgets
- BuildContext
- Scene Nodes
- rendering dependencies

Recommended structure:

```text
domain/
├── player/
│   ├── player.dart
│   ├── attributes.dart
│   └── condition.dart
│
├── exercise/
│   ├── exercise.dart
│   ├── workout.dart
│   └── workout_session.dart
│
├── training/
│   ├── training_service.dart
│   ├── fatigue_calculator.dart
│   └── workout_evaluator.dart
│
├── quest/
│   ├── quest.dart
│   └── objective.dart
│
├── progression/
│   ├── progression.dart
│   └── xp.dart
│
├── codex/
│   └── codex_entry.dart
│
└── recovery/
    └── recovery_service.dart
```

Example:

```dart
class PlayerCondition {
  final double hydration;
  final double fatigue;
  final double sleep;
  final double stress;
  final double injuryRisk;
}
```

Training logic can then be tested separately:

```dart
TrainingResult performExercise({
  required Exercise exercise,
  required PlayerCondition condition,
  required int reps,
  required double load,
}) {
  // domain simulation
}
```

This means the entire training simulation can be tested without launching Flutter or loading a 3D scene.

---

# 8. Interaction Flow

Example: player approaches an incline bench.

```text
Touch / WASD
     ↓
InputController
     ↓
PlayerMotor
     ↓
Physics
     ↓
Player moves
     ↓
InteractionDetector
     ↓
Finds InclinePressStation
     ↓
InteractionPrompt appears
     ↓
Player presses E / Interact
     ↓
StartExerciseUseCase
     ↓
TrainingSystem
     ↓
Fatigue changes
     ↓
QuestSystem notified
     ↓
CodexSystem notified
     ↓
UI updates
```

Avoid putting domain logic directly inside widgets.

Bad:

```dart
onTap() {
  fatigue += 10;
  xp += 50;
}
```

The widget should trigger a use case instead.

---

# 9. World Entities

Do not build a massive enterprise-grade ECS for the prototype.

Start with a lightweight entity/component approach.

```dart
abstract class WorldEntity {
  String get id;

  void update(double dt);
}
```

Interactables:

```dart
class InteractableEntity extends WorldEntity {
  final Interaction interaction;
  final Collider collider;
}
```

Possible entities:

```text
InclineBenchEntity
CableMachineEntity
ChestPressEntity
WaterStationEntity
CoachEntity
RecoveryMatEntity
```

However, behavior should preferably be data-driven.

Instead of hardcoding:

```dart
InclineBenchEntity()
```

use something like:

```dart
GymStation(
  id: 'incline_press_01',
  exerciseId: 'incline_dumbbell_press',
)
```

That scales much better.

---

# 10. Data-Driven Content

IRON ASCENT should be heavily data-driven.

Avoid:

```dart
if (benchPress) ...
if (cableFly) ...
if (pecDeck) ...
```

Use JSON or structured content files.

Recommended:

```text
assets/
└── data/
    ├── exercises/
    │   ├── chest.json
    │   ├── back.json
    │   └── legs.json
    │
    ├── quests/
    │   └── hypertrophy/
    │
    ├── districts/
    │   └── hypertrophy_gym.json
    │
    ├── npcs/
    └── items/
```

Example exercise:

```json
{
  "id": "incline_dumbbell_press",
  "name": "Incline Dumbbell Press",
  "movement": "horizontal_press",
  "primaryMuscles": ["chest"],
  "secondaryMuscles": [
    "triceps",
    "anterior_deltoid"
  ],
  "fatigueCost": 12,
  "techniqueDifficulty": 2
}
```

World station:

```json
{
  "id": "incline_station_01",
  "type": "exercise_station",
  "exerciseId": "incline_dumbbell_press"
}
```

This keeps the environment separate from exercise knowledge.

---

# 11. District Architecture

Each district should behave like a self-contained content module.

```text
districts/
├── home_base/
├── hypertrophy/
├── strength/
├── cardio/
├── recovery/
├── mobility/
└── macro_market/
```

Each district can define:

```text
scene GLB
spawn points
interactables
NPC positions
audio
district metadata
quest availability
```

Example:

```json
{
  "id": "hypertrophy_gym",
  "scene": "assets/scenes/hypertrophy_gym.glb",

  "spawn": {
    "x": 2.5,
    "y": 0,
    "z": 8.0
  },

  "interactables": [
    {
      "id": "incline_press",
      "action": "exercise",
      "target": "incline_dumbbell_press"
    }
  ]
}
```

Then:

```dart
await districtManager.load('hypertrophy_gym');
```

This allows expansion from one room to the full Iron Map without rewriting the engine.

---

# 12. State Management

Use two categories of state.

## Real-Time Game State

Owned by the game runtime:

```text
position
rotation
velocity
animation
camera
collisions
nearby interactables
```

Do **not** push these through Riverpod 60 times per second.

## Persistent / Application State

Owned by Riverpod or equivalent:

```text
profile
level
XP
quests
Codex
inventory
hydration
fatigue
settings
entitlements
save slot
```

Recommended flow:

```text
GAME LOOP
60 fps
│
├─ movement
├─ camera
├─ physics
└─ animation

        occasionally
            ↓

DOMAIN EVENT
ExerciseCompleted
QuestCompleted
HydrationChanged
CodexUnlocked

            ↓

STATE MANAGEMENT

            ↓

Flutter HUD rebuild
```

---

# 13. Domain Events

Use lightweight events so systems remain independent.

```dart
sealed class GameEvent {}

class ExerciseDiscovered extends GameEvent {
  final String exerciseId;
}

class ExerciseCompleted extends GameEvent {
  final String exerciseId;
}

class FatigueChanged extends GameEvent {
  final double value;
}

class QuestCompleted extends GameEvent {
  final String questId;
}
```

Example flow:

```text
TrainingSystem
      ↓
ExerciseCompleted
      ↓
 ┌────┼────────────┐
 ↓    ↓            ↓
Quest Codex    Progression
```

Avoid system chains like:

```dart
trainingSystem
  .questManager
  .codexManager
  .playerState
```

Systems should communicate through events and use cases.

---

# 14. Persistence

Use bundled structured data for static game content.

```text
JSON
↓
Game Content
```

Use a local database for player saves.

Recommended:

> **Drift / SQLite**

Store:

```text
PlayerProfile
UnlockedExercises
QuestProgress
Inventory
WorkoutHistory
Settings
DistrictProgress
Achievements
```

Architecture:

```text
Bundled JSON
    ↓
Static Game Content

Drift
    ↓
Local Save
```

Later:

```text
Local Save
    ↓
Sync Repository
    ↓
Cloud Backend
```

Do not build cloud sync during the first vertical slice unless the hackathon absolutely requires it.

---

# 15. Repository Layer

Domain and application code should not depend directly on Drift, Firebase, Supabase, or another storage provider.

Use interfaces.

```dart
abstract interface class PlayerRepository {
  Future<PlayerProfile> load();
  Future<void> save(PlayerProfile player);
}
```

Exercise repository:

```dart
abstract interface class ExerciseRepository {
  Future<Exercise> get(String id);
  Future<List<Exercise>> getAll();
}
```

Implementations:

```text
ExerciseRepository
       │
       └── JsonExerciseRepository

PlayerRepository
       │
       └── DriftPlayerRepository
```

Later:

```text
PlayerRepository
       │
       ├── DriftPlayerRepository
       └── CloudPlayerRepository
```

The game domain remains unchanged.

---

# 16. Backend Architecture — Later

The backend is not the game engine.

Server responsibilities:

```text
accounts
profiles
leaderboards
competition submissions
friend challenges
season data
cloud saves
remote configuration
```

Architecture:

```text
                     ┌──────────────┐
                     │   BACKEND    │
                     ├──────────────┤
                     │ Auth         │
                     │ Profiles     │
                     │ Leaderboards │
                     │ Events       │
                     │ Challenges   │
                     │ Cloud Saves  │
                     └───────▲──────┘
                             │
Flutter Game ── API ─────────┘
```

Keep ordinary single-player simulation client-side.

The backend becomes important where a shared source of truth matters, especially:

- leaderboards
- competitive scores
- seasonal events
- anti-cheat validation
- cloud save synchronization

---

# 17. RevenueCat Architecture

Do not call RevenueCat directly from random UI components.

Wrap it behind a service.

```dart
abstract interface class MonetizationService {
  Future<bool> hasPremium();
  Future<void> purchasePremium();
}
```

Implementation:

```text
MonetizationService
        ↓
RevenueCatMonetizationService
```

Platform-specific subscription details stay inside:

```text
infrastructure/
└── monetization/
```

The rest of the game only asks whether an entitlement exists.

---

# 18. Cross-Platform Input

Input must be abstracted from the beginning.

Avoid gameplay systems directly checking for:

```text
keyboard
touch
gamepad
```

Instead:

```dart
abstract class PlayerInput {
  Vector2 get movement;
  bool get interactPressed;
  bool get actionPressed;
}
```

Adapters:

```text
TouchInputAdapter
KeyboardInputAdapter
GamepadInputAdapter
```

All adapters produce the same game input.

```text
Mobile Joystick
      │
WASD ─┼──→ InputState → PlayerController
      │
Gamepad
```

This makes the same gameplay work across:

- Android
- iOS
- Web
- Windows
- macOS

---

# 19. Recommended Flutter Project Structure

```text
lib/
│
├── app/
│   ├── app.dart
│   ├── router.dart
│   ├── bootstrap.dart
│   └── theme/
│
├── game/
│   ├── game_host.dart
│   │
│   ├── runtime/
│   │   ├── game_runtime.dart
│   │   └── game_session.dart
│   │
│   ├── world/
│   │   ├── scene_manager.dart
│   │   ├── district_manager.dart
│   │   └── world_entity.dart
│   │
│   ├── player/
│   │   ├── player_controller.dart
│   │   ├── player_motor.dart
│   │   └── player_animation.dart
│   │
│   ├── camera/
│   │   └── iso_camera_controller.dart
│   │
│   ├── physics/
│   │   └── collision_system.dart
│   │
│   ├── input/
│   │   ├── input_state.dart
│   │   ├── touch_input.dart
│   │   └── keyboard_input.dart
│   │
│   └── interactions/
│       ├── interactable.dart
│       └── interaction_system.dart
│
├── domain/
│   ├── player/
│   ├── exercise/
│   ├── workout/
│   ├── health/
│   ├── quest/
│   ├── progression/
│   ├── codex/
│   └── competition/
│
├── features/
│   ├── hud/
│   ├── profile/
│   ├── codex/
│   ├── quests/
│   ├── map/
│   ├── body/
│   ├── competition/
│   ├── settings/
│   └── monetization/
│
├── application/
│   ├── use_cases/
│   │   ├── start_exercise.dart
│   │   ├── complete_exercise.dart
│   │   ├── hydrate.dart
│   │   ├── recover.dart
│   │   ├── discover_exercise.dart
│   │   └── travel.dart
│   │
│   └── events/
│
├── data/
│   ├── repositories/
│   ├── database/
│   ├── local/
│   └── content/
│
├── infrastructure/
│   ├── persistence/
│   ├── cloud/
│   ├── analytics/
│   ├── monetization/
│   └── audio/
│
└── shared/
    ├── widgets/
    ├── math/
    ├── errors/
    └── utils/
```

---

# 20. Chest-Day Vertical Slice Architecture

For the hackathon, reduce everything to this.

```text
                    IRON ASCENT MVP

 Flutter App
     │
     ▼
 GameScreen
     │
     ├── SceneView
     │      │
     │      ├── Gym GLB
     │      ├── Player GLB
     │      ├── Coach GLB
     │      └── Machines
     │
     └── HUD
            │
            ├── Hydration
            ├── Fatigue
            ├── Quest
            └── Interaction Prompt


 InputController
       ↓
 PlayerController
       ↓
 InteractionSystem
       ↓
 ExerciseStation
       ↓
 StartExercise
       ↓
 TrainingSystem
       ↓
 ┌─────┼──────────┬───────────┐
 ↓     ↓          ↓           ↓
Fatigue XP       Quest       Codex
 ↓
Player State
 ↓
SaveRepository
```

That is enough to prove the architecture.

---

# 21. MVP Runtime Requirements

The first playable technical slice only needs:

```text
Flutter shell
↓
GameScreen
↓
Scene rendering
↓
Player movement
↓
Camera
↓
Collision
↓
Object interaction
↓
Exercise station
↓
Training result
↓
Fatigue update
↓
Quest update
↓
Codex unlock
↓
Local save
```

Do not build:

- multiplayer netcode
- procedural generation
- huge open world
- sophisticated character creator
- advanced cloud architecture
- hundreds of exercises
- giant design system
- over-engineered ECS

until this works.

---

# 22. Final Architecture Rule

Think of IRON ASCENT as three separate machines.

```text
      PRESENTATION
 Flutter / HUD / menus
          │
          ▼
       SIMULATION
 fitness / quests / progression
          ▲
          │
        RUNTIME
 world / player / physics / input
```

Underneath all three:

```text
DATA + INFRASTRUCTURE
```

Responsibilities:

### Runtime

> “The player interacted with `incline_station_01`.”

### Domain

> “That station represents the Incline Dumbbell Press. Apply its fatigue cost, unlock its Codex entry, evaluate quest objectives, and calculate progression.”

### Presentation

> “NEW EXERCISE DISCOVERED — Incline Dumbbell Press.”

This separation allows IRON ASCENT to grow from one chest-day gym room into the full Iron Map without forcing a rewrite of the application.

---

# 23. Technical North Star

Every implementation decision should preserve this flow:

```text
Player Input
    ↓
Game Runtime
    ↓
Interaction / Action
    ↓
Application Use Case
    ↓
Domain Simulation
    ↓
Domain Event
    ↓
Persistent State
    ↓
Flutter UI
```

If the game reaches the point where UI widgets directly modify fitness rules, rendering code directly owns progression, or backend services are mixed into gameplay logic, the architecture is drifting in the wrong direction.

The goal is:

> **A small game engine, a strong pure-Dart fitness simulation, and a Flutter product layer wrapped around both.**
