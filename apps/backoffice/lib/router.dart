import 'package:domain/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:blocs/blocs.dart';

import 'screens/schedule_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', redirect: (context, state) => ScheduleScreen.pathFor(context.read<DailyScheduleBloc>().today)),
      GoRoute(
        path: '/schedule/:date',
        builder: (context, state) {
          final day = DateTime.tryParse(state.pathParameters['date']!) ?? context.read<DailyScheduleBloc>().today;
          final selected = state.uri.queryParameters['reservation'];
          return ScheduleScreen(
            day: DateTime(day.year, day.month, day.day),
            selectedId: selected == null ? null : ReservationId(selected),
          );
        },
      ),
    ],
  );
}
