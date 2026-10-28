import 'package:ui/ui.dart';

import '../data/scenarios.dart';

const accounts = {
  'guest2': 'Ana Petrović, gost',
  'guest1': 'Gost',
  'waiter1': 'Marija Kostić, konobar',
  'manager1': 'Nenad Popović, menadžer',
};

String accountLabel(String account) => accounts[account] ?? account;

String whoLabel(Scenario scenario, String account) => switch (scenario) {
  LocalStep() => 'na ovom računaru',
  _ => accountLabel(account),
};

String noteLabel(int length) => 'Napomena od $length ${pluralize(length, one: 'znaka', few: 'znaka', many: 'znakova')}';

String clockLabel(DateTime at) => [at.hour, at.minute, at.second].map((part) => '$part'.padLeft(2, '0')).join(':');

String reasonPhrase(int status) => switch (status) {
  200 => 'OK',
  201 => 'Created',
  400 => 'Bad Request',
  401 => 'Unauthorized',
  403 => 'Forbidden',
  404 => 'Not Found',
  409 => 'Conflict',
  413 => 'Content Too Large',
  415 => 'Unsupported Media Type',
  422 => 'Unprocessable Content',
  500 => 'Internal Server Error',
  _ => '',
};
