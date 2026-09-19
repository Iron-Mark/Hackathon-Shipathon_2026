# IRON ASCENT
## Cross-Platform Low-Poly Fitness RPG — Product & Game Plan

> **Working tagline:** Grind your body into its best version.
>
> **Core pitch:** IRON ASCENT is a cross-platform low-poly fitness RPG where players explore an interactive world, learn how training, nutrition, recovery, and conditioning work, build their own fitness identity, and compete across bodybuilding, strength, cardio, mobility, and hybrid disciplines.

---

## 1. Product Vision

IRON ASCENT is **not a fitness tracker with game skins** and it is **not a gym simulator where clicking “Chest Day” gives +10 muscle**.

The product is an explorable fitness RPG where:

- the **environment is interactive**
- fitness education is taught through **playable situations**
- exercises are discovered through equipment and locations
- training decisions create visible consequences
- players develop different physical archetypes
- progress depends on **training + nutrition + recovery + consistency**
- healthy progress beats reckless progress
- players can compete asynchronously across multiple fitness disciplines
- the game can later bridge into real-world workout planning and logging

The intended emotional fantasy is:

> **Start untrained. Learn how the body works. Build intelligently. Become the strongest version of your character — and eventually yourself.**

---

# 2. Why It Exists

Most fitness products fall into one of four buckets:

1. **Workout trackers**
2. **Exercise libraries**
3. **Coaching apps**
4. **Fitness-themed games**

IRON ASCENT combines education and gameplay differently.

Instead of:

> “Here are 10 chest exercises.”

The player enters the **Hypertrophy District**, walks through a gym, examines different pieces of equipment, learns what they are for, uses them, discovers overlapping movement patterns, and eventually completes:

> **Quest: Build a Chest Session**

The player learns by **interacting, experimenting, failing, recovering, and improving**.

The intended learning loop is:

**Discover → Try → Understand → Apply → Experience consequences → Improve**

---

# 3. Health & Well-Being Category Fit

The health component is not secondary.

The core game directly teaches and rewards:

- sustainable physical activity
- exercise technique
- training organization
- fatigue management
- recovery
- hydration
- nutrition literacy
- mobility
- cardiovascular conditioning
- injury-risk awareness
- sleep habits
- consistency
- stress management
- misinformation recognition

## Primary design principle

> **Optimal progress beats reckless progress.**

A player who blindly trains harder should not automatically win.

Poor decisions can produce:

- accumulated fatigue
- reduced performance
- higher injury risk
- stalled progression
- lower recovery
- decreased competition performance

Good decisions can produce:

- better long-term performance
- sustainable physique development
- improved recovery
- improved technique
- greater versatility

### Safety positioning

IRON ASCENT should be positioned as:

- fitness education
- healthy-habit learning
- fitness literacy
- general wellness entertainment

It should **not** diagnose medical conditions or replace professional medical, nutritional, or rehabilitation advice.

Any future real-world training recommendations should include sensible limitations and encourage professional evaluation for pain, injury, medical conditions, or symptoms outside normal exercise discomfort.

---

# 4. Platform Strategy

## Technology

**Flutter-first, cross-platform.**

Target order:

1. **Android / iOS**
2. **Web**
3. **Windows / macOS**
4. Other platforms later if viable

### Recommended technical split

#### Flutter
Use Flutter for:

- onboarding
- HUD overlays
- menus
- player profile
- map
- inventory
- quest log
- Codex
- leaderboards
- store
- RevenueCat
- account / cloud UI
- accessibility settings
- settings

#### 3D World
Preferred direction:

**Low-poly 3D rendered in compact isometric / elevated third-person scenes.**

Candidate implementation:

- `flutter_scene` for low-poly 3D scenes
- GLB / glTF assets created in Blender
- small self-contained diorama environments
- Flutter widgets layered over the 3D scene

Alternative fallback:

- Flame / 2D isometric if 3D becomes too risky for the hackathon

### Critical rule

Do **not** attempt an open-world engine.

IRON ASCENT should be built from **small connected districts / rooms / dioramas**.

