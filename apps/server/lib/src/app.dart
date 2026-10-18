import 'package:api_contract/api_contract.dart';
import 'package:relic/relic.dart';

import 'cors.dart';
import 'handlers.dart';
import 'http.dart';
import 'sessions.dart';

Handler buildHandler(RestaurantHandlers handlers, SessionHandlers sessions, {required List<String> corsOrigins}) {
  final signedIn = sessions.signedIn;
  final router = RelicRouter()
    ..get(ApiPaths.health, (request) => Response.ok(body: Body.fromString('ok')))
    ..get(ApiPaths.openingHours, handlers.openingHours)
    ..get(ApiPaths.slots, sessions.optionallySignedIn(handlers.slots))
    ..post(ApiPaths.sessions, sessions.logIn)
    ..get(ApiPaths.currentSession, signedIn(sessions.current))
    ..delete(ApiPaths.currentSession, signedIn(sessions.logOut))
    ..get(ApiPaths.schedule, signedIn(handlers.schedule))
    ..get(ApiPaths.reservationsOfGuest(':guestId'), signedIn(handlers.reservationsOfGuest))
    ..get(ApiPaths.reservation(':id'), signedIn(handlers.find))
    ..post(ApiPaths.reservations, signedIn(handlers.create))
    ..post(ApiPaths.confirmation(':id'), signedIn(handlers.confirm))
    ..post(ApiPaths.cancellation(':id'), signedIn(handlers.cancel))
    ..post(ApiPaths.arrival(':id'), signedIn(handlers.arrival))
    ..post(ApiPaths.noShow(':id'), signedIn(handlers.noShow))
    ..fallback = respondWith((request) => problemResponse(notFoundRoute));
  return const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(allowOrigins(corsOrigins))
      .addMiddleware(handleErrors())
      .addHandler(router.asHandler);
}

const notFoundRoute = ProblemDto(status: 404, code: ErrorCodes.notFound, title: 'No such route');
