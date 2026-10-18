import '../user.dart';
import 'reservation.dart';
import 'reservation_guest.dart';

abstract final class AccessPolicy {
  static bool canView(User user, Reservation reservation) => user.role.isStaff || reservation.guest.isAccount(user.id);

  static bool canCancel(User user, Reservation reservation) =>
      user.role.isStaff || reservation.guest.isAccount(user.id);

  static bool canCreateReservation(User user, {required ReservationGuest guest}) =>
      user.role.isStaff ? !guest.isAccount(user.id) : guest.isAccount(user.id);

  static bool canHoldReservation(User user) => user.role == Role.guest;

  static bool canViewSchedule(User user) => user.role.isStaff;

  static bool canConfirm(User user) => user.role.isStaff;

  static bool canRecordArrival(User user) => user.role.isStaff;

  static bool canManageRestaurant(User user) => user.role == Role.manager;
}
