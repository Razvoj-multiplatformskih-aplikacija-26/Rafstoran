import 'package:blocs/blocs.dart';
import 'package:domain/domain.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'dependencies.dart';
import 'models/slot_selection.dart';
import 'screens/home_shell.dart';
import 'screens/my_reservations_screen.dart';
import 'screens/reservation_detail_screen.dart';
import 'screens/reservation_form_screen.dart';
import 'screens/slot_detail_screen.dart';
import 'screens/slots_screen.dart';

GoRouter createRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const SlotsScreen(),
                routes: [
                  GoRoute(
                    path: 'slots/:start',
                    parentNavigatorKey: rootNavigatorKey,
                    redirect: (context, state) => state.extra is SlotSelection ? null : '/',
                    builder: (context, state) => SlotDetailScreen(selection: state.extra! as SlotSelection),
                    routes: [
                      GoRoute(
                        path: 'reserve',
                        parentNavigatorKey: rootNavigatorKey,
                        redirect: (context, state) => state.extra is SlotSelection ? null : '/',
                        builder: (context, state) {
                          final selection = state.extra! as SlotSelection;
                          final dependencies = context.read<AppDependencies>();
                          return BlocProvider(
                            create: (_) => ReservationFormBloc(
                              createReservation: dependencies.createReservation,
                              user: dependencies.user,
                              slot: selection.availability.slot,
                              partySize: selection.partySize,
                            ),
                            child: ReservationFormScreen(selection: selection),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reservations',
                builder: (context, state) => const MyReservationsScreen(),
                routes: [
                  GoRoute(
                    path: ':id',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (context, state) =>
                        ReservationDetailScreen(id: ReservationId(state.pathParameters['id']!)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
