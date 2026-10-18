import 'package:api_client/api_client.dart';
import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:session_storage/session_storage.dart';
import 'package:ui/ui.dart';

import 'app.dart';
import 'dependencies.dart';

Future<void> main() async {
  usePathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  initializeDomainTimeZones();
  await initializeDateFormatting(serbianLatin);
  if (kDebugMode) Bloc.observer = ConsoleBlocObserver(debugPrint);
  runApp(
    BackofficeApp(
      dependencies: BackofficeDependencies.server(
        baseUri: Uri.parse(const String.fromEnvironment('SERVER_URL', defaultValue: 'http://localhost:8080')),
        tokens: kIsWeb ? MemoryTokenStore() : const SecureTokenStore(),
      ),
    ),
  );
}
