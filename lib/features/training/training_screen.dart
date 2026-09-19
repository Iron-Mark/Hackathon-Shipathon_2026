// Training minigame: a five-rep timing interaction. The screen only scores
// the player's timing; the TrainingResult (grade, fatigue, hydration, XP)
// comes from the domain through the session.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../../domain/content.dart';
import '../../domain/rules.dart';
import '../shared/icons.dart';
import '../shared/widgets.dart';

enum RepRating {
  clean('CLEAN', IronColors.success),
  good('GOOD', IronColors.accentBright),
  rough('ROUGH', IronColors.fatigue),
  miss('MISS', IronColors.locked);

  const RepRating(this.label, this.color);
  final String label;
  final Color color;
  bool get countsAsClean => this == clean || this == good;
}

/// Pure scoring helper (tested separately).
RepRating rateRep(double marker, double zoneCenter, double zoneHalfWidth) {
  final d = (marker - zoneCenter).abs();
  if (d <= zoneHalfWidth * 0.45) return RepRating.clean;
  if (d <= zoneHalfWidth) return RepRating.good;
  if (d <= zoneHalfWidth * 1.7) return RepRating.rough;
  return RepRating.miss;
}

class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key, required this.exerciseId});
  final String exerciseId;

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

enum _Phase { ready, active, feedback, complete }