That gives:

- lower rendering complexity
- faster asset creation
- simpler collision
- easier mobile optimization
- easier cross-platform testing
- more intentional scene composition

---

# 5. Art Direction

## Core aesthetic

**Low-poly industrial grit + hopeful rebuilding.**

Take inspiration from the atmosphere of post-apocalyptic survival games without making the world hopeless.

The world should feel:

- rough
- lived-in
- industrial
- determined
- weathered
- community-driven
- aspirational underneath the grit

## Avoid

- cheerful generic mobile-game gym
- neon cyberpunk overload
- medieval RPG fantasy
- photorealistic bodybuilding
- pure zombie-horror misery
- direct imitation of Project Zomboid assets or UI

## Visual vocabulary

### Materials

- concrete
- steel
- rubber flooring
- reclaimed wood
- worn gym equipment
- old-school iron plates
- chalk
- faded posters
- chain-link barriers
- training banners
- patched-up lighting

### Lighting

- dusty shafts of daylight
- warm indoor lamps
- stronger daylight in active districts
- darker industrial corners
- subtle neon only for wayfinding / competitions

### Character style

- stylized low-poly proportions
- recognizable silhouettes
- readable muscle development
- clothing customization
- body progression visible without becoming anatomically extreme

---

# 6. World Concept

## The Iron Map

The world is organized into districts representing different areas of fitness.

Players can specialize while still benefiting from balanced development.

---

## 6.1 Home Base / Iron Shelter

The player's personal hub.

### Purpose

- sleep
- recovery
- inventory
- body-condition overview
- wardrobe / appearance
- food storage
- workout planning
- trophy display
- quest tracking

### Interactive objects

- bed
- mirror
- water station
- food storage
- med kit
- training notebook
- stash box
- mobility mat
- basic rack
- world map
- radio / community terminal

---

## 6.2 Hypertrophy District

Focus:

**Bodybuilding / muscle development**

### Environment

A reclaimed bodybuilding gym with:

- dumbbell racks
- incline benches
- flat benches
- cable stations
- pec deck
- chest press
- pulldown
- row stations
- hack squat
- leg press
- posing room

### Concepts taught

- exercise selection
- movement patterns
- hypertrophy-oriented training
- exercise overlap
- technique
- volume
- fatigue
- progression
- exercise substitution
- muscle-group balance

### Competition

**Physique League**

Possible scoring dimensions:

- muscular development
- balance
- symmetry
- conditioning
- posing

---

## 6.3 Strength Yard

Focus:

**Raw strength and technical lifting**

### Environment

Industrial warehouse-style training yard.

Equipment:

- squat racks
- bench stations
- deadlift platforms
- calibrated plates
- chalk station
- lifting belts
- specialty bars

### Concepts taught

- progressive overload
- load management
- lower-rep training
- technique
- warm-up progression
- rest periods
- fatigue
- strength-specific programming

### Competition

**Strength League**

Events:

- squat
- bench
- deadlift
- total
- rep challenges

---

## 6.4 Cardio Run

Focus:

**Endurance and cardiovascular conditioning**

### Environment

Mixed indoor/outdoor district.

Objects:

- running track
- treadmills
- rowing machines
- bikes
- stairs
- interval timers
- recovery checkpoints

### Concepts taught

- pacing
- intervals
- endurance
- sprint work
- recovery
- work-to-rest ratios
- conditioning without automatically framing cardio as “muscle loss”

### Competition

**Endurance League**

Events:

- timed run
- interval survival
- distance score
- rowing challenge
- hybrid conditioning course

---

## 6.5 Mobility Temple

Focus:

**Movement quality, mobility, balance, and prevention**

### Interactive stations

- stretching areas
- balance platforms
- mobility flows
- range-of-motion challenges
- bodyweight movement stations

### Concepts

- mobility
- stability
- balance
- controlled movement
- warm-ups
- exercise readiness
- movement alternatives

---

## 6.6 Recovery House

Focus:

**Recovery and sustainability**

### Interactive objects

