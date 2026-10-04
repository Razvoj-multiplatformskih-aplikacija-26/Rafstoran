import 'package:domain/domain.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'dependencies.dart';

void main() {
  initializeDomainTimeZones();
  runApp(RafstoranApp(dependencies: AppDependencies.fake()));
}
