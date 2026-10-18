import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import 'dependencies.dart';
import 'router.dart';

class BackofficeApp extends StatefulWidget {
  const BackofficeApp({super.key, required this.dependencies});

  static const locale = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

  final BackofficeDependencies dependencies;

  @override
  State<BackofficeApp> createState() => _BackofficeAppState();
}

class _BackofficeAppState extends State<BackofficeApp> {
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
    if (!user.role.isStaff) {
      await widget.dependencies.logOut();
      setState(() => _notice = 'Backoffice je za osoblje restorana.');
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
              key: ValueKey('signed-out ${reason?.name} $_notice'),
              home: LoginScreen(
                title: 'Rafstoran Backoffice',
                logIn: dependencies.logIn,
                reason: reason,
                notice: _notice,
                onSignedIn: _signedIn,
              ),
            ),
            SignedIn(:final user) => _SignedInApp(key: ValueKey(user.id), staff: user, dependencies: dependencies),
          },
        ),
      ),
    );
  }
}

class _SignedInApp extends StatefulWidget {
  const _SignedInApp({super.key, required this.staff, required this.dependencies});

  final User staff;
  final BackofficeDependencies dependencies;

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
      value: widget.staff,
      child: BlocProvider(
        create: (_) => DailyScheduleBloc(
          getDailySchedule: dependencies.getDailySchedule,
          confirmReservation: dependencies.confirmReservation,
          recordArrival: dependencies.recordArrival,
          recordNoShow: dependencies.recordNoShow,
          cancelReservation: dependencies.cancelReservation,
          clock: dependencies.clock,
          staff: widget.staff,
        )..add(DailyScheduleRequested(restaurantDay(dependencies.clock.now()))),
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
      title: 'Rafstoran Backoffice',
      theme: RafTheme.light(),
      darkTheme: RafTheme.dark(),
      themeMode: ThemeMode.system,
      locale: BackofficeApp.locale,
      supportedLocales: const [BackofficeApp.locale],
      localizationsDelegates: delegates,
      routerConfig: router,
    );
  }
  return MaterialApp(
    key: key,
    title: 'Rafstoran Backoffice',
    theme: RafTheme.light(),
    darkTheme: RafTheme.dark(),
    themeMode: ThemeMode.system,
    locale: BackofficeApp.locale,
    supportedLocales: const [BackofficeApp.locale],
    localizationsDelegates: delegates,
    onGenerateInitialRoutes: (_) => [MaterialPageRoute<void>(builder: (_) => home!)],
    onGenerateRoute: (_) => MaterialPageRoute<void>(builder: (_) => home!),
  );
}
