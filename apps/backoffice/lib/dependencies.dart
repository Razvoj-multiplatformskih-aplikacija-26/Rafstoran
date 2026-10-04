import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_schedule.dart';

final class BackofficeDependencies {
  BackofficeDependencies({
    required this.clock,
    required this.staff,
    required ScheduleRepository schedules,
    required ReservationRepository reservations,
    this.fakeSchedule,
  }) : getDailySchedule = GetDailySchedule(schedules: schedules),
       confirmReservation = ConfirmReservation(reservations: reservations, clock: clock),
       recordArrival = RecordArrival(reservations: reservations, clock: clock),
       cancelReservation = CancelReservation(reservations: reservations, clock: clock);

  factory BackofficeDependencies.fake({Clock clock = const SystemClock(), Duration? latency}) {
    final schedule = latency == null ? FakeSchedule(clock: clock) : FakeSchedule(clock: clock, latency: latency);
    return BackofficeDependencies(
      clock: clock,
      staff: const User(id: UserId('u-waiter'), username: 'Konobar', role: Role.waiter),
      schedules: schedule,
      reservations: schedule,
      fakeSchedule: schedule,
    );
  }

  final Clock clock;
  final User staff;
  final GetDailySchedule getDailySchedule;
  final ConfirmReservation confirmReservation;
  final RecordArrival recordArrival;
  final CancelReservation cancelReservation;
  final FakeSchedule? fakeSchedule;
}
