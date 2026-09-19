# IRON ASCENT

Learn fitness by playing it. A Flutter low-poly 3D fitness RPG vertical slice:
**Build Your First Chest Day**.

The six documents in `docs/` are the implementation contract. Gameplay rules
live in pure Dart (`lib/domain`), frame state lives in the game runtime
(`lib/game`), and Flutter only presents (`lib/features`).

## MVP progress

- [x] Inspect specifications and publish original source
- [x] Flutter bootstrap (routing, theme, flutter_scene asset hook)
- [x] Structured content (exercises, quest, district, coach, knowledge) + parsing/validation tests
- [x] Domain rules: discovery, Codex, session validation, training formulas, quest engine, recovery, XP/levels
- [x] Local-first save with schemaVersion, New Game / Continue / Reset
- [x] Generated original low-poly model kit (`tool/assets/generate_models.dart`) and audio cues (`tool/assets/generate_audio.dart`)
- [x] 3D Hypertrophy Gym: player, coach, three stations, water station, recovery mat, signage, lighting, shadows
- [x] Movement (WASD / arrows / virtual joystick), follow camera, collision, one contextual interaction prompt
- [x] Coach dialogue, exercise inspection + discovery, Session Builder, five-rep training minigame, condition changes, recovery, idempotent quest completion
- [x] Product surfaces: main menu, HUD, Quest Log, Codex, Session Builder, Iron Map preview, Arena preview, Settings, Supporter (RevenueCat adapter, safe when unconfigured)
- [x] Accessibility: keyboard navigation, touch controls, scalable text, reduced motion (slower training window), labelled status
- [x] Unit + widget tests; manual end-to-end pass on web (expanded and compact layouts) including restart → Continue

## Development

Flutter **3.47.2** (stable). Web needs no flags; native platforms use Flutter
GPU (enabled in the Android manifest and iOS/macOS `Info.plist`; pass
`--enable-flutter-gpu` when running on desktop).

```sh
flutter pub get
dart run tool/assets/generate_models.dart   # regenerate assets/models/*.glb
dart run tool/assets/generate_audio.dart    # regenerate assets/audio/*.wav
dart format .
flutter analyze
flutter test
flutter run -d chrome                        # or: flutter run --enable-flutter-gpu
```

Optional store configuration (never committed):

```sh
flutter run --dart-define=REVENUECAT_API_KEY=<public sdk key> \
            --dart-define=REVENUECAT_ENTITLEMENT=supporter
```

Without a key the Supporter screen reports "Store unavailable" and the game
stays fully playable.

## Deployment

Production: https://iron-ascent-three.vercel.app (Vercel project `iron-ascent`,
Git-linked to `main`; `vercel.json` + `tool/vercel_build.sh` install Flutter and
publish `build/web`).

## Embedding in FlutterFlow (or any host app)

The 3D runtime depends on `flutter_scene` (build hook, Flutter GPU flags,
Flutter 3.47+), which FlutterFlow custom code cannot host, so integrate the
deployed web build through a WebView:

1. Add a **WebView** widget (full page, JavaScript enabled) with URL
   `https://iron-ascent-three.vercel.app/?embed=1`.
2. `?embed=1` skips the title screen: it continues the device's save or starts
   a new game, and the pause menu shows **EXIT GAME** instead of Return to
   Title.
3. Optional: register a JavaScript channel named `IronAscent` on the WebView
   (or listen for `message` events on an iframe host). The game posts JSON
   strings `{"source":"iron-ascent","type":...}` with types `ready`,
   `progress` (`level`, `xp`), `quest_complete` (`questId`) and `exit`, so the
   host can close the game view or reflect progress.
4. Recommended: landscape or full-screen page, WebGL2-capable device (any
   modern phone), hardware acceleration left on.

### FlutterFlow MCP (build the FlutterFlow shell from Cursor)

The repo is pre-wired for FlutterFlow's official MCP server
(`flutterflow_cli` → `flutterflow ai mcp`), declared in `.cursor/mcp.json` as
`flutterflow_ai`. One-time setup needs your FlutterFlow API key
(FlutterFlow → Account → API Token; requires a plan with API access):

```sh
FF_API_KEY=<key> FF_PROJECT_ID=<existing project id, optional> bash tool/flutterflow_setup.sh
```

This installs the CLI and creates the git-ignored `flutterflow_workspace/`
bound to your project (or a new app). Then reload MCP servers in Cursor,
approve `flutterflow_ai`, and drive the FlutterFlow project from chat, e.g.:

> Create a page `IronAscentGame` with a full-screen WebView (JavaScript
> enabled) loading `https://iron-ascent-three.vercel.app/?embed=1`, a
> JavaScript channel `IronAscent`, and navigate back when a message with
> `"type":"exit"` arrives.

Useful CLI checks from inside `flutterflow_workspace/`: `flutterflow ai status
<project-id>`, `flutterflow ai doctor`, `flutterflow ai context-check`.

## Layout

```text
assets/data/        structured content (exercises, quest, district, npc, knowledge)
assets/models/      generated GLB kit (converted to .fsceneb by hook/build.dart)
assets/audio/       generated WAV cues
lib/domain/         pure Dart rules, engine and events
lib/application/    GameSession (use cases, persistence orchestration)
lib/data/           content loading, save codec, save repositories
lib/game/           runtime: world, input, collision, interaction, camera
lib/features/       Flutter screens, HUD, panels
lib/infrastructure/ monetization (RevenueCat adapter), audio
tool/assets/        reproducible asset generators
```

The original downloaded specifications are preserved in `Downloads`; this
repository lives in `Desktop/Iron-Mark-Repos/Hackathon-Shipathon_2026`.
