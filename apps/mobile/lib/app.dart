import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'router.dart';
import 'theme/theme.dart';

class RafstoranApp extends StatelessWidget {
  const RafstoranApp({super.key});

  static const locale = Locale.fromSubtags(languageCode: 'sr', scriptCode: 'Latn');

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Rafstoran',
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
      routerConfig: router,
    );
  }
}
