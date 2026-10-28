part of 'console_bloc.dart';

final class Call extends Equatable {
  const Call({required this.scenario, required this.account, required this.at, required this.run});

  final Scenario scenario;
  final String account;
  final DateTime at;
  final Run run;

  @override
  List<Object?> get props => [scenario, account, at, run];
}

final class ConsoleState extends Equatable {
  const ConsoleState({
    this.account = 'guest2',
    this.password = '',
    this.tokens = const {},
    this.noteLength = 201,
    this.calls = const [],
    this.selected,
    this.running = false,
  });

  final String account;
  final String password;
  final Map<String, String> tokens;
  final int noteLength;
  final List<Call> calls;
  final int? selected;
  final bool running;

  bool get signedIn => tokens.containsKey(account);

  Call? get current => switch (selected) {
    final index? => calls[index],
    null => null,
  };

  ConsoleState copyWith({
    String? account,
    String? password,
    Map<String, String>? tokens,
    int? noteLength,
    List<Call>? calls,
    int? selected,
    bool? running,
  }) => ConsoleState(
    account: account ?? this.account,
    password: password ?? this.password,
    tokens: tokens ?? this.tokens,
    noteLength: noteLength ?? this.noteLength,
    calls: calls ?? this.calls,
    selected: selected ?? this.selected,
    running: running ?? this.running,
  );

  @override
  List<Object?> get props => [account, password, tokens, noteLength, calls, selected, running];
}