- sleep station
- mobility mat
- breathing station
- hydration station
- recovery lounge
- deload planning board
- stress-management challenges

### Concepts

- sleep
- fatigue
- rest
- deloading
- stress
- recovery habits
- pain awareness
- sustainable progression

---

## 6.7 Macro Market

Focus:

**Nutrition literacy**

### World interactions

- food stalls
- meal combinations
- hydration vendors
- supplement shop
- grocery challenges

### Concepts

- protein
- carbohydrates
- dietary fat
- hydration
- food quality
- energy balance
- practical meal composition
- supplement literacy
- avoiding misleading claims

The game should avoid oversimplifying food into:

> good food vs bad food

Instead teach:

> goals, context, quantity, composition, consistency.

---

## 6.8 Arena

The multiplayer / competitive hub.

### Leagues

- Physique League
- Strength League
- Endurance League
- Hybrid League
- Wellness League

### Activities

- seasonal competitions
- friend challenges
- personal-best boards
- ghost scores
- event rankings
- build showcases

---

# 7. Core Gameplay Loop

## Main loop

1. Spawn at home base
2. Review current body condition
3. Select destination
4. Travel to a district
5. Explore the environment
6. Interact with equipment / NPCs / objects
7. Learn or practice a fitness concept
8. Perform a gameplay challenge
9. Gain XP / knowledge / physical progression
10. Accumulate fatigue and resource costs
11. Recover / eat / hydrate
12. Enter competitions or complete quests
13. Improve character build
14. Repeat

The important point:

> **The player should spend meaningful time controlling a character in the world, not living inside menus.**

---

# 8. Environmental Interaction System

## Design rule

> **Menus explain the world. Objects create the gameplay.**

Important actions should begin with physical interaction.

### Example

The player approaches a bench.

Prompt:

```text
BENCH PRESS STATION

[E] Inspect
[Hold E] Train
```

Inspecting shows:

- movement category
- muscles involved
- current knowledge
- unlocked variations
- technique notes

Training launches the gameplay interaction.

---

## Safehouse objects

| Object | Interaction |
|---|---|
| Bed | Sleep / Nap |
| Mirror | Check physique / body condition |
| Water Station | Drink / refill |
| Food Storage | Eat / prep |
| Med Kit | Minor care / injury status |
| Notebook | Quests / body log |
| Stash | Inventory |
| Mat | Mobility / breathing |
| Rack | Basic strength session |
| Map | Travel |

---

# 9. Exercise Discovery System

Exercises should be **discovered**, not dumped into a giant list on day one.

The player unlocks an exercise by:

- finding equipment
- inspecting equipment
- learning from coaches
- completing quests
- visiting new districts
- completing movement lessons

Example:

```text
NEW EXERCISE DISCOVERED

Incline Dumbbell Press

Category: Press
Primary: Chest
Emphasis: Upper chest
Secondary: Triceps / anterior delts
```

This feeds into the **Iron Codex**.

---

# 10. Iron Codex

The Codex is the player's fitness encyclopedia and collection system.

Think:

**Pokédex for training knowledge.**

### Example structure

```text
CHEST
├── Pressing
│   ├── Flat Bench Press
│   ├── Incline Dumbbell Press
│   └── Machine Chest Press
│
├── Isolation
│   ├── Cable Fly
│   └── Pec Deck
│
└── Bodyweight
    ├── Push-Up
    └── Dip
```

### Each exercise entry can include

- muscles involved
- movement type
- equipment
- setup
- execution cues
- common mistakes
- substitutions
- when it may be useful
- progression options
- discovered variants

### Collection hook

```text
Exercises Discovered
42 / 120
```

This creates progression even for players more interested in learning than competition.

---

# 11. Fitness Education as Gameplay

## Bad implementation

```text
What trains chest?

A. Bench press
B. Curl
C. Calf raise
```

That is just trivia.

## Better implementation

The player receives:

> **Quest: Build a Chest Session**

They explore the gym.

Possible available exercises:

- bench press
- incline dumbbell press
- machine press
- dips
- cable fly
- pec deck
- push-ups

