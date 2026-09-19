import 'package:flutter/material.dart';

import '../../app/app.dart';
import '../../app/theme.dart';
import '../../application/game_session.dart';
import '../shared/widgets.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = GameScope.sessionOf(context);
    final text = Theme.of(context).textTheme;
    final compact = IronBreakpoints.isCompact(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF23262C), Color(0xFF14161A), Color(0xFF1B1611)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(IronSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 4,
                      width: 72,
                      color: IronColors.accent,
                      margin: const EdgeInsets.only(bottom: IronSpacing.m),
                    ),
                    Text(
                      'IRON ASCENT',
                      style: compact ? text.headlineMedium : text.displayLarge,
                    ),
                    const SizedBox(height: IronSpacing.xs),
                    Text(
                      'Learn fitness by playing it.',
                      style: text.bodyLarge?.copyWith(
                        color: IronColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: IronSpacing.xxl),
                    ListenableBuilder(
                      listenable: session,
                      builder: (context, _) => _MenuBody(session: session),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuBody extends StatelessWidget {
  const _MenuBody({required this.session});
  final GameSession session;

  @override
  Widget build(BuildContext context) {
    switch (session.phase) {
      case SessionPhase.loading:
        return const IronPanel(
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: IronSpacing.m),
              Text('Loading gym content...'),
            ],
          ),
        );
      case SessionPhase.contentError:
        return IronPanel(
          accent: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Exercise data unavailable.'),
              const SizedBox(height: IronSpacing.s),
              Text(
                session.contentError ?? '',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: IronColors.textMuted),
              ),
              const SizedBox(height: IronSpacing.m),
              FilledButton(
                onPressed: session.initialize,
                child: const Text('RETRY'),
              ),
            ],
          ),
        );
      case SessionPhase.menu:
      case SessionPhase.playing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (session.saveCorrupt || session.saveError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: IronSpacing.m),
                child: IronPanel(
                  accent: true,
                  child: Text(
                    session.saveCorrupt
                        ? 'Your previous save could not be read. New Game '
                              'will start fresh; nothing is deleted until then.'
                        : session.saveError!,
                  ),
                ),
              ),
            if (session.hasExistingSave)
              FilledButton(
                autofocus: true,
                onPressed: () {
                  if (session.continueGame()) {
                    Navigator.of(context).pushNamed(Routes.game);
                  }
                },
                child: const Text('CONTINUE'),
              ),
            if (session.hasExistingSave) const SizedBox(height: IronSpacing.m),
            session.hasExistingSave
                ? OutlinedButton(
                    onPressed: () => _confirmNewGame(context),
                    child: const Text('NEW GAME'),
                  )
                : FilledButton(
                    autofocus: true,
                    onPressed: () => _startNewGame(context),
                    child: const Text('NEW GAME'),
                  ),
            const SizedBox(height: IronSpacing.m),
            OutlinedButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
              child: const Text('SETTINGS'),
            ),
            const SizedBox(height: IronSpacing.m),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(Routes.support),
              child: const Text('SUPPORT / PREMIUM'),
            ),
            const SizedBox(height: IronSpacing.xl),
            Text(
              'Build Your First Chest Day',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
    }
  }

  void _startNewGame(BuildContext context) {
    session.startNewGame();
    Navigator.of(context).pushNamed(Routes.game);
  }

  Future<void> _confirmNewGame(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('START A NEW GAME?'),
        content: const Text(
          'Your current chest-day progress will be replaced.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('KEEP SAVE'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('NEW GAME'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) _startNewGame(context);
  }
}
