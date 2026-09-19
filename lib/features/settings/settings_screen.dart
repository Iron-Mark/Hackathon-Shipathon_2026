import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../../domain/player.dart';
import '../shared/widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = GameScope.sessionOf(context);
    return ListenableBuilder(
      listenable: session,
      builder: (context, _) {
        final s = session.settings;
        final text = Theme.of(context).textTheme;
        void update(GameSettings next) => session.updateSettings(next);
        return IronScreen(
          title: 'Settings',
          child: ListView(
            children: [
              IronPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Audio volume'),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: s.audioVolume,
                            onChanged: (v) =>
                                update(s.copyWith(audioVolume: v)),
                            semanticFormatterCallback: (v) =>
                                '${(v * 100).round()} percent',
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '${(s.audioVolume * 100).round()}%',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Reduced motion'),
                      subtitle: const Text(
                        'Calmer camera, simpler feedback and a slower training '
                        'timing window. Progression is unchanged.',
                      ),
                      value: s.reducedMotion,
                      onChanged: (v) => update(s.copyWith(reducedMotion: v)),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Control hints'),
                      subtitle: const Text(
                        'Show control reminders in the HUD.',
                      ),
                      value: s.controlHints,
                      onChanged: (v) => update(s.copyWith(controlHints: v)),
                    ),
                    const Divider(),
                    const SectionLabel('Graphics quality'),
                    const SizedBox(height: IronSpacing.s),
                    SegmentedButton<String>(
                      segments: [
                        for (final q in GameSettings.graphicsOptions)
                          ButtonSegment(value: q, label: Text(q.toUpperCase())),
                      ],
                      selected: {s.graphicsQuality},
                      onSelectionChanged: (v) =>
                          update(s.copyWith(graphicsQuality: v.first)),
                    ),
                    Text(
                      'Applies the next time the gym loads.',
                      style: text.bodySmall?.copyWith(
                        color: IronColors.textMuted,
                      ),
                    ),
                    const Divider(),
                    const SectionLabel('Text size'),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: s.textScale,
                            min: 1,
                            max: 1.5,
                            divisions: 5,
                            onChanged: (v) => update(s.copyWith(textScale: v)),
                            semanticFormatterCallback: (v) =>
                                '${(v * 100).round()} percent',
                          ),
                        ),
                        SizedBox(
                          width: 48,
                          child: Text(
                            '${(s.textScale * 100).round()}%',
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: IronSpacing.l),
              IronPanel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionLabel('Save data'),
                    const SizedBox(height: IronSpacing.s),
                    Text(
                      session.hasExistingSave || session.isPlaying
                          ? 'A chest-day save exists on this device.'
                          : 'No save on this device.',
                    ),
                    const SizedBox(height: IronSpacing.m),
                    OutlinedButton(
                      onPressed: (session.hasExistingSave || session.isPlaying)
                          ? () => _confirmReset(context)
                          : null,
                      child: const Text('RESET SAVE'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final session = GameScope.sessionOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('RESET SAVE?'),
        content: const Text(
          'Level, XP, condition, quest progress, discoveries and Codex '
          'unlocks will be cleared. Settings and any supporter purchase '
          'are kept.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    await session.resetSave();
    if (!context.mounted) return;
    Navigator.of(context).popUntil((r) => r.settings.name == Routes.menu);
  }
}