The player creates a session.

If they choose seven overlapping movements, the game explains:

> You selected several movements that serve similar roles. More exercises do not automatically mean better training.

The player revises the program.

A stronger session might become:

- incline dumbbell press
- chest press
- cable fly

The game then explains the structure.

### Learning outcome

The player learns:

- movement categories
- redundancy
- selection
- fatigue
- exercise roles

without answering a quiz.

---

# 12. Workout-Day Quest Design

Training days become playable learning quests.

---

## Chest Day

Possible concepts:

- pressing vs fly movements
- flat vs inclined pressing
- exercise overlap
- technique
- fatigue
- progressive overload

Possible stations:

- flat bench
- incline bench
- machine press
- cable fly
- pec deck
- push-up zone

---

## Back Day

Concepts:

- horizontal pulling
- vertical pulling
- movement variety
- grip variations
- fatigue and technique

Stations:

- pull-up station
- pulldown
- cable row
- chest-supported row
- dumbbell row

---

## Leg Day

Concepts:

- knee-dominant movement
- hip-dominant movement
- knee flexion
- calves
- load management

Stations:

- squat rack
- hack squat
- leg press
- leg extension
- leg curl
- Romanian deadlift
- calf station

---

## Shoulder / Arms

Teach:

- pressing
- lateral raise patterns
- curls
- triceps extension / pressing
- overlap from compound movements
- realistic volume

---

# 13. Exercise Substitution Mechanic

This can become one of the most educational systems.

Example:

The player approaches the bench.

Status:

```text
Shoulder discomfort: Mild
Fatigue: Moderate
```

Instead of saying:

> “Chest day unavailable.”

The quest becomes:

> **Find a chest movement that accomplishes a similar goal while fitting your current condition.**

The player explores and finds:

### Machine Chest Press

The game explains:

- stable setup
- similar pressing pattern
- reduced stabilization demand

The lesson becomes:

> **Fitness knowledge includes knowing alternatives, not blindly following a fixed program.**

---

# 14. Training Gameplay

Each exercise should have a **small gameplay interaction**, not a full biomechanics simulator.

The goal is:

- tactile enough to feel like play
- simple enough for mobile
- educational enough to reinforce technique

---

## Possible Bench Press Mini-System

Player interactions:

1. Load the bar
2. Choose working weight
3. Position character
4. Perform reps using timing / rhythm input
5. Maintain control
6. Stop before technique collapses

Performance influenced by:

- Strength
- Technique
- Fatigue
- Sleep
- Hydration
- Injury status

Possible outcomes:

- clean reps
- grind
- technical breakdown
- failed rep
- excessive fatigue

---

## Cardio gameplay

Possible systems:

- rhythm / pacing
- interval timing
- route decisions
- stamina conservation

---

## Mobility gameplay

Possible systems:

- controlled pointer / joystick movement
- balance zones
- sequence memory
- timing

---

# 15. Character Development

## Core attributes

### Performance

- Muscle
- Strength
- Endurance
- Mobility
- Technique

### Health / readiness

- Recovery
- Hydration
- Sleep
- Stress
- Fatigue
- Injury Risk

### Knowledge

- Training Knowledge
- Nutrition Knowledge
- Recovery Knowledge

### Meta

- Discipline
- XP
- Level

---

# 16. Character Archetypes

Players should naturally become different types of athletes.

---

## Bodybuilder

High:

- Muscle
- hypertrophy knowledge
- posing
- physique score

Potential weakness if neglected:

- endurance

---

## Strength Athlete

High:

- Strength
- technique
- heavy-load performance

Potential cost:

- high fatigue demand

---

## Endurance Athlete

High:

- stamina
- conditioning
- recovery between efforts

Potential risk:

- reduced muscle progression if poorly fueled

---

## Hybrid Athlete

Balanced:

- Strength
- Endurance
- Muscle

Benefit:

- versatility

---

## Balanced / Wellness Build

High:

- recovery
- consistency
- mobility
- sustainable performance

