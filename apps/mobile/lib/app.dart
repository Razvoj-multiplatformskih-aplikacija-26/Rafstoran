import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import 'dependencies.dart';
import 'router.dart';

class RafstoranApp extends StatefulWidget {
  const RafstoranApp({super.key, required this.dependencies});

  static const locale = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

  final AppDependencies dependencies;

  @override
  State<RafstoranApp> createState() => _RafstoranAppState();
}

class _RafstoranAppState extends State<RafstoranApp> {
  late final SessionBloc _session = SessionBloc(
    restoreSession: widget.dependencies.restoreSession,
    logOut: widget.dependencies.logOut,
    expirations: widget.dependencies.sessionExpirations,
  )..add(const SessionRestoreRequested());

  @override
  void dispose() {
    _session.close();
    super.dispose();
  }

  String? _notice;

  Future<void> _signedIn(User user) async {
    if (user.role != Role.guest) {
      await widget.dependencies.logOut();
      setState(() => _notice = 'Aplikacija je za goste. Osoblje koristi backoffice.');
      return;
    }
    _notice = null;
    _session.add(SessionStarted(user));
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return RepositoryProvider.value(
      value: dependencies,
      child: BlocProvider.value(
        value: _session,
        child: BlocBuilder<SessionBloc, SessionState>(
          builder: (context, session) => switch (session) {
            SessionUnknown() => _material(
              key: const ValueKey('session-unknown'),
              home: const Scaffold(body: Center(child: CircularProgressIndicator())),
            ),
            SignedOut(:final reason) => _material(
              key: const ValueKey('signed-out'),
              home: LoginScreen(
                title: 'Rafstoran',
                logIn: dependencies.logIn,
                reason: reason,
                notice: _notice,
                onSignedIn: _signedIn,
              ),
            ),
            SignedIn(:final user) => _SignedInApp(key: ValueKey(user.id), user: user, dependencies: dependencies),
          },
        ),
      ),
    );
  }
}

class _SignedInApp extends StatefulWidget {
  const _SignedInApp({super.key, required this.user, required this.dependencies});

  final User user;
  final AppDependencies dependencies;

  @override
  State<_SignedInApp> createState() => _SignedInAppState();
}

class _SignedInAppState extends State<_SignedInApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dependencies = widget.dependencies;
    return RepositoryProvider.value(
      value: widget.user,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AvailableSlotsBloc(
              getAvailableSlots: dependencies.getAvailableSlots,
              clock: dependencies.clock,
              user: dependencies.user,
            )..add(const AvailableSlotsRequested()),
          ),
          BlocProvider(
            create: (_) => MyReservationsBloc(
              getMyReservations: dependencies.getMyReservations,
              cancelReservation: dependencies.cancelReservation,
              clock: dependencies.clock,
              guest: widget.user,
            )..add(const MyReservationsRequested()),
          ),
        ],
        child: _material(router: _router),
      ),
    );
  }
}

Widget _material({Key? key, Widget? home, GoRouter? router}) {
  const delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
  if (router != null) {
    return MaterialApp.router(
      key: key,
      title: 'Rafstoran',
      theme: RafTheme.light(),
      darkTheme: RafTheme.dark(),
      themeMode: ThemeMode.system,
      locale: RafstoranApp.locale,
      supportedLocales: const [RafstoranApp.locale],
      localizationsDelegates: delegates,
      routerConfig: router,
    );
  }
  return MaterialApp(
    key: key,
    title: 'Rafstoran',
    theme: RafTheme.light(),
    darkTheme: RafTheme.dark(),
    themeMode: ThemeMode.system,
    locale: RafstoranApp.locale,
    supportedLocales: const [RafstoranApp.locale],
    localizationsDelegates: delegates,
    onGenerateInitialRoutes: (_) => [MaterialPageRoute<void>(builder: (_) => home!)],
    onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => home!),
  );
}
