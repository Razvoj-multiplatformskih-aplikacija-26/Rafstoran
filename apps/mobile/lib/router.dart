import 'package:go_router/go_router.dart';

import 'models/slot_selection.dart';
import 'screens/slot_detail_screen.dart';
import 'screens/slots_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SlotsScreen(),
      routes: [
        GoRoute(
          path: 'slots/:start',
          redirect: (context, state) => state.extra is SlotSelection ? null : '/',
          builder: (context, state) => SlotDetailScreen(selection: state.extra! as SlotSelection),
        ),
      ],
    ),
  ],
);
