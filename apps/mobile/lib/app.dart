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
    admits: AccessPolicy.canHoldReservation,
    expirations: widget.dependencies.sessionExpirations,
  )..add(const SessionRestoreRequested());
  late final AvailableSlotsBloc _slots = AvailableSlotsBloc(
    getAvailableSlots: widget.dependencies.getAvailableSlots,
    clock: widget.dependencies.clock,
    user: null,
  )..add(const AvailableSlotsRequested());
  late final MyReservationsBloc _reservations = MyReservationsBloc(
    getMyReservations: widget.dependencies.getMyReservations,
    cancelReservation: widget.dependencies.cancelReservation,
    clock: widget.dependencies.clock,
  );
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    _reservations.close();
    _slots.close();
    _session.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: widget.dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _session),
          BlocProvider.value(value: _slots),
          BlocProvider.value(value: _reservations),
        ],
        child: MultiBlocListener(
          listeners: [
            BlocListener<SessionBloc, SessionState>(
              listenWhen: (previous, current) => current is! SessionUnknown,
              listener: (context, session) => _reservations.add(
                MyReservationsGuestChanged(switch (session) {
                  SignedIn(:final user) => user,
                  _ => null,
                }),
              ),
            ),
            BlocListener<SessionBloc, SessionState>(
              listenWhen: (previous, current) =>
                  previous is SignedIn && current is SignedOut && current.reason == SignOutReason.expired,
              listener: (context, session) => _router.push('/login'),
            ),
          ],
          child: MaterialApp.router(
            title: 'Rafstoran',
            theme: RafTheme.light(),
            darkTheme: RafTheme.dark(),
            themeMode: ThemeMode.system,
            locale: RafstoranApp.locale,
            supportedLocales: const [RafstoranApp.locale],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          ),
        ),
      ),
    );
  }
}