class _TrainingScreenState extends State<TrainingScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final _random = math.Random();
  final FocusNode _focus = FocusNode(debugLabel: 'training');

  _Phase _phase = _Phase.ready;
  int _rep = 0;
  double _marker = 0;
  double _direction = 1;
  double _repElapsed = 0;
  double _feedbackElapsed = 0;
  double _zoneCenter = 0.5;
  double _zoneHalfWidth = 0.1;
  double _speed = 0.9; // sweeps per second
  final List<RepRating> _ratings = [];
  RepRating? _last;
  TrainingResult? _result;
  Duration? _lastTick;

  static const totalReps = TrainingRules.repsPerSet;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = GameScope.sessionOf(context);
    if (!session.isPlaying) return;
    final reduced = session.settings.reducedMotion;
    final scale = TrainingRules.timingWindowScale(session.condition);
    _speed = reduced ? 0.42 : 0.9;
    _zoneHalfWidth = (reduced ? 0.16 : 0.10) * scale;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _start() {
    if (_phase != _Phase.ready) return;
    _nextRep();
    _lastTick = null;
    _ticker.start();
    setState(() {});
  }

  void _nextRep() {
    _phase = _Phase.active;
    _repElapsed = 0;
    _marker = 0;
    _direction = 1;
    _zoneCenter = 0.3 + _random.nextDouble() * 0.4;
  }

  void _onTick(Duration elapsed) {
    final last = _lastTick;
    _lastTick = elapsed;
    if (last == null) return;
    final dt = ((elapsed - last).inMicroseconds / 1e6).clamp(0.0, 0.05);
    switch (_phase) {
      case _Phase.active:
        _repElapsed += dt;
        _marker += _direction * _speed * dt;
        if (_marker > 1) {
          _marker = 2 - _marker;
          _direction = -1;
        } else if (_marker < 0) {
          _marker = -_marker;
          _direction = 1;
        }
        // Never stall: after ~2.5 sweeps the rep counts as a miss.
        if (_repElapsed > 2.5 / _speed) _scoreRep(RepRating.miss);
      case _Phase.feedback:
        _feedbackElapsed += dt;
        if (_feedbackElapsed > 0.55) {
          if (_rep >= totalReps) {
            _finish();
          } else {
            _nextRep();
          }
        }
      case _Phase.ready:
      case _Phase.complete:
        break;
    }
    if (mounted) setState(() {});
  }

  void _press() {
    switch (_phase) {
      case _Phase.ready:
        _start();
      case _Phase.active:
        _scoreRep(rateRep(_marker, _zoneCenter, _zoneHalfWidth));
      case _Phase.feedback:
      case _Phase.complete:
        break;
    }
  }

  void _scoreRep(RepRating rating) {
    _ratings.add(rating);
    _last = rating;
    _rep += 1;
    _phase = _Phase.feedback;
    _feedbackElapsed = 0;
  }

  void _finish() {
    _ticker.stop();
    final session = GameScope.sessionOf(context);
    final clean = _ratings.where((r) => r.countsAsClean).length;
    _result = session.completeTraining(widget.exerciseId, clean);
    _phase = _Phase.complete;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.space ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.keyE) {
      if (_phase == _Phase.complete) {
        Navigator.of(context).maybePop();
      } else {
        _press();
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final session = GameScope.sessionOf(context);
    final exercise = session.exercises[widget.exerciseId];
    if (!session.isPlaying || exercise == null) {
      return const IronScreen(
        title: 'Training',
        child: Center(child: Text('Exercise data unavailable.')),
      );
    }
    final text = Theme.of(context).textTheme;
    final compact = IronBreakpoints.isCompact(context);
    final result = _result;

    return Scaffold(
      body: Focus(
        focusNode: _focus,
        autofocus: true,
        onKeyEvent: _onKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) => _phase == _Phase.complete ? null : _press(),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Padding(
                  padding: EdgeInsets.all(
                    compact ? IronSpacing.l : IronSpacing.xxl,
                  ),
                  child: result != null
                      ? _ResultView(
                          exercise: exercise,
                          result: result,
                          onContinue: () => Navigator.of(context).maybePop(),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SectionLabel('Working set'),
                            Text(
                              exercise.name.toUpperCase(),
                              style: compact
                                  ? text.titleLarge
                                  : text.headlineMedium,
                            ),
                            const SizedBox(height: IronSpacing.xxl),
                            Text(
                              _phase == _Phase.ready
                                  ? 'READY'
                                  : 'REP ${math.min(_rep + (_phase == _Phase.active ? 1 : 0), totalReps)} / $totalReps',
                              style: text.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: IronSpacing.l),
                            _TimingBar(
                              marker: _marker,
                              zoneCenter: _zoneCenter,
                              zoneHalfWidth: _zoneHalfWidth,
                              active: _phase == _Phase.active,
                            ),
                            const SizedBox(height: IronSpacing.l),
                            SizedBox(
                              height: 48,
                              child: Center(
                                child:
                                    _phase == _Phase.feedback && _last != null
                                    ? Text(
                                        _last!.label,
                                        style: text.headlineMedium?.copyWith(
                                          color: _last!.color,
                                        ),
                                      )
                                    : Text(
                                        _phase == _Phase.ready
                                            ? 'Lower under control. Press when the '
                                                  'marker is inside the control zone.'
                                            : 'PRESS',
                                        textAlign: TextAlign.center,
                                        style: _phase == _Phase.ready
                                            ? text.bodyMedium
                                            : text.titleMedium?.copyWith(
                                                color: IronColors.accentBright,
                                              ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: IronSpacing.l),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                for (var i = 0; i < totalReps; i++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: i < _ratings.length
                                            ? _ratings[i].color
                                            : IronColors.surfaceRaised,
                                        border: Border.all(
                                          color: IronColors.border,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: IronSpacing.xxl),
                            FilledButton(
                              onPressed: _press,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(64, 64),
                              ),
                              child: Text(
                                _phase == _Phase.ready ? 'START SET' : 'PRESS',
                              ),
                            ),
                            const SizedBox(height: IronSpacing.s),
                            Text(
                              'Tap anywhere · Space / Enter / E',
                              textAlign: TextAlign.center,
                              style: text.labelSmall,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TimingBar extends StatelessWidget {
  const _TimingBar({
    required this.marker,
    required this.zoneCenter,
    required this.zoneHalfWidth,
    required this.active,
  });
  final double marker, zoneCenter, zoneHalfWidth;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Timing bar. Control zone at ${(zoneCenter * 100).round()} percent.',
      child: SizedBox(
        height: 64,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: IronColors.surface,
                      borderRadius: BorderRadius.circular(IronRadius.small),
                      border: Border.all(color: IronColors.border),
                    ),
                  ),
                ),
                Positioned(
                  left: w * (zoneCenter - zoneHalfWidth),
                  width: w * zoneHalfWidth * 2,
                  top: 6,
                  bottom: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: IronColors.success.withValues(alpha: 0.35),
                      border: Border.all(color: IronColors.success, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'CONTROL',
                      style: Theme.of(context).textTheme.labelSmall
                          ?.copyWith(color: IronColors.success, fontSize: 9),
                    ),
                  ),
                ),
                if (active)
                  Positioned(
                    left: (w * marker - 4).clamp(0, w - 8),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 8,
                      decoration: BoxDecoration(
                        color: IronColors.accentBright,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.exercise,
    required this.result,
    required this.onContinue,
  });
  final Exercise exercise;
  final TrainingResult result;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget row(
      String label,
      String value, {
      Color? color,
      IronIconKind? icon,
    }) => Padding(
      padding: const EdgeInsets.only(bottom: IronSpacing.s),
      child: Row(
        children: [
          if (icon != null) IronIcon(icon, size: 16, color: color),
          if (icon != null) const SizedBox(width: IronSpacing.s),
          Expanded(child: Text(label, style: text.bodyLarge)),
          Text(value, style: text.titleMedium?.copyWith(color: color)),
        ],
      ),
    );
    final gradeColor = switch (result.grade) {
      TrainingGrade.excellent => IronColors.success,
      TrainingGrade.good => IronColors.accentBright,
      TrainingGrade.rough => IronColors.fatigue,
      TrainingGrade.failed => IronColors.locked,
    };
    return IronPanel(
      padding: const EdgeInsets.all(IronSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'SET COMPLETE',
            style: text.labelSmall?.copyWith(color: gradeColor),
          ),
          const SizedBox(height: IronSpacing.xs),
          Text(exercise.name.toUpperCase(), style: text.titleLarge),
          const SizedBox(height: IronSpacing.xl),
          row('Clean Reps', '${result.cleanReps} / ${result.totalReps}'),
          row('Technique', result.grade.label, color: gradeColor),
          const Divider(height: IronSpacing.xl),
          row(
            'Fatigue',
            '+${result.fatigueAdded}',
            color: IronColors.fatigue,
            icon: IronIconKind.fatigue,
          ),
          row(
            'Hydration',
            '-${result.hydrationLost}',
            color: IronColors.hydration,
            icon: IronIconKind.hydration,
          ),
          row(
            'XP',
            '+${result.xpGranted}',
            color: IronColors.xp,
            icon: IronIconKind.xp,
          ),
          if (result.grade == TrainingGrade.rough ||
              result.grade == TrainingGrade.failed) ...[
            const SizedBox(height: IronSpacing.m),
            Text(
              'Technique note: ${exercise.techniqueNotes.first} The set still '
              'counts; fatigue applies either way.',
              style: text.bodySmall?.copyWith(color: IronColors.textMuted),
            ),
          ],
          const SizedBox(height: IronSpacing.xl),
          FilledButton(
            autofocus: true,
            onPressed: onContinue,
            child: const Text('CONTINUE'),
          ),
        ],
      ),
    );
  }
}
