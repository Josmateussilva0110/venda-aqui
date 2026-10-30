import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../core/widgets/app_feedback.dart';
import '../features/auth/presentation/controllers/session_controller.dart';
import '../l10n/app_localizations.dart';
import 'dependencies.dart';
import 'router.dart';

class VendaquiApp extends StatefulWidget {
  const VendaquiApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<VendaquiApp> createState() => _VendaquiAppState();
}

class _VendaquiAppState extends State<VendaquiApp> {
  late final GoRouter _router;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    final session = widget.dependencies.sessionController;
    _router = buildRouter(session);
    session.restore();
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: widget.dependencies.providers,
      // Só o MaterialApp escuta o tema: trocar claro/escuro não reconstrói o resto da árvore por fora dele
      child: ListenableBuilder(
        listenable: widget.dependencies.themeController,
        builder: (context, _) => MaterialApp.router(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: _messengerKey,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: widget.dependencies.themeController.mode,
          locale: const Locale('pt', 'BR'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: _router,
          builder: (context, child) => _SessionEndedNotice(messengerKey: _messengerKey, child: child ?? const SizedBox.shrink()),
        ),
      ),
    );
  }
}

/// Avisa quando o servidor encerrou a sessão (ex.: login em outro aparelho).
class _SessionEndedNotice extends StatefulWidget {
  const _SessionEndedNotice({required this.messengerKey, required this.child});

  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  State<_SessionEndedNotice> createState() => _SessionEndedNoticeState();
}

class _SessionEndedNoticeState extends State<_SessionEndedNotice> {
  late final SessionController _session;

  @override
  void initState() {
    super.initState();
    _session = context.read<SessionController>()..addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    _session.removeListener(_onSessionChanged);
    super.dispose();
  }

  void _onSessionChanged() {
    if (!_session.consumeEndedByServer()) return;
    final message = AppLocalizations.of(context).genericSessionExpired;
    widget.messengerKey.currentState?.showAppToast(message, tone: ToastTone.error);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
