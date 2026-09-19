// In-world panels: coach dialogue, exercise inspection, pause menu.
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../../domain/content.dart';
import '../shared/icons.dart';
import '../shared/widgets.dart';

Widget _panelShell(
  BuildContext context, {
  required Widget child,
  double width = 480,
}) {
  final compact = IronBreakpoints.isCompact(context);
  return Dialog(
    insetPadding: EdgeInsets.all(compact ? IronSpacing.l : IronSpacing.xxl),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: width),
      child: Padding(
        padding: const EdgeInsets.all(IronSpacing.xl),
        child: SingleChildScrollView(child: child),
      ),
    ),
  );
}

Future<bool?> showCoachDialogue(
  BuildContext context, {
  required NPCDefinition coach,
  required String text,
  bool offerSessionBuilder = false,
}) => showDialog<bool>(
  context: context,
  builder: (context) {
    final theme = Theme.of(context).textTheme;
    return _panelShell(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SectionLabel(coach.role),
          Text(coach.name.toUpperCase(), style: theme.titleLarge),
          const SizedBox(height: IronSpacing.l),
          Text(text, style: theme.bodyLarge?.copyWith(height: 1.4)),
          const SizedBox(height: IronSpacing.xl),
          Wrap(
            spacing: IronSpacing.m,
            runSpacing: IronSpacing.s,
            children: [
              FilledButton(
                autofocus: true,
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CONTINUE'),
              ),
              if (offerSessionBuilder)
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('OPEN SESSION BUILDER'),
                ),
            ],
          ),
        ],
      ),
    );
  },
);

/// Compact exercise information panel. Returns true when the player chose
/// to train at this station.
Future<bool?> showExerciseInspect(
  BuildContext context, {
  required InteractableDefinition station,
  required Exercise exercise,
  required bool newlyDiscovered,
  required bool sessionBuilt,
}) => showDialog<bool>(
  context: context,
  builder: (context) {
    final theme = Theme.of(context).textTheme;
    Widget field(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: IronSpacing.s),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 96, child: SectionLabel(label)),
          Expanded(child: Text(value)),
        ],
      ),
    );
    return _panelShell(
      context,
      width: 520,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (newlyDiscovered)
            Padding(
              padding: const EdgeInsets.only(bottom: IronSpacing.s),
              child: Row(
                children: [
                  const IronIcon(
                    IronIconKind.codex,
                    size: 16,
                    color: IronColors.accentBright,
                  ),
                  const SizedBox(width: IronSpacing.s),
                  Text(
                    'NEW EXERCISE DISCOVERED',
                    style: theme.labelSmall?.copyWith(
                      color: IronColors.accentBright,
                    ),
                  ),
                ],
              ),
            ),
          Text(exercise.name.toUpperCase(), style: theme.titleLarge),
          const SizedBox(height: IronSpacing.s),
          Row(
            children: [
              RoleChip(isPress: exercise.movementRole == MovementRole.press),
              const SizedBox(width: IronSpacing.s),
              Text(
                'Chest / ${humanize(exercise.category)}',
                style: theme.bodySmall?.copyWith(color: IronColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: IronSpacing.l),
          field('Primary', exercise.primaryMuscles.map(humanize).join(', ')),
          field('Emphasis', exercise.emphasis.map(humanize).join(', ')),
          field(
            'Secondary',
            exercise.secondaryMuscles.isEmpty
                ? 'None'
                : exercise.secondaryMuscles.map(humanize).join(', '),
          ),
          const SizedBox(height: IronSpacing.s),
          const SectionLabel('Role'),
          const SizedBox(height: IronSpacing.xs),
          Text(exercise.summary),
          const SizedBox(height: IronSpacing.l),
          const SectionLabel('Technique'),
          const SizedBox(height: IronSpacing.xs),
          CueList(exercise.techniqueNotes),
          const SizedBox(height: IronSpacing.xl),
          Wrap(
            spacing: IronSpacing.m,
            runSpacing: IronSpacing.s,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              OutlinedButton(
                autofocus: !station.trainingEnabled,
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CLOSE'),
              ),
              if (station.trainingEnabled)
                FilledButton(
                  autofocus: true,
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('TRAIN · 1 WORKING SET'),
                ),
            ],
          ),
          if (station.trainingEnabled && !sessionBuilt)
            Padding(
              padding: const EdgeInsets.only(top: IronSpacing.s),
              child: Text(
                'Quest tip: build your 3-exercise session first so this '
                'working set counts toward Build Your First Chest Day.',
                style: theme.bodySmall?.copyWith(color: IronColors.textMuted),
              ),
            ),
        ],
      ),
    );
  },
);

enum PauseAction { resume, codex, quests, session, map, arena, settings, title }

Future<PauseAction?> showPauseMenu(BuildContext context) =>
    showDialog<PauseAction>(
      context: context,
      builder: (context) {
        Widget item(String label, PauseAction action, {bool primary = false}) =>
            Padding(
              padding: const EdgeInsets.only(bottom: IronSpacing.s),
              child: primary
                  ? FilledButton(
                      autofocus: true,
                      onPressed: () => Navigator.of(context).pop(action),
                      child: Text(label),
                    )
                  : OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(action),
                      child: Text(label),
                    ),
            );
        return _panelShell(
          context,
          width: 360,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('PAUSED', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: IronSpacing.l),
              item('RESUME', PauseAction.resume, primary: true),
              item('CODEX', PauseAction.codex),
              item('QUEST LOG', PauseAction.quests),
              item('SESSION BUILDER', PauseAction.session),
              item('IRON MAP', PauseAction.map),
              item('ARENA', PauseAction.arena),
              item('SETTINGS', PauseAction.settings),
              const SizedBox(height: IronSpacing.s),
              TextButton(
                onPressed: () => Navigator.of(context).pop(PauseAction.title),
                child: const Text('RETURN TO TITLE'),
              ),
            ],
          ),
        );
      },
    );

/// Maps a pause action to its route (null for resume/title).
String? routeForPauseAction(PauseAction action) => switch (action) {
  PauseAction.codex => Routes.codex,
  PauseAction.quests => Routes.quests,
  PauseAction.session => Routes.session,
  PauseAction.map => Routes.map,
  PauseAction.arena => Routes.arena,
  PauseAction.settings => Routes.settings,
  PauseAction.resume || PauseAction.title => null,
};