Ideal for health-focused progression.

---

# 17. Visual Body Progression

The player's appearance should evolve gradually.

Avoid instant transformation.

Possible stages:

1. Untrained
2. Beginner
3. Trained
4. Athletic
5. Muscular
6. Specialized

The final silhouette depends on specialization.

### Important

Transformation should reflect:

- time
- training
- recovery
- nutrition
- specialization

not simply XP.

---

# 18. Coaches and NPCs

NPCs should teach systems, not just deliver fetch quests.

---

## Hypertrophy Coach

Teaches:

- movement patterns
- exercise selection
- volume
- progression

---

## Strength Coach

Teaches:

- loading
- technique
- progressive overload
- recovery between heavy sessions

---

## Conditioning Coach

Teaches:

- pacing
- intervals
- aerobic conditioning

---

## Recovery Specialist

Teaches:

- fatigue
- sleep
- deloading
- stress
- pain awareness

---

## Nutrition NPC

Teaches:

- meal composition
- protein
- energy balance
- hydration
- supplement literacy

---

# 19. Misinformation NPCs

Fitness misinformation becomes an entertaining recurring world mechanic.

## Example: Bro Scientist

Possible statements:

> “If you're not sore, the workout didn't work.”

> “Cardio kills gains.”

> “You need fourteen exercises on chest day.”

> “Rest days are weakness.”

> “More supplements = more muscle.”

The player does not defeat these characters with swords.

They defeat misinformation by:

- completing training experiments
- building better sessions
- demonstrating knowledge
- producing better outcomes

This keeps the educational content memorable.

---

# 20. Real-World Bridge

Long term, the strongest product evolution is:

## Game World

Learn fitness principles.

## Real World

Apply them.

After completing a chest programming quest:

```text
CHEST SESSION UNLOCKED

Incline Dumbbell Press
3 working sets

Machine Chest Press
3 working sets

Cable Fly
2–3 working sets
```

Possible CTA:

> **Try this session in real life**

Future capabilities:

- workout logging
- personal bests
- real workout plans
- progression history
- Apple Health / Health Connect integration
- exercise reminders
- wearable integration

This should **not be required for the initial game**.

---

# 21. Competition System

Start asynchronous.

Do not build real-time multiplayer first.

## Why

Async competition gives:

- social proof
- replayability
- low infrastructure complexity
- cross-platform compatibility
- fairer hackathon scope

---

## Physique League

Potential dimensions:

- development
- symmetry
- conditioning
- posing

---

## Strength League

Events:

- squat
- bench
- deadlift
- total

---

## Endurance League

Events:

- time trial
- distance
- interval performance
- rowing
- cycling

---

## Hybrid League

Combines:

- strength
- endurance
- body development

---

## Wellness League

Rewards:

- consistency
- recovery
- sustainable training
- injury avoidance
- balanced development

This reinforces the health mission.

---

# 22. Social Systems

Phase 1:

- player profiles
- friend leaderboard
- event rankings
- personal-best sharing
- challenge links
- physique/build showcase

Later:

- gyms / clubs
- teams
- seasonal factions
- cooperative challenges
- live events

Do not make the product dependent on having friends online.

Core loop must work solo.

---

# 23. Retention

## Daily

- body condition changes
- daily challenge
- limited training opportunities
- recovery decisions
- quests

## Weekly

- programming objectives
- competition
- physique / stat update
- Codex discoveries

## Seasonal

- leagues
- rankings
- themed district events
- cosmetic rewards

## Long-term

- specialization
- body development
- Codex completion
- district mastery
- competitive ranking

---

# 24. Monetization

RevenueCat should support monetization without making the health experience predatory.

## Free

- core world
- starter districts
- daily progression
- basic competitions
- core education

## Premium possibilities

- additional districts
- cosmetic character packs
- additional storylines
- advanced programming quests
- advanced statistics
- more competition formats
- expanded real-world workout tools

## Rewarded ads

Use sparingly.

Possible safe use:

- optional cosmetic reward
- additional non-critical side quest
- bonus replay token
- event reroll

