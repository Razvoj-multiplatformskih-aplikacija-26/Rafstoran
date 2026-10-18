import '../identifiers.dart';
import '../user.dart';
import 'reservation.dart';

abstract final class AccessPolicy {
  static bool canView(User user, Reservation reservation) => user.role.isStaff || reservation.guestId == user.id;

  static bool canCancel(User user, Reservation reservation) => user.role.isStaff || reservation.guestId == user.id;

  static bool canCreateReservation(User user, {required UserId forGuest}) =>
      user.role.isStaff ? forGuest != user.id : forGuest == user.id;

  static bool canConfirm(User user) => user.role.isStaff;

  static bool canRecordArrival(User user) => user.role.isStaff;

  static bool canManageRestaurant(User user) => user.role == Role.manager;
}
