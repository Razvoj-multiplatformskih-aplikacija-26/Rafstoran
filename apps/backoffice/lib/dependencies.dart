import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_schedule.dart';

final class BackofficeDependencies {
  BackofficeDependencies({
    required this.clock,
    required this.staff,
    required ScheduleRepository schedules,
    required ReservationRepository reservations,
    required SlotRepository slots,
    this.fakeSchedule,
  }) : getDailySchedule = GetDailySchedule(schedules: schedules),
       getAvailableSlots = GetAvailableSlots(slots: slots, clock: clock),
       createReservation = CreateReservation(reservations: reservations, slots: slots, clock: clock),
       confirmReservation = ConfirmReservation(reservations: reservations, clock: clock),
       recordArrival = RecordArrival(reservations: reservations, clock: clock),
       recordNoShow = RecordNoShow(reservations: reservations, clock: clock),
       cancelReservation = CancelReservation(reservations: reservations, clock: clock);

  factory BackofficeDependencies.server({required Uri baseUri, Clock clock = const SystemClock()}) {
    final api = ApiClient(baseUri: baseUri, userId: staffWaiter.id);
    return BackofficeDependencies(
      clock: clock,
      staff: staffWaiter,
      schedules: HttpScheduleRepository(api),
      reservations: HttpReservationRepository(api),
      slots: HttpSlotRepository(api),
    );
  }

  factory BackofficeDependencies.fake({Clock clock = const SystemClock(), Duration? latency}) {
    final schedule = latency == null ? FakeSchedule(clock: clock) : FakeSchedule(clock: clock, latency: latency);
    return BackofficeDependencies(
      clock: clock,
      staff: staffManager,
      schedules: schedule,
      reservations: schedule,
      slots: schedule,
      fakeSchedule: schedule,
    );
  }

  final Clock clock;
  final User staff;
  final GetDailySchedule getDailySchedule;
  final GetAvailableSlots getAvailableSlots;
  final CreateReservation createReservation;
  final ConfirmReservation confirmReservation;
  final RecordArrival recordArrival;
  final RecordNoShow recordNoShow;
  final CancelReservation cancelReservation;
  final FakeSchedule? fakeSchedule;
}
