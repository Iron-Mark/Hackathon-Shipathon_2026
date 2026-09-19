// Session Builder: choose three discovered exercises; the domain validator
// explains structure (press vs isolation) with educational feedback.
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../../domain/content.dart';
import '../../domain/rules.dart';
import '../shared/icons.dart';
import '../shared/widgets.dart';

class SessionBuilderScreen extends StatefulWidget {
  const SessionBuilderScreen({super.key});

  @override
  State<SessionBuilderScreen> createState() => _SessionBuilderScreenState();
}

class _SessionBuilderScreenState extends State<SessionBuilderScreen> {
  WorkoutValidationResult? _result;

  @override
  Widget build(BuildContext context) {
    final session = GameScope.sessionOf(context);
    if (!session.isPlaying) {
      return const IronScreen(
        title: 'Session Builder',
        child: Center(child: Text('Start a game to build a session.')),
      );
    }
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final text = Theme.of(context).textTheme;
        final exercises = session.exercises.values.toList();
        final discovered = session.player.discoveredExerciseIds;
        final selection = session.selection;
        final selected = selection.exerciseIds
            .map((id) => session.exercises[id])
            .nonNulls
            .toList();
        final hasPress = selected.any(
          (e) => e.movementRole == MovementRole.press,
        );
        final hasIsolation = selected.any(
          (e) => e.movementRole == MovementRole.isolation,
        );
        final built = session.engine.sessionBuilt;
        final result = _result;

        return IronScreen(
          title: 'Build Your Chest Session',
          subtitle: 'Select 3 discovered exercises',
          child: ListView(
            children: [
              if (discovered.isEmpty)
                const IronPanel(
                  child: Text(
                    'No exercises discovered yet. Walk to a station in the '
                    'gym and inspect it first.',
                  ),
                ),
              for (final e in exercises)
                _ExerciseChoice(
                  exercise: e,
                  discovered: discovered.contains(e.id),
                  selected: selection.contains(e.id),
                  enabled:
                      discovered.contains(e.id) &&
                      (selection.contains(e.id) ||
                          selection.exerciseIds.length < 3),
                  onChanged: () {
                    session.toggleWorkoutExercise(e.id);
                    setState(() => _result = null);
                  },
                ),
              const SizedBox(height: IronSpacing.l),
              IronPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Session structure'),
                    const SizedBox(height: IronSpacing.s),
                    _StructureRow('Pressing', hasPress, IronColors.press),
                    _StructureRow(
                      'Isolation',
                      hasIsolation,
                      IronColors.isolation,
                    ),
                    _StructureRow(
                      'Exercise count  ${selection.exerciseIds.length} / 3',
                      selection.exerciseIds.length == 3,
                      IronColors.accentBright,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IronSpacing.l),
              if (result != null)
                IronPanel(
                  accent: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.isValid
                            ? 'SESSION APPROVED'
                            : 'SESSION NEEDS ADJUSTMENT',
                        style: text.titleMedium?.copyWith(
                          color: result.isValid
                              ? IronColors.success
                              : IronColors.accentBright,
                        ),
                      ),
                      const SizedBox(height: IronSpacing.s),
                      Text(
                        result.isValid
                            ? 'Two pressing movements build the chest; the '
                                  'isolation movement adds a different role '
                                  'instead of more of the same. Return to a '
                                  'station and complete one working set.'
                            : result.feedback,
                        style: text.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),
              if (built && result == null)
                IronPanel(
                  child: Text(
                    'Your session structure has been approved. Complete one '
                    'working set at any discovered station.',
                    style: text.bodyMedium,
                  ),
                ),
              const SizedBox(height: IronSpacing.l),
              Wrap(
                spacing: IronSpacing.m,
                runSpacing: IronSpacing.s,
                children: [
                  FilledButton(
                    onPressed: selection.exerciseIds.isEmpty
                        ? null
                        : () => setState(
                            () => _result = session.validateWorkout(),
                          ),
                    child: const Text('VALIDATE SESSION'),
                  ),
                  if (result?.isValid == true)
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: const Text('BACK TO THE GYM'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ExerciseChoice extends StatelessWidget {
  const _ExerciseChoice({
    required this.exercise,
    required this.discovered,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });
  final Exercise exercise;
  final bool discovered, selected, enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: IronSpacing.s),
      child: Semantics(
        label: discovered
            ? '${exercise.name}, ${exercise.movementRole.label}'
            : 'Undiscovered exercise',
        checked: selected,
        enabled: enabled,
        child: InkWell(
          onTap: enabled ? onChanged : null,
          borderRadius: BorderRadius.circular(IronRadius.panel),
          child: IronPanel(
            accent: selected,
            opacity: discovered ? 0.9 : 0.5,
            child: Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: enabled ? (_) => onChanged() : null,
                  activeColor: IronColors.accent,
                ),
                const SizedBox(width: IronSpacing.s),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discovered ? exercise.name : '???',
                        style: text.titleMedium?.copyWith(
                          color: discovered
                              ? IronColors.text
                              : IronColors.locked,
                        ),
                      ),
                      Text(
                        discovered
                            ? exercise.summary
                            : 'Inspect this station in the gym to unlock it.',
                        style: text.bodySmall?.copyWith(
                          color: IronColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: IronSpacing.s),
                if (discovered)
                  RoleChip(isPress: exercise.movementRole == MovementRole.press)
                else
                  const IronIcon(
                    IronIconKind.locked,
                    size: 18,
                    color: IronColors.locked,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StructureRow extends StatelessWidget {
  const _StructureRow(this.label, this.ok, this.color);
  final String label;
  final bool ok;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: IronSpacing.xs),
    child: Row(
      children: [
        Expanded(child: Text(label)),
        ok
            ? IronIcon(IronIconKind.check, size: 18, color: color)
            : Text(
                '—',
                style: Theme.of(context).textTheme.bodyLarge
                    ?.copyWith(color: IronColors.textMuted),
              ),
      ],
    ),
  );
}
