import 'package:api_contract/api_contract.dart';
import 'package:relic/relic.dart';

import 'cors.dart';
import 'handlers.dart';
import 'http.dart';

Handler buildHandler(RestaurantHandlers handlers, {required List<String> corsOrigins}) {
  final router = RelicRouter()
    ..get(ApiPaths.health, (request) => Response.ok(body: Body.fromString('ok')))
    ..get(ApiPaths.openingHours, handlers.openingHours)
    ..get(ApiPaths.slots, handlers.slots)
    ..get(ApiPaths.schedule, handlers.schedule)
    ..get(ApiPaths.reservationsOfGuest(':guestId'), handlers.reservationsOfGuest)
    ..get(ApiPaths.reservation(':id'), handlers.find)
    ..post(ApiPaths.reservations, handlers.create)
    ..post(ApiPaths.confirmation(':id'), handlers.confirm)
    ..post(ApiPaths.cancellation(':id'), handlers.cancel)
    ..post(ApiPaths.arrival(':id'), handlers.arrival)
    ..post(ApiPaths.noShow(':id'), handlers.noShow)
    ..fallback = respondWith((request) => problemResponse(notFoundRoute));
  return const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(allowOrigins(corsOrigins))
      .addMiddleware(handleErrors())
      .addHandler(router.asHandler);
}

const notFoundRoute = ProblemDto(status: 404, code: ErrorCodes.notFound, title: 'No such route');
