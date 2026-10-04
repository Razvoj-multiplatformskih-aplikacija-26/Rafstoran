import 'package:domain/domain.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ui/ui.dart';

import 'app.dart';
import 'dependencies.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDomainTimeZones();
  await initializeDateFormatting(serbianLatin);
  runApp(BackofficeApp(dependencies: BackofficeDependencies.fake()));
}
