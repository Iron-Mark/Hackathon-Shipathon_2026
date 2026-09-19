// Turns domain events into short, non-blocking player feedback: small toasts
// near the status HUD and centered cards for discoveries and quest beats.
import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../../app/theme.dart';
import '../../domain/content.dart';
import '../../domain/events.dart';
import '../../domain/rules.dart';
import '../shared/icons.dart';

class Toast {
  Toast(this.text, {required this.color, required this.icon, this.detail});
  final String text;
  final String? detail;
  final Color color;
  final IronIconKind icon;
  final int id = _counter++;
  static int _counter = 0;
}

enum CardKind { discovery, questStart, questComplete, levelUp }

class FeedbackCard {
  const FeedbackCard({
    required this.kind,
    required this.heading,
    required this.title,
    this.lines = const [],
    this.duration = const Duration(milliseconds: 2600),
  });
  final CardKind kind;
  final String heading, title;
  final List<String> lines;
  final Duration duration;
}

class FeedbackController extends ChangeNotifier {
  FeedbackController({required this.content, required this.reducedMotion});
  final GameContent content;
  bool reducedMotion;

  final List<Toast> toasts = [];
  final Queue<FeedbackCard> _cards = Queue();
  FeedbackCard? current;
  Timer? _cardTimer;
  final Map<int, Timer> _toastTimers = {};

  /// Cards wait while a panel is open or another route is on top.
  bool _suspended = false;
  bool get suspended => _suspended;
  set suspended(bool value) {
    if (_suspended == value) return;
    _suspended = value;
    if (!value) _advance();
  }

  void handle(GameEvent event) {
    switch (event) {
      case HydrationChanged(:final delta):
        _toast(
          'HYDRATION ${_signed(delta)}',
          IronColors.hydration,
          IronIconKind.hydration,
        );
      case FatigueChanged(:final delta):
        _toast(
          'FATIGUE ${_signed(delta)}',
          IronColors.fatigue,
          IronIconKind.fatigue,
        );
      case XPGranted(:final amount):
        _toast('${_signed(amount)} XP', IronColors.xp, IronIconKind.xp);
      case PlayerLeveledUp(:final level):
        _toast(
          'LEVEL $level',
          IronColors.xp,
          IronIconKind.xp,
          detail: 'Level up',
        );
      case ExerciseDiscovered(:final exerciseId):
        final name = content.exercises[exerciseId]?.name ?? exerciseId;
        _card(
          FeedbackCard(
            kind: CardKind.discovery,
            heading: 'NEW EXERCISE DISCOVERED',
            title: name.toUpperCase(),
            lines: ['Codex Updated', '+${DiscoveryRules.discoveryXp} XP'],
          ),
        );
      case QuestStarted():
        _card(
          FeedbackCard(
            kind: CardKind.questStart,
            heading: 'NEW QUEST',
            title: content.quest.title.toUpperCase(),
            lines: const ["Don't collect exercises.", 'Build a session.'],
            duration: const Duration(milliseconds: 3200),
          ),
        );
      case QuestObjectiveCompleted(:final label):
        _toast(
          'OBJECTIVE COMPLETE',
          IronColors.success,
          IronIconKind.check,
          detail: label,
        );
      case QuestCompleted():
        _card(
          FeedbackCard(
            kind: CardKind.questComplete,
            heading: 'QUEST COMPLETE',
            title: content.quest.title.toUpperCase(),
            lines: [
              '${content.knowledge.name.toUpperCase()} UNLOCKED',
              '+${content.quest.rewardXp} XP',
            ],
            duration: const Duration(milliseconds: 4800),
          ),
        );
      default:
        break;
    }
  }

  void info(String text, {String? detail}) => _toast(
    text,
    IronColors.textMuted,
    IronIconKind.interaction,
    detail: detail,
  );

  String _signed(int v) => v > 0 ? '+$v' : '$v';

  void _toast(String text, Color color, IronIconKind icon, {String? detail}) {
    final toast = Toast(text, color: color, icon: icon, detail: detail);
    toasts.add(toast);
    if (toasts.length > 4) _remove(toasts.first.id);
    _toastTimers[toast.id] = Timer(
      const Duration(milliseconds: 2200),
      () => _remove(toast.id),
    );
    notifyListeners();
  }

  void _remove(int id) {
    _toastTimers.remove(id)?.cancel();
    toasts.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void _card(FeedbackCard card) {
    _cards.add(card);
    _advance();
  }

  void _advance() {
    if (current != null || _suspended || _cards.isEmpty) return;
    current = _cards.removeFirst();
    _cardTimer?.cancel();
    _cardTimer = Timer(current!.duration, dismissCard);
    notifyListeners();
  }

  void dismissCard() {
    if (current == null) return;
    _cardTimer?.cancel();
    current = null;
    notifyListeners();
    _advance();
  }

  @override
  void dispose() {
    _cardTimer?.cancel();
    for (final t in _toastTimers.values) {
      t.cancel();
    }
    super.dispose();
  }
}
