import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_schedule.dart';
import 'data/fake_sessions.dart';

final class BackofficeDependencies {
  BackofficeDependencies({
    required this.clock,
    required ScheduleRepository schedules,
    required ReservationRepository reservations,
    required SlotRepository slots,
    required SessionRepository sessions,
    this.fakeSchedule,
  }) : getDailySchedule = GetDailySchedule(schedules: schedules),
       getAvailableSlots = GetAvailableSlots(slots: slots, clock: clock),
       createReservation = CreateReservation(reservations: reservations, slots: slots, clock: clock),
       confirmReservation = ConfirmReservation(reservations: reservations, clock: clock),
       recordArrival = RecordArrival(reservations: reservations, clock: clock),
       recordNoShow = RecordNoShow(reservations: reservations, clock: clock),
       cancelReservation = CancelReservation(reservations: reservations, clock: clock),
       logIn = LogIn(sessions: sessions),
       restoreSession = RestoreSession(sessions: sessions),
       logOut = LogOut(sessions: sessions),
       sessionExpirations = sessions.expirations;

  factory BackofficeDependencies.server({
    required Uri baseUri,
    required TokenStore tokens,
    Clock clock = const SystemClock(),
  }) {
    final api = ApiClient(baseUri: baseUri, tokens: tokens);
    return BackofficeDependencies(
      clock: clock,
      schedules: HttpScheduleRepository(api),
      reservations: HttpReservationRepository(api),
      slots: HttpSlotRepository(api),
      sessions: HttpSessionRepository(api),
    );
  }

  factory BackofficeDependencies.fake({
    Clock clock = const SystemClock(),
    Duration? latency,
    User staff = staffManager,
  }) {
    final schedule = latency == null ? FakeSchedule(clock: clock) : FakeSchedule(clock: clock, latency: latency);
    return BackofficeDependencies(
      clock: clock,
      schedules: schedule,
      reservations: schedule,
      slots: schedule,
      sessions: FakeSessions(staff),
      fakeSchedule: schedule,
    );
  }

  final Clock clock;
  final GetDailySchedule getDailySchedule;
  final GetAvailableSlots getAvailableSlots;
  final CreateReservation createReservation;
  final ConfirmReservation confirmReservation;
  final RecordArrival recordArrival;
  final RecordNoShow recordNoShow;
  final CancelReservation cancelReservation;
  final LogIn logIn;
  final RestoreSession restoreSession;
  final LogOut logOut;
  final Stream<void> sessionExpirations;
  final FakeSchedule? fakeSchedule;
}