Avoid:

> Watch an ad to recover from an injury.

That would undermine the health message.

---

# 25. UI / UX

The environment should remain visible whenever possible.

## HUD

Keep only essentials on-screen:

- hydration
- fatigue
- stress / injury warning
- quick items
- active objective
- contextual interaction prompt

## Menus

Dedicated screens:

- Map
- Body
- Inventory
- Codex
- Quests
- Competitions
- Profile

---

# 26. Core Screens

## Gameplay

- World Scene
- Interaction Prompt
- Training Minigame
- Competition Scene

## Progression

- Body Overview
- Character Profile
- Stats
- Iron Codex
- Quest Log

## World

- Iron Map
- District Overview
- Travel

## Social

- Arena
- Leaderboard
- Friend Challenge

## Product

- Settings
- Accessibility
- RevenueCat Store
- Account

---

# 27. MVP — Vertical Slice

Do not attempt the full vision.

The MVP must prove:

1. exploration
2. object interaction
3. fitness education
4. training gameplay
5. body-condition consequences
6. progression

---

## MVP World

### Area 1 — Home Base

Interactables:

- bed
- water
- mirror
- food
- map

### Area 2 — Hypertrophy Gym

Interactables:

- incline press
- machine press
- cable fly
- chest press
- coach NPC

### Area 3 — Recovery Corner

Interactables:

- mat
- water
- recovery NPC

---

# 28. MVP Quest

## Quest: Build Your First Chest Day

### Phase 1

Enter gym.

Coach says:

> “Don't collect exercises. Build a session.”

### Phase 2

Player explores equipment.

Discovers:

- Incline Dumbbell Press
- Machine Chest Press
- Cable Fly
- Pec Deck
- Push-Up

### Phase 3

Player trains / inspects equipment.

Learns:

- pressing
- isolation
- overlap

### Phase 4

Player assembles three movements.

### Phase 5

Game evaluates structure.

### Phase 6

Player performs one simplified set.

### Phase 7

Fatigue increases.

### Phase 8

Player returns to Recovery Corner.

### Phase 9

Recover.

### Outcome

Unlock:

**Chest Programming I**

Codex progression:

```text
5 / 120 Exercises Discovered
```

---

# 29. Hackathon Scope

For the event, build **one polished playable vertical slice**.

## Must Have

- Flutter project launches cross-platform
- one low-poly gym room
- controllable character
- isometric camera
- collision
- contextual object interaction
- three gym objects
- one coach NPC
- hydration / fatigue stats
- one short training minigame
- one quest
- one Codex unlock
- one RevenueCat integration

## Nice to Have

- body model changes slightly
- leaderboard mock / backend
- home base
- recovery station
- sound
- polish

## Do Not Build

- open world
- real-time multiplayer
- 100 exercises
- full nutrition engine
- live wearable integration
- complicated combat
- advanced avatar customization
- full city map

---

# 30. Hackathon Demo Flow

Target: **60–90 seconds.**

### Demo

1. Spawn in the gym.
2. Walk toward incline press.
3. Inspect it.
4. Unlock exercise information.
5. Train a short set.
6. Fatigue increases.
7. Walk to cable station.
8. Coach warns about exercise overlap.
9. Complete the Chest Day quest.
10. Unlock Codex entry.
11. Show map with future districts.
12. Show competition board.
13. Show RevenueCat premium / progression possibility.

### Final line

> **“Instead of telling players how to train, IRON ASCENT lets them learn fitness by living inside it.”**

---

# 31. Asset Prep

Prepare before coding whenever possible.

## Player

- low-poly base character
- idle
- walk
- interact
- training pose
- simple flex / victory pose

## Gym

- rack
- bench
- dumbbells
- cable machine
- chest press
- floor mat
- mirror
- water bottle / fountain

## Environment

- concrete walls
- rubber floor
- lockers
- posters
- lights
- crates
- doorway
- district signage

## NPC

- Hypertrophy Coach
- Bro Scientist

## UI Icons

