import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'models/slot_selection.dart';
import 'screens/home_shell.dart';
import 'screens/my_reservations_screen.dart';
import 'screens/reservation_form_screen.dart';
import 'screens/slot_detail_screen.dart';
import 'screens/slots_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
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
                  parentNavigatorKey: _rootNavigatorKey,
                  redirect: (context, state) => state.extra is SlotSelection ? null : '/',
                  builder: (context, state) => SlotDetailScreen(selection: state.extra! as SlotSelection),
                  routes: [
                    GoRoute(
                      path: 'reserve',
                      parentNavigatorKey: _rootNavigatorKey,
                      redirect: (context, state) => state.extra is SlotSelection ? null : '/',
                      builder: (context, state) => ReservationFormScreen(selection: state.extra! as SlotSelection),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [GoRoute(path: '/reservations', builder: (context, state) => const MyReservationsScreen())],
        ),
      ],
    ),
  ],
);
