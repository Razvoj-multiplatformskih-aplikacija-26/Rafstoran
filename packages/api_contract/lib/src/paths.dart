abstract final class ApiPaths {
  static const health = '/health';
  static const openingHours = '/api/v1/opening-hours';
  static const slots = '/api/v1/slots';
  static const reservations = '/api/v1/reservations';
  static const schedule = '/api/v1/schedule';

  static String reservation(String id) => '$reservations/$id';

  static String confirmation(String id) => '${reservation(id)}/confirmation';

  static String cancellation(String id) => '${reservation(id)}/cancellation';

  static String arrival(String id) => '${reservation(id)}/arrival';

  static String noShow(String id) => '${reservation(id)}/no-show';

  static String reservationsOfGuest(String guestId) => '/api/v1/guests/$guestId/reservations';
}

abstract final class ApiQuery {
  static const day = 'day';
  static const partySize = 'partySize';
}

abstract final class ApiHeaders {
  static const userId = 'X-User-Id';
}
