// Small reusable presentation pieces shared by HUD, panels and screens.
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import 'icons.dart';

/// Translucent, bordered panel embedded into the game presentation.
class IronPanel extends StatelessWidget {
  const IronPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(IronSpacing.m),
    this.opacity = 0.82,
    this.accent = false,
    this.width,
  });
  final Widget child;
  final EdgeInsets padding;
  final double opacity;
  final bool accent;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: IronColors.surface.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(IronRadius.panel),
        border: Border.all(
          color: accent ? IronColors.accent : IronColors.border,
          width: accent ? 1.5 : 1,
        ),
      ),
      // Ink effects of tiles/buttons inside the panel paint on this surface.
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.color});
  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: color ?? IronColors.textMuted),
  );
}

/// Icon + label + numeric value (+ compact bar). Never color-only.
class StatusRow extends StatelessWidget {
  const StatusRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.compact = false,
  });
  final IronIconKind icon;
  final String label;
  final int value;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      label: '$label $value of 100',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IronIcon(icon, size: compact ? 16 : 18, color: color),
          const SizedBox(width: IronSpacing.s),
          SizedBox(
            width: compact ? 74 : 92,
            child: Text(
              label.toUpperCase(),
              style: text.labelSmall?.copyWith(color: IronColors.text),
            ),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$value',
              textAlign: TextAlign.right,
              style: text.titleMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(width: IronSpacing.s),
          SizedBox(
            width: compact ? 40 : 64,
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: value / 100,
                backgroundColor: IronColors.surfaceRaised,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Screen scaffold used by every non-gameplay surface: title, back, body.
class IronScreen extends StatelessWidget {
  const IronScreen({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.maxWidth = 720,
    this.actions = const [],
  });
  final String title;
  final String? subtitle;
  final Widget child;
  final double maxWidth;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final compact = IronBreakpoints.isCompact(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.all(compact ? IronSpacing.l : IronSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      if (Navigator.of(context).canPop())
                        Semantics(
                          button: true,
                          label: 'Back',
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            child: const Text('BACK'),
                          ),
                        ),
                      const SizedBox(width: IronSpacing.l),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title.toUpperCase(),
                              style: compact
                                  ? text.titleLarge
                                  : text.headlineMedium,
                            ),
                            if (subtitle != null)
                              Text(
                                subtitle!,
                                style: text.bodyMedium?.copyWith(
                                  color: IronColors.textMuted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      ...actions,
                    ],
                  ),
                  const SizedBox(height: IronSpacing.l),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RoleChip extends StatelessWidget {
  const RoleChip({super.key, required this.isPress});
  final bool isPress;

  @override
  Widget build(BuildContext context) {
    final color = isPress ? IronColors.press : IronColors.isolation;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(IronRadius.small),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IronIcon(
            isPress ? IronIconKind.press : IronIconKind.isolation,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            isPress ? 'PRESS' : 'ISOLATION',
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

/// A short list of bullet cues.
class CueList extends StatelessWidget {
  const CueList(this.cues, {super.key});
  final List<String> cues;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final cue in cues)
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '•  ',
                style: TextStyle(color: IronColors.accentBright),
              ),
              Expanded(child: Text(cue)),
            ],
          ),
        ),
    ],
  );
}
