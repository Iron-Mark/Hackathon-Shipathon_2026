// Iron Codex: a small field guide driven entirely by domain state.
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../../domain/content.dart';
import '../shared/icons.dart';
import '../shared/widgets.dart';

class CodexScreen extends StatefulWidget {
  const CodexScreen({super.key});

  @override
  State<CodexScreen> createState() => _CodexScreenState();
}

class _CodexScreenState extends State<CodexScreen> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final session = GameScope.sessionOf(context);
    final content = session.content;
    final unlocked = session.isPlaying
        ? session.player.unlockedCodexIds
        : const <String>{};
    final knowledge = session.isPlaying
        ? session.player.unlockedKnowledgeIds
        : const <String>{};
    final exercises = content.exercises.values.toList();
    final pressing = exercises
        .where((e) => e.movementRole == MovementRole.press)
        .toList();
    final isolation = exercises
        .where((e) => e.movementRole == MovementRole.isolation)
        .toList();
    final discoveredCount = exercises
        .where((e) => unlocked.contains('codex:${e.id}'))
        .length;
    final compact = IronBreakpoints.isCompact(context);

    final list = ListView(
      children: [
        Text('CHEST', style: Theme.of(context).textTheme.titleLarge),
        Text(
          '$discoveredCount / ${exercises.length} exercises discovered',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: IronColors.textMuted),
        ),
        if (discoveredCount == 0)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: IronSpacing.m),
            child: IronPanel(
              child: Text(
                'No exercises discovered yet.\n\nExplore the gym and inspect '
                'equipment.',
              ),
            ),
          ),
        const SizedBox(height: IronSpacing.l),
        _Group(
          label: 'Pressing',
          icon: IronIconKind.press,
          color: IronColors.press,
          entries: pressing,
          unlocked: unlocked,
          selected: _selected,
          onSelect: (id) => setState(() => _selected = id),
          compact: compact,
        ),
        const SizedBox(height: IronSpacing.l),
        _Group(
          label: 'Isolation',
          icon: IronIconKind.isolation,
          color: IronColors.isolation,
          entries: isolation,
          unlocked: unlocked,
          selected: _selected,
          onSelect: (id) => setState(() => _selected = id),
          compact: compact,
        ),
        const SizedBox(height: IronSpacing.xl),
        const SectionLabel('Knowledge'),
        const SizedBox(height: IronSpacing.s),
        _KnowledgeTile(
          knowledge: content.knowledge,
          unlocked: knowledge.contains(content.knowledge.id),
        ),
      ],
    );

    final detail = _selected == null
        ? null
        : _EntryDetail(
            exercise: content.exercises[_selected]!,
            unlocked: unlocked.contains('codex:$_selected'),
          );

    return IronScreen(
      title: 'Iron Codex',
      subtitle: 'Discovered exercise knowledge',
      maxWidth: 960,
      child: compact || detail == null
          ? list
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 4, child: list),
                const SizedBox(width: IronSpacing.xl),
                Expanded(flex: 5, child: SingleChildScrollView(child: detail)),
              ],
            ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.label,
    required this.icon,
    required this.color,
    required this.entries,
    required this.unlocked,
    required this.selected,
    required this.onSelect,
    required this.compact,
  });
  final String label;
  final IronIconKind icon;
  final Color color;
  final List<Exercise> entries;
  final Set<String> unlocked;
  final String? selected;
  final ValueChanged<String> onSelect;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IronIcon(icon, size: 16, color: color),
            const SizedBox(width: IronSpacing.s),
            Text(
              label.toUpperCase(),
              style: text.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: IronSpacing.s),
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: IronSpacing.s),
            child: _EntryTile(
              exercise: e,
              unlocked: unlocked.contains('codex:${e.id}'),
              selected: selected == e.id,
              onTap: () => unlocked.contains('codex:${e.id}')
                  ? (compact ? _showDetail(context, e) : onSelect(e.id))
                  : null,
            ),
          ),
      ],
    );
  }

  void _showDetail(BuildContext context, Exercise e) {
    showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(IronSpacing.l),
        child: Padding(
          padding: const EdgeInsets.all(IronSpacing.xl),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EntryDetail(exercise: e, unlocked: true),
                const SizedBox(height: IronSpacing.l),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('CLOSE'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.exercise,
    required this.unlocked,
    required this.selected,
    required this.onTap,
  });
  final Exercise exercise;
  final bool unlocked, selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: unlocked,
      label: unlocked ? exercise.name : 'Undiscovered exercise, locked',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(IronRadius.panel),
        child: IronPanel(
          accent: selected,
          opacity: unlocked ? 0.9 : 0.5,
          child: Row(
            children: [
              IronIcon(
                unlocked ? IronIconKind.codex : IronIconKind.locked,
                size: 18,
                color: unlocked ? IronColors.accentBright : IronColors.locked,
              ),
              const SizedBox(width: IronSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unlocked ? exercise.name : '???',
                      style: text.titleMedium?.copyWith(
                        color: unlocked ? IronColors.text : IronColors.locked,
                      ),
                    ),
                    Text(
                      unlocked ? 'Discovered' : 'Undiscovered',
                      style: text.bodySmall?.copyWith(
                        color: IronColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (unlocked)
                RoleChip(isPress: exercise.movementRole == MovementRole.press),
            ],
          ),
        ),
      ),
    );
  }
}

