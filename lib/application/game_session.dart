// Application layer: coordinates content, the pure-Dart GameEngine and the
// SaveRepository. Widgets call use cases here and listen for changes; they
// never mutate domain state directly. Frame-by-frame runtime state never
// passes through this class.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/content_repository.dart';
import '../data/save_codec.dart';
import '../domain/content.dart';
import '../domain/engine.dart';
import '../domain/events.dart';
import '../domain/player.dart';
import '../domain/rules.dart';

enum SessionPhase { loading, contentError, menu, playing }

class GameSession extends ChangeNotifier {
  GameSession({
    required ContentRepository contentRepository,
    required SaveRepository saveRepository,
  }) : _contentRepository = contentRepository,
       _saveRepository = saveRepository;

  final ContentRepository _contentRepository;
  final SaveRepository _saveRepository;
  final _events = StreamController<GameEvent>.broadcast();

  GameContent? _content;
  GameEngine? _engine;
  SaveGame? _existingSave;
  GameSettings _menuSettings = const GameSettings();
  SessionPhase _phase = SessionPhase.loading;
  String? _contentError;
  String? _saveError;
  bool _saveCorrupt = false;
  Future<void> _saveChain = Future.value();

  /// Every domain event, in order, for HUD feedback and audio.
  Stream<GameEvent> get events => _events.stream;

  SessionPhase get phase => _phase;
  String? get contentError => _contentError;

  /// Non-blocking persistence error (spec: keep in-memory state, notify).
  String? get saveError => _saveError;
  bool get saveCorrupt => _saveCorrupt;

  GameContent get content => _content!;
  bool get hasContent => _content != null;
  bool get hasExistingSave => _existingSave != null;
  bool get isPlaying => _engine != null;

  /// The active engine. Only valid while [isPlaying].
  GameEngine get engine => _engine!;

  PlayerProfile get player => engine.player;
  PlayerCondition get condition => player.condition;
  QuestProgress get questProgress => engine.questProgress;
  QuestObjectiveDefinition? get currentObjective => engine.currentObjective;
  WorkoutSelection get selection => engine.state.selection;
  Map<String, Exercise> get exercises => content.exercises;

  GameSettings get settings =>
      _engine?.state.settings ?? _existingSave?.settings ?? _menuSettings;

  // ---------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------

  Future<void> initialize() async {
    try {
      _content = await _contentRepository.load();
    } catch (e) {
      _contentError = '$e';
      _phase = SessionPhase.contentError;
      notifyListeners();
      return;
    }
    await _loadExistingSave();
    _phase = SessionPhase.menu;
    notifyListeners();
  }

  Future<void> _loadExistingSave() async {
    try {
      _existingSave = await _saveRepository.load();
      _saveCorrupt = false;
    } on SaveCorruptException catch (e) {
      // Never silently overwrite a corrupt save: report it and let the
      // player choose New Game (which replaces it) from the menu.
      _existingSave = null;
      _saveCorrupt = true;
      _saveError = '$e';
    } catch (e) {
      _existingSave = null;
      _saveError = 'Save could not be read: $e';
    }
  }

  void startNewGame() {
    final save = SaveGame.newGame(content.quest.id, settings: settings);
    _engine = GameEngine(content, save);
    _existingSave = save;
    _saveCorrupt = false;
    _phase = SessionPhase.playing;
    _dispatch([const NewGameCreated(), const SaveRequested()]);
  }

  bool continueGame() {
    final save = _existingSave;
    if (save == null) return false;
    _engine = GameEngine(content, save);
    _phase = SessionPhase.playing;
    _dispatch([const SaveLoaded()]);
    return true;
  }

  /// Returns to the title without discarding progress.
  void leaveToMenu() {
    if (_engine != null) _existingSave = _engine!.state;
    _engine = null;
    _phase = SessionPhase.menu;
    notifyListeners();
  }

  /// Clears gameplay progression (not monetization entitlement, which lives
  /// in the store adapter). Settings are kept.
  Future<void> resetSave() async {
    final keep = settings;
    _engine = null;
    _existingSave = null;
    _menuSettings = keep;
    _saveCorrupt = false;
    _phase = SessionPhase.menu;
    try {
      await _saveRepository.clear();
      _saveError = null;
    } catch (e) {
      _saveError = 'Progress could not be cleared: $e';
    }
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Use cases (thin wrappers over the engine)
  // ---------------------------------------------------------------------

  String coachDialogue() =>
      content.coach.dialogue[engine.coachDialogueId()] ?? '';

  List<GameEvent> interactWithCoach() =>
      _run(() => engine.interactWithNpc(content.coach.id));

  List<GameEvent> inspectExercise(String exerciseId) =>
      _run(() => engine.inspectExercise(exerciseId));

  List<GameEvent> toggleWorkoutExercise(String exerciseId) =>
      _run(() => engine.toggleWorkoutExercise(exerciseId));

  WorkoutValidationResult previewWorkout() => engine.previewWorkout();

  WorkoutValidationResult validateWorkout() {
    final (result, events) = engine.validateWorkout();
    _dispatch(events);
    return result;
  }

  List<GameEvent> startTraining(String exerciseId) =>
      _run(() => engine.startTraining(exerciseId));

  TrainingResult? completeTraining(String exerciseId, int cleanReps) {
    final events = _run(() => engine.completeTraining(exerciseId, cleanReps));
    return events.whereType<ExerciseCompleted>().firstOrNull?.result;
  }

  List<GameEvent> drinkWater() => _run(engine.drinkWater);

  List<GameEvent> useRecoveryMat() => _run(engine.useRecoveryMat);

  void updateSettings(GameSettings next) {
    if (_engine != null) {
      _run(() => engine.updateSettings(next));
      return;
    }
    final existing = _existingSave;
    if (existing != null) {
      _existingSave = existing.copyWith(settings: next);
      _dispatch([SettingsChanged(next), const SaveRequested()]);
      return;
    }
    _menuSettings = next;
    _dispatch([SettingsChanged(next)]);
  }

  /// Retries a failed save (spec: retry on the next meaningful save).
  void retrySave() => _dispatch(const [SaveRequested()]);

  // ---------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------

  List<GameEvent> _run(List<GameEvent> Function() useCase) {
    final events = useCase();
    _dispatch(events);
    return events;
  }

  void _dispatch(List<GameEvent> events) {
    if (events.isEmpty) return;
    for (final e in events) {
      _events.add(e);
    }
    if (events.any((e) => e is SaveRequested)) _persist();
    notifyListeners();
  }

  void _persist() {
    final save = _engine?.state ?? _existingSave;
    if (save == null) return;
    _saveChain = _saveChain.then((_) async {
      try {
        await _saveRepository.save(save);
        if (_saveError != null) {
          _saveError = null;
          notifyListeners();
        }
      } catch (e) {
        _saveError = 'Progress could not be saved. '
            'Your current session remains active.';
        debugPrint('save failed: $e');
        notifyListeners();
      }
    });
  }

  /// Completes when every queued save has been attempted.
  Future<void> flushSaves() => _saveChain;

  @override
  void dispose() {
    _events.close();
    super.dispose();
  }
}
