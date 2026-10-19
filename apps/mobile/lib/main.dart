import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/secure_token_store.dart';
import 'dependencies.dart';
import 'server_address.dart';

import 'package:ui/ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDomainTimeZones();
  await initializeDateFormatting(serbianLatin);
  if (kDebugMode) Bloc.observer = ConsoleBlocObserver(debugPrint);
  runApp(
    RafstoranApp(
      dependencies: AppDependencies.server(baseUri: serverAddress(), tokens: const SecureTokenStore()),
    ),
  );
}
