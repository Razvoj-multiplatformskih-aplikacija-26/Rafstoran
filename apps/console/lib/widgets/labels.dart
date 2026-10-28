import 'package:domain/domain.dart';
import 'package:ui/ui.dart';

import '../data/scenarios.dart';

const callers = {
  UserId('u-ana'): 'Ana Petrović, gost',
  UserId('u-marko'): 'Marko Jovanović, gost',
  UserId('u-guest'): 'Gost',
  UserId('u-waiter'): 'Marija Kostić, konobar',
};

String callerLabel(UserId caller) => callers[caller] ?? caller.value;

String whoLabel(Scenario scenario, UserId caller) => switch (scenario) {
  LocalStep() => 'na ovom računaru',
  _ => callerLabel(caller),
};

String noteLabel(int length) => 'Napomena od $length ${pluralize(length, one: 'znaka', few: 'znaka', many: 'znakova')}';

String clockLabel(DateTime at) => [at.hour, at.minute, at.second].map((part) => '$part'.padLeft(2, '0')).join(':');

String reasonPhrase(int status) => switch (status) {
  200 => 'OK',
  201 => 'Created',
  400 => 'Bad Request',
  403 => 'Forbidden',
  404 => 'Not Found',
  409 => 'Conflict',
  413 => 'Content Too Large',
  415 => 'Unsupported Media Type',
  422 => 'Unprocessable Content',
  500 => 'Internal Server Error',
  _ => '',
};
