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

  factory AppDependencies.fake({Clock clock = const SystemClock(), Duration? latency}) {
    final restaurant = latency == null ? FakeRestaurant(clock: clock) : FakeRestaurant(clock: clock, latency: latency);
    return AppDependencies(
      clock: clock,
      user: const User(id: UserId('u-guest'), username: 'gost', role: Role.guest),
      reservations: restaurant,
      slots: restaurant,
      fakeRestaurant: restaurant,
    );
  }

  final Clock clock;
  final User user;
  final GetAvailableSlots getAvailableSlots;
  final CreateReservation createReservation;
  final GetMyReservations getMyReservations;
  final CancelReservation cancelReservation;
  final FakeRestaurant? fakeRestaurant;
}
