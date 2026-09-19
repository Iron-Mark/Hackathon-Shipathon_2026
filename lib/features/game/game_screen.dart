// Gameplay screen: 3D world underneath, Flutter HUD on top. Routes world
// interactions to application use cases and turns domain events into
// feedback. Frame state stays inside GameRuntime.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_scene/scene.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../../application/game_session.dart';
import '../../domain/content.dart';
import '../../domain/events.dart';
import '../../game/game_runtime.dart';
import '../../infrastructure/audio.dart';
import '../../infrastructure/gpu_watchdog.dart';
import '../shared/widgets.dart';
import 'feedback.dart';
import 'hud.dart';
import 'panels.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameSession _session;
  late AudioService _audio;
  late GpuWatchdog _watchdog;
  Timer? _recoverTimer;
  GameRuntime? _runtime;
  Future<void>? _load;
  Object? _loadError;
  FeedbackController? _feedback;
  StreamSubscription<GameEvent>? _events;
  final FocusNode _focus = FocusNode(debugLabel: 'gameplay');
  bool _panelOpen = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    _session = GameScope.sessionOf(context);
    _audio = GameScope.of(context).audio;
    _watchdog = GameScope.of(context).watchdog;
    if (!_session.isPlaying) return;
    final settings = _session.settings;
    _feedback = FeedbackController(
      content: _session.content,
      reducedMotion: settings.reducedMotion,
    );
    _runtime = GameRuntime(
      district: _session.content.district,
      onInteract: _handleInteract,
      reducedMotion: settings.reducedMotion,
      graphicsQuality: settings.graphicsQuality,
    );
    _load = _runtime!
        .load()
        .then((_) {
          // The GPU context exists once the scene has loaded; watch it from here.
          _watchdog.install();
          _watchdog.contextLost.addListener(_onContextLost);
        })
        .catchError((Object e, StackTrace s) {
          debugPrint('Gym scene failed to load: $e\n$s');
          _loadError = e;
        });
    _events = _session.events.listen(_feedback!.handle);
    _session.addListener(_onSessionChanged);
    _audio.startAmbience();
  }

  void _onSessionChanged() {
    final runtime = _runtime;
    if (runtime == null) return;
    if (!_session.isPlaying) {
      // The game ended underneath us (reset / return to title): drop the HUD.
      if (mounted) setState(() {});
      return;
    }
    runtime.reducedMotion = _session.settings.reducedMotion;
    _feedback?.reducedMotion = _session.settings.reducedMotion;
    _audio.refreshVolume();
  }

  void _onContextLost() {
    if (!_watchdog.contextLost.value || _recoverTimer != null) return;
    if (mounted) setState(() {});
    // Give the pending save write a moment to land, then restart into it.
    _recoverTimer = Timer(const Duration(milliseconds: 1200), () {
      _watchdog.recover();
    });
  }

  @override
  void dispose() {
    _recoverTimer?.cancel();
    _watchdog.contextLost.removeListener(_onContextLost);
    _audio.stopAmbience();
    _session.removeListener(_onSessionChanged);
    _events?.cancel();
    _feedback?.dispose();
    _runtime?.dispose();
    _focus.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------
  // Panels and interactions
  // ---------------------------------------------------------------------

  Future<T> _withPanel<T>(Future<T> Function() open) async {
    final runtime = _runtime!;
    _panelOpen = true;
    runtime.paused = true;
    runtime.keyboard.release();
    _feedback!.suspended = true;
    try {
      return await open();
    } finally {
      _panelOpen = false;
      runtime.paused = false;
      runtime.input.clear();
      runtime.lockInteract();
      _feedback!.suspended = false;
      if (mounted) _focus.requestFocus();
    }
  }

  Future<void> _handleInteract(InteractableDefinition target) async {
    if (_panelOpen || !mounted) return;
    final session = _session;
    if (target.isNpc) {
      final events = session.interactWithCoach();
      final dialogueId =
          events.whereType<NPCInteracted>().firstOrNull?.dialogueId ??
          'coach_intro';
      final text = session.content.coach.dialogue[dialogueId] ?? '';
      final engine = session.engine;
      final offerBuilder =
          engine.questProgress.isActive &&
          !engine.sessionBuilt &&
          engine.player.discoveredExerciseIds.length >= 3;
      final openBuilder = await _withPanel(
        () => showCoachDialogue(
          context,
          coach: session.content.coach,
          text: text,
          offerSessionBuilder: offerBuilder,
        ),
      );
      if (openBuilder == true && mounted) _openRoute(Routes.session);
    } else if (target.isExerciseStation) {
      final exercise = session.exercises[target.targetId];
      if (exercise == null) {
        _feedback!.info('Exercise data unavailable.');
        return;
      }
      final events = session.inspectExercise(target.targetId);
      final newlyDiscovered = events.any((e) => e is ExerciseDiscovered);
      final train = await _withPanel(
        () => showExerciseInspect(
          context,
          station: target,
          exercise: exercise,
          newlyDiscovered: newlyDiscovered,
          sessionBuilt: session.engine.sessionBuilt,
        ),
      );
      if (train == true && mounted) {
        session.startTraining(exercise.id);
        await _openRoute(Routes.training, arguments: exercise.id);
      }
    } else if (target.isWaterStation) {
      final events = session.drinkWater();
      if (!events.any((e) => e is HydrationChanged)) {
        _feedback!.info('HYDRATION FULL', detail: 'You are fully hydrated.');
      }
    } else if (target.isRecoveryMat) {
      final events = session.useRecoveryMat();
      if (!events.any((e) => e is FatigueChanged)) {
        _feedback!.info('FULLY RESTED', detail: 'Fatigue is already at 0.');
      }
    }
  }

  Future<void> _openRoute(String route, {Object? arguments}) => _withPanel(
    () => Navigator.of(context).pushNamed(route, arguments: arguments),
  );

  Future<void> _openPauseMenu() async {
    final scope = GameScope.of(context);
    final action = await _withPanel(
      () => showPauseMenu(context, embedded: scope.embed.embedded),
    );
    if (!mounted || action == null) return;
    if (action == PauseAction.title) {
      _session.leaveToMenu();
      Navigator.of(context).popUntil((r) => r.settings.name == Routes.menu);
      // Tell an embedding host (FlutterFlow WebView / iframe) we are done.
      if (scope.embed.embedded) scope.bridge.exit();
      return;
    }
    final route = routeForPauseAction(action);
    if (route != null) await _openRoute(route);
  }

  bool _tickErrorReported = false;

  /// An exception inside the frame tick must never blank or stall the view.
  void _safeTick(GameRuntime runtime, double dt) {
    try {
      runtime.tick(dt);
    } catch (e, s) {
      if (!_tickErrorReported) {
        _tickErrorReported = true;
        debugPrint('IRON ASCENT tick error: $e\n$s');
      }
    }
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    final runtime = _runtime;
    if (runtime == null || _panelOpen) return KeyEventResult.ignored;
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.escape) {
      if (_feedback!.current != null) {
        _feedback!.dismissCard();
      } else {
        _openPauseMenu();
      }
      return KeyEventResult.handled;
    }
    if (_feedback!.current != null && event is KeyDownEvent) {
      final key = event.logicalKey;
      if (key == LogicalKeyboardKey.enter ||
          key == LogicalKeyboardKey.space ||
          key == LogicalKeyboardKey.keyE) {
        _feedback!.dismissCard();
        runtime.lockInteract();
        return KeyEventResult.handled;
      }
    }
    return runtime.keyboard.handle(event)
        ? KeyEventResult.handled
        : KeyEventResult.ignored;
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------

  bool get _touch {
    final platform = defaultTargetPlatform;
    return platform == TargetPlatform.android ||
        platform == TargetPlatform.iOS ||
        IronBreakpoints.isCompact(context);
  }

  @override
  Widget build(BuildContext context) {
    final session = GameScope.sessionOf(context);
    if (!session.isPlaying || _runtime == null) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () =>
                Navigator.of(context)
                    .popUntil((r) => r.settings.name == Routes.menu),
            child: const Text('RETURN TO TITLE'),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: IronColors.background,
      body: FutureBuilder<void>(
        future: _load,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const _LoadingView();
          }
          if (_loadError != null) return _ErrorView(error: _loadError!);
          if (_watchdog.contextLost.value) return const _RecoveringView();
          return _buildGame(context, session);
        },
      ),
    );
  }

  Widget _buildGame(BuildContext context, GameSession session) {
    final runtime = _runtime!;
    final feedback = _feedback!;
    final compact = IronBreakpoints.isCompact(context);
    final touch = _touch;
    final padding = EdgeInsets.all(compact ? IronSpacing.s : IronSpacing.l);
    // Phones report 2.5-3.5x pixel ratios; rendering the world at full
    // density there triples GPU memory and fill cost for no visible gain on
    // low-poly geometry, and is the usual trigger for mobile WebGL context
    // loss. HUD text stays crisp because only the SceneView is capped.
    final pixelRatio = math.min(
      MediaQuery.devicePixelRatioOf(context),
      compact ? 1.5 : 2.0,
    );

    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: _onKey,
      onFocusChange: (has) {
        if (!has) runtime.keyboard.release();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => _focus.requestFocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Backdrop in the gym's floor tone: a dropped frame (context
            // hiccup, resize) reads as a dim flicker rather than pure black.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF3A3D42), Color(0xFF2B2E33)],
                ),
              ),
            ),
            SceneView(
              runtime.scene,
              cameraBuilder: (_) => runtime.camera,
              pixelRatio: pixelRatio,
              onTick: (_, dt) => _safeTick(runtime, dt),
            ),
            // HUD (rebuilds on application state only).
            SafeArea(
              child: Padding(
                padding: padding,
                child: ListenableBuilder(
                  listenable: session,
                  builder: (context, _) {
                    if (!session.isPlaying) return const SizedBox.shrink();
                    final quest = QuestTracker(
                      session: session,
                      compact: compact,
                      onOpenSessionBuilder: () => _openRoute(Routes.session),
                    );
                    final status = Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ConditionPanel(
                          condition: session.condition,
                          level: session.player.level,
                          xp: session.player.xp,
                          compact: compact,
                          onMenu: _openPauseMenu,
                        ),
                        ListenableBuilder(
                          listenable: feedback,
                          builder: (context, _) =>
                              ToastColumn(feedback: feedback),
                        ),
                        if (session.saveError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: IronSpacing.s),
                            child: IronPanel(
                              accent: true,
                              padding: const EdgeInsets.all(IronSpacing.s),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    session.saveError!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall,
                                  ),
                                  TextButton(
                                    onPressed: session.retrySave,
                                    child: const Text('RETRY'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    );
                    return Stack(
                      children: [
                        // Wide: quest top-left, status top-right. Compact:
                        // status first, quest stacked beneath so the panels
                        // never overlap.
                        Align(
                          alignment: Alignment.topCenter,
                          child: compact
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: status,
                                    ),
                                    const SizedBox(height: IronSpacing.s),
                                    Align(
                                      alignment: Alignment.topLeft,
                                      child: quest,
                                    ),
                                  ],
                                )
                              : Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [quest, const Spacer(), status],
                                ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: EdgeInsets.only(bottom: touch ? 120 : 0),
                            child:
                                ValueListenableBuilder<InteractableDefinition?>(
                                  valueListenable: runtime.target,
                                  builder: (context, target, _) =>
                                      InteractionPrompt(
                                        target: target,
                                        discovered:
                                            target != null &&
                                            session.player.hasDiscovered(
                                              target.targetId,
                                            ),
                                        controlHints:
                                            session.settings.controlHints,
                                        touch: touch,
                                      ),
                                ),
                          ),
                        ),
                        if (touch)
                          Align(
                            alignment: Alignment.bottomCenter,
                            child:
                                ValueListenableBuilder<InteractableDefinition?>(
                                  valueListenable: runtime.target,
                                  builder: (context, target, _) =>
                                      TouchControls(
                                        onJoystick: runtime.touch.onJoystick,
                                        onInteract: runtime.input.pressInteract,
                                        hasTarget: target != null,
                                        actionLabel: _actionLabel(
                                          target,
                                          session,
                                        ),
                                      ),
                                ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
            // Centered feedback cards.
            ListenableBuilder(
              listenable: feedback,
              builder: (context, _) {
                final card = feedback.current;
                if (card == null) return const SizedBox.shrink();
                return FeedbackCardView(
                  card: card,
                  onDismiss: feedback.dismissCard,
                  reducedMotion: feedback.reducedMotion,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _actionLabel(InteractableDefinition? target, GameSession session) {
    if (target == null) return 'Interact';
    if (target.isNpc) return 'Talk';
    if (target.isWaterStation) return 'Drink';
    if (target.isRecoveryMat) return 'Recover';
    return 'Inspect';
  }
}

class _RecoveringView extends StatelessWidget {
  const _RecoveringView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('DISPLAY RESET', style: text.headlineMedium),
          const SizedBox(height: IronSpacing.m),
          const SizedBox(
            width: 220,
            child: LinearProgressIndicator(color: IronColors.accent),
          ),
          const SizedBox(height: IronSpacing.m),
          Text(
            'Your device dropped the graphics context. '
            'Reloading the gym from your save...',
            textAlign: TextAlign.center,
            style: text.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('IRON ASCENT', style: text.headlineMedium),
          const SizedBox(height: IronSpacing.m),
          const SizedBox(
            width: 220,
            child: LinearProgressIndicator(color: IronColors.accent),
          ),
          const SizedBox(height: IronSpacing.m),
          Text('Loading Hypertrophy Gym...', style: text.bodyMedium),
          const SizedBox(height: IronSpacing.xl),
          Text(
            'More exercises do not automatically mean better training.',
            style: text.bodySmall?.copyWith(color: IronColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IronPanel(
        accent: true,
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THE GYM COULD NOT BE LOADED',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: IronSpacing.s),
            Text(
              '$error',
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: IronColors.textMuted),
            ),
            const SizedBox(height: IronSpacing.l),
            FilledButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('BACK'),
            ),
          ],
        ),
      ),
    );
  }
}
