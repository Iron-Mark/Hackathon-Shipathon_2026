// Supporter / premium surface. Talks only to MonetizationService; core
// gameplay never depends on the entitlement.
import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../../infrastructure/monetization.dart';
import '../shared/icons.dart';
import '../shared/widgets.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final monetization = GameScope.of(context).monetization;
    return ListenableBuilder(
      listenable: monetization,
      builder: (context, _) {
        final state = monetization.state;
        final text = Theme.of(context).textTheme;
        return IronScreen(
          title: 'Iron Ascent Supporter',
          child: ListView(
            children: [
              IronPanel(
                accent: state.premium,
                padding: const EdgeInsets.all(IronSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IronIcon(
                          state.premium ? IronIconKind.check : IronIconKind.xp,
                          size: 18,
                          color: state.premium
                              ? IronColors.success
                              : IronColors.xp,
                        ),
                        const SizedBox(width: IronSpacing.s),
                        Text(
                          state.premium ? 'SUPPORTER ACTIVE' : 'SUPPORTER',
                          style: text.labelSmall?.copyWith(
                            color: state.premium
                                ? IronColors.success
                                : IronColors.xp,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: IronSpacing.m),
                    Text(
                      'Support development and future expansion.',
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: IronSpacing.s),
                    Text(
                      'Core fitness education remains playable without '
                      'purchase. Supporters unlock future premium districts '
                      'and programming quests when they arrive.',
                      style: text.bodyMedium?.copyWith(height: 1.4),
                    ),
                    if (state.offeringTitle != null) ...[
                      const SizedBox(height: IronSpacing.m),
                      Text(
                        '${state.offeringTitle}  ${state.offeringPrice ?? ''}',
                        style: text.bodyMedium,
                      ),
                    ],
                    const SizedBox(height: IronSpacing.xl),
                    if (state.loading)
                      const Row(
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: IronSpacing.m),
                          Text('Contacting store...'),
                        ],
                      )
                    else
                      Wrap(
                        spacing: IronSpacing.m,
                        runSpacing: IronSpacing.s,
                        children: [
                          FilledButton(
                            onPressed:
                                state.configured && state.purchaseSupported
                                ? monetization.purchaseSupporter
                                : null,
                            child: Text(
                              state.premium
                                  ? 'THANK YOU'
                                  : 'VIEW SUPPORTER OPTION',
                            ),
                          ),
                          OutlinedButton(
                            onPressed: state.configured
                                ? monetization.restorePurchases
                                : null,
                            child: const Text('RESTORE PURCHASE'),
                          ),
                        ],
                      ),
                    if (!state.configured || state.error != null) ...[
                      const SizedBox(height: IronSpacing.l),
                      Text(
                        state.configured
                            ? state.error!
                            : MonetizationService.unavailableMessage,
                        style: text.bodySmall?.copyWith(
                          color: IronColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: IronSpacing.l),
              Text(
                'Purchases are handled by the platform store through '
                'RevenueCat. Nothing in the chest-day loop, hydration, '
                'recovery or the Codex is locked behind payment.',
                style: text.bodySmall?.copyWith(color: IronColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}
