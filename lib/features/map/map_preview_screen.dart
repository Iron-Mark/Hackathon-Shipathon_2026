// Iron Map preview: communicates the larger world without building it.
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../shared/icons.dart';
import '../shared/widgets.dart';

class MapPreviewScreen extends StatelessWidget {
  const MapPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = GameScope.sessionOf(context);
    final previews = session.content.district.previews;
    final text = Theme.of(context).textTheme;
    return IronScreen(
      title: 'Iron Map',
      subtitle: 'One district is open. The rest of the map is coming.',
      child: ListView(
        children: [
          for (final p in previews)
            Padding(
              padding: const EdgeInsets.only(bottom: IronSpacing.s),
              child: _DistrictTile(name: p['name']!, state: p['state']!),
            ),
          const SizedBox(height: IronSpacing.l),
          Text(
            'Travel between districts is not part of this vertical slice.',
            style: text.bodySmall?.copyWith(color: IronColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _DistrictTile extends StatelessWidget {
  const _DistrictTile({required this.name, required this.state});
  final String name, state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final available = state == 'AVAILABLE';
    final future = state == 'FUTURE';
    final color = available
        ? IronColors.success
        : future
        ? IronColors.textMuted
        : IronColors.locked;
    return Semantics(
      label: '$name, $state',
      child: IronPanel(
        accent: available,
        opacity: available ? 0.95 : 0.6,
        child: Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: available ? IronColors.accentBright : Colors.transparent,
                border: Border.all(color: color, width: 2),
              ),
            ),
            const SizedBox(width: IronSpacing.l),
            Expanded(
              child: Text(
                name,
                style: text.titleMedium?.copyWith(
                  color: available ? IronColors.text : IronColors.textMuted,
                ),
              ),
            ),
            if (!available)
              IronIcon(IronIconKind.locked, size: 16, color: color),
            const SizedBox(width: IronSpacing.s),
            Text(state, style: text.labelSmall?.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}
