import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:ui/ui.dart';

import 'console/console_bloc.dart';
import 'data/local_system.dart';
import 'data/scenarios.dart';
import 'data/server_calls.dart';
import 'screens/console_screen.dart';

class ConsoleApp extends StatelessWidget {
  const ConsoleApp({
    super.key,
    required this.client,
    required this.server,
    required this.local,
    this.now = DateTime.now,
  });

  static const locale = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

  final http.Client client;
  final Uri server;
  final LocalSystem local;
  final DateTime Function() now;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => ConsoleBloc(
      scenarios: ScenarioRunner(
        calls: ServerCalls(client: client, server: server),
        local: local,
        now: now,
      ),
      now: now,
    ),
    child: MaterialApp(
      title: 'Rafstoran Console',
      theme: RafTheme.light(),
      darkTheme: RafTheme.dark(),
      themeMode: ThemeMode.system,
      locale: locale,
      supportedLocales: const [locale],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: ConsoleScreen(server: server, localCommands: local.available),
    ),
  );
}
