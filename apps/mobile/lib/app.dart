import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'dependencies.dart';
import 'router.dart';

import 'package:ui/ui.dart';

class RafstoranApp extends StatefulWidget {
  const RafstoranApp({super.key, required this.dependencies});

  static const locale = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

  final AppDependencies dependencies;

  @override
  State<RafstoranApp> createState() => _RafstoranAppState();
}

class _RafstoranAppState extends State<RafstoranApp> {
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
      value: dependencies,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                AvailableSlotsBloc(getAvailableSlots: dependencies.getAvailableSlots, clock: dependencies.clock)
                  ..add(const AvailableSlotsRequested()),
          ),
          BlocProvider(
            create: (_) => MyReservationsBloc(
              getMyReservations: dependencies.getMyReservations,
              cancelReservation: dependencies.cancelReservation,
              clock: dependencies.clock,
              guest: dependencies.user,
            )..add(const MyReservationsRequested()),
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
    );
  }
}