- Muscle
- Strength
- Endurance
- Recovery
- Hydration
- Sleep
- Stress
- Fatigue
- Injury

---

# 32. 3D Asset Standards

Recommended:

- GLB / glTF
- low polygon count
- shared texture atlases
- limited materials
- baked lighting where useful
- simple skeletons
- minimal animation bones
- optimized mobile textures

### Scene rule

Each district should be:

> **small, dense, interactive, recognizable**

rather than huge and empty.

---

# 33. Suggested Project Structure

```text
lib/
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme/
│
├── game/
│   ├── world/
│   ├── scenes/
│   ├── player/
│   ├── camera/
│   ├── interactions/
│   ├── objects/
│   ├── npcs/
│   └── minigames/
│
├── features/
│   ├── body/
│   ├── codex/
│   ├── inventory/
│   ├── quests/
│   ├── map/
│   ├── competition/
│   ├── profile/
│   └── monetization/
│
├── domain/
│   ├── exercise/
│   ├── player_stats/
│   ├── health_state/
│   ├── progression/
│   └── competition/
│
├── data/
│   ├── exercises/
│   ├── quests/
│   ├── items/
│   └── districts/
│
└── shared/
    ├── widgets/
    ├── audio/
    ├── persistence/
    └── utils/
```

---

# 34. Example Exercise Data

```json
{
  "id": "incline_dumbbell_press",
  "name": "Incline Dumbbell Press",
  "category": "hypertrophy",
  "movement": "horizontal_press",
  "primaryMuscles": ["chest"],
  "secondaryMuscles": ["triceps", "front_delts"],
  "emphasis": ["upper_chest"],
  "equipment": ["incline_bench", "dumbbells"],
  "knowledgeLevel": 1,
  "fatigueCost": 12,
  "techniqueDifficulty": 2,
  "codexUnlock": true
}
```

---

# 35. Example Player State

```json
{
  "level": 3,
  "xp": 420,

  "performance": {
    "muscle": 12,
    "strength": 14,
    "endurance": 9,
    "mobility": 8,
    "technique": 11
  },

  "condition": {
    "hydration": 72,
    "sleep": 63,
    "fatigue": 32,
    "stress": 18,
    "injuryRisk": 4
  },

  "knowledge": {
    "hypertrophy": 2,
    "strength": 1,
    "conditioning": 0,
    "nutrition": 1,
    "recovery": 1
  }
}
```

---

# 36. Example Quest Data

```json
{
  "id": "build_first_chest_day",
  "title": "Build Your First Chest Day",
  "district": "hypertrophy",
  "objectives": [
    "Discover 3 chest exercises",
    "Include at least 1 pressing movement",
    "Include at least 1 isolation movement",
    "Avoid excessive overlap",
    "Complete 1 working set"
  ],
  "reward": {
    "xp": 150,
    "knowledge": {
      "hypertrophy": 1
    },
    "codex": [
      "chest_programming_1"
    ]
  }
}
```

---

# 37. Backend / Cloud — Later

The first prototype does not need heavy backend infrastructure.

Possible later architecture:

- Firebase / Supabase / Appwrite for user data
- cloud profile sync
- leaderboards
- challenge sharing
- remote content configuration
- analytics
- RevenueCat entitlements

Keep the game simulation itself deterministic and primarily client-side where reasonable.

---

# 38. Content Validation

Because the product teaches health and fitness:

- source exercise information carefully
- avoid medical diagnosis
- separate general fitness education from individualized medical advice
- review claims around supplements
- avoid absolutist claims
- do not teach unsafe extreme dieting
- do not reward dehydration, overtraining, or injury
- provide alternatives rather than shame

Long term, content should be reviewed with qualified fitness / healthcare professionals where appropriate.

---

# 39. Accessibility

A health product should not ignore accessibility.

Plan for:

- scalable UI
- captions
- color-independent status indicators
- remappable controls
- reduced motion
- high contrast
- simplified interactions
- alternatives to timing-heavy minigames
- keyboard / controller support on desktop
- touch controls on mobile

---

# 40. Product Principles

