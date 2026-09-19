// Supporter / premium surface. Talks only to MonetizationService; core
// gameplay never depends on the entitlement. Without a store key it becomes
// the anti-monetization ledger: costs accrue, earnings stay at zero, and every
// payment attempt is politely refused.
import 'dart:async';

import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../../infrastructure/monetization.dart';
import '../shared/icons.dart';
import '../shared/widgets.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final monetization = GameScope.of(context).monetization;
    return ListenableBuilder(
      listenable: monetization,
      builder: (context, _) {
        final state = monetization.state;
        final ledger = monetization is UnconfiguredMonetizationService
            ? monetization
            : null;
        final text = Theme.of(context).textTheme;
        return IronScreen(
          title: ledger == null ? 'Iron Ascent Supporter' : 'Anti-Monetization',
          subtitle: ledger == null ? null : 'Category: Help Apps Lose Money. It costs us to run and earns nothing.',
          child: ListView(
            children: [
              if (ledger != null) _Ledger(service: ledger, state: state),
              if (ledger != null) const SizedBox(height: IronSpacing.l),
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
                      ledger == null
                          ? 'Support development and future expansion.'
                          : 'Try to give us money. We will say no.',
                      style: text.titleMedium,
                    ),
                    const SizedBox(height: IronSpacing.s),
                    Text(
                      'Core fitness education remains playable without '
                      'purchase. Nothing in the chest-day loop, hydration, '
                      'recovery or the Codex is locked behind payment.',
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
                            onPressed: state.purchaseSupported
                                ? monetization.purchaseSupporter
                                : null,
                            child: Text(
                              state.premium
                                  ? 'THANK YOU'
                                  : ledger == null
                                  ? 'VIEW SUPPORTER OPTION'
                                  : 'PAY ₱99 (WILL BE REFUSED)',
                            ),
                          ),
                          OutlinedButton(
                            onPressed: state.configured || ledger != null
                                ? monetization.restorePurchases
                                : null,
                            child: const Text('RESTORE PURCHASE'),
                          ),
                        ],
                      ),
                    if (state.error != null) ...[
                      const SizedBox(height: IronSpacing.l),
                      Text(
                        state.error!,
                        style: text.bodyMedium?.copyWith(
                          color: IronColors.accentBright,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: IronSpacing.l),
              Text(
                ledger == null
                    ? 'Purchases are handled by the platform store through '
                          'RevenueCat.'
                    : 'The RevenueCat adapter is fully wired behind '
                          'MonetizationService; this build simply ships '
                          'without a store key, so the adapter refuses instead '
                          'of charging. Add REVENUECAT_API_KEY to turn it into '
                          'a real store.',
                style: text.bodySmall?.copyWith(color: IronColors.textMuted),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Ledger extends StatelessWidget {
  const _Ledger({required this.service, required this.state});
  final UnconfiguredMonetizationService service;
  final EntitlementState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cost = service.runningCostPhp();
    Widget cell(String label, String value, Color color) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(label),
          const SizedBox(height: IronSpacing.xs),
          Text(
            value,
            style: text.headlineMedium?.copyWith(
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
    return IronPanel(
      accent: true,
      padding: const EdgeInsets.all(IronSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              cell(
                'Hosting cost so far',
                '₱${cost.toStringAsFixed(4)}',
                IronColors.fatigue,
              ),
              cell('Earned', '₱0.00', IronColors.hydration),
              cell(
                'Payments refused',
                '${state.refusedPurchases}',
                IronColors.accentBright,
              ),
            ],
          ),
          const SizedBox(height: IronSpacing.m),
          Text(
            'Vercel Pro seat at USD 20 / month (≈ ₱${UnconfiguredMonetizationService.monthlyCostPhp.toStringAsFixed(0)}), '
            'accruing since launch on ${service.launchedAt.toIso8601String().substring(0, 10)}. '
            'Revenue is structurally impossible: no ads, no unlocks, no key.',
            style: text.bodySmall?.copyWith(color: IronColors.textMuted),
          ),
        ],
      ),
    );
  }
}
