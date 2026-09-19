// Arena preview: future asynchronous leagues, presentation only.
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../shared/widgets.dart';

class CompetitionPreviewScreen extends StatelessWidget {
  const CompetitionPreviewScreen({super.key});

  static const _descriptions = {
    'Physique': 'Development, balance and conditioning judged over a season.',
    'Strength': 'Squat, bench, deadlift and total.',
    'Endurance': 'Time trials, intervals and distance scores.',
    'Hybrid': 'Strength and conditioning combined.',
  };

  @override
  Widget build(BuildContext context) {
    final session = GameScope.sessionOf(context);
    final leagues = session.content.district.leagues;
    final text = Theme.of(context).textTheme;
    return IronScreen(
      title: 'Arena',
      subtitle: 'Asynchronous competition arrives after the first districts.',
      child: ListView(
        children: [
          for (final league in leagues)
            Padding(
              padding: const EdgeInsets.only(bottom: IronSpacing.s),
              child: IronPanel(
                opacity: 0.7,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${league.toUpperCase()} LEAGUE',
                            style: text.titleMedium,
                          ),
                          Text(
                            _descriptions[league] ?? '',
                            style: text.bodySmall?.copyWith(
                              color: IronColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'COMING SOON',
                      style: text.labelSmall?.copyWith(
                        color: IronColors.accentBright,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: IronSpacing.l),
          Text(
            'Leaderboards will be asynchronous. Solo play never requires them.',
            style: text.bodySmall?.copyWith(color: IronColors.textMuted),
          ),
        ],
      ),
    );
  }
}