### 1. The world teaches.

Don't hide all education inside articles.

### 2. Objects create gameplay.

A gym should be something you explore.

### 3. Health is a system.

Not a badge.

### 4. Better knowledge creates better outcomes.

Learning is progression.

### 5. Recklessness has consequences.

Grinding harder is not always better.

### 6. Solo first.

Social makes the game better but should never be required.

### 7. Competition is broad.

Bodybuilding is only one valid path.

### 8. Cross-platform from the start.

Mobile first, but don't design a UI that only works on phones.

### 9. Small worlds, dense interactions.

Avoid giant empty maps.

### 10. Build the framework, then expand the world.

---

# 41. Development Phases

## Phase 0 — Concept / Assets

- finalize title
- establish visual language
- player model
- one coach
- gym environment
- interaction icons
- exercise data structure
- chest quest content

---

## Phase 1 — Hackathon Vertical Slice

- movement
- camera
- collision
- object interaction
- chest equipment
- coach
- player condition
- training minigame
- Codex unlock
- RevenueCat integration

Goal:

> One complete playable learning loop.

---

## Phase 2 — Core Game

Add:

- home base
- map
- Strength Yard
- Recovery House
- more exercises
- inventory
- progression
- character body variants

---

## Phase 3 — Competition

Add:

- asynchronous leaderboard
- events
- friend challenges
- profiles
- seasonal ranking

---

## Phase 4 — Fitness World

Add:

- Cardio Run
- Mobility Temple
- Macro Market
- larger Codex
- deeper programming quests
- more NPCs

---

## Phase 5 — Real-World Bridge

Add:

- workout builder
- workout logging
- personal records
- optional health-platform integrations
- personalized planning

---

# 42. Success Criteria for the Prototype

The prototype succeeds if a new player can understand within a few minutes that:

1. This is a real RPG world, not a static fitness app.
2. Gym equipment is physically interactable.
3. The player learns something useful about training.
4. Training affects fatigue / condition.
5. Recovery matters.
6. Knowledge unlocks progression.
7. Different fitness paths will exist.
8. Competition is possible.
9. The visual identity feels distinctive.
10. The player wants to see what their character becomes.

---

# 43. Final Product Statement

> **IRON ASCENT is an explorable low-poly fitness RPG where training knowledge becomes progression. Players interact with real gym equipment, learn how to build workouts, manage nutrition and recovery, specialize across bodybuilding, strength, cardio, mobility, and hybrid fitness, and compete to forge the best version of their character.**

### Short version

> **Learn fitness by playing it.**

### World fantasy

> **Build the body. Master the system. Climb the Iron Map.**

---

# 44. Immediate Next Actions

Do these in order.

## Main Quest

### Build one playable chest-day vertical slice.

Required:

1. Player model
2. Gym room
3. Character movement
4. Incline press
5. Machine press
6. Cable fly
7. Coach NPC
8. Hydration + fatigue
9. Chest quest
10. One training interaction
11. Codex unlock
12. RevenueCat

## Support Quest 1

Create the **visual asset kit**.

- player
- coach
- gym
- three machines
- HUD
- interaction prompt
- icons

## Support Quest 2

Create the **content data**.

- five chest exercises
- one quest
- exercise metadata
- three educational lessons
- player starting stats

Everything else waits.

---

# 45. What Not to Do Yet

Do not burn time on:

- perfect logo
- giant Figma system
- 50 character outfits
- huge city map
- multiplayer netcode
- complicated backend
- 100 exercise entries
- elaborate nutrition simulation
- realistic muscle deformation
- procedural generation

If the player cannot walk to an incline bench, interact with it, learn something, perform a training action, gain fatigue, and unlock knowledge, the core product does not exist yet.

---

# 46. North Star

The entire project should repeatedly answer one question:

> **Does this mechanic help the player understand, practice, or experience fitness better?**

If not, it probably does not belong in the core game.

The winning experience is not:

> “I clicked enough times and my character became jacked.”

It is:

> **“I understand why my character improved — and I learned something I can use outside the game.”**
