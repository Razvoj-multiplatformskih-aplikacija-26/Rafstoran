import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_restaurant.dart';
import 'data/fake_sessions.dart';

final class AppDependencies {
  AppDependencies({
    required this.clock,
    required ReservationRepository reservations,
    required SlotRepository slots,
    required SessionRepository sessions,
    this.fakeRestaurant,
  }) : getAvailableSlots = GetAvailableSlots(slots: slots, clock: clock),
       createReservation = CreateReservation(reservations: reservations, slots: slots, clock: clock),
       getMyReservations = GetMyReservations(reservations: reservations),
       cancelReservation = CancelReservation(reservations: reservations, clock: clock),
       logIn = LogIn(sessions: sessions),
       restoreSession = RestoreSession(sessions: sessions),
       logOut = LogOut(sessions: sessions),
       sessionExpirations = sessions.expirations;

  factory AppDependencies.server({
    required Uri baseUri,
    required TokenStore tokens,
    Clock clock = const SystemClock(),
  }) {
    final api = ApiClient(baseUri: baseUri, tokens: tokens);
    return AppDependencies(
      clock: clock,
      reservations: HttpReservationRepository(api),
      slots: HttpSlotRepository(api),
      sessions: HttpSessionRepository(api),
    );
  }

  factory AppDependencies.fake({Clock clock = const SystemClock(), Duration? latency, bool signedIn = true}) {
    final restaurant = latency == null ? FakeRestaurant(clock: clock) : FakeRestaurant(clock: clock, latency: latency);
    return AppDependencies(
      clock: clock,
      reservations: restaurant,
      slots: restaurant,
      sessions: FakeSessions(guest, signedIn: signedIn),
      fakeRestaurant: restaurant,
    );
  }

  static const guest = User(id: UserId('u-guest'), username: 'Gost', role: Role.guest);

  final Clock clock;
  final GetAvailableSlots getAvailableSlots;
  final CreateReservation createReservation;
  final GetMyReservations getMyReservations;
  final CancelReservation cancelReservation;
  final LogIn logIn;
  final RestoreSession restoreSession;
  final LogOut logOut;
  final Stream<void> sessionExpirations;
  final FakeRestaurant? fakeRestaurant;
}
