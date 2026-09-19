// Anti-monetization surface ("Help Apps Lose Money"). Talks only to
// MonetizationService; core gameplay never depends on the entitlement.
// Without a store key every payment is refused; with a RevenueCat Test Store
// key purchases are sandbox-only. Either way the hosting ledger shows costs
// accruing against zero real revenue.
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
        final refusing = monetization is UnconfiguredMonetizationService;
        final text = Theme.of(context).textTheme;
        final headline = refusing
            ? 'Try to give us money. We will say no.'
            : monetization.isTestStore
            ? 'Buy the supporter pack with sandbox money.'
            : 'Support development and future expansion.';
        final buyLabel = state.premium
            ? 'THANK YOU'
            : refusing
            ? 'PAY ₱99 (WILL BE REFUSED)'
            : state.offeringPrice != null
            ? 'BUY SUPPORTER · ${state.offeringPrice}'
            : 'VIEW SUPPORTER OPTION';
        return IronScreen(
          title: 'Anti-Monetization',
          subtitle:
              'Category: Help Apps Lose Money. It costs us to run and earns '
              'nothing.',
          child: ListView(
            children: [
              _Ledger(service: monetization, state: state),
              const SizedBox(height: IronSpacing.l),
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
                    Text(headline, style: text.titleMedium),
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
                            child: Text(buyLabel),
                          ),
                          OutlinedButton(
                            onPressed: state.configured || refusing
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
                '${monetization.storeLabel} The RevenueCat adapter sits behind '
                'MonetizationService; core gameplay never asks it anything.',
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
  final MonetizationService service;
  final EntitlementState state;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cost = HostingLedger.runningCostPhp();
    final refusing = service is UnconfiguredMonetizationService;
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
              cell('Real revenue', '₱0.00', IronColors.hydration),
              if (refusing)
                cell(
                  'Payments refused',
                  '${state.refusedPurchases}',
                  IronColors.accentBright,
                )
              else
                cell(
                  'Sandbox entitlement',
                  state.premium ? 'ACTIVE' : 'NONE',
                  IronColors.accentBright,
                ),
            ],
          ),
          const SizedBox(height: IronSpacing.m),
          Text(
            'Vercel Pro seat at USD 20 / month '
            '(≈ ₱${HostingLedger.monthlyCostPhp.toStringAsFixed(0)}), accruing '
            'since launch on '
            '${HostingLedger.launchedAt.toIso8601String().substring(0, 10)}. '
            '${service.storeLabel}',
            style: text.bodySmall?.copyWith(color: IronColors.textMuted),
          ),
        ],
      ),
    );
  }
}
