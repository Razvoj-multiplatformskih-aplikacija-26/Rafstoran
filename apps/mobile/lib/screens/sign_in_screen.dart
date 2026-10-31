import 'package:blocs/blocs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ui/ui.dart';

import '../dependencies.dart';

Future<bool> ensureSignedIn(BuildContext context) async =>
    context.read<SessionBloc>().state is SignedIn || (await context.push<bool>('/login') ?? false);

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.read<SessionBloc>();
    return BlocConsumer<SessionBloc, SessionState>(
      listenWhen: (previous, current) => current is SignedIn,
      listener: (context, state) => context.pop(true),
      builder: (context, state) => LoginScreen(
        title: 'Prijava',
        appBar: AppBar(),
        logIn: context.read<AppDependencies>().logIn,
        reason: switch (state) {
          SignedOut(:final reason) => reason,
          _ => null,
        },
        roleNotAllowedMessage: 'Aplikacija je za goste. Osoblje koristi backoffice.',
        onSignedIn: (user) => session.add(SessionStarted(user)),
      ),
    );
  }
}
