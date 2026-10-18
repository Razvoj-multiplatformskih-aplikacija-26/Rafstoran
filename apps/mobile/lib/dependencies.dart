import 'package:api_client/api_client.dart';
import 'package:domain/domain.dart';
import 'package:use_cases/use_cases.dart';

import 'data/fake_restaurant.dart';

final class AppDependencies {
  AppDependencies({
    required this.clock,
    required this.user,
    required ReservationRepository reservations,
    required SlotRepository slots,
    this.fakeRestaurant,
  }) : getAvailableSlots = GetAvailableSlots(slots: slots, clock: clock),
       createReservation = CreateReservation(reservations: reservations, slots: slots, clock: clock),
       getMyReservations = GetMyReservations(reservations: reservations),
       cancelReservation = CancelReservation(reservations: reservations, clock: clock);

  factory AppDependencies.server({required Uri baseUri, Clock clock = const SystemClock()}) {
    final api = ApiClient(baseUri: baseUri, userId: guest.id);
    return AppDependencies(
      clock: clock,
      user: guest,
      reservations: HttpReservationRepository(api),
      slots: HttpSlotRepository(api),
    );
  }

  factory AppDependencies.fake({Clock clock = const SystemClock(), Duration? latency}) {
    final restaurant = latency == null ? FakeRestaurant(clock: clock) : FakeRestaurant(clock: clock, latency: latency);
    return AppDependencies(
      clock: clock,
      user: guest,
      reservations: restaurant,
      slots: restaurant,
      fakeRestaurant: restaurant,
    );
  }

  static const guest = User(id: UserId('u-guest'), username: 'Gost', role: Role.guest);

  final Clock clock;
  final User user;
  final GetAvailableSlots getAvailableSlots;
  final CreateReservation createReservation;
  final GetMyReservations getMyReservations;
  final CancelReservation cancelReservation;
  final FakeRestaurant? fakeRestaurant;
}