class _EntryDetail extends StatelessWidget {
  const _EntryDetail({required this.exercise, required this.unlocked});
  final Exercise exercise;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    if (!unlocked) {
      return const IronPanel(child: Text('???\nUndiscovered'));
    }
    Widget field(String label, String value) => Padding(
      padding: const EdgeInsets.only(bottom: IronSpacing.s),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [SectionLabel(label), Text(value)],
      ),
    );
    return IronPanel(
      padding: const EdgeInsets.all(IronSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(exercise.name.toUpperCase(), style: text.titleLarge),
          const SizedBox(height: IronSpacing.s),
          Row(
            children: [
              RoleChip(isPress: exercise.movementRole == MovementRole.press),
              const SizedBox(width: IronSpacing.s),
              Text(
                exercise.emphasis.map(humanize).join(', '),
                style: text.bodySmall?.copyWith(color: IronColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: IronSpacing.l),
          field('Category', 'Chest / ${humanize(exercise.category)}'),
          field('Primary', exercise.primaryMuscles.map(humanize).join(', ')),
          field(
            'Secondary',
            exercise.secondaryMuscles.isEmpty
                ? 'None'
                : exercise.secondaryMuscles.map(humanize).join(', '),
          ),
          field('Equipment', exercise.equipment.map(humanize).join(', ')),
          const SizedBox(height: IronSpacing.s),
          const SectionLabel('What it does'),
          const SizedBox(height: IronSpacing.xs),
          Text(exercise.summary),
          const SizedBox(height: IronSpacing.l),
          const SectionLabel('Technique'),
          const SizedBox(height: IronSpacing.xs),
          CueList(exercise.techniqueNotes),
          const SizedBox(height: IronSpacing.l),
          Text(
            'Training cost: fatigue +${exercise.fatigueCost}, hydration '
            '-${exercise.hydrationCost}, base XP ${exercise.xpReward}',
            style: text.bodySmall?.copyWith(color: IronColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _KnowledgeTile extends StatelessWidget {
  const _KnowledgeTile({required this.knowledge, required this.unlocked});
  final KnowledgeUnlock knowledge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return IronPanel(
      accent: unlocked,
      opacity: unlocked ? 0.9 : 0.5,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IronIcon(
            unlocked ? IronIconKind.xp : IronIconKind.locked,
            size: 18,
            color: unlocked ? IronColors.xp : IronColors.locked,
          ),
          const SizedBox(width: IronSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unlocked ? knowledge.name.toUpperCase() : '???',
                  style: text.titleMedium?.copyWith(
                    color: unlocked ? IronColors.text : IronColors.locked,
                  ),
                ),
                const SizedBox(height: IronSpacing.xs),
                Text(
                  unlocked
                      ? knowledge.summary
                      : 'Complete Build Your First Chest Day to unlock.',
                  style: text.bodyMedium?.copyWith(
                    color: unlocked ? IronColors.text : IronColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
