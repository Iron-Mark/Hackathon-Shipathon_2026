import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../../domain/player.dart';
import '../shared/icons.dart';
import '../shared/widgets.dart';

class QuestLogScreen extends StatelessWidget {
  const QuestLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = GameScope.sessionOf(context);
    final text = Theme.of(context).textTheme;
    final quest = session.content.quest;
    final progress = session.isPlaying
        ? session.questProgress
        : QuestProgress(questId: quest.id);
    final stateLabel = switch (progress.state) {
      QuestState.locked => 'LOCKED',
      QuestState.available => 'AVAILABLE · Talk to the Hypertrophy Coach',
      QuestState.active => 'ACTIVE',
      QuestState.completed => 'COMPLETED',
    };
    return IronScreen(
      title: 'Quest Log',
      child: ListView(
        children: [
          IronPanel(
            accent: progress.isActive,
            padding: const EdgeInsets.all(IronSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IronIcon(
                      IronIconKind.quest,
                      size: 16,
                      color: IronColors.accentBright,
                    ),
                    const SizedBox(width: IronSpacing.s),
                    Text(
                      stateLabel,
                      style: text.labelSmall?.copyWith(
                        color: progress.isCompleted
                            ? IronColors.success
                            : IronColors.accentBright,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: IronSpacing.s),
                Text(quest.title.toUpperCase(), style: text.titleLarge),
                const SizedBox(height: IronSpacing.xs),
                Text(
                  "Don't collect exercises. Build a session.",
                  style: text.bodyMedium?.copyWith(color: IronColors.textMuted),
                ),
                const SizedBox(height: IronSpacing.xl),
                for (final o in quest.objectives)
                  _ObjectiveRow(
                    label: o.label,
                    done: progress.count(o.id) >= o.targetCount,
                    counter: o.targetCount > 1
                        ? '${progress.count(o.id)} / ${o.targetCount}'
                        : null,
                    current:
                        session.isPlaying &&
                        session.currentObjective?.id == o.id,
                  ),
                const SizedBox(height: IronSpacing.l),
                const SectionLabel('Reward'),
                const SizedBox(height: IronSpacing.xs),
                Text(
                  '+${quest.rewardXp} XP · ${session.content.knowledge.name}'
                  '${progress.rewardClaimed ? ' (claimed)' : ''}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectiveRow extends StatelessWidget {
  const _ObjectiveRow({
    required this.label,
    required this.done,
    required this.current,
    this.counter,
  });
  final String label;
  final bool done, current;
  final String? counter;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final color = done
        ? IronColors.success
        : current
        ? IronColors.text
        : IronColors.textMuted;
    return Semantics(
      label: '${done ? 'Completed' : 'Open'}: $label ${counter ?? ''}',
      child: Padding(
        padding: const EdgeInsets.only(bottom: IronSpacing.m),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: done
                  ? const IronIcon(
                      IronIconKind.check,
                      size: 18,
                      color: IronColors.success,
                    )
                  : Icon(
                      current
                          ? Icons.radio_button_checked
                          : Icons.circle_outlined,
                      size: 16,
                      color: color,
                    ),
            ),
            const SizedBox(width: IronSpacing.m),
            Expanded(
              child: Text(
                label,
                style: text.bodyLarge?.copyWith(
                  color: color,
                  decoration: done ? TextDecoration.lineThrough : null,
                  decorationColor: IronColors.success,
                ),
              ),
            ),
            if (counter != null) Text(counter!, style: text.labelLarge),
          ],
        ),
      ),
    );
  }
}
