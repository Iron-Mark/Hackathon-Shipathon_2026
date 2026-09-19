// Compact HUD: quest (top-left), condition (top-right), interaction prompt
// (bottom-center), touch controls on compact/mobile layouts. Rebuilds only on
// application-state changes, never on player movement.
import 'package:flutter/material.dart';
import 'package:flutter_scene/kit.dart' show VirtualJoystick;
import 'package:vector_math/vector_math.dart' as vm;

import '../../app/theme.dart';
import '../../application/game_session.dart';
import '../../domain/content.dart';
import '../../domain/player.dart';
import '../shared/icons.dart';
import '../shared/widgets.dart';
import 'feedback.dart';

class QuestTracker extends StatelessWidget {
  const QuestTracker({
    super.key,
    required this.session,
    required this.onOpenSessionBuilder,
    this.compact = false,
  });
  final GameSession session;
  final VoidCallback onOpenSessionBuilder;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final quest = session.content.quest;
    final progress = session.questProgress;
    final objective = session.currentObjective;
    String line;
    String? counter;
    if (progress.state == QuestState.available) {
      line = 'Talk to the ${session.content.coach.name}';
    } else if (progress.isCompleted) {
      line = '${session.content.knowledge.name} unlocked';
    } else if (objective != null) {
      line = objective.label;
      if (objective.targetCount > 1) {
        counter = '${progress.count(objective.id)} / ${objective.targetCount}';
      }
    } else {
      line = '';
    }
    final showBuilder =
        objective?.type == ObjectiveType.workoutValidation && progress.isActive;
    return Semantics(
      label: 'Quest ${quest.title}. $line ${counter ?? ''}',
      child: IronPanel(
        width: compact ? 220 : 300,
        padding: const EdgeInsets.all(IronSpacing.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const IronIcon(
                  IronIconKind.quest,
                  size: 14,
                  color: IronColors.accentBright,
                ),
                const SizedBox(width: IronSpacing.s),
                Expanded(
                  child: Text(
                    progress.state == QuestState.available
                        ? 'HYPERTROPHY GYM'
                        : quest.title.toUpperCase(),
                    style: text.labelSmall?.copyWith(
                      color: IronColors.accentBright,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (counter != null) Text(counter, style: text.labelLarge),
              ],
            ),
            const SizedBox(height: IronSpacing.xs),
            Text(
              line,
              style: compact ? text.bodySmall : text.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (showBuilder)
              Padding(
                padding: const EdgeInsets.only(top: IronSpacing.s),
                child: FilledButton(
                  onPressed: onOpenSessionBuilder,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(44, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  child: const Text('SESSION BUILDER'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ConditionPanel extends StatelessWidget {
  const ConditionPanel({
    super.key,
    required this.condition,
    required this.level,
    required this.xp,
    required this.onMenu,
    this.compact = false,
  });
  final PlayerCondition condition;
  final int level, xp;
  final VoidCallback onMenu;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return IronPanel(
      padding: const EdgeInsets.fromLTRB(
        IronSpacing.m,
        IronSpacing.s,
        IronSpacing.s,
        IronSpacing.s,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusRow(
                icon: IronIconKind.hydration,
                label: 'Hydration',
                value: condition.hydration,
                color: IronColors.hydration,
                compact: compact,
              ),
              const SizedBox(height: IronSpacing.xs),
              StatusRow(
                icon: IronIconKind.fatigue,
                label: 'Fatigue',
                value: condition.fatigue,
                color: IronColors.fatigue,
                compact: compact,
              ),
              const SizedBox(height: IronSpacing.xs),
              Row(
                children: [
                  const IronIcon(
                    IronIconKind.xp,
                    size: 14,
                    color: IronColors.xp,
                  ),
                  const SizedBox(width: IronSpacing.s),
                  Text(
                    'LEVEL $level   $xp XP',
                    style: text.labelSmall?.copyWith(color: IronColors.text),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: IronSpacing.s),
          Semantics(
            button: true,
            label: 'Menu',
            child: InkWell(
              onTap: onMenu,
              borderRadius: BorderRadius.circular(IronRadius.small),
              child: const Padding(
                padding: EdgeInsets.all(IronSpacing.s),
                child: IronIcon(IronIconKind.menu, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InteractionPrompt extends StatelessWidget {
  const InteractionPrompt({
    super.key,
    required this.target,
    required this.discovered,
    required this.controlHints,
    required this.touch,
  });
  final InteractableDefinition? target;
  final bool discovered, controlHints, touch;

  @override
  Widget build(BuildContext context) {
    final t = target;
    final text = Theme.of(context).textTheme;
    if (t == null) {
      if (!controlHints) return const SizedBox.shrink();
      return Text(
        touch
            ? 'Move with the joystick. Approach equipment to interact.'
            : 'WASD / Arrows to move   ·   E to interact   ·   Esc for menu',
        style: text.labelSmall,
      );
    }
    final action = t.isNpc
        ? 'Talk'
        : t.isWaterStation
        ? 'Drink'
        : t.isRecoveryMat
        ? 'Recover'
        : discovered && t.trainingEnabled
        ? 'Inspect / Train'
        : 'Inspect';
    return IronPanel(
      accent: true,
      padding: const EdgeInsets.symmetric(
        horizontal: IronSpacing.l,
        vertical: IronSpacing.s,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.name.toUpperCase(), style: text.titleMedium),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!touch) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: IronColors.accentBright),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'E',
                    style: text.labelSmall?.copyWith(
                      color: IronColors.accentBright,
                    ),
                  ),
                ),
                const SizedBox(width: IronSpacing.s),
              ],
              Text(action, style: text.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}

class TouchControls extends StatelessWidget {
  const TouchControls({
    super.key,
    required this.onJoystick,
    required this.onInteract,
    required this.hasTarget,
    required this.actionLabel,
  });
  final void Function(vm.Vector2 direction) onJoystick;
  final VoidCallback onInteract;
  final bool hasTarget;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Semantics(
          label: 'Movement joystick',
          child: VirtualJoystick(
            radius: 58,
            knobRadius: 24,
            onChanged: onJoystick,
            baseDecoration: BoxDecoration(
              color: IronColors.surface.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(color: IronColors.border, width: 2),
            ),
            knobDecoration: BoxDecoration(
              color: IronColors.accent.withValues(alpha: 0.9),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Spacer(),
        Semantics(
          button: true,
          label: 'Interact',
          child: SizedBox(
            width: 84,
            height: 84,
            child: FilledButton(
              onPressed: hasTarget ? onInteract : null,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: hasTarget
                    ? IronColors.accent
                    : IronColors.surfaceRaised,
                disabledBackgroundColor: IronColors.surface.withValues(
                  alpha: 0.6,
                ),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                actionLabel.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ToastColumn extends StatelessWidget {
  const ToastColumn({super.key, required this.feedback});
  final FeedbackController feedback;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final t in feedback.toasts)
          Padding(
            padding: const EdgeInsets.only(top: IronSpacing.s),
            child: IronPanel(
              opacity: 0.9,
              padding: const EdgeInsets.symmetric(
                horizontal: IronSpacing.m,
                vertical: IronSpacing.s,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IronIcon(t.icon, size: 16, color: t.color),
                  const SizedBox(width: IronSpacing.s),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.text,
                        style: text.labelLarge?.copyWith(color: t.color),
                      ),
                      if (t.detail != null)
                        Text(t.detail!, style: text.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class FeedbackCardView extends StatelessWidget {
  const FeedbackCardView({
    super.key,
    required this.card,
    required this.onDismiss,
    required this.reducedMotion,
  });
  final FeedbackCard card;
  final VoidCallback onDismiss;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final strong = card.kind == CardKind.questComplete;
    final color = switch (card.kind) {
      CardKind.discovery => IronColors.accentBright,
      CardKind.questStart => IronColors.accentBright,
      CardKind.questComplete => IronColors.xp,
      CardKind.levelUp => IronColors.xp,
    };
    final content = Semantics(
      liveRegion: true,
      label: '${card.heading} ${card.title} ${card.lines.join(' ')}',
      child: IronPanel(
        accent: true,
        opacity: 0.94,
        padding: const EdgeInsets.symmetric(
          horizontal: IronSpacing.xl,
          vertical: IronSpacing.l,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(card.heading, style: text.labelSmall?.copyWith(color: color)),
            const SizedBox(height: IronSpacing.s),
            Text(
              card.title,
              textAlign: TextAlign.center,
              style: strong ? text.headlineMedium : text.titleLarge,
            ),
            const SizedBox(height: IronSpacing.s),
            for (final line in card.lines)
              Text(
                line,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: line.contains('XP') ? IronColors.xp : IronColors.text,
                ),
              ),
          ],
        ),
      ),
    );
    return GestureDetector(
      onTap: onDismiss,
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: strong
            ? Colors.black.withValues(alpha: 0.45)
            : Colors.transparent,
        alignment: Alignment.center,
        child: reducedMotion
            ? content
            : TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.85, end: 1),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutBack,
                builder: (context, v, child) => Transform.scale(
                  scale: v,
                  child: Opacity(opacity: v.clamp(0, 1), child: child),
                ),
                child: content,
              ),
      ),
    );
  }
}
