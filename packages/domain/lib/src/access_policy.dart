import 'reservation.dart';
import 'user.dart';

abstract final class AccessPolicy {
  static bool canView(User user, Reservation reservation) => user.role.isStaff || reservation.guestId == user.id;

  static bool canCancel(User user, Reservation reservation) => user.role.isStaff || reservation.guestId == user.id;

  static bool canCreateReservation(User user) => user.role == Role.guest;

  static bool canConfirm(User user) => user.role.isStaff;

  static bool canRecordArrival(User user) => user.role.isStaff;

  static bool canManageRestaurant(User user) => user.role == Role.manager;
}
